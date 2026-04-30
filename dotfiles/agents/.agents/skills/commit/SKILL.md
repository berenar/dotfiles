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

1. Come up with a list of commits, each with a short title that explains _why_ the changes were made, not _what_.
2. Commits should be independent, atomic and grouped by scope. Not necessarily one commit per file, they should aggregate changes in a logical way.
3. The title should have no more than 100 characters.
4. Don't provide any description, unless I ask you explicitly.
5. Offer the user the preview of the commit messages and wait for confirmation before committing it.
6. Never push the commit unless the user asks for it explicitly.
