---
name: rebase
description: Rebase the current branch onto its base branch and resolve conflicts, auto-fixing them whenever possible.
allowed-tools: Bash(git status:*) Bash(git branch:*) Bash(git log:*) Bash(git diff:*) Bash(git fetch:*) Bash(git rebase:*) Bash(git rev-parse:*) Bash(git symbolic-ref:*) Bash(git stash:*) Bash(git add:*) Bash(git show:*) Bash(gh repo view:*)
---

## Repository context

Current branch and status:
!`git status -sb`

Upstream tracking branch (if any):
!`git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "none"`

Remote default branch:
!`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null || echo "unknown"`

## Task

### 1. Pick the base branch

Use, in order: a base branch the user named explicitly; the upstream tracking branch from the context above; the remote default branch from the context above. If none of these resolve, ask the user which branch to rebase onto — don't guess.

State which base you're using in one line before doing anything else.

### 2. Get a clean starting point

- If the working tree is dirty, `git stash push -u -m "pre-rebase autostash"` before touching anything, and note that you did so — you'll pop it at the end.
- `git fetch origin <base>` so the rebase target is current.
- Refuse to proceed (and say why) if the current branch IS the base branch.

### 3. Start the rebase

`git rebase origin/<base>` (fall back to the local `<base>` if there's no remote). If it completes clean, skip to step 6.

### 4. Work through conflicts, one stopped commit at a time

When rebase stops on a commit, run `git status` to list conflicted files, then read each one's conflict markers and classify every hunk:

**Auto-resolve these — they don't need the user:**

- Whitespace/formatting-only differences.
- Lockfiles (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Gemfile.lock`, `poetry.lock`, `Cargo.lock`, etc.) — take the base branch's version of the manifest lock and regenerate it with the project's package manager instead of hand-merging; if you can't regenerate, take `--theirs` and flag it for the user to sanity-check.
- Two sides adding different, non-overlapping entries to the same list/import block/export map — keep both additions.
- A hunk where one side is a pure rename/move and the other is an unrelated content change further down — reapply the content change on top of the rename.
- Generated or lock-style files that are safe to regenerate rather than merge.

**Stop and ask the user about these — do not guess:**

- Both sides changed the same lines with different logic or intent (a real semantic conflict).
- Either side's change looks like a bug fix, security fix, or behavior change that the other side might silently undo if you pick one.
- Delete/modify conflicts (deleted on one side, edited on the other).
- Anything where merging both sides could plausibly produce broken or wrong behavior, even if it "compiles."

For each file you're auto-resolving, briefly say what you picked and why, then `git add` it. Batch every hunk you're unsure about from this stopped commit into one question: show the file, the conflicting sides (labeled "current branch" / base branch name), and what you'd lean toward, then ask the user to pick or describe the right merge. Use AskUserQuestion when the options reduce to a handful of concrete choices (keep ours, keep theirs, merge both, something else); ask in plain text when the resolution needs the user to explain intent. Apply their answer, `git add` the file.

Once every conflicted file in the current stop is staged, run `git rebase --continue`. Repeat this step for each subsequent stop.

### 5. If it gets messy

If conflicts pile up across many commits with no clear resolution, or the user says to bail, run `git rebase --abort` to restore the pre-rebase state and confirm that with the user rather than pushing through.

### 6. Wrap up

- Run `git status` and `git log --oneline origin/<base>..HEAD` to show the result.
- If you stashed in step 2, `git stash pop` now and resolve any conflicts it raises the same way as step 4.
- Rebase rewrites history. Do not force-push — mention that the branch now needs `git push --force-with-lease` if it has an upstream, and wait for the user to explicitly ask before running it.
