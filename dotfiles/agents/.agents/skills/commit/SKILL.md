---
name: commit
description: Commit pending changes — invoke automatically when the user asks to commit, stage changes, or save work to git.
allowed-tools: Bash(git add:*) Bash(git commit:*) Bash(git status:*) Bash(git diff:*) Bash(git log:*)
---

## Repository context

Recent commit style:
!`git log --oneline -20`

Current status:
!`git status`

Unstaged changes:
!`git diff`

Staged changes:
!`git diff --staged`

## Task

0. There may be WIP changes unrelated to the work you did — only commit your code, leave the rest unstaged.
1. Plan a list of commits, each with a short title that explains **why** the change was made, not what. If the "why" is obvious from the diff, the title can just name the change.
2. Commits should be independent, atomic, and grouped by scope — not one commit per file. Aggregate related changes logically.
3. Match the existing repo style (see `git log --oneline -20` above). If the repo uses Conventional Commits or includes a ticket ID (e.g. `ABC-123:` prefix), follow that convention.
4. Title max 100 characters. No description body unless the user explicitly asks for one.
5. **Never** add `Co-authored-by: Claude` or any AI attribution line.
6. Keep each commit scoped to files relevant to the current task — don't sweep in unrelated edits.
7. Preview the commit messages to the user and wait for confirmation before committing.
8. Never push unless the user explicitly asks.
