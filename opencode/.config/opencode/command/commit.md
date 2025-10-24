---
description: commit pending changes
agent: plan
model: github-copilot/gpt-4.1
tools:
  write: false
  edit: false
  bash:
    git: ask
  webfetch: false
---

Use instructions from: ../instructions/commits.md to commit the pending changes:
!`npm test`

1. Come up with a short title that explains why the changes were made, not what
2. The title should have no more than 100 characters
3. Don't provide any description, unless I ask you explicitly
4. Commit it
