---
name: commit
description: Commit pending changes — invoke automatically when the user asks to commit, stage changes, or save work to git.
---

Run these in parallel to gather context:

- `git log --oneline -20` to match the format of past commits
- `git status` to see what's pending
- `git diff` to see the changes

Then:

1. Come up with a short title that explains _why_ the changes were made, not _what_
2. The title should have no more than 100 characters
3. Don't provide any description, unless I ask you explicitly
4. Offer the user the preview of the commit message and wait for confirmation before committing it

Never push the commit unless the user asks for it explicitly.
