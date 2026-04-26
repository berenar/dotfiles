---
description: implement plans in parallel (subagents, worktrees)
---

$ARGUMENTS is either a path to a `./plans/<timestamp>/` directory or not provided at all. If not provided, use the most recent `./plans/<timestamp>/` directory that contains plan markdown files.

Your job is to implement each remaining plan independently in its own git worktree.

Rules:

1. Fail fast if the main worktree is dirty with `git status --porcelain`. Explain that parallel worktrees can only branch from committed state, so uncommitted changes must be committed or stashed first.
2. Resolve the target plan directory from `$ARGUMENTS` or by picking the most recent valid `./plans/<timestamp>/` directory.
3. Read all plan files in that directory:
   - include only `*.md`
   - exclude `.gitignore`
   - sort by leading numeric prefix, then filename
4. Treat the remaining plan files in that directory as the reviewed shortlist to implement. If I deleted or edited any plan files, trust the current directory contents.
5. Create `./.worktrees/<timestamp>/` if it doesn't exist.
6. Ensure `./.worktrees/` is ignored without modifying tracked repo files if possible (prefer `.git/info/exclude` over editing `.gitignore`).
7. For each actionable plan, create a dedicated branch from the current `HEAD` named `<timestamp>-<n-short-kebab-case-title>`.
8. For each branch, create a dedicated worktree at `./.worktrees/<timestamp>/<n-short-kebab-case-title>`.
9. If a branch or worktree for a plan already exists, reuse it instead of failing.
10. Launch one Agent per actionable plan in parallel, using the Agent tool with `subagent_type: general-purpose`. Send all agent invocations in a single message so they run concurrently. Scope each subagent to its own worktree only.
11. Each subagent may read the full repository context it needs, but may only modify files inside its assigned worktree.
12. Each subagent must implement only its assigned plan. Do not mix multiple plans into one worktree.
13. If a plan says the item is already solved, not actionable, or should be skipped, do not implement it. Still create a `RESULTS.md` file in that worktree explaining why it was skipped.
14. Each subagent should follow the plan closely, but it may adapt small details if the codebase has changed since the plan was written.
15. Each subagent should run focused verification for its change when possible. If there is no obvious verification command, say so explicitly.
16. Do not commit, push, or open pull requests.
17. Each subagent must create exactly one root-level file in its assigned worktree: `RESULTS.md`.

Each `RESULTS.md` should include:

- Plan file
- Status (`implemented`, `skipped`, `blocked`, or `failed`)
- Branch
- Worktree
- What changed
- Verification
- Follow-ups or blockers

After all subagents finish, summarize:

- which plans were implemented
- which plans were skipped, blocked, or failed
- the branch name and worktree path for each plan
- where each `RESULTS.md` file lives
- any verification results
- any likely overlap or conflicts between plans
