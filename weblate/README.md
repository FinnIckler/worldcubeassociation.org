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
CLDR forms, and Rails' `zero:` does not survive that. On the first write to a
file, Weblate drops it.

It is worth being precise about why, because "zero isn't CLDR" is wrong. CLDR
*does* define a `zero` category — but per language, only where the grammar needs
one, and **none of WCA's 33 locales have it** (Arabic, Welsh and Latvian do;
English, German, Polish and the rest are `one/other` or narrower). Weblate
builds each language's plural-form list from CLDR, so for our locales there is
simply no slot to put the value in.

Rails' `zero:` is a different mechanism altogether: the i18n Simple backend
checks `count == 0 && entry.has_key?(:zero)` *before* any plural rule, so it is
an exact-zero text override that works in any language. That is why translators
were able to add it to 32 locale files whose languages have no zero form. The
two are not interchangeable even where both exist — CLDR `zero` in Latvian
covers 0, 10, 11-19, 20, 30 … , not just 0.

Measured over the full locale set:

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

## Payload CMS content

Payload content is translated here too, as a second component:

```bash
./weblate/seed-payload.sh
```

Payload stores its content in MongoDB, so unlike `locales` there is no
repository to point Weblate at. The component uses Weblate's own local VCS
(`vcs: local`, `repo: local:`) and strings move over the REST API instead:

```
Payload (MongoDB)  ──push source──▶  Weblate  ──translators work here
       ▲                                │
       └────────pull translations───────┘
```

Both directions run from one route in next-frontend, which needs a Payload
session with the `wst_admin` role:

```bash
POST /api/translate/sync          # push source strings, pull translations back
POST /api/translate/sync?seed=1   # first run only, see below
GET  /api/translate/sync          # per-language progress, straight from Weblate
```

Or from the command line, which is the practical option locally and from cron
since there is no session to arrange. Same code path — both call `runSync`:

```bash
cd next-frontend
yarn payload run scripts/weblate-sync.ts dry-run   # report, touch nothing
yarn payload run scripts/weblate-sync.ts seed      # first run
yarn payload run scripts/weblate-sync.ts           # afterwards
```

`?seed=1` uploads translations that *already exist in Payload* before pulling.
It is a one-time migration step: routine syncs never push translations upward,
because that would overwrite newer work by translators with whatever Payload
happens to hold. Run it once, then stop using it.

Two design decisions worth knowing:

**There is no translation UI in the app.** An earlier prototype shipped a
`/translate` page with a hand-rolled Lexical editor; it was removed when this
landed. Weblate is the only place translators work, which is the entire point of
adopting it.

**Rich text is split into one unit per text node**, keyed by its position in the
tree (`home:body#0.1.0`). Translators see plain sentences, never Lexical JSON.
On write-back the **source** document is deep-cloned and only `text` values are
substituted, so structure, node versions and any node type the code has never
heard of come from Payload itself — a Payload or Lexical upgrade cannot corrupt
a write, because we never author the structure. That is what removed the need
for the editor. A rich text field is written only when *every* one of its text
nodes is translated; a half-German paragraph reads worse than the English
fallback.

**A document is written only when all its required strings are translated.**
Payload validates `required` per locale on write, so for a required field with
no translation there are three options: write `null` (Payload rejects the whole
document), write the English source (which then silently goes stale the next
time English changes), or hold the document back. Only the last keeps Payload's
own fallback working, so an untranslated locale renders English *now* rather
than English from whenever the last sync ran. The sync reports what it held back
and why, otherwise a translator who has done most of the work sees nothing
happen. Optional fields have no such constraint and are cleared individually.

`file_format` is flat `json`, not `json-nested` — the keys are dotted paths like
`home#64f2:blocks(TextCard)[abc].body#0.1.0`, and nested would split them on
every dot into a tree that no longer round-trips.

**Six locale codes need translating for Weblate**, which has its own language
database: `es-ES` is plain `es` there, `zh-CN`/`zh-TW` are script-based
(`zh_Hans`/`zh_Hant`), and `es-419`, `fr-CA`, `pt-BR` use underscores. The map
lives in `WEBLATE_LANGUAGE_CODES` in `weblate.ts`. Two traps worth knowing if
you extend it: the code a component *reports* is not always the code its URL
accepts (`language_code_style: linux` displays `zh_Hans` as `zh_CN`, but only
`zh_Hans` resolves), and Weblate answers both "language already exists" and
"never heard of this language" with an identical 400, so `ensureLanguage`
verifies by lookup instead of trusting the response.

## Not configured here

- **Push back to GitHub.** Weblate commits translations into its own clone; to
  get PRs you set the component's push URL and a GitHub token
  (`WEBLATE_GITHUB_TOKEN`, plus *Manage → Repository maintenance*). Worth wiring
  up against a fork before committing to this route, since that is the part
  replacing internationalize's PR flow. Only relevant to `locales` — the Payload
  component writes back through the API, not git.
- **WCA SSO.** The `WEBLATE_SOCIAL_AUTH_OIDC_*` block in `environment` is
  commented out. In a real deployment this is what keeps translators on their
  WCA account instead of needing GitHub.
- **Scheduling the Payload sync.** `/api/translate/sync` is called by hand for
  now. A cron would need a non-session credential; that is deliberately not
  built yet.

## Resources

Weblate wants ~3 GB RAM on its own. `WEBLATE_WORKERS=2` in `environment` keeps
it modest, but running this alongside the full WCA stack on Docker Desktop is
worth watching.
