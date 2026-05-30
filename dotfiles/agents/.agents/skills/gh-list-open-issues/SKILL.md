---
name: gh-list-open-issues
description: List the open GitHub issues for the current repository using the `gh` CLI. Use when the user asks to see, list, or check open issues, the issue backlog, or what's pending on GitHub.
---

# gh-list-open-issues

Lists the open issues from GitHub for whatever repository the current directory belongs to.

## When to use

Invoke when the user asks things like:

- "list open issues"
- "what issues are open?"
- "show me the GitHub backlog"
- "qué issues hay abiertos"
- "issues pendientes"

## How to run

Use the GitHub CLI. The repository is auto-detected from the current working directory's git
remote, so no owner/repo flag is needed.

Run:

```sh
gh issue list --state open --limit 100 --json number,title,labels,assignees,updatedAt
```

If the user asks for a quick view rather than structured data, fall back to:

```sh
gh issue list --state open --limit 100
```

If `gh` is not authenticated, tell the user to run `gh auth login` — do not attempt to
authenticate for them. If the current directory has no GitHub remote, say so and stop.

## Output

Render a compact Markdown table with the columns: `#`, `Title`, `Labels`, `Assignee`, `Updated`.

- `#` should link to the issue: `[#13](https://github.com/<owner>/<repo>/issues/13)`. Get
  `<owner>/<repo>` from `gh repo view --json nameWithOwner -q .nameWithOwner` if needed.
- `Labels`: comma-separated label names, or `—` if none.
- `Assignee`: login of the first assignee, or `—` if unassigned.
- `Updated`: relative time (e.g. `3d ago`). Compute from `updatedAt`.

If there are no open issues, say so in one line and stop.

## Filters

If the user specifies extra criteria, pass them through to `gh issue list`:

- by label: `--label "<name>"`
- by assignee: `--assignee "<login>"` (or `@me`)
- by author: `--author "<login>"`
- by search: `--search "<query>"`

Do not invent filters the user didn't ask for.
