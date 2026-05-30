---
name: parallel-gh-issues-implement
description: Fetch open GitHub issues for the current repo, group them by conflict risk, then implement each group in parallel via Sonnet subagents in separate git worktrees. Each worktree builds and starts the app on its own port, and the skill returns a comparison table for manual QA.
allowed-tools: Bash, Read, Write, Edit, Agent, AskUserQuestion, ToolSearch
---

## Goal

Implement multiple open issues from the current repository in parallel, isolated in git worktrees,
so the user can visually compare each variant side-by-side before merging.

## Inputs

- `$ARGUMENTS` (optional): extra filters for `gh issue list` (e.g. `--milestone v2`). The
  `ai-ready` label filter is always applied.

## Workflow

### 0. Resolve the repo

The repo is auto-detected from the current directory's git remote. Capture it once:

```bash
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
```

Use `-R "$REPO"` on every `gh` call below. If `gh` is not authenticated, stop and tell the user to
run `gh auth login`. If there is no GitHub remote, stop and say so.

### 1. Fetch issues

Only issues labeled `ai-ready` are considered. Run:

```bash
gh issue list -R "$REPO" --state open --label ai-ready --json number,title,body,labels,url --limit 100 $ARGUMENTS
```

If the result is empty, stop and tell the user there are no `ai-ready` issues to implement.

### 2. Analyze and group

For each issue, infer which files/areas it likely touches by reading the title, body, and labels,
then cross-checking the repo with `grep`/`find` when the target is ambiguous.

Group issues by **conflict risk**, not by topic similarity. Two issues belong in the same group if:

- They likely edit the same file(s), or
- They edit closely-coupled files (e.g. a component + its CSS module + its tests), or
- One depends on the other.

Independent issues go in separate groups so they can truly run in parallel. Aim for the fewest
groups that keep each group conflict-free.

Each group gets:

- `id`: short kebab-case slug, e.g. `header`, `contact-form`, `i18n-fixes`
- `issues`: list of issue numbers + titles
- `rationale`: one line on why these were grouped
- `files`: best-guess list of files that will be touched

### 3. Present groups to the user

Show the groups as a markdown table:

| Group | Issues | Files (predicted) | Rationale |
| ----- | ------ | ----------------- | --------- |

Then call `AskUserQuestion` with a single question: "Proceed with these groups?" Options:
`Yes, run all in parallel`, `Let me edit the groups first`, `Cancel`.

If the user wants to edit, accept their edits via free-form input and re-display the table. Loop
until confirmed.

### 4. Provision worktrees

For each confirmed group, use `EnterWorktree` (fetch via ToolSearch: `select:EnterWorktree`) to
create an isolated worktree. Name the branch `parallel/<group-id>`.

Each worktree must install dependencies first (with pnpm's symlink layout `node_modules` does not
transfer across worktrees — re-install to be safe; use the project's package manager).

### 5. Spawn Sonnet subagents in parallel

Send **one message with multiple `Agent` tool calls** (parallel execution). For each group, use:

- `subagent_type`: `general-purpose`
- `model`: `sonnet`
- `description`: short, e.g. "Implement header issues"
- `prompt`: must be self-contained — include:
  - The group's issue numbers, titles, and full bodies (fetched via `gh issue view <n> -R "$REPO"`)
  - The worktree path the agent should work in
  - Explicit instruction: implement all issues in this group, run the project's typecheck and lint
    until clean, do NOT commit, do NOT push, do NOT merge
  - Repo conventions: read the repo's `AGENTS.md`/`CLAUDE.md`; design-system tokens (no hardcoded
    colors), no code comments unless WHY is non-obvious
  - Report back: list of files changed and a short bullet list of user-visible changes to verify
  - **Post a comment on every issue in the group** with the execution result. For each issue
    number `<n>`:

    ```bash
    gh issue comment <n> -R "$REPO" -F -
    ```

    Pipe a markdown body via stdin containing:
    - Status: `success` or `failed` (set `failed` if typecheck/lint did not pass cleanly)
    - Branch: `parallel/<group-id>`
    - Worktree path
    - Files changed (bulleted list)
    - User-visible changes to verify (bulleted list)
    - Typecheck result and lint result (pass/fail with error excerpt if failed)
    - If the group contains multiple issues, mention the other issue numbers so reviewers know they
      shipped together

    Post the comment whether the implementation succeeded or failed — a failed attempt is still
    useful signal. Do not post duplicate comments if the agent retries; post exactly once at the end.

Wait for all subagents to finish before proceeding.

### 6. Build and start each variant on its own port

Assign ports starting at 3001 (3000 reserved for the user's main dev server). For each worktree,
build and start the production server on its assigned port, using the project's package manager.
Run each start with `run_in_background: true` so they all stay up. If a build fails, report the
failure, skip starting that variant, and continue with the rest — do not abort the whole run.

### 7. Final report

Output a single markdown table:

| Subagent | Branch          | URL                   | Issues   | Changes to verify                                             |
| -------- | --------------- | --------------------- | -------- | ------------------------------------------------------------- |
| header   | parallel/header | http://localhost:3001 | #12, #15 | - Logo now links to /<br>- Mobile menu closes on route change |

Below the table, list any build failures with the error excerpt.

End with a one-line reminder: the worktrees and background servers remain running until the user
stops them; provide the `kill` commands and the `git worktree remove` commands needed to clean up.

## Guardrails

- Never `git push`, never merge, never delete branches.
- Never commit unless the user explicitly asks afterwards.
- If a subagent fails or times out, surface its error verbatim in the final report — do not
  silently retry.
- If two groups end up touching the same file (despite your grouping), flag it in the final report
  so the user knows merge conflicts are expected.
