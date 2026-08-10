# Weblate evaluation instance

> Deploying this for real? See [DEPLOYMENT.md](DEPLOYMENT.md) — one EC2 instance
> behind the existing `wca-on-rails` ALB.

A throwaway self-hosted [Weblate](https://weblate.org/) pointed at
`config/locales/*.yml`, to judge whether it should replace the
[internationalize](https://github.com/jonatanklosko/internationalize) workflow —
and eventually take Payload CMS content too.

It is deliberately **separate from the main stack**: its own compose project
(`wca-weblate`), its own network and volumes. Nothing here touches
`docker-compose.yml`, and the two can run at the same time.

## Run it

```bash
docker compose -f weblate/docker-compose.yml up -d
./weblate/seed.sh
```

Then <http://localhost:8080/projects/wca/>, log in as **admin / admin**.

First boot takes a few minutes (migrations + search index), and `seed.sh` waits
for that. It then creates a `wca` project with two components and Weblate starts
cloning the repo in the background, so string counts appear a little later.

Tear down, including all data:

```bash
docker compose -f weblate/docker-compose.yml down -v
```

## Faster: translate a local clone

`seed.sh` defaults to cloning `github.com/thewca/worldcubeassociation.org`, which
is ~450 MB. The repo root is already mounted read-only at `/wca-repo` in the
container, so you can point at your working copy instead:

```bash
docker compose -f weblate/docker-compose.yml down -v   # start clean
docker compose -f weblate/docker-compose.yml up -d
REPO=file:///wca-repo BRANCH=$(git branch --show-current) ./weblate/seed.sh
```

Weblate clones from it, so it never writes to your working tree — but it also
can't push back, which makes this the wrong setup for testing the PR flow.

## What the seeded config demonstrates

Rails i18n YAML is **monolingual** — every file carries the full key set and
`en.yml` is the base — which maps onto Weblate's `ruby-yaml` format with
`template: config/locales/en.yml` and `edit_template: false` so translators
can't edit English.

One detail worth knowing before judging the fit: `config/locales/` holds 43
`.yml` files but only 33 are locales. The rest (`faker.en.yml`, `shared.en.yml`,
`devise_overrieds.ru.yml`, `time_will_tell.*.yml`) carry a dotted prefix, and
Weblate's default language filter `^[^.]+$` already excludes exactly those. So
the `Locales` component lands on the 33 real locales with no hand-maintained
exclusion list — verified: the discovered language set is an exact match for
`lib/static_data/available_locales.json`. `time_will_tell` becomes a second
component over the same clone (`repo: weblate://wca/locales`) rather than a
second checkout.

## Format choice: ruby-yaml is mandatory

`file_format` must be `ruby-yaml`. Plain `yaml` looks tempting (it round-trips
the files losslessly, see below) but it is **broken** for Rails locale files:
they are rooted at the locale code, so plain `yaml` produces keys like
`en->about->x` and `de->about->x`. None of them match the template — 0 of 2303 —
and every language reports 0% translated. Stripping that root key is the whole
point of `ruby-yaml`.

The price of `ruby-yaml` is that it normalizes plurals to the target language's
CLDR forms, and Rails' `zero:` key is not CLDR. On the first write to a file,
Weblate drops it. Measured over the full locale set:

| | count | matters? |
|---|---|---|
| `zero:` entries where **English also has** `zero:` | **49** | real regression — those strings fall back to the `other` form |
| `zero:` entries orphaned (English has no `zero:`) | 521 | already dead weight, inconsistent with the source |
| `#original_hash` comments dropped | 431 | only matters if internationalize runs in parallel |

The 49 real ones come from just three English keys —
`competitions.messages.spots_left`,
`competitions.registration_v2.list.spots_remaining_plural` and
`competitions.registration_v2.update.move_to` — so this is a scoped pre-migration
cleanup, not a blocker. Decide those three keys' fate before the first Weblate
write.

Separately, the first write to each file **reflows** long lines to ~80 columns:
~300 changed lines on a 2244-string file. That is one-time. A second edit to an
already-reflowed file produces a clean 2-line diff. Land the reflow as its own
mechanical commit so it never pollutes a translation PR.

## What to actually evaluate

The point of this instance is the things internationalize doesn't do:

- **Stale detection.** Edit an English string in the repo, let Weblate pull, and
  watch every translation of that key flip to "needs editing". Note that
  internationalize already does this — the `#original_hash: <sha>` comments
  throughout the locale files are its record of the English source each string
  was translated against (2244 of them in `ko.yml` alone). The Payload
  `/translate` prototype is the one with no stale tracking at all;
  `hasContent()` only tests empty vs. non-empty.
- **Translation memory + glossary.** Shared across components, so Payload
  content would later benefit from the ~2,300 Rails keys already translated.
- **Per-language teams.** *Manage → Access*: a team scoped to specific
  languages, with distinct translate / suggest-only / review roles.
- **Review workflow.** Enable "Turn on reviews" on the project and see the
  suggest → approve path.
- **Translator UX.** The side-by-side translate view, keyboard flow, checks
  (placeholders, punctuation), and per-language progress.

## Bugs it found on first run

Weblate refused two files with "String contains control character". Both were
real corruption, not Weblate artifacts — a literal `\b` inside a double-quoted
YAML scalar, which Ruby's Psych parses to `\x08` exactly the same way, so both
were live in production:

- `ja.organizer_guidelines.paragraph-events.content`
- `ko.users.errors.wca_id_no_gender_html` — which also had a malformed link,
  `<a href='%{path}'='%{path}' target='_blank'>`, with the `href` fragment
  duplicated

Both are fixed in `config/locales/{ja,ko}.yml`. That fix has to land on `main`
before this instance stops reporting the error, since it translates GitHub.
Worth weighing in the decision: these sat in the repo through the existing
pipeline and Weblate caught them within minutes of first parse.

## Not configured here

- **Push back to GitHub.** Weblate commits translations into its own clone; to
  get PRs you set the component's push URL and a GitHub token
  (`WEBLATE_GITHUB_TOKEN`, plus *Manage → Repository maintenance*). Worth wiring
  up against a fork before committing to this route, since that is the part
  replacing internationalize's PR flow.
- **WCA SSO.** The `WEBLATE_SOCIAL_AUTH_OIDC_*` block in `environment` is
  commented out. In a real deployment this is what keeps translators on their
  WCA account instead of needing GitHub.
- **Payload CMS content.** Not covered — that needs the JSON export/import sync
  built on `next-frontend/src/lib/translate/registry.ts`. Evaluate the Rails half
  first.

## Resources

Weblate wants ~3 GB RAM on its own. `WEBLATE_WORKERS=2` in `environment` keeps
it modest, but running this alongside the full WCA stack on Docker Desktop is
worth watching.
