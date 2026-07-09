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
1. Partition the diff into independent change sets before proposing multiple commits. Default to multiple commits when WIP contains more than one fix, feature, refactor, config change, or docs update.
2. Combine changes only when they share one clear reason and should be reviewed, reverted, and tested together. Changes are not related just because they touch the same file, package, or session.
3. Plan a list of commits, each with a short title that explains **why** the change was made, not what. If the "why" is obvious from the diff, the title can just name the change.
4. Commits should be independent, atomic, and grouped by intent — not one commit per file. If one file contains hunks for multiple unrelated fixes, split those hunks into separate commits.
5. Match the existing repo style (see `git log --oneline -20` above). If the repo uses Conventional Commits or includes a ticket ID (e.g. `ABC-123:` prefix), follow that convention.
6. Title max 100 characters. No description body unless the user explicitly asks for one.
7. **Never** add `Co-authored-by: Claude` or any AI attribution line.
8. Keep each commit scoped to files relevant to its change set — don't sweep in unrelated edits.
9. Preview the commit plan and messages to the user and wait for confirmation before committing.
10. Stage selectively for each commit and inspect `git diff --staged` before committing.
11. Never push unless the user explicitly asks.
