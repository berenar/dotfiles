---
name: audit-content
description: Audits the copy of a multilingual project (next-intl, i18next, vue-i18n, Rails locales, etc.) for grammar errors, register inconsistencies (e.g. tu/vostè mixing in Catalan, tú/usted in Spanish), cross-locale structural gaps, non-idiomatic phrasing, and formatting issues. Discovers the locale files, presents findings in severity-grouped tables, then asks the user to confirm each group before applying any fix. Use when the user says "audit copy", "check translations", "find copy inconsistencies", "review locale files", or wants to check multilingual content quality.
allowed-tools: Bash, Read, Edit, Grep, Glob, Agent
---

# audit-content

## Step 0 — Delegate discovery + analysis to a fork

Discovery (finding locale files) and analysis (reading every locale file, cross-referencing
keys across locales, checking grammar/register/formatting) can touch dozens of files and
produce a lot of raw output that's only useful for building the findings table below — not
useful to keep around afterward. Dispatch it to a fork (`Agent` with
`subagent_type: "fork"`) instead of doing it inline.

Prompt the fork with the Discover + Analyse instructions below verbatim, and tell it to
return ONLY the findings list (nothing edited, no file dumps) in the exact format from
"Analyse". Then continue at "Present findings" using what it returns.

### Discover

Do NOT assume file paths. Find them first.

1. **Locale message files** — one structured file per locale. Find them:
   ```bash
   rg -l --glob '**/{messages,locales,lang,i18n,translations}/**' --glob '**/*.{json,yaml,yml}' '' | head -50
   ```
   Common layouts: `messages/{locale}.json` (next-intl), `public/locales/{locale}/*.json` (i18next), `src/locales/{locale}.{ts,json}` (vue-i18n), `config/locales/{locale}.yml` (Rails). Pick the cluster of per-locale files. Derive locale codes from filenames/folders.

2. **Localised long-form content** (optional) — MDX/Markdown organised per locale, e.g. `content/blog/{locale}/*.mdx`. Glob for it; skip if absent.

3. **Build/lint command** — read `CLAUDE.md`, `Makefile`, then `package.json` scripts. Note it for the Verify step instead of assuming a package manager.

### Analyse

Build a findings list — each entry records:
`severity · locale(s) · key or file:line · current value · proposed fix · reason`

Severity: **Critical** = breaks rendering / changes meaning / wrong legal term / broken `{var}` interpolation; **Major** = unambiguous error a native speaker would correct; **Minor** = stylistic or intentional-but-worth-reviewing.

Check categories in this order:

1. **Grammar errors** — per-language spelling, accents, agreement, punctuation; typos, doubled words, missing spaces. (E.g. CA contractions `l'`/`d'`/`del`/`al` and accents `è`/`é`, `ò`/`ó`; ES tildes `qué`/`cómo`; EN its/it's, subject-verb agreement.)
2. **Register inconsistency** (within one locale) — mixing informal/formal address or tone. (E.g. CA `tu`/`vosaltres` vs `vostè`/`vostès`; ES `tú`/`vosotros` vs `usted`/`ustedes`; imperatives like `Comparteix` vs `Comparteixi`; EN tone swings.) Pick the project's dominant register, flag the deviating minority.
3. **Cross-locale structural gaps** — diff the key sets across locales; report keys present in one but missing in another. Check **interpolation parity**: every `{var}` / ICU plural / named placeholder must appear in all locales (missing or renamed = Critical). Long-form content missing in one locale = informational gap.
4. **Non-standard or non-idiomatic phrasing** — calques / awkward literal translations, wrong legal term, anglicisms, inconsistent terminology for the same concept.
5. **Formatting inconsistencies** — trailing-punctuation mismatch across locales for the same key, stray `\n` / double spaces / leading-trailing whitespace, quotation-mark style, capitalization, copyright/date/brand format.

Cite an exact anchor per finding (key path or `file:line`); `Current` and `Proposed fix` must be copy-pasteable exact strings. Within a category sort Critical → Major → Minor.

## Workflow

### 1. Present findings

For each non-empty category, output a markdown table:

| # | Locale | Key / File:line | Current | Proposed fix | Reason |
|---|--------|----------------|---------|--------------|--------|

Then call **AskUserQuestion** (multiSelect: true):
- Header: the category name
- Question: "Which fixes do you want to apply?"
- First option: "Apply all in this category"
- One option per row: `#N — locale · key — one-line summary`

Do **not** edit any file until the user has responded for that category.

### 2. Apply confirmed fixes

Read each file that has a confirmed fix (only those files — no need to re-read ones with
nothing confirmed), then use **Edit** to replace the exact string. Batch all edits to the
same file together.

### 3. Verify

Run the build/lint command the fork found in Discover and report pass/fail.

## Notes

- Legal/policy pages (privacy, cookies, terms) and search-result meta descriptions often use a formal register intentionally — present as "Minor / review" rather than auto-fixing.
- Only change what is listed; never rewrite surrounding copy.
- If a finding is ambiguous, explain both interpretations in the Reason column so the user can decide.
