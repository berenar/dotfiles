---
name: audit-ds
description: Audit and realign a project's design system. Finds hardcoded colors/values that bypass DS tokens, unused DS tokens, and font inconsistencies. Use when the user wants to check DS coverage, hunt down hardcoded styling, or readjust styling to flow through the DS.
allowed-tools: Bash, Read, Edit, Grep, Glob
---

## Goal

Make sure all styling flows through the project's design system. Report any hardcoded colors, shadows, fonts, or one-off values that should be tokens; flag DS tokens that nothing uses; and surface fonts that aren't aligned with the project's font tokens.

## Inputs

- `$ARGUMENTS` (optional): `--fix` to also propose/apply edits inline. Without it, the skill only reports.

## Step 0 — Discover the design system

Do NOT assume file paths or token names. Discover them first.

1. **Find the source of truth.** Look for the file(s) that define DS tokens. Common locations:
   ```bash
   rg -l --glob '**/*.{css,scss,ts,tsx,js}' '(@theme|:root\s*\{|--color-|--font-|tailwind\.config)'
   ```
   Typical candidates: `globals.css`, `app/**/globals.css`, `theme.css`, `tailwind.config.{js,ts}`, a `tokens.*` file, or a `theme/` dir. Pick the file with the densest cluster of `--*` custom-property definitions or the Tailwind theme config. Confirm with the user if ambiguous.

2. **Extract the token inventory** from that file: every `--color-*` / color-ish custom property, `--shadow-*`, `--font-*`, radii/spacing tokens, and any Tailwind class names they expose (e.g. `bg-surface`, `text-fg-muted`). Build the mapping table dynamically from what you find — there is no fixed list.

3. **Identify the source dir** (`src/`, `app/`, `lib/`, etc.) and the styling stack (Tailwind v3 vs v4, CSS modules, styled-components). Adapt the greps below to the actual extensions and dirs in use.

## Workflow

### 1. Scan for hardcoded color values

Search source (excluding the DS source-of-truth file you found in step 0):

```bash
rg -nP --glob '!**/<ds-source-file>' --glob '<src-dir>/**' \
  '(#[0-9a-fA-F]{3,8}\b|\brgba?\(|\bhsla?\(|\boklch\(|\boklab\()'
```

Then scan for raw Tailwind color utilities that should be tokens (raw shades used directly for fg/bg/border where a token exists):

```bash
rg -n --glob '<src-dir>/**/*.{tsx,ts,jsx,js,css}' \
  '\b(?:bg|text|border|ring|fill|stroke|from|to|via|placeholder|decoration|outline|divide|shadow)-(?:stone|neutral|zinc|gray|slate|orange|amber|red|fuchsia|purple|sky|blue|emerald|green)-(?:50|100|200|300|400|500|600|700|800|900|950)\b'
```

For each hit, decide:

- If a token covers it → propose a replacement (e.g. `text-stone-700` → `text-fg-muted`), based on the inventory from step 0.
- If it's a genuinely new role → flag it and suggest adding a token to the DS source instead of one-off use.
- Animations, gradients, or annotation/overlay styles may be legitimate exceptions; call them out but don't auto-rewrite.

### 2. Detect hardcoded shadows / radii / spacing magic numbers

```bash
rg -n --glob '<src-dir>/**/*.{tsx,ts,css}' 'shadow-\['
rg -n --glob '<src-dir>/**/*.{tsx,ts,css}' 'box-shadow:'
```

Anything matching the literal values of a defined `--shadow-*` token should switch to the token reference (`shadow-[var(--shadow-…)]` or the exposed Tailwind class).

### 3. Find unused DS tokens

For every token extracted in step 0, grep the rest of the repo for references. Report tokens with zero references outside the DS source file. Do NOT delete automatically — list them so the user decides.

```bash
rg -n --glob '<src-dir>/**' --glob '!**/<ds-source-file>' '<token>'
```

### 4. Font alignment

```bash
rg -n --glob '<src-dir>/**' 'font-(?![a-z-]*\b<default-font-token>)[a-z-]+|fontFamily|next/font|@font-face'
```

- Confirm the expected font(s) are the only ones loaded (check the root layout / entry).
- Flag any component pinning a different `font-*` class, inline `style={{ fontFamily }}`, or extra font imports.
- If a separate renderer registers fonts (e.g. `@react-pdf/renderer`, canvas, email templates), verify it stays in sync with the web font — or document the divergence.

### 5. Dark-mode sanity

For each hit found in step 1, check if it has a `dark:` counterpart hardcoded too. Prefer tokens that already adapt (token families that flip automatically under a `.dark` / `prefers-color-scheme` rule). Surface any pair that hardcodes both light and dark.

### 6. Report

Print a single grouped report:

```
DS Audit — <repo name>

Hardcoded colors (N)
  <src-dir>/components/x.tsx:42  text-stone-700  →  text-fg-muted
  ...

Hardcoded shadows (N)
  ...

Unused tokens (N)
  --surface-2 (0 refs)
  ...

Font misalignment (N)
  ...

Suggested new tokens (N)
  --… for repeated literal #abcdef seen in 3 files
```

If `--fix` was passed, apply only the unambiguous mapping-table replacements from steps 1 + 2, then run the project's lint + typecheck (discover via `package.json` scripts or a `Makefile`) and report. Leave anything ambiguous (new tokens, unused-token deletions, font changes) for the user to confirm.

## Notes

- Cohesion beats fidelity: if two near-identical fonts/colors/shadows exist for no strong reason, collapse them into one token even if it slightly compromises a specific component's original look. Standardization is the goal — pick the closest DS value and move on.
- Never delete unused tokens from the DS source without explicit user confirmation — they may be intentionally reserved.
- Don't rewrite values inside annotation libraries, animation keyframes, or `::selection` rules: those are intentional low-level styles.
- Respect the repo's `CLAUDE.md` / conventions and the user's no-commit-unless-asked rule.
