---
name: copy-audit
description: Audits all locale copy in a multilingual Next.js/next-intl project for grammar errors, register inconsistencies (e.g., tu/vosaltres mixing in Catalan, tú/usted mixing in Spanish), structural cross-locale gaps, non-idiomatic phrasing, and formatting issues. Reads src/messages/{locale}.json and src/content/blog/{locale}/*.mdx, presents findings in severity-grouped tables, then asks the user to confirm each group before applying any fix. Use when user says "audit copy", "check translations", "find copy inconsistencies", "review locale files", or wants to check multilingual content quality.
---

# copy-audit

## Quick start

Run from a multilingual Next.js/next-intl project root. No arguments needed.

## Workflow

### 1. Discover files

Read all of:
- `src/messages/*.json` — one JSON per locale
- `src/content/blog/{locale}/*.mdx` — MDX blog posts (glob per locale subfolder, if present)

Identify locale codes from filenames.

### 2. Analyse

Build a findings list — each entry records:
`severity · locale(s) · key or file:line · current value · proposed fix · reason`

Severity: **Critical** = breaks rendering / changes meaning / wrong legal term / broken `{var}` interpolation; **Major** = unambiguous error a native speaker would correct; **Minor** = stylistic or intentional-but-worth-reviewing.

Check categories in this order:

1. **Grammar errors** — CA contractions (`l'`, `d'`, `del`/`al`), accents (`è`/`é`, `ò`/`ó`), gender/number agreement; ES tildes (`qué`, `cómo`); EN its/it's, subject-verb agreement; typos, doubled words, missing spaces.
2. **Register inconsistency** (within one locale) — mixing informal/formal address: CA `tu`/`vosaltres` vs `vostè`/`vostès` (`tens`/`el teu` vs `té`/`el seu`); ES `tú`/`vosotros` vs `usted`/`ustedes` (`tienes`/`tu` vs `tiene`/`su`); EN tone swings. Imperatives reveal it (`Comparteix` vs `Comparteixi`). Pick the project's dominant register, flag the deviating minority.
3. **Cross-locale structural gaps** — diff the key sets across `messages/*.json`; report keys present in one locale but missing in another. For shared keys compare completeness, and check **interpolation parity**: every `{var}` / ICU plural must appear in all locales (missing/renamed = Critical). Blog posts missing in one locale folder = informational gap.
4. **Non-standard or non-idiomatic phrasing** — calques / awkward literal translations, wrong legal term (`Política de privacitat`, `Aviso legal`), anglicisms, inconsistent terminology for the same concept.
5. **Formatting inconsistencies** — trailing punctuation mismatch across locales for the same key, stray `\n` / double spaces / leading-trailing whitespace, quotation-mark style, title capitalization, copyright/date/brand format.

Cite an exact anchor per finding (JSON key path or `file:line`); `Current` and `Proposed fix` must be copy-pasteable exact strings. Within a category sort Critical → Major → Minor.

### 3. Present findings

For each non-empty category, output a markdown table:

| # | Locale | Key / File:line | Current | Proposed fix | Reason |
|---|--------|----------------|---------|--------------|--------|

Then call **AskUserQuestion** (multiSelect: true):
- Header: the category name
- Question: "Which fixes do you want to apply?"
- First option: "Apply all in this category"
- One option per row: `#N — locale · key — one-line summary`

Do **not** edit any file until the user has responded for that category.

### 4. Apply confirmed fixes

For each confirmed fix use **Edit** to replace the exact string. Batch all edits to the same file together.

### 5. Verify

Check CLAUDE.md or Makefile for the build command (default: `pnpm build`). Run it and report pass/fail.

## Notes

- Legal pages (privacyPolicy, cookiePolicy, legalNotice) often use a formal register intentionally — present as "Minor / review" rather than auto-fixing
- OG/meta descriptions shown in search results may use a slightly more formal tone — lower severity
- Only change what is listed; never rewrite surrounding copy
- If a finding is ambiguous, explain both interpretations in the Reason column so the user can decide
