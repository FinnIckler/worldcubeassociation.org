# Deploying Weblate to production

Target: **one EC2 instance** in the existing VPC, running the Docker stack, behind
the **existing** `wca-on-rails` ALB on `translate.worldcubeassociation.org`.
The instance is a **Spot** instance in a single-instance Auto Scaling group, with
all state on a separate EBS volume that is reattached on every launch.

This is deliberately the small version. Weblate is a supporting tool, not a
user-facing service — if it is down for an hour, translators wait. Everything
here is sized for that tolerance. See [Accepted risks](#accepted-risks) for what
you are signing up for.

---

## How it attaches to existing infra

```
                 wca-on-rails ALB  (us-west-2, default VPC)
                 HTTPS :443  ── ACM *.worldcubeassociation.org
                        │
                        ├── host www.worldcubeassociation.org  → Fargate (rails/next/anycable)
                        ├── host staging.worldcubeassociation.org → Fargate
                        └── host translate.worldcubeassociation.org  ← NEW rule, priority 120
                                    │
                                    ▼
                        TG wca-weblate (target_type = "instance", :8080)
                                    │
                        ASG min=max=1, Spot, us-west-2b only
                        └── EC2 (t3/t3a/m5/m6i/m6a .large)
                            ├── docker compose: weblate + postgres + valkey
                            └── EBS gp3 50 GB ── attached at boot,
                                                 mounted at /var/lib/docker
```

Three things it reuses for free, and one it must not:

- **TLS** — the listener's ACM cert is `*.worldcubeassociation.org`, so the
  subdomain is already covered. No cert request, no validation.
- **The HTTPS listener** — add a rule, don't add a load balancer.
- **The security group `wca-on-rails-load-balancer`** — reference it as the
  source in the instance SG so nothing else in the VPC can reach port 8080.
- **Not Vault.** Every Rails service authenticates to Vault with
  `Aws::ECSCredentials` against its *task* role (`vault_config.rb:12`). Weblate
  is a third-party Django image that reads plain env vars and has no such hook.
  Bridging it means running Vault Agent as a sidecar purely to template one env
  file. Use **SSM Parameter Store** with the instance profile instead — see
  [Step 2](#step-2--secrets-in-ssm). This is a conscious divergence from the
  house convention; it is contained to this one service.

### Terraform placement

Put it in `infra/wca_on_rails/shared/weblate.tf`. It needs
`aws_default_vpc.default`, `aws_default_subnet.default_az2`,
`aws_security_group.lb` and `aws_lb_listener.https`, all of which live in
`shared/`. It is neither production- nor staging-scoped, so the `production/`
and `staging/` modules are the wrong home.

The boot script goes in `infra/templates/weblate_user_data.sh.tftpl`, matching
the existing `ecs.tf` convention of keeping user-data templates in
`infra/templates/`.

---

## Before you start

Verify these three, because each one silently breaks the deploy:

1. **NAT egress from `us-west-2b`.** The instance goes in
   `aws_default_subnet.default_az2` (`map_public_ip_on_launch = false`). Weblate
   must reach `github.com`, `www.worldcubeassociation.org` and the SES SMTP
   endpoint. ECS tasks already run in that subnet and pull images, so a NAT path
   almost certainly exists — confirm it rather than assume, or the instance
   boots fine and every clone hangs.
2. **Where WCA DNS lives.** There is no `aws_route53_*` resource anywhere in
   `infra/`, so the zone is managed outside Terraform. You need whoever holds it
   to add one CNAME.
3. **The `ja.yml` / `ko.yml` control-character fix is on `main`.** Weblate
   translates GitHub, not your working copy. Until that PR lands, those two
   languages report a misleading 100% (`total=0`) because Weblate parsed nothing
   from them. Not a blocker for deploying, but don't let anyone read the
   dashboard before it merges.

---

## Step 1 — Register the production OIDC application

The local evaluation instance borrows staging's seeded
`example-application-id`, which carries every scope and
`dangerously_allow_any_redirect_uri: true` (`lib/tasks/db.rake:153`). **That
must not be used in production.**

At <https://www.worldcubeassociation.org/oauth/applications/new>:

| Field | Value |
|---|---|
| Name | `Weblate` |
| Redirect URI | `https://translate.worldcubeassociation.org/accounts/complete/oidc/` |
| Scopes | `openid email public` |
| Confidential | yes |

The trailing slash on the callback is required — python-social-auth builds it as
`/accounts/complete/<backend>/` and Doorkeeper does exact-match on redirect URIs.

Keep `WEBLATE_SOCIAL_AUTH_OIDC_USERNAME_KEY=sub`. python-social-auth defaults to
`preferred_username`, which WCA maps to `wca_id`
(`config/initializers/doorkeeper_openid_connect.rb`) — and `users.wca_id` is
**nullable**, so every translator without a WCA ID fails to get a username.
`sub` is the WCA user id and is always present. Display names still come from
the `name` claim.

---

## Step 2 — Secrets in SSM

Create these as `SecureString` under `/weblate/`:

```bash
aws ssm put-parameter --type SecureString --name /weblate/oidc_key       --value '<client id>'
aws ssm put-parameter --type SecureString --name /weblate/oidc_secret    --value '<client secret>'
aws ssm put-parameter --type SecureString --name /weblate/postgres_password --value "$(openssl rand -base64 32)"
aws ssm put-parameter --type SecureString --name /weblate/admin_password --value "$(openssl rand -base64 32)"
aws ssm put-parameter --type SecureString --name /weblate/github_token   --value '<PAT, see step 6>'
aws ssm put-parameter --type SecureString --name /weblate/smtp_user      --value '<SES SMTP username>'
aws ssm put-parameter --type SecureString --name /weblate/smtp_password  --value '<SES SMTP password>'
```

These seven names are exactly what `render-env.sh` reads; it fails the boot if
any is missing or empty rather than starting a half-configured Weblate.

`admin_password` matters more than it looks. The evaluation instance uses
`admin`/`admin`; that account is a full superuser and the fallback if SSO
breaks. Generate it, store it, and don't set `WEBLATE_NO_EMAIL_AUTH=1` until a
real WCA login has succeeded — that flag disables password auth for *every*
account including this one, and turning it on early locks you out of your own
instance.

The instance profile needs `ssm:GetParameter*` on `/weblate/*` and
`kms:Decrypt` on the key backing them.

---

## Step 3 — Terraform

### Why Spot, and why an ASG

Measured spot prices in `us-west-2b`:

| Instance | On-demand | Spot | Monthly (spot) |
|---|---|---|---|
| t3.large | $0.0832 | **$0.0289** | ~$21 |
| t4g.large | $0.0672 | $0.0319 | ~$23 |
| m6i.large | $0.0960 | $0.0387 | ~$28 |

Spot is ~65% off, saving roughly **$40/month** against an on-demand t3.large.
Note that t4g (Graviton) spot is currently *more expensive* than t3 spot despite
being cheaper on-demand — Graviton is the better on-demand play, not the better
spot play. All three images (`weblate/weblate`, `postgres:18-alpine`, `valkey`)
do publish arm64, so t4g.large on-demand at ~$49/month is the zero-risk option
if you would rather not run Spot at all.

The ASG is not just Spot plumbing. It is what makes the instance recoverable at
all: with the boot script reattaching the data volume, a dead instance —
interrupted, failed, or terminated by hand — is replaced automatically instead
of needing someone to rebuild it. That is worth doing on its own merits, and it
is what makes Spot cheap to adopt on top.

**The single EBS volume constrains the design in two ways.** It is AZ-bound, so
the ASG is pinned to `us-west-2b` and cannot diversify across zones the way Spot
workloads normally do — instance-type diversification is the only lever left,
which is why the mixed-instances policy lists five equivalent 8 GB types. And
only one instance can hold the volume at a time, so `max_size` must stay at 1
and Capacity Rebalancing is left off: there is no way to launch a replacement
before terminating the incumbent.

### `infra/wca_on_rails/shared/weblate.tf`

```hcl
resource "aws_security_group" "weblate" {
  name        = "${var.name_prefix}-weblate"
  description = "Weblate instance"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
    description     = "Weblate HTTP from the load balancer only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all egress"
  }

  tags = { Name = "${var.name_prefix}-weblate" }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_iam_role" "weblate" {
  name               = "${var.name_prefix}-weblate"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_assume_role_policy.json
}

# SSM Session Manager, so the instance needs no SSH key and no bastion.
resource "aws_iam_role_policy_attachment" "weblate_ssm" {
  role       = aws_iam_role.weblate.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "weblate_secrets" {
  role = aws_iam_role.weblate.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
        Resource = "arn:aws:ssm:${var.region}:*:parameter/weblate/*"
      },
      # Describe* has no resource-level permissions; the attach is scoped to the
      # one volume, and to instances carrying this service's tag.
      {
        Effect   = "Allow"
        Action   = ["ec2:DescribeVolumes"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["ec2:AttachVolume"]
        Resource = [
          aws_ebs_volume.weblate_data.arn,
          "arn:aws:ec2:${var.region}:*:instance/*",
        ]
        # Keys on Service, not Name: the condition is evaluated against BOTH
        # ARNs above, and the volume and the instance have different Name tags.
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Service" = "weblate"
          }
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "weblate" {
  name = "${var.name_prefix}-weblate"
  role = aws_iam_role.weblate.name
}

resource "aws_ebs_volume" "weblate_data" {
  availability_zone = "us-west-2b"
  size              = 50
  type              = "gp3"
  encrypted         = true

  tags = {
    Name    = "${var.name_prefix}-weblate-data"
    Service = "weblate" # the IAM attach condition keys on this
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_launch_template" "weblate" {
  name_prefix   = "${var.name_prefix}-weblate-"
  image_id      = data.aws_ami.al2023.id
  instance_type = "t3.large" # overridden per-type by the mixed instances policy

  user_data = base64encode(templatefile("../templates/weblate_user_data.sh.tftpl", {
    volume_id = aws_ebs_volume.weblate_data.id
    region    = var.region
  }))

  iam_instance_profile {
    name = aws_iam_instance_profile.weblate.name
  }

  vpc_security_group_ids = [aws_security_group.weblate.id]

  # Only applies to burstable types; silently ignored for m5/m6i/m6a.
  # A full repo re-scan is CPU-heavy and the t3 baseline is 30%.
  credit_specification {
    cpu_credits = "unlimited"
  }

  metadata_options {
    http_tokens = "required" # IMDSv2, which the boot script uses
  }

  # Must be applied at launch, not by the ASG: the boot script calls
  # AttachVolume, and the IAM condition above checks the instance's Service tag.
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.name_prefix}-weblate"
      Service = "weblate"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "weblate" {
  name_prefix         = "${var.name_prefix}-weblate-"
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = [aws_default_subnet.default_az2.id]
  target_group_arns   = [aws_lb_target_group.weblate.arn]

  # EC2, not ELB: an application-level fault would otherwise make the ASG
  # replace the instance in a loop, re-attaching the volume each time. Instance
  # death is what we want automatic recovery from; a broken Weblate should stay
  # up and be debuggable.
  health_check_type         = "EC2"
  health_check_grace_period = 600 # first boot runs migrations

  # Deliberately absent: capacity_rebalance. It works by launching a replacement
  # before terminating the instance at risk, which max_size = 1 forbids and the
  # single EBS volume makes impossible anyway.

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "price-capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.weblate.id
        version            = "$Latest"
      }

      # All 8 GB / 2 vCPU x86_64, so any of them can run the stack unchanged.
      # AZ diversification is impossible (the volume pins us to us-west-2b), so
      # this list is the entire interruption-resilience story.
      override { instance_type = "t3.large" }
      override { instance_type = "t3a.large" }
      override { instance_type = "m5.large" }
      override { instance_type = "m6i.large" }
      override { instance_type = "m6a.large" }
    }
  }

  # Roll the instance when the launch template changes. With one instance and
  # one volume there is no way to stay healthy through it, hence 0%.
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-weblate"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "weblate" {
  name        = "wca-weblate"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_default_vpc.default.id
  target_type = "instance"

  deregistration_delay = 10

  health_check {
    interval            = 30
    path                = "/healthz/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = 200
  }

  tags = {
    Name = "${var.name_prefix}-weblate"
    Env  = "production"
  }
}

resource "aws_lb_listener_rule" "weblate" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 120

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.weblate.arn
  }

  condition {
    host_header {
      values = ["translate.worldcubeassociation.org"]
    }
  }
}
```

Notes on choices that differ from the surrounding code:

- **`target_type = "instance"`, not `"ip"`.** Every existing target group uses
  `"ip"` because they front Fargate tasks. Instance targets let the ASG register
  and deregister members itself via `target_group_arns` — no
  `aws_lb_target_group_attachment`, and nothing to fix up when a replacement
  instance comes back with a different private IP.
- **Priority 120.** In use today: 20, 33, 34, 35, 36, 40, 50, 60, 110. 120 sits
  after `next_forward_prod` and collides with nothing.
- **`min = max = desired = 1`.** Not really autoscaling — the ASG is here for
  automatic replacement and Spot integration. Two instances could never run
  concurrently anyway, since only one can attach the data volume.
- **`prevent_destroy` on the volume.** The instance is disposable, the volume is
  not. This is the one resource whose loss is unrecoverable, and the reason the
  ASG is safe: replacements reattach state rather than starting empty.
- **No `key_name`.** Access is via SSM Session Manager
  (`aws ssm start-session --target <id>`), matching the no-bastion pattern the
  ECS instances already use.

---

## Step 4 — DNS

Add a CNAME in whatever manages the `worldcubeassociation.org` zone:

```
translate.worldcubeassociation.org.  CNAME  <the wca-on-rails ALB DNS name>
```

Get the value from `terraform output` on the shared module (`lb`) or the
console. Since the ALB rule matches on `Host`, nothing responds until this
resolves.

---

## Step 5 — Instance bootstrap

Everything in this step is a real file in the repo, not a snippet to copy:

| File | Installed to | Purpose |
|---|---|---|
| `infra/templates/weblate_user_data.sh.tftpl` | instance user-data | attaches the volume, installs Docker, starts the stack |
| `weblate/render-env.sh` | `/opt/wca/weblate/` | renders `environment.prod` from SSM |
| `weblate/environment.prod.template` | `/opt/wca/weblate/` | all non-secret settings, reviewable in git |
| `weblate/spot-monitor.sh` | `/usr/local/bin/weblate-spot-monitor` | clean shutdown on an interruption notice |
| `weblate/systemd/weblate.service` | `/etc/systemd/system/` | runs `docker compose up -d` |
| `weblate/systemd/weblate-spot-monitor.service` | `/etc/systemd/system/` | runs the monitor |

The boot script clones the repo to `/opt/wca` and installs the rest from there,
so changing any of them is a normal PR rather than a Terraform edit — but note
that a running instance will not pick the change up until it is replaced.

### The parts worth understanding before you run it

**The `.tftpl` is a Terraform template, and Terraform parses `$`-brace and
`%`-brace sequences everywhere in the file, comments included.** Shell variables
are written bare (`$VAR`) throughout so nothing needs escaping. If you add brace
syntax for a shell variable, double its leading `$` or the plan fails with
"Invalid template interpolation value".

**Formatting is conditional.** The script runs `blkid "$DEVICE" || mkfs -t xfs
"$DEVICE"`. Written unconditionally, that destroys every translation on the
first Spot interruption and the instance comes back looking perfectly healthy.
It is the most dangerous line in this deployment.

**The data device is resolved by volume serial, not by path.** Nitro renames
`/dev/sdf` unpredictably, and the mixed-instances policy means you do not know
in advance which instance type you landed on. The script matches the volume ID
(hyphen stripped) against `lsblk`'s SERIAL column instead of guessing
`/dev/nvme1n1`.

**No `dnf update -y`.** It would add minutes to every Spot replacement, and
`data.aws_ami.al2023` uses `most_recent = true`, so each replacement already
launches a freshly patched AMI.

**Mounting at `/var/lib/docker` means replacements skip the image pull.** Images
and named volumes both live on the persistent disk, so only the very first boot
pays the ~1 GB download — which is why `TimeoutStartSec=600` in
`weblate.service` is generous rather than routine.

### Handling interruptions

Spot gives a two-minute warning at
`/latest/meta-data/spot/instance-action`, which returns 404 until an
interruption is scheduled. `spot-monitor.sh` polls it every five seconds and
then stops Weblate, stops Docker, and unmounts the volume.

Postgres would survive an abrupt kill through WAL replay, so this is not about
preventing data loss. It avoids taking the crash-recovery path on every
interruption, and it leaves a cleanly unmounted XFS for the replacement
instance to mount.

The unit uses `Restart=on-failure` rather than `always` deliberately: the script
exits 0 once it has handled a notice, and restarting it then would re-stop an
already-stopped stack in a loop until the instance goes away.

### Compose changes for production

Copy `weblate/docker-compose.yml` to `weblate/docker-compose.prod.yml` and:

- **Drop the `/wca-repo` read-only mount.** That is a local convenience for
  cloning your working tree; production clones GitHub.
- **`restart: unless-stopped`** on all three services.
- **Keep the image pinned** to an exact tag (`weblate/weblate:2026.8`). Weblate
  uses CalVer and **requires sequential upgrades across major versions** — you
  cannot jump from 2026.8 to 2027.5 in one step. A floating tag will eventually
  destroy the database on some unattended pull.
- **Pin Postgres too** (`postgres:18-alpine`). A major Postgres bump needs an
  explicit `pg_upgrade` or dump/restore; it will not happen by itself.
- **Bind only to the instance**: `ports: ["8080:8080"]` is fine — the SG is the
  boundary and nothing else runs on the box.

### Production environment settings

Beyond the evaluation values, these five matter:

```bash
WEBLATE_SITE_DOMAIN=translate.worldcubeassociation.org
WEBLATE_ENABLE_HTTPS=1
WEBLATE_IP_PROXY_HEADER=HTTP_X_FORWARDED_FOR
WEBLATE_ALLOWED_HOSTS=translate.worldcubeassociation.org,${WEBLATE_PRIVATE_IP}
WEBLATE_REGISTRATION_OPEN=1
WEBLATE_REGISTRATION_ALLOW_BACKENDS=oidc
WEBLATE_SOCIAL_AUTH_OIDC_OIDC_ENDPOINT=https://www.worldcubeassociation.org
WEBLATE_SOCIAL_AUTH_OIDC_TITLE=WCA account
WEBLATE_SOCIAL_AUTH_OIDC_USERNAME_KEY=sub
WEBLATE_WORKERS=4
```

Two of those are load-balancer-specific and will bite you if skipped:

**`WEBLATE_IP_PROXY_HEADER`** — without it every request appears to originate
from the ALB's private IP. Weblate's brute-force protection then counts all
users as one client, so a handful of failed logins rate-limits *everyone*
simultaneously.

**`WEBLATE_ALLOWED_HOSTS` must include the private IP.** ALB health checks send
`Host: <target-ip>:8080`, not the public hostname. Django validates `Host`
against `ALLOWED_HOSTS` before any view runs and returns **400** on a mismatch —
including for `/healthz/`. The target group then never goes healthy, the ALB
serves 503, and the application logs look completely normal because the app is
fine.

Under the ASG that IP is no longer fixed: every replacement instance gets a new
one, so it cannot be hardcoded in a checked-in env file. The boot script reads
it from IMDS and passes it to `render-env.sh` as `WEBLATE_PRIVATE_IP`, which is
why the value above is a placeholder rather than a literal. Getting this wrong
produces a deployment that works until the first interruption and then serves
503 forever.

Setting `WEBLATE_ALLOWED_HOSTS=*` sidesteps the whole problem and is defensible
here — the ALB listener rule already filters by host header, and the security
group admits nothing else. Take that shortcut if the IMDS plumbing feels like
more than it is worth; just make it a decision rather than an accident.

Also swap the console email backend for SES, or nobody gets notifications:

```bash
WEBLATE_EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
WEBLATE_EMAIL_HOST=email-smtp.us-west-2.amazonaws.com
WEBLATE_EMAIL_PORT=587
WEBLATE_EMAIL_USE_TLS=1
WEBLATE_EMAIL_HOST_USER=<SES SMTP user>
WEBLATE_SERVER_EMAIL=weblate@worldcubeassociation.org
WEBLATE_DEFAULT_FROM_EMAIL=weblate@worldcubeassociation.org
```

The `From` address must be a verified SES identity, and the SES account needs to
be out of the sandbox to mail arbitrary translators.

---

## Step 6 — Seed the project and enable push

Run `weblate/seed.sh` against the production URL. It creates the `wca` project
and the two components, with `file_format: "ruby-yaml"`.

That format choice is load-bearing and is explained in `weblate/README.md` —
plain `yaml` produces keys rooted at the locale code (`de->about->x`), none of
which match the template, so all 33 languages report 0%. Do not "fix" it.

**Before the first write to `main`**, settle two things from the README:

1. The three English keys carrying a non-CLDR `zero:` form
   (`competitions.messages.spots_left`,
   `competitions.registration_v2.list.spots_remaining_plural`,
   `competitions.registration_v2.update.move_to`). `ruby-yaml` drops `zero:` on
   write, costing 49 real translations. Scoped cleanup, but decide first.
2. The one-time ~80-column reflow of every locale file (~300 changed lines on a
   2,244-string file). Land it as its own mechanical commit so it never
   pollutes a translation PR.

Then wire up push, which is the part that actually replaces internationalize:

- Create a machine-user PAT with `repo` scope on a user that can open PRs
  against `thewca/worldcubeassociation.org` (store as `/weblate/github_token`,
  exposed to the container as `WEBLATE_GITHUB_TOKEN`).
- Set the component's **push URL** to the GitHub remote and its VCS to
  `github`, so Weblate opens pull requests rather than pushing to `main`.
- **Test against a fork first.** This is the highest-risk piece of the whole
  migration and the only one that writes to the repo.

---

## Step 7 — Verify

```bash
# From the instance (aws ssm start-session --target <id>)
curl -s -o /dev/null -w '%{http_code}\n' localhost:8080/healthz/         # 200
curl -s -H "Host: $(hostname -i)" localhost:8080/healthz/                # 200, not 400
mount | grep /var/lib/docker                                             # the EBS volume

# Target health — the ASG registers members itself
aws elbv2 describe-target-health --target-group-arn <arn>                 # healthy

# End to end
curl -sI https://translate.worldcubeassociation.org/                      # 200
```

**Then rehearse an interruption before you trust it.** This is the one step
people skip, and it is the only way to know the volume reattaches:

```bash
# Simulate a real Spot interruption (2-minute notice, then reclaim)
aws ec2 send-spot-instance-interruptions --instance-id <id> --region us-west-2
```

Watch a replacement launch, attach the volume, and come back healthy with all
translations intact. If `mkfs` was written unconditionally, this is where you
find out — on a test project rather than on real translation work.

Then log in via **WCA account** in a browser. Confirm your Weblate username is
the numeric WCA user id (that is `USERNAME_KEY=sub` working) and that the
display name came through. Only after that succeeds, consider setting
`WEBLATE_NO_EMAIL_AUTH=1`.

---

## Operations

**Backups.** The EBS volume is the entire durability story. Set up an AWS
Backup / DLM policy with daily snapshots and ~30-day retention. Weblate also has
built-in BorgBackup that can target S3 — worth enabling as a second,
application-consistent layer, since an EBS snapshot of a running Postgres is
crash-consistent rather than clean. Test a restore once before you rely on
either.

**Upgrades.** Bump the pinned tag, `docker compose pull`, restart. Never skip a
major version. Snapshot the volume first; the container runs migrations on start
and there is no down-migration.

**Sizing.** The mixed-instances list is all 2 vCPU / 8 GB, which is right to
start: Weblate alone wants ~3 GB, plus Postgres, Valkey, and a ~450 MB repo
clone. The second component shares the first's checkout via
`repo: weblate://wca/locales` rather than cloning again. If memory turns out
tight during a full scan, move the whole override list up to the `.xlarge`
sizes — keep them uniform so any interruption lands somewhere that fits.

**Spot interruptions.** Expect occasional unannounced restarts of a few minutes.
CloudWatch metric `AutoScalingGroup GroupInServiceInstances` dropping to 0, or
the EventBridge `EC2 Spot Instance Interruption Warning` event, are the things
to alarm on if the restarts turn out to be more frequent than tolerable. If they
become disruptive, flipping `on_demand_percentage_above_base_capacity` to 100 in
`instances_distribution` converts the ASG to on-demand with no other change —
that one line is the whole escape hatch, which is the main reason this is worth
trying.

**Logs.** `docker compose logs` on the box only. Shipping to CloudWatch means
adding the agent; skip it until something actually needs debugging remotely.

---

## Accepted risks

Worth stating plainly, since this is a single Spot instance by choice:

- **No HA, but automatic recovery.** Instance failure or a Spot interruption
  means a few minutes of downtime while the ASG launches a replacement and
  reattaches the volume — no human involved. An **AZ** failure is different:
  the volume lives in `us-west-2b` and cannot be launched elsewhere, so that is
  a manual restore-from-snapshot into another AZ.
- **Interruptions are unannounced.** Translators lose their session and a
  partly-typed string. Acceptable for this workload, and the reason Spot is
  defensible here rather than on anything user-facing.
- **Spot capacity is pinned to one AZ.** Diversification across five instance
  types is the only hedge available. A simultaneous capacity crunch across all
  of them in `us-west-2b` means extended downtime.
- **Restarts are downtime.** Every upgrade and every config change interrupts
  translators. Do it outside a translation push.
- **Postgres is on the instance.** Cheaper and simpler than RDS, but backup
  correctness is now your problem instead of AWS's. RDS is the obvious upgrade
  if Weblate becomes load-bearing — and it would also decouple the data from the
  AZ, removing the constraint that forces `max_size = 1`.
- **One EBS volume is the single point of data loss.** `prevent_destroy` guards
  Terraform; snapshots guard everything else. Nothing guards a missing snapshot
  policy — set it up on day one, not after the pilot.

If Weblate graduates from "pilot" to "the only way translations happen", moving
Postgres to RDS is the single change that retires the most of this list.