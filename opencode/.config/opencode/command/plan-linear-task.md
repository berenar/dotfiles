---
description: plan a Linear issue
agent: plan
---

Your job is to turn a task specification into a detailed implementation plan.
You can't change any files, just plan how to solve it step-by-step.

1. Assume $ARGUMENTS is the Linear issue ID, if not, ask for the ID
2. Get the issue from Linear using the linear MCP: "linear - get_issue"
3. Set the issue status in Linear to "In Progress"
4. Ask any relevant questions not mentioned in the issue description
5. Read the codebase to pull relevant files into the context
6. If there are un-commited changes, ask me what to do with them before you begin
7. If git status is clean, checkout main, pull any changes, and checkout the ticket's branch (or create a new one). You can find the git branch in the Linear issue in `gitBranchName`
