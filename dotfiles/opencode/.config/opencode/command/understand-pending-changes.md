---
description: check git status and diff to gather context
agent: plan
tools:
  write: false
  edit: false
  bash:
    git: allow
  webfetch: false
---

Check the pending changes in the git repository

!`git branch --show-current`
!`git status`
!`git diff HEAD`

to understand what changes I've done so far
and come up with a summary of the pending changes.
