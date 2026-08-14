# Spec: MCP Background-Attribute Disambiguation — Repo B (inboundsavvy-ai-builder)

**Sibling spec:** `inboundsavvy-integration: docs/specs/mcp-background-attr-docs.md`
(covers CONTENT_SCHEMA_REFERENCE.md edits, mcp_handler.py `instructions=` wiring, and tests)

This file records the Repo B portion of the approved spec at
`/home/acz/.claude/plans/modular-giggling-deer.md`.

---

## Context

Two independent AI agents driving the InboundSavvy content MCP both concluded
that `get_schema` "talks about `backgroundColor` but the real attribute is
`background`." Investigation confirmed a real, verified guidance gap:

- Live renderer `StylesCreator.astro` reads `options.background`; there is **no
  `backgroundColor` / `background-color` emit anywhere** → `options.backgroundColor`
  is a **dead key on the live site**.
- `SKILL.md` L268 was telling agents the leading slash on a background `url()` is
  **incorrect** — the reverse of the truth. The canonical stored form (GrapesJS
  editor export, `style-converter.js:867,884-894`) **keeps the leading slash**;
  the live build strips and resolves it via the asset gallery.
- `SKILL.md` L266's umbrella bullet said "no leading slashes", directly
  contradicting the corrected L268 (INV-3 breach within one file).

---

## Changes (Repo B)

### 1. SKILL.md §3 Imperatives (~L97) — add NEVER bullet

Added one NEVER rule embedding the **canonical rule sentence verbatim** (AC-4,
INV-3 — byte-identical to the sentence in Repo A §7.1/§7.5):

> **NEVER** put a `backgroundColor` key inside an element's `options` — Set a
> section or element background with the `background` key in `options`
> (e.g. `"background": "var(--backgroundColor)"`); a `backgroundColor` key
> inside `options` is not rendered on the live site. The hex `backgroundColor`
> belongs only in `globaldesignsettings.colorDesign`, and the CSS variable
> `var(--backgroundColor)` is always valid as a *value* inside `background`.
> (This forbids only the JSON key; using `var(--backgroundColor)` as a value
> inside `background` is always correct.)

### 2. SKILL.md L268 — reverse the url() slash note (AC-5)

**Before:** "Use the filename only — no leading slash (the schema reference
examples may show `url('/hero.png')` but the slash is incorrect)"

**After:** "Use `url('/filename.jpg')` with a leading slash — this is the
canonical stored form (matches the editor export; the live build strips and
resolves it via the asset gallery). Filename only — no directory path."

### 3. SKILL.md L266 — fix the contradicting umbrella bullet (AC-5, F1)

**Before:** "Reference the filename only (no paths, no leading slashes) in
whichever form fits the context:"

**After:** "Reference the filename only (no paths) in whichever form fits the
context:"

Removed "no leading slashes" so the umbrella no longer contradicts the corrected
L268. No other "leading slash" / "no leading slash" phrasing was found elsewhere
in SKILL.md that required reconciliation.

---

## Acceptance criteria satisfied

- **AC-4:** SKILL.md §3 contains the canonical rule sentence verbatim.
- **AC-5:** L268 states `url('/filename')` (leading slash) is canonical; the
  "slash is incorrect" claim is removed; L266's "no leading slashes" umbrella is
  reconciled.
- **INV-3:** All background guidance in SKILL.md is mutually consistent and no
  longer contradicts the Repo A doc.

## Tests

None — doc-only repo, no test harness (declared N/A in spec).
