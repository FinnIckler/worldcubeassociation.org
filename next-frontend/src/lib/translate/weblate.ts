/**
 * Minimal Weblate REST client for the Payload CMS component.
 *
 * The component is created with `vcs: "local"` / `repo: "local:"`, so Weblate
 * owns a git repo it manages itself and there is no external repository of
 * generated JSON to keep in sync. Files move in and out purely over the API:
 * we upload the source strings, translators work in Weblate, we download the
 * translated files back. See weblate/seed-payload.sh.
 *
 * `file_format: "json"` (flat) is deliberate — our keys are dotted paths like
 * `home:blocks(TextCard)[abc].body#0.1.0`, and `json-nested` would split them
 * on the dots into a tree that no longer round-trips.
 */

const url = process.env.WEBLATE_URL ?? "http://localhost:8080";
const token = process.env.WEBLATE_TOKEN;
const project = process.env.WEBLATE_PROJECT ?? "wca";
const component = process.env.WEBLATE_COMPONENT ?? "payload";

export const weblateConfigured = Boolean(token);

function headers(): HeadersInit {
  if (!token) {
    throw new Error(
      "WEBLATE_TOKEN is not set; cannot talk to Weblate. Get a token from " +
        `${url}/accounts/profile/#api`,
    );
  }
  return { Authorization: `Token ${token}` };
}

async function call(path: string, init?: RequestInit): Promise<Response> {
  const res = await fetch(`${url}/api${path}`, {
    ...init,
    headers: { ...headers(), ...(init?.headers ?? {}) },
    cache: "no-store",
  });
  if (!res.ok) {
    throw new Error(
      `Weblate ${init?.method ?? "GET"} ${path} failed: ${res.status} ${await res.text()}`,
    );
  }
  return res;
}

export interface LanguageStats {
  code: string;
  total: number;
  translated: number;
  percent: number;
}

/** Languages that already exist in the component, with their progress. */
export async function listLanguages(): Promise<LanguageStats[]> {
  const out: LanguageStats[] = [];
  let next: string | null = `/components/${project}/${component}/translations/`;
  while (next) {
    const page: {
      next: string | null;
      results: {
        language_code: string;
        total: number;
        translated: number;
        translated_percent: number;
      }[];
    } = await (await call(next)).json();
    for (const t of page.results) {
      out.push({
        code: t.language_code,
        total: t.total,
        translated: t.translated,
        percent: t.translated_percent,
      });
    }
    // Weblate returns an absolute URL for `next`; strip back to the API path.
    next = page.next ? new URL(page.next).pathname.replace(/^\/api/, "") : null;
  }
  return out;
}

/** Create a translation for `code` if the component does not have one yet. */
export async function ensureLanguage(code: string): Promise<void> {
  const res = await fetch(
    `${url}/api/components/${project}/${component}/translations/`,
    {
      method: "POST",
      headers: { ...headers(), "Content-Type": "application/json" },
      body: JSON.stringify({ language_code: code }),
      cache: "no-store",
    },
  );
  // 400 here is the "already exists" case, which is not an error for us.
  if (!res.ok && res.status !== 400) {
    throw new Error(
      `Weblate could not add language ${code}: ${res.status} ${await res.text()}`,
    );
  }
}

function jsonFile(strings: Record<string, string>, name: string): FormData {
  const form = new FormData();
  form.append("file", new Blob([JSON.stringify(strings, null, 2)]), name);
  return form;
}

/**
 * Replace the source file. `method=replace` is what lets strings that no longer
 * exist in Payload disappear from Weblate — with `translate` they would linger
 * forever as orphaned units.
 */
export async function pushSource(
  strings: Record<string, string>,
): Promise<void> {
  const form = jsonFile(strings, "en.json");
  form.append("method", "replace");
  await call(`/translations/${project}/${component}/en/file/`, {
    method: "POST",
    body: form,
  });
}

/**
 * Seed an existing translation into Weblate. Only used by the one-time
 * `?seed=1` migration — routine syncs must never push translations upward or
 * they would clobber newer work done by translators.
 */
export async function pushTranslations(
  code: string,
  strings: Record<string, string>,
): Promise<{ accepted: number; total: number }> {
  const form = jsonFile(strings, `${code}.json`);
  form.append("method", "translate");
  const res = await call(
    `/translations/${project}/${component}/${code}/file/`,
    {
      method: "POST",
      body: form,
    },
  );
  const body: { accepted: number; total: number } = await res.json();
  return { accepted: body.accepted, total: body.total };
}

/** Download the translated file for `code` as a flat key/value map. */
export async function pullTranslations(
  code: string,
): Promise<Record<string, string>> {
  const res = await call(`/translations/${project}/${component}/${code}/file/`);
  const body = (await res.json()) as Record<string, unknown>;
  const out: Record<string, string> = {};
  for (const [key, value] of Object.entries(body)) {
    // Untranslated units come back as empty strings; treat them as absent so a
    // blank never overwrites anything in Payload.
    if (typeof value === "string" && value.trim() !== "") out[key] = value;
  }
  return out;
}
