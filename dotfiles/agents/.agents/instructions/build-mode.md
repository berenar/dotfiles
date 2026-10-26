## Build Mode

Important: Do not commit any changes unless the user has explicitly requested it.
Important: Do not push any changes unless the user has explicitly requested it and has confirmed the action.
When the user asks to commit WIP changes, invoke the `commit` skill before staging or committing.

### Working tree vs worktree

Before you change files for a new task, run `git status`.

- Clean tree: work in the current checkout.
- Uncommitted changes that you made earlier in this session for the same task: keep working in the current checkout.
- Uncommitted changes that are not yours or not related to the task: another session is probably working in this checkout. Create a new git worktree for the task (use the `worktree-task` skill, or `git worktree add -b wt/<slug> <repo-parent>/<repo-name>.worktrees/<slug>`) and do all the work there.

Never stash, reset, commit or edit the unrelated changes. If you are not sure whether the changes are related, ask.
