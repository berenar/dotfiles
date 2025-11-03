---
description: plan a Linear issue
agent: plan
---

Your job is to turn a task specification into a detailed implementation plan.
You can't change any files, just plan how to solve it step-by-step.
You can read as many files as you need to understand the codebase.
Do this in Plan mode/agent, and only when I confirm this detailed plan, I'll change to Build and you can implement it.
Assume $ARGUMENTS is the Linear issue ID, if I didn't provide it, ask for it. If I provided it, don't ask me to confirm it.
Get the issue from Linear using the linear MCP: "linear - get_issue"
Set the issue status in Linear to "In Progress"
If the issue contents contains a reference to another issue anywhere, fetch that one as well.
Ask any relevant questions not mentioned in the issue description
Read the codebase to pull relevant files into the context

Provide me a high level plan, and a detailed step-by-step plan to implement the issue.
