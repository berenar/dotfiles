---
name: test-assist
description: Guide the user through manually testing the current branch — start the services it needs, resolve the exact URL (or curl/CLI command) that shows each change, open it, and hand over a checklist of what to click and what should happen. Does not run or write automated tests and does not verify anything itself; a human does the testing. Use when the user asks how to test this branch, wants to try the changes by hand, asks for a QA plan or manual test checklist, says "let me test it" or "how do I check this works", or wants the app running to review a PR.
---

# test-assist

The user wants to *see* the branch's changes working with their own eyes. Do the boring
part for them: get everything running, find the exact place each change shows up, open it,
and give them a short checklist of what to do and what should happen.

You are preparing a manual test, not running one. Don't drive the browser or assert things
yourself unless the user asks — the point is that a human looks at it.

## 1. Work out what changed and why

```bash
git rev-parse --abbrev-ref HEAD
git log --oneline $(git merge-base HEAD main)..HEAD
git diff --stat $(git merge-base HEAD main)..HEAD
git diff $(git merge-base HEAD main)..HEAD
```

Use `master` (or the repo's real default) if there's no `main`. Include uncommitted work
too — `git status` and `git diff` — the user usually wants to test what's on disk.

Then find the **original ask**, because the checklist is built from it, not from the diff:

- the plan or request earlier in this conversation
- the PR description (`gh pr view --json title,body`)
- a linked Linear/GitHub issue — use the `external-links` skill for those URLs
- the commit messages, as a fallback

The diff tells you what to test. The original ask tells you what *should* happen. If the two
disagree — the diff does something the ticket didn't ask for, or skips something it did —
say so before the checklist; that's the most useful thing you can report.

## 2. Get it running

Check what's already up before starting anything. If the dev server is already listening,
reuse it, don't start a second one.

```bash
lsof -iTCP -sTCP:LISTEN -P -n | grep -E 'node|python|docker|ruby'
```

Then, in order:

- **Services**: `docker-compose.yml` / `compose.yaml` → `docker compose up -d`. If Docker
  isn't running: `open -a OrbStack`, wait, retry.
- **Env**: check `.env` exists against `.env.example`. If keys are missing, list them and
  stop — ask the user, never invent values.
- **Deps**: install if the lockfile is newer than `node_modules`, or if the branch touched
  the lockfile. Detect the package manager from the lockfile.
- **Migrations / seeds**: if the branch added migration files, run them. Say what you ran.
- **App**: prefer `make` targets if there's a Makefile (`make help`), else the `dev` script.
  Start it with `run_in_background: true`, log to a file, and poll until it's actually
  serving (or ~60s). If it fails, show the last lines of the log and stop — don't hand over
  a checklist for an app that isn't up.

## 3. Find the exact URL or command

This is the part that saves the user the most time. Don't say "go to the app" — give the
precise thing.

**Frontend.** Map each changed component/page back to a route:

- Next.js app router: `app/(group)/foo/[id]/page.tsx` → `/foo/<id>`
- Next.js pages router: `pages/foo/[id].tsx` → `/foo/<id>`
- A changed shared component: grep for its imports to find which pages render it, and pick
  the one that best shows the change.

If the route needs a real id, **go get one** — query the dev database, hit the list
endpoint, or read the seed/fixture files. A URL with `<id>` in it is a half-finished job.
If a change is behind a flag, login, or a specific role, say which and how to get there.

Then open it: `open "http://localhost:<port>/<path>"`.

**Backend / API.** Give a ready-to-run `curl` per changed endpoint, with a real id and auth
header if needed. Copy the first one to the clipboard with `pbcopy`.

**CLI / script / job.** Give the exact invocation, with real arguments.

**No user-visible surface** (refactor, types, CI): say so plainly. The test is then "the app
still builds and the existing flows still work" — say that instead of inventing clicks.

## 4. Write the checklist

One section per user-visible change, in the order the user would naturally hit them. Each
item is a thing to do and the thing that should happen. Be specific about the expected
result — "the button works" is useless, "the row disappears and a green toast says Deleted"
is testable.

```markdown
## Running

- App: http://localhost:3000 (opened)
- API: http://localhost:4000
- Postgres + Redis via docker compose
- Logs: /path/to/dev.log

## 1. <change title>

http://localhost:3000/orders/8f2c-...

- [ ] Click **Cancel order** → dialog opens asking to confirm
- [ ] Confirm → row moves to *Cancelled*, toast says "Order cancelled"
- [ ] Reload → still cancelled (it persisted, not just local state)
- [ ] Try it on an already-shipped order → button is disabled

## 2. <next change>
...

## Should NOT have changed

- [ ] The orders list still filters and paginates as before
- [ ] Existing exports still download

## Not covered here

- <thing that needs staging data / a real payment / another env>
```

Rules for the checklist:

- Cover the happy path first, then the edge cases the diff actually handles (empty state,
  error branch, permissions, loading). Only list edge cases the code has a path for.
- Add a **Should NOT have changed** section for whatever the diff came close to breaking —
  shared components, changed queries, modified helpers. This is where regressions hide.
- Be honest in **Not covered here** about anything you can't set up locally.
- Keep it short enough to actually run. If it's over ~15 items, the branch is doing too
  much and you should say that.

## 5. Hand it over

Tell the user, in a few lines:

- what's running and where the logs are
- the URL you opened
- the checklist (in the response — also write it to a file if it's long)
- how to stop everything (`docker compose down`, killing the bg server)

Then offer, without doing it: to walk through it with them, to check items yourself with
`agent-browser`, or to fix whatever fails. Leave their environment as you found it when
they're done.
