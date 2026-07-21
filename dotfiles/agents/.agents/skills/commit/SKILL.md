---
name: commit
description: Commit pending changes by planning, staging, and creating separate atomic commits for unrelated WIP. Invoke automatically when the user asks to commit, stage changes, save work to git, or split WIP into commits.
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
1. Before grouping anything, go hunk by hunk (not file by file) and list every independent change you see, each with its own one-line reason for existing. Build the commit plan from that list — don't start from "how few commits can this be."
2. Default assumption: **each item on that list is its own commit.** Only merge two items if you can state one single reason that covers both and that reason would still make sense as a PR description. "Both touch auth", "both are cleanup", "both happened in this session" are not valid reasons to merge. If you're unsure whether two changes are related, treat them as unrelated.
3. Never bundle these together even if they're adjacent or in the same file: a bug fix + a refactor, a new feature + unrelated cleanup, a behavior change + a formatting/lint pass, config changes for different concerns, or changes to different files that happen to serve different features. Each gets its own commit.
4. If one file contains hunks for multiple unrelated concerns, split those hunks into separate commits (`git add -p` / patch staging) rather than committing the whole file at once.
5. Plan a list of commits, each with a short title that explains **why** the change was made, not what. If the "why" is obvious from the diff, the title can just name the change.
6. Match the existing repo style (see `git log --oneline -20` above). If the repo uses Conventional Commits or includes a ticket ID (e.g. `ABC-123:` prefix), follow that convention.
7. Title max 100 characters. No description body unless the user explicitly asks for one.
8. **Never** add `Co-authored-by: Claude` or any AI attribution line.
9. Keep each commit scoped to files/hunks relevant to its change set — don't sweep in unrelated edits.
10. Preview the full commit plan (numbered list of titles + what's in each) to the user and wait for confirmation before committing. If the user pushes back that it's still too clustered, split further rather than defending the grouping.
11. Stage selectively for each commit and inspect `git diff --staged` before committing.
12. Never push unless the user explicitly asks.
