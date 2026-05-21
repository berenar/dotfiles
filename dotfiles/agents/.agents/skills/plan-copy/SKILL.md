---
name: plan-copy
description: Copy the last plan from the conversation into the clipboard. Use when the user asks to copy a plan, save a plan to clipboard, or wants to share a plan.
allowed-tools: Bash(pbcopy:*)
---

## Task

Find the most recent plan in the current conversation. A plan is typically a structured list of steps, implementation strategy, or design document that was proposed or outlined.

Extract the full plan text and copy it to the clipboard:

```bash
echo "<plan content>" | pbcopy
```

After copying, confirm to the user what was copied and how many lines/steps it contained.
