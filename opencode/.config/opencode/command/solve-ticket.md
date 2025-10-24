---
description: implement a Linear issue end-to-end
agent: plan
---

1. Assume $ARGUMENTS is the Linear issue ID, if not, ask for the ID
2. Get the issue from Linear using the linear MCP: "linear - get_issue"
3. Set the issue status in Linear to "In Progress"
4. Ask any relevant questions not mentioned in the issue description
5. Show me a high level plan of what you will try to do to fix it or implement it
6. If there are un-commited changes, ask me what to do with them before you begin
7. If git status is clean, checkout main, pull any changes, and checkout the ticket's branch (or create a new one). You can find the git branch in the Linear issue in `gitBranchName`
8. Do your changes in this branch, after doing them and before commiting, lint/format/check the code (check the readme or `make help` on how to do that)
9. Commit regularly at each step along the way.
10. After finishing, create a Pull Request for it
    - Respect any existing PR templates in `.github/pull_request_template.md`
    - Create it as DRAFT
    - Assign me (@berenar) to it
