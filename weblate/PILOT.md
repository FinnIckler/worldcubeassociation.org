# Weblate pilot — manual deployment

A single on-demand instance behind the existing `wca-on-rails` ALB, created with
plain AWS CLI commands so a translator pilot can start without landing any
Terraform. [DEPLOYMENT.md](DEPLOYMENT.md) is the version to build once the pilot
proves the workflow; this one is deliberately disposable and has a teardown
section.

Every ID below was read out of the WCA account, not guessed.

> **Commands are fish**, the shell this repo's maintainers use. For bash,
> replace `set -x NAME value` with `export NAME=value`, and `set NAME (cmd)`
> with `NAME=$(cmd)`. Nothing else differs — the AWS CLI invocations and the
> quoting are identical, and the instance bootstrap lives in its own file rather
> than a heredoc precisely so it does not depend on your shell.

| | |
|---|---|
| ALB | `arn:aws:elasticloadbalancing:us-west-2:285938427530:loadbalancer/app/wca-on-rails/396a56d00f80f390` |
| HTTPS listener | `.../listener/app/wca-on-rails/396a56d00f80f390/8fb3d991e0309121` |
| ALB security group | `sg-04e3a30309aab1b1a` |
| VPC | `vpc-a19320c4` |
| ACM cert | `*.worldcubeassociation.org` (ISSUED) — covers the subdomain already |
| Route53 zone | `Z06972271NGRVXJI4XQPM` (public) |
| Free rule priority | **120** (in use: 20,30,33–36,40,50,60,70,80,90,100,110,1001,1002) |

## How the pilot differs from DEPLOYMENT.md

Three deliberate simplifications, each of which you would undo later:

- **On-demand, not Spot.** Translators working a pilot should not have the
  instance vanish mid-session. ~$60/month for a t3.large; the Spot design saves
  ~$40 but only pays off once replacement is automated.
- **Public subnet with a public IP, not private.** This sidesteps having to
  confirm NAT egress from `us-west-2b`. The security group still admits nothing
  but the load balancer, and SSM Session Manager works over outbound
  connections, so nothing is actually exposed.
- **Data on the root volume**, sized 50 GB with `DeleteOnTermination=false` plus
  termination protection, instead of a separate EBS volume. Fewer moving parts;
  the volume still survives an accidental terminate.

---

## Before you start

Two things that are not AWS CLI and will block the deploy:

**1. Push the branch.** The instance clones `weblate/` from GitHub, and
`docker-compose.prod.yml`, `render-env.sh` and `environment.prod.template` are
not on `main` yet. Push whatever branch holds them and use it below.

**2. Register a production OAuth application** at
<https://www.worldcubeassociation.org/oauth/applications/new>:

| Field | Value |
|---|---|
| Name | `Weblate (pilot)` |
| Redirect URI | `https://translate.worldcubeassociation.org/accounts/complete/oidc/` |
| Scopes | `openid profile email public` |
| Confidential | yes |

The trailing slash is required — Doorkeeper matches redirect URIs exactly.

`profile` is easy to leave off and produces a confusing failure. python-social-auth
requests `openid profile email` (its `DEFAULT_SCOPE`), and Doorkeeper validates
that against the *application's* own scope list, so a missing `profile` fails the
authorize step with "The requested scope is invalid, unknown, or malformed" —
which reads like a Weblate misconfiguration but is the app registration. Weblate
has no environment variable for the requested scope (`settings_docker.py` exposes
only endpoint, key, secret, title, image and username key), so fix it on the
application, not on Weblate. Staging's seeded `example-application-id` carries
every scope, which is why this never shows up when testing against staging.

---

## 0. Shell variables

```fish
set -x AWS_PAGER ""
set -x AWS_REGION us-west-2

set BRANCH weblate-poc                  # the branch you pushed above
set NAME wca-weblate-pilot
set DOMAIN translate.worldcubeassociation.org

set VPC vpc-a19320c4
set SUBNET subnet-5475fd31              # us-west-2a, auto-assigns a public IP
set ALB_SG sg-04e3a30309aab1b1a
set ZONE Z06972271NGRVXJI4XQPM

set LISTENER (aws elbv2 describe-listeners \
  --load-balancer-arn (aws elbv2 describe-load-balancers --names wca-on-rails \
      --query 'LoadBalancers[0].LoadBalancerArn' --output text) \
  --query 'Listeners[?Port==`443`].ListenerArn' --output text)

set AMI (aws ssm get-parameter \
  --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --query 'Parameter.Value' --output text)

echo "listener=$LISTENER ami=$AMI"
```

Note these are shell-local: if you open a new terminal partway through, re-run
this block before continuing.

## 1. Secrets in SSM

`render-env.sh` reads all seven and refuses to boot if any is missing or empty —
that is deliberate, so a half-configured Weblate never starts. If you are not
using SES or GitHub push during the pilot, put obvious placeholders in rather
than leaving them out.

