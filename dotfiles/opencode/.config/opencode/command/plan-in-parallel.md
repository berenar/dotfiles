---
description: plan list in parallel (subagents)
agent: build
---

$ARGUMENTS is either a list of items, a reference to a list of items (e.g. GitHub PR URL, GitHub PR Comment), or not provided at all. If not provided, take the most recent list from the conversation.

Your job is to investigate each item independently to come up with an actionable plan.

Rules:

1. Create the ./plans/ directory if it doesn't exist.
2. Add a `.gitignore` file with `*` to ignore all files that subagents will add there
3. Create a ./plans/<current-timestamp>/ directory. The <current-timestamp> is !`date +%Y%m%d%H%M%S`
4. Run one @general subagent per item, in parallel.
5. Each subagent may read the codebase as needed to understand the item.
6. Each subagent must only create one file: `./plans/<timestamp>/<n-short-kebab-case-title>.md` where <n> is the item's index. That way the list of plan files will match the list of items order.
7. Do not implement any fix or modify any existing file.
8. If the item is a non-issue, already solved, or not actionable, still create the file and explain why.

Each plan file should include:

- Item (as a reference)
- Verdict
- Why
- Affected files or areas
- Step-by-step plan
- Risks or open questions

After all subagents finish, summarize the generated plan files, and review if any of them would overlap when implemented. If any, suggest how to combine them.
