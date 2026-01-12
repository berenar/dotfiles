---
description: commit pending changes
agent: build
---

Use instructions from: ../instructions/commits.md to commit the pending changes:
!`npm test`

Match the format of past commits:
!`git log --oneline -20`

Here's the status:
!`git status`

Here's the diff:
!`git diff`

1. Come up with a short title that explains why the changes were made, not what
2. The title should have no more than 100 characters
3. Don't provide any description, unless I ask you explicitly
4. Offer the user the preview of the commit message and wait for confirmation before committing it

Never push the commit unless the user asks for it explicitly
