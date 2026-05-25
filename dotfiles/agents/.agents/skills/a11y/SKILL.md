---
name: a11y
description: Run a comprehensive accessibility audit on a web project using axe-core (runtime browser scanning) and/or eslint-plugin-jsx-a11y (static analysis). Use when the user says "run accessibility scan", "a11y audit", "check accessibility", "WCAG compliance", or invokes /a11y or /accessibility.
---

# Accessibility Audit Skill

Run comprehensive accessibility audits on web projects using axe-core (runtime browser scanning) and eslint-plugin-jsx-a11y (static analysis). Configurable scan modes let you choose the right level of depth for your needs.

Source: https://github.com/airowe/claude-a11y-skill

## Triggers
- User says "run accessibility scan", "a11y audit", "check accessibility", "WCAG compliance"
- User references "/accessibility" or "/a11y"

## Configuration

The skill supports three configurable modes. Ask the user which mode they prefer if not specified:

1. **`runtime`** — Browser-based axe-core scan (default)
   - Injects axe-core into running pages via browser automation
   - Tests against WCAG 2.1 Level AA (wcag2a, wcag2aa, wcag21a, wcag21aa) + best practices
   - Scans multiple pages if a sitemap or route list is available
   - Reports violations with impact level, affected elements, and fix recommendations

2. **`static`** — ESLint jsx-a11y static analysis
   - Runs eslint-plugin-jsx-a11y rules against source code
   - Catches issues at build time without needing a running server
   - Best for React/Next.js/Vue projects with JSX/TSX files
   - Requires: `eslint-plugin-jsx-a11y` installed as dev dependency

3. **`full`** — Both runtime + static combined
   - Runs static analysis first for fast feedback
   - Then starts dev server and runs axe-core on all discoverable pages
   - Provides the most comprehensive coverage
   - Generates a combined report with deduplicated findings

## Runtime Scan Procedure

### Step 1: Discover pages to scan
Look for routes in the project:
- Next.js: Check `src/app/**/page.tsx` or `pages/**/*.tsx` for routes
- React Router: Check route definitions
- Static sites: Check HTML files or sitemap.xml
- Ask user if unclear

### Step 2: Start dev server
- Detect the project's dev command from `package.json` scripts (usually `dev`, `start`, or `serve`)
- Start it in the background
- Wait for HTTP 200 on localhost

### Step 3: Inject axe-core and scan each page
For each page, use browser automation to:
1. Navigate to the page
2. Wait for content to load (2-3 seconds)
3. Inject axe-core from CDN: `https://cdnjs.cloudflare.com/ajax/libs/axe-core/4.8.4/axe.min.js`
4. Run the audit:
```javascript
(async () => {
  if (!window.axe) {
    const script = document.createElement('script');
    script.src = 'https://cdnjs.cloudflare.com/ajax/libs/axe-core/4.8.4/axe.min.js';
    document.head.appendChild(script);
    await new Promise(resolve => { script.onload = resolve; });
  }
  const results = await axe.run(document, {
    runOnly: ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'best-practice']
  });
  window.__axeResults = {
    page: window.location.pathname,
    violations: results.violations.length,
    passes: results.passes.length,
    incomplete: results.incomplete.length,
    details: results.violations.map(v => ({
      id: v.id,
      impact: v.impact,
      description: v.description,
      helpUrl: v.helpUrl,
      nodes: v.nodes.length,
      elements: v.nodes.slice(0, 5).map(n => ({
        html: n.html.substring(0, 200),
        target: n.target,
        failureSummary: n.failureSummary
      }))
    }))
  };
})().then(() => console.log('AXE_SCAN_DONE'));
```
5. Wait 3 seconds, then retrieve `window.__axeResults`

### Step 4: Kill dev server
After all pages are scanned, kill the background dev server process.

### Step 5: Generate report
Format results as a markdown table with:
- Page path
- Number of violations
- Number of passes
- Impact levels

Then list each violation with:
- Rule ID and description
- Impact (critical/serious/moderate/minor)
- Affected elements (HTML snippet + CSS selector)
- Fix recommendation
- WCAG reference link

## Static Analysis Procedure

### Step 1: Check if eslint-plugin-jsx-a11y is installed
Look in `package.json` devDependencies. If not installed:
```bash
pnpm add -D eslint-plugin-jsx-a11y  # or npm/yarn based on lockfile
```

### Step 2: Create temporary standalone config
Due to ESLint 9 flat config compatibility issues with some frameworks, create a standalone config:
```javascript
// eslint.a11y.mjs
import jsxA11y from "eslint-plugin-jsx-a11y";
import tseslint from "typescript-eslint";

export default [
  {
    files: ["src/**/*.tsx", "src/**/*.jsx"],
    plugins: { "jsx-a11y": jsxA11y },
    languageOptions: {
      parser: tseslint.parser,
      parserOptions: { ecmaFeatures: { jsx: true } },
    },
    rules: { ...jsxA11y.flatConfigs.recommended.rules },
  },
];
```

### Step 3: Run ESLint with the a11y config
```bash
npx eslint --config eslint.a11y.mjs src/
```

### Step 4: Report findings
List each violation with file, line number, rule, and description.

### Step 5: Clean up
Remove the temporary config file. Keep `eslint-plugin-jsx-a11y` installed for future use.

### Step 6: Handle false positives
Common false positives to note:
- Custom component props named `role` (not HTML role attribute)
- Components that pass through ARIA attributes to child elements
- Dynamic content loaded after initial render

## Auto-Fix Suggestions

For each violation found, provide specific fix recommendations:

| Violation | Fix |
|-----------|-----|
| `region` (content not in landmarks) | Wrap page content in `<main>`, ensure nav in `<nav>`, footer in `<footer>` |
| `heading-order` (skipped heading levels) | Change heading level or add intermediate headings; use `<p>` with styling for decorative text |
| `color-contrast` | Adjust foreground/background colors to meet 4.5:1 ratio (3:1 for large text) |
| `image-alt` | Add descriptive `alt` text; use `alt=""` for decorative images |
| `button-name` | Add text content, `aria-label`, or `aria-labelledby` to buttons |
| `link-name` | Add text content or `aria-label` to links |
| `label` | Associate `<label>` with form controls via `htmlFor`/`id` or wrapping |
| `aria-*` | Fix invalid ARIA attributes, roles, or values |

## Output Format

Always present the final report in this structure:

```
## Accessibility Audit Results

**Scan mode:** [runtime/static/full]
**Standards:** WCAG 2.1 Level AA + Best Practices
**Pages scanned:** [count]

| Page | Violations | Passes | Worst Impact |
|------|-----------|--------|--------------|
| /    | 2         | 38     | moderate     |

### Violations Found

#### 1. [rule-id] — [impact]
**Description:** [what the rule checks]
**Pages affected:** [list]
**Elements:** [count] instances
**Example:**
```html
<element that failed>
```
**Fix:** [specific recommendation]
**WCAG:** [reference]

---

### Summary
- Total violations: [n]
- Critical: [n] | Serious: [n] | Moderate: [n] | Minor: [n]
- Recommendation: [prioritized next steps]
```
