import type { CollectionSlug, GlobalSlug, Payload, TypedLocale } from "payload";
import { fallbackLng } from "@/lib/i18n/settings";
import {
  buildTranslationRegistry,
  resolveLeaf,
  resolveStrings,
  type LocalizedField,
} from "./registry";

/**
 * Turns Payload documents into the flat key/value units Weblate translates, and
 * writes translated units back.
 *
 * Rich text is the interesting half. Rather than shipping Lexical JSON to
 * translators (which is what forced the prototype to hand-roll an editor), each
 * *text node* becomes its own unit, keyed by its index path in the tree:
 *
 *   home:body            -> plain field
 *   home:body#0.1.0      -> the text node at root.children[0].children[1].children[0]
 *
 * Translators therefore see plain sentences. On write-back we deep-clone the
 * **source** Lexical state and substitute only `text` values, so structure,
 * node `version`s and any node type we have never heard of come from Payload
 * itself. A Payload or Lexical upgrade cannot corrupt a write, because we never
 * author the structure.
 */

interface LexicalNode {
  type?: string;
  text?: string;
  children?: unknown[];
}

function lexicalRoot(value: unknown): LexicalNode | null {
  const root = (value as { root?: unknown } | null | undefined)?.root;
  return root && typeof root === "object" ? (root as LexicalNode) : null;
}

/** Every non-blank text node in a Lexical value, with its index path. */
export function lexicalTextNodes(
  value: unknown,
): { path: string; text: string }[] {
  const out: { path: string; text: string }[] = [];
  const visit = (node: unknown, path: number[]): void => {
    if (!node || typeof node !== "object") return;
    const n = node as LexicalNode;
    if (n.type === "text" && typeof n.text === "string" && n.text.trim()) {
      out.push({ path: path.join("."), text: n.text });
    }
    if (Array.isArray(n.children)) {
      n.children.forEach((child, i) => visit(child, [...path, i]));
    }
  };
  const root = lexicalRoot(value);
  if (root && Array.isArray(root.children)) {
    root.children.forEach((child, i) => visit(child, [i]));
  }
  return out;
}

/** Clone `source` and replace the text of every node named in `texts`. */
export function applyLexicalTexts(
  source: unknown,
  texts: Map<string, string>,
): unknown {
  const clone = structuredClone(source);
  const visit = (node: unknown, path: number[]): void => {
    if (!node || typeof node !== "object") return;
    const n = node as LexicalNode;
    if (n.type === "text" && typeof n.text === "string") {
      const replacement = texts.get(path.join("."));
      if (replacement !== undefined) n.text = replacement;
    }
    if (Array.isArray(n.children)) {
      n.children.forEach((child, i) => visit(child, [...path, i]));
    }
  };
  const root = lexicalRoot(clone);
  if (root && Array.isArray(root.children)) {
    root.children.forEach((child, i) => visit(child, [i]));
  }
  return clone;
}

/** A localized leaf in one document, plus the units it produces. */
interface Leaf {
  field: LocalizedField;
  dataPath: (string | number)[];
  /** Unit key for a plain field; the prefix before `#` for rich text. */
  baseKey: string;
  source: unknown;
}

interface SourceDoc {
  type: "collection" | "global";
  slug: string;
  docId: string | null;
  doc: Record<string, unknown>;
  leaves: Leaf[];
}

function groupByParent(
  fields: LocalizedField[],
): Map<string, LocalizedField[]> {
  const byParent = new Map<string, LocalizedField[]>();
  for (const field of fields) {
    const id = `${field.parent.type}:${field.parent.slug}`;
    const existing = byParent.get(id);
    if (existing) existing.push(field);
    else byParent.set(id, [field]);
  }
  return byParent;
}

/**
 * Read every document in the source locale and expand it into localized leaves.
 * Keys embed the document id so collection rows stay addressable and stable
 * across syncs; the path itself comes from the registry, which prefers a row's
 * `id` over its index.
 */
export async function collectSourceDocs(
  payload: Payload,
): Promise<SourceDoc[]> {
  const out: SourceDoc[] = [];

  for (const fields of groupByParent(
    buildTranslationRegistry(payload.config),
  ).values()) {
    const { type, slug } = fields[0].parent;

    const docs: { docId: string | null; doc: Record<string, unknown> }[] = [];
    if (type === "global") {
      const doc = await payload.findGlobal({
        slug: slug as GlobalSlug,
        locale: fallbackLng,
        depth: 0,
      });
      docs.push({
        docId: null,
        doc: doc as unknown as Record<string, unknown>,
      });
    } else {
      const found = await payload.find({
        collection: slug as CollectionSlug,
        locale: fallbackLng,
        depth: 0,
        pagination: false,
      });
      for (const doc of found.docs) {
        docs.push({
          docId: String(doc.id),
          doc: doc as unknown as Record<string, unknown>,
        });
      }
    }

    for (const { docId, doc } of docs) {
      const leaves: Leaf[] = [];
      for (const field of fields) {
        for (const string of resolveStrings(field, doc)) {
          // resolveStrings keys look like `slug:path`; re-compose so the
          // document id sits between them for collections.
          const path = string.key.slice(slug.length + 1);
          leaves.push({
            field,
            dataPath: string.dataPath,
            baseKey:
              docId === null ? `${slug}:${path}` : `${slug}#${docId}:${path}`,
            source: string.value,
          });
        }
      }
      out.push({ type, slug, docId, doc, leaves });
    }
  }

  return out;
}

