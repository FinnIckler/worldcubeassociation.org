#!/usr/bin/env bash
#
# Creates the "payload" component that Payload CMS content is translated in.
#
#   ./weblate/seed-payload.sh
#
# Unlike the `locales` component (which translates config/locales/*.yml straight
# out of git), Payload content lives in MongoDB. There is no repository to point
# at, so this component uses Weblate's own local VCS and the strings are pushed
# in over the API by next-frontend's /api/translate/sync.
set -euo pipefail

COMPOSE_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/docker-compose.yml"
WEBLATE_URL="${WEBLATE_URL:-http://localhost:8080}"

dc() { docker compose -f "$COMPOSE_FILE" "$@"; }

if ! curl -fsS "${WEBLATE_URL}/healthz/" >/dev/null 2>&1; then
  echo "Weblate is not responding at ${WEBLATE_URL}. Start it with:" >&2
  echo "  docker compose -f ${COMPOSE_FILE} up -d" >&2
  exit 1
fi

if [ -z "${WEBLATE_TOKEN:-}" ]; then
  echo "==> Fetching admin API token"
  WEBLATE_TOKEN="$(dc exec -T weblate weblate shell -c '
from weblate.auth.models import User
from rest_framework.authtoken.models import Token
u = User.objects.get(username="admin")
token, _ = Token.objects.get_or_create(user=u)
print(token.key)
' 2>/dev/null | tr -d '\r' | tail -n1)"
fi

if [ -z "${WEBLATE_TOKEN:-}" ]; then
  echo "Could not read the admin API token. Get it from" >&2
  echo "  ${WEBLATE_URL}/accounts/profile/#api" >&2
  echo "and re-run with WEBLATE_TOKEN=wlu_xxx" >&2
  exit 1
fi

echo "==> Creating project 'wca' (no-op if it exists)"
curl -fsS -X POST "${WEBLATE_URL}/api/projects/" \
  -H "Authorization: Token ${WEBLATE_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"name":"WCA","slug":"wca","web":"https://www.worldcubeassociation.org/"}' \
  >/dev/null 2>&1 || echo "    (project already exists, continuing)"

# Weblate needs a source file to create a component, but the real strings arrive
# over the API on the first sync. This placeholder is replaced wholesale by the
# `method=replace` upload in pushSource().
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
echo '{"_placeholder": "Replaced on the first /api/translate/sync run."}' > "$TMP/en.json"

# file_format MUST be flat "json", not "json-nested": the keys are dotted paths
# like `home#64f2:blocks(TextCard)[abc].body#0.1.0`, and json-nested would split
# them on every dot into a tree that no longer round-trips.
#
# vcs=local / repo=local: gives Weblate an internal git repo it manages itself,
# so there is no external repository of generated JSON to keep in sync.
echo "==> Creating component 'payload'"
curl -fsS -X POST "${WEBLATE_URL}/api/projects/wca/components/" \
  -H "Authorization: Token ${WEBLATE_TOKEN}" \
  -F name="Payload CMS" \
  -F slug=payload \
  -F vcs=local \
  -F repo=local: \
  -F file_format=json \
  -F filemask='payload/*.json' \
  -F template='payload/en.json' \
  -F edit_template=false \
  -F new_lang=add \
  -F language_code_style=linux \
  -F license="GPL-3.0-or-later" \
  -F docfile=@"$TMP/en.json" \
  >/dev/null || echo "    (component already exists, continuing)"

cat <<EOF

Done: ${WEBLATE_URL}/projects/wca/payload/

Next, push the real strings in from next-frontend. The sync route needs a
Payload session with the wst_admin role, plus these in next-frontend/.env:

  WEBLATE_URL=${WEBLATE_URL}
  WEBLATE_TOKEN=${WEBLATE_TOKEN}
  WEBLATE_PROJECT=wca
  WEBLATE_COMPONENT=payload

Then:

  # first run only — copies translations already in Payload up to Weblate
  curl -X POST 'http://localhost:3001/api/translate/sync?seed=1' -b <session cookie>

  # afterwards
  curl -X POST 'http://localhost:3001/api/translate/sync' -b <session cookie>
EOF