```fish
aws ssm put-parameter --type SecureString --name /weblate/oidc_key          --value '<client id from step 2>'
aws ssm put-parameter --type SecureString --name /weblate/oidc_secret       --value '<client secret>'
aws ssm put-parameter --type SecureString --name /weblate/postgres_password --value (openssl rand -base64 32)
aws ssm put-parameter --type SecureString --name /weblate/admin_password    --value (openssl rand -base64 32)
aws ssm put-parameter --type SecureString --name /weblate/github_token      --value 'unused-during-pilot'
aws ssm put-parameter --type SecureString --name /weblate/smtp_user         --value 'unused-during-pilot'
aws ssm put-parameter --type SecureString --name /weblate/smtp_password     --value 'unused-during-pilot'

# Keep the admin password — it is your way back in if SSO misbehaves.
aws ssm get-parameter --name /weblate/admin_password --with-decryption \
  --query 'Parameter.Value' --output text
```

## 2. IAM role and instance profile

```fish
aws iam create-role --role-name $NAME --assume-role-policy-document '{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}'

# Session Manager, so the instance needs no SSH key and no bastion.
aws iam attach-role-policy --role-name $NAME \
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore

aws iam put-role-policy --role-name $NAME --policy-name weblate-secrets --policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"],
      "Resource": "arn:aws:ssm:us-west-2:285938427530:parameter/weblate/*"
    },
    {
      "Effect": "Allow",
      "Action": "kms:Decrypt",
      "Resource": "*",
      "Condition": {"StringEquals": {"kms:ViaService": "ssm.us-west-2.amazonaws.com"}}
    }
  ]
}'

aws iam create-instance-profile --instance-profile-name $NAME
aws iam add-role-to-instance-profile --instance-profile-name $NAME --role-name $NAME

# IAM is eventually consistent; launching immediately often fails to attach.
sleep 15
```

## 3. Security group

```fish
set SG (aws ec2 create-security-group --group-name $NAME \
  --description "Weblate pilot: HTTP from the wca-on-rails load balancer only" \
  --vpc-id $VPC --query GroupId --output text)

# Source is the ALB's security group, not a CIDR — nothing else in the VPC,
# and nothing on the internet, can reach 8080 even though the instance has a
# public IP.
aws ec2 authorize-security-group-ingress --group-id $SG \
  --protocol tcp --port 8080 --source-group $ALB_SG

echo "sg=$SG"
```

## 4. Launch the instance

The bootstrap lives in [`pilot-user-data.sh`](pilot-user-data.sh); only the
branch is substituted in.

```fish
sed "s|@BRANCH@|$BRANCH|" weblate/pilot-user-data.sh > /tmp/weblate-user-data.sh
grep 'git clone' -A1 /tmp/weblate-user-data.sh    # confirm the branch landed

set INSTANCE (aws ec2 run-instances \
  --image-id $AMI \
  --instance-type t3.large \
  --subnet-id $SUBNET \
  --security-group-ids $SG \
  --iam-instance-profile Name=$NAME \
  --associate-public-ip-address \
  --metadata-options "HttpTokens=required,HttpEndpoint=enabled" \
  --block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":50,"VolumeType":"gp3","DeleteOnTermination":false,"Encrypted":true}}]' \
  --disable-api-termination \
  --user-data file:///tmp/weblate-user-data.sh \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$NAME},{Key=Service,Value=weblate}]" \
  --query 'Instances[0].InstanceId' --output text)

echo "instance=$INSTANCE"
aws ec2 wait instance-running --instance-ids $INSTANCE
```

First boot pulls ~1 GB of images and runs Weblate's migrations — allow about
five minutes before it answers on `/healthz/`.

## 5. Target group and listener rule

```fish
set TG (aws elbv2 create-target-group --name $NAME \
  --protocol HTTP --port 8080 --vpc-id $VPC --target-type instance \
  --health-check-path /healthz/ \
  --health-check-interval-seconds 30 --health-check-timeout-seconds 5 \
  --healthy-threshold-count 2 --unhealthy-threshold-count 5 \
  --matcher HttpCode=200 \
  --query 'TargetGroups[0].TargetGroupArn' --output text)

aws elbv2 register-targets --target-group-arn $TG --targets Id=$INSTANCE

aws elbv2 create-rule --listener-arn $LISTENER --priority 120 \
  --conditions "[{\"Field\":\"host-header\",\"HostHeaderConfig\":{\"Values\":[\"$DOMAIN\"]}}]" \
  --actions "[{\"Type\":\"forward\",\"TargetGroupArn\":\"$TG\"}]"

echo "tg=$TG"
```

No certificate work: the listener already carries `*.worldcubeassociation.org`.

## 6. DNS