/** Flat source strings for Weblate, keyed exactly as they will come back. */
export function unitsFromDocs(docs: SourceDoc[]): Record<string, string> {
  const units: Record<string, string> = {};
  for (const { leaves } of docs) {
    for (const leaf of leaves) {
      if (leaf.field.widget === "plain") {
        if (typeof leaf.source === "string" && leaf.source.trim()) {
          units[leaf.baseKey] = leaf.source;
        }
      } else {
        for (const node of lexicalTextNodes(leaf.source)) {
          units[`${leaf.baseKey}#${node.path}`] = node.text;
        }
      }
    }
  }
  return units;
}

/**
 * The value to store for one leaf in the target locale, or `undefined` when
 * Weblate has nothing for it.
 *
 * Rich text is all-or-nothing: a paragraph half in German and half in English
 * reads worse than the English original, which is what Payload's fallback shows
 * when we leave the field empty.
 */
function translatedValue(
  leaf: Leaf,
  translations: Record<string, string>,
): unknown | undefined {
  if (leaf.field.widget === "plain") {
    return translations[leaf.baseKey];
  }
  const nodes = lexicalTextNodes(leaf.source);
  if (nodes.length === 0) return undefined;
  const texts = new Map<string, string>();
  for (const node of nodes) {
    const value = translations[`${leaf.baseKey}#${node.path}`];
    if (value === undefined) return undefined;
    texts.set(node.path, value);
  }
  return applyLexicalTexts(leaf.source, texts);
}

export interface ApplyResult {
  locale: string;
  documentsUpdated: number;
  stringsWritten: number;
}

/**
 * Write Weblate's translations for `locale` into Payload.
 *
 * The document sent to Payload is built from the **source** structure so that
 * arrays and blocks exist in the target locale at all, then every localized
 * leaf is filled from Weblate, falling back to whatever the target locale
 * already held, and finally to `null`. Explicitly nulling the leftovers is what
 * stops English text leaking into a locale and masking Payload's own fallback.
 */
export async function applyLocale(
  payload: Payload,
  locale: TypedLocale,
  docs: SourceDoc[],
  translations: Record<string, string>,
): Promise<ApplyResult> {
  let documentsUpdated = 0;
  let stringsWritten = 0;

  for (const source of docs) {
    if (source.leaves.length === 0) continue;

    const existing =
      source.type === "global"
        ? ((await payload.findGlobal({
            slug: source.slug as GlobalSlug,
            locale,
            depth: 0,
            fallbackLocale: false,
          })) as unknown as Record<string, unknown>)
        : ((await payload.findByID({
            collection: source.slug as CollectionSlug,
            id: source.docId!,
            locale,
            depth: 0,
            fallbackLocale: false,
          })) as unknown as Record<string, unknown>);

    const next = structuredClone(source.doc);
    let writes = 0;

    for (const leaf of source.leaves) {
      const target = resolveLeaf(next, leaf.field, leaf.dataPath);
      if (!target) continue;

      const translated = translatedValue(leaf, translations);
      if (translated !== undefined) {
        target.container[target.key] = translated;
        writes += 1;
        continue;
      }
      // Preserve anything already translated inside Payload that Weblate does
      // not know about; otherwise clear, so Payload falls back to English.
      const previous = resolveLeaf(existing, leaf.field, leaf.dataPath);
      target.container[target.key] = previous
        ? (previous.container[previous.key] ?? null)
        : null;
    }

    if (writes === 0) continue;

    // Payload replaces arrays wholesale, so send whole top-level fields.
    const data: Record<string, unknown> = {};
    for (const leaf of source.leaves) {
      const top = leaf.dataPath[0];
      if (typeof top === "string") data[top] = next[top];
    }

    if (source.type === "global") {
      await payload.updateGlobal({
        slug: source.slug as GlobalSlug,
        locale,
        data,
      });
    } else {
      await payload.update({
        collection: source.slug as CollectionSlug,
        id: source.docId!,
        locale,
        data,
      });
    }

    documentsUpdated += 1;
    stringsWritten += writes;
  }

  return { locale, documentsUpdated, stringsWritten };
}

/** Existing Payload translations for `locale`, keyed like the source units. */
export async function collectExistingTranslations(
  payload: Payload,
  locale: TypedLocale,
  docs: SourceDoc[],
): Promise<Record<string, string>> {
  const out: Record<string, string> = {};

  for (const source of docs) {
    if (source.leaves.length === 0) continue;

    const doc =
      source.type === "global"
        ? ((await payload.findGlobal({
            slug: source.slug as GlobalSlug,
            locale,
            depth: 0,
            fallbackLocale: false,
          })) as unknown as Record<string, unknown>)
        : ((await payload.findByID({
            collection: source.slug as CollectionSlug,
            id: source.docId!,
            locale,
            depth: 0,
            fallbackLocale: false,
          })) as unknown as Record<string, unknown>);

    for (const leaf of source.leaves) {
      const resolved = resolveLeaf(doc, leaf.field, leaf.dataPath);
      if (!resolved) continue;
      const value = resolved.container[resolved.key];
      if (value == null) continue;

      if (leaf.field.widget === "plain") {
        if (typeof value === "string" && value.trim())
          out[leaf.baseKey] = value;
      } else {
        // Only meaningful when the translated tree still matches the source
        // shape; a mismatch means the structures diverged and the safe move is
        // to let the translator start from the source.
        const sourceNodes = lexicalTextNodes(leaf.source);
        const targetNodes = new Map(
          lexicalTextNodes(value).map((n) => [n.path, n.text]),
        );
        for (const node of sourceNodes) {
          const text = targetNodes.get(node.path);
          if (text) out[`${leaf.baseKey}#${node.path}`] = text;
        }
      }
    }
  }

  return out;
}
