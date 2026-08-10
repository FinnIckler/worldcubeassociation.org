#!/bin/bash
#
# Watches the EC2 instance metadata service for a Spot interruption notice and
# shuts the Weblate stack down cleanly while the two-minute grace period lasts.
#
# Installed to /usr/local/bin/weblate-spot-monitor by the instance user-data and
# run by weblate-spot-monitor.service. See DEPLOYMENT.md.
#
# Postgres would survive an abrupt kill via WAL replay, so this is not about
# preventing data loss — it is about not taking the crash-recovery path on every
# interruption, and about unmounting the data volume cleanly so the replacement
# instance mounts a consistent filesystem.

set -euo pipefail

IMDS=http://169.254.169.254
POLL_SECONDS=5

log() { logger -t weblate-spot-monitor -s "$*"; }

log "watching for Spot interruption notices"

while true; do
  # IMDSv2 is enforced on this instance (metadata_options.http_tokens =
  # "required" in the launch template), so every read needs a fresh token.
  token=$(curl -sX PUT "$IMDS/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 60" || true)

  if [ -n "$token" ]; then
    # 404 until an interruption is scheduled, then 200 with the action and a
    # deadline. Anything else (network blip, IMDS hiccup) is treated as "no
    # notice" and retried rather than triggering a shutdown.
    code=$(curl -s -o /dev/null -w '%{http_code}' \
      -H "X-aws-ec2-metadata-token: $token" \
      "$IMDS/latest/meta-data/spot/instance-action" || true)

    if [ "$code" = "200" ]; then
      log "interruption notice received; stopping Weblate"

      # docker compose down, bounded by TimeoutStopSec in weblate.service.
      systemctl stop weblate.service || log "weblate.service stop failed"

      # Release the data volume so the replacement instance finds a clean XFS
      # rather than replaying a journal. Docker holds /var/lib/docker open, so
      # it has to go first.
      systemctl stop docker.socket || true
      systemctl stop docker.service || log "docker stop failed"
      umount /var/lib/docker || log "umount /var/lib/docker failed"

      log "clean shutdown complete"
      exit 0
    fi
  fi

  sleep "$POLL_SECONDS"
done