An alias A record rather than a CNAME — one less lookup, and no charge.

```fish
set ALB_DNS (aws elbv2 describe-load-balancers --names wca-on-rails \
  --query 'LoadBalancers[0].DNSName' --output text)
set ALB_ZONE (aws elbv2 describe-load-balancers --names wca-on-rails \
  --query 'LoadBalancers[0].CanonicalHostedZoneId' --output text)

aws route53 change-resource-record-sets --hosted-zone-id $ZONE --change-batch "{
  \"Changes\": [{
    \"Action\": \"UPSERT\",
    \"ResourceRecordSet\": {
      \"Name\": \"$DOMAIN\",
      \"Type\": \"A\",
      \"AliasTarget\": {
        \"HostedZoneId\": \"$ALB_ZONE\",
        \"DNSName\": \"$ALB_DNS\",
        \"EvaluateTargetHealth\": false
      }
    }
  }]
}"
```

## 7. Verify

```fish
# Target health — expect "healthy" within ~5 minutes of launch.
aws elbv2 describe-target-health --target-group-arn $TG \
  --query 'TargetHealthDescriptions[].TargetHealth' --output json

# End to end
curl -sI "https://$DOMAIN/" | head -1

# On the box, if it does not come up
aws ssm start-session --target $INSTANCE
#   sudo tail -100 /var/log/cloud-init-output.log
#   sudo docker compose -f /opt/wca/weblate/docker-compose.prod.yml logs --tail 100
#   curl -s -o /dev/null -w '%{http_code}\n' -H "Host: $(hostname -i)" localhost:8080/healthz/
```

That last curl is the one worth running if the target stays unhealthy while the
container looks fine — it reproduces exactly what the ALB health check sends,
and a `400` means `ALLOWED_HOSTS` did not pick up the private IP. (It runs in
the instance's bash shell, so `$(...)` is correct there.)

## 8. Seed the projects

```fish
aws ssm start-session --target $INSTANCE
# then, on the instance:
#   sudo /opt/wca/weblate/seed.sh          # Rails locales, from GitHub
#   sudo /opt/wca/weblate/seed-payload.sh  # Payload CMS component
```

Log in at `https://translate.worldcubeassociation.org/` with **WCA account**.
`admin` plus the password from step 1 is the fallback if SSO misbehaves; leave
`WEBLATE_NO_EMAIL_AUTH` commented out until a real WCA login has worked.

## 9. Teardown

In this order — the rule and target group cannot be deleted while in use.

```fish
set RULE (aws elbv2 describe-rules --listener-arn $LISTENER \
  --query "Rules[?Priority=='120'].RuleArn" --output text)
aws elbv2 delete-rule --rule-arn $RULE
aws elbv2 delete-target-group --target-group-arn $TG

aws route53 change-resource-record-sets --hosted-zone-id $ZONE --change-batch "{
  \"Changes\": [{\"Action\": \"DELETE\", \"ResourceRecordSet\": {
    \"Name\": \"$DOMAIN\", \"Type\": \"A\",
    \"AliasTarget\": {\"HostedZoneId\": \"$ALB_ZONE\", \"DNSName\": \"$ALB_DNS\",
                      \"EvaluateTargetHealth\": false}}}]
}"

aws ec2 modify-instance-attribute --instance-id $INSTANCE --no-disable-api-termination
aws ec2 terminate-instances --instance-ids $INSTANCE
aws ec2 wait instance-terminated --instance-ids $INSTANCE

# The root volume deliberately survives termination — delete it explicitly once
# you are sure the pilot data is not wanted.
aws ec2 describe-volumes --filters Name=status,Values=available \
  --query 'Volumes[].{Id:VolumeId,Created:CreateTime,Size:Size}' --output table

aws ec2 delete-security-group --group-id $SG
aws iam remove-role-from-instance-profile --instance-profile-name $NAME --role-name $NAME
aws iam delete-instance-profile --instance-profile-name $NAME
aws iam delete-role-policy --role-name $NAME --policy-name weblate-secrets
aws iam detach-role-policy --role-name $NAME \
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
aws iam delete-role --role-name $NAME

for p in oidc_key oidc_secret postgres_password admin_password github_token smtp_user smtp_password
    aws ssm delete-parameter --name "/weblate/$p"
end
```

## Known limits of this pilot

- **No backups.** The root volume survives termination and nothing else. If the
  pilot runs longer than a few weeks, add a snapshot schedule — a translator
  losing a month of work is the failure that would kill adoption.
- **No automatic recovery.** An instance failure is a manual rebuild. That is
  the gap the ASG in DEPLOYMENT.md closes.
- **Payload sync is manual.** `POST /api/translate/sync` (or
  `yarn payload run scripts/weblate-sync.ts`) has to be run by hand for now.
- **Restarts drop translator sessions**, since Postgres runs on the same box.
