---
name: worktree-task
description: Implement a task in an isolated git worktree, install dependencies, link .env files, then start the dev server on a free port and report the URL. Use when the user wants to run changes in parallel with other instances on the same repo without disturbing the current working tree.
---

## Task

The user wants the changes described in `$ARGUMENTS` applied inside a fresh git worktree, with its own dependencies installed and the dev server running on a free port. They will continue working on the main checkout in parallel.

If `$ARGUMENTS` is empty, ask the user briefly what task to perform in the worktree before proceeding.

## Steps

### 1. Gather repo context

```bash
git rev-parse --show-toplevel
git rev-parse --abbrev-ref HEAD
```

Detect package manager from lockfiles (`pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, `package-lock.json` → npm, `bun.lockb` → bun). If no `package.json`, infer language and ask the user how to install/run.

### 2. Create the worktree

- Worktree location: `<repo-parent>/<repo-name>.worktrees/<slug>` where `<slug>` is a short kebab-case summary of the task (5-6 words max).
- New branch name: `wt/<slug>` based off the current branch.

```bash
git worktree add -b wt/<slug> <path> <base-branch>
```

If the branch already exists, append a short random suffix.

### 3. Link `.env` files (do NOT link `node_modules`)

Find all `.env*` files tracked or untracked in the source repo (root and common subdirs like `apps/*`, `packages/*`):

```bash
cd <repo-root>
find . -maxdepth 4 -name ".env*" -not -path "*/node_modules/*" -not -path "*/.git/*"
```

For each match, create a symlink at the same relative path inside the worktree pointing to the absolute path in the source repo. Create parent dirs as needed. Skip if the worktree already has a real file there.

### 4. Install dependencies

Run the install command inside the worktree (`pnpm install`, `yarn`, `npm install`, etc.). Stream output so the user sees progress. Do not link `node_modules` — they must be installed fresh.

### 5. Apply the task

`cd` into the worktree and implement the changes described in `$ARGUMENTS`. Use the normal edit/read tools. Commit only if the user asked you to.

### 6. Find a free port and start the dev server

Pick a free port (try 3000, then increment until one is unused):

```bash
for p in $(seq 3000 3050); do
  if ! lsof -iTCP:$p -sTCP:LISTEN >/dev/null 2>&1; then echo $p; break; fi
done
```

Detect the dev script from `package.json` (`dev` preferred, else `start`). Start it in the background with `PORT=<port>` exported, logging to `<worktree>/.worktree-task.log`. Use `Bash` with `run_in_background: true`.

Poll the log (or `lsof`) until the server is listening on the chosen port, or up to ~30 seconds. If it fails, show the last lines of the log.

### 7. Report the outcome

Tell the user, concisely:

- The worktree path and branch name
- The port and the localhost URL (`http://localhost:<port>`)
- The log file path
- How to stop it (`git worktree remove` and how to kill the bg shell)
- One-liner to open it: `open http://localhost:<port>`

If anything failed (install, server start), surface the error and the log location instead of pretending success.
