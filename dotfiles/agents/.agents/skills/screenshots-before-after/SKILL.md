---
name: screenshots-before-after
description: Capture before/after screenshots (or recordings) of a branch's UI/UX changes by running the base commit and the branch side by side against the same data, then saving paired shots to ~/Downloads. Use when the user asks to screenshot changes before and after, show a branch's visual diff, capture before/after of a PR, or document UI/UX improvements visually. Works for any stack — frontend, backend/API responses, CLI output, etc.
---

# screenshots-before-after

Given a branch (or task id), capture **before** (base commit) and **after** (branch tip)
evidence of each user-visible change, and save the pairs to `~/Downloads/<name>/`.

The core trick: run **both** versions live at the same time against the **same data/state**,
so each change can be captured identically on both — no file-swapping, no stale-state
juggling.

## Inputs & output

- **Target**: a branch name (default: current branch) or a task id.
- **Output folder**: `~/Downloads/<name>/` where `<name>` is the task id if known, else the
  branch name with `/` → `-`. Create it fresh. Save as `NN-<slug>-before.png` /
  `NN-<slug>-after.png` (numbered per change).

## Workflow

1. **Resolve target & base.** `after` = branch tip. `base` = `git merge-base <branch> main`.
   Everything the branch changed is `git diff <base>..<branch>`.

2. **Enumerate the changes.** From the commits/diff, list the user-visible changes — one
   before/after pair each. Skip non-visible commits (refactors, internal fixes); note them
   separately instead of capturing them.

3. **Bring up both versions, sharing data.** `after` is usually already running. For `before`,
   check out `base` in a second location (e.g. `git worktree add --detach ../<repo>-before
   <base>`) and start it the way this project normally starts — its own port/instance, but
   pointed at the **same** database/API/services `after` uses, so a given record or request
   looks identical either way. Copy over anything gitignored that the base checkout needs to run
   (`.env`, generated clients) rather than regenerating it. Confirm both are actually serving
   before capturing anything.

4. **Find real test data.** Pick a record or input that actually exercises the changed
   behavior. Reuse the same one for before and after.

5. **Capture each change.** Drive each instance to the exact same state and capture it —
   screenshot for UI, or the equivalent evidence for non-UI changes (a curl response, CLI
   output, log line). Use `agent-browser` for browser work if available, otherwise the
   Playwright MCP. Save both files into the output folder.

6. **Verify every capture.** Read each file back to confirm it shows the intended state —
   automation silently produces blank or wrong-state captures. Re-capture failures.

7. **(Optional) Fan out.** One subagent per change speeds this up, but if they share a single
   browser/instance they must run **sequentially**; only parallelize if each has its own
   session.

8. **Update the PR description.** GitHub has no API/CLI to upload images, so this step is
   manual: ask the user to open the PR description editor and drag-and-drop the files in order
   — `01-*-before`, `01-*-after`, `02-*-before`, `02-*-after`, ... — then save. Once the user
   confirms it's saved, fetch the resulting body with `gh pr view <number> --json body -q
   .body` and pull out the uploaded image entries (`https://github.com/user-attachments/...`)
   in the order they appear — that upload is the only way to get a referenceable URL for each
   image. Pair them two at a time against the change list from step 2, and for each write:

   ```
   ### <change title>
   <one-line description of what changed>

   | Before | After |
   | --- | --- |
   | <img width="500" alt="<slug>-before" src="..."> | <img width="500" alt="<slug>-after" src="..."> |
   ```

   Every repo's PR template (or lack of one) is different, so don't impose a fixed structure —
   fit these sections into whatever's already there: under an existing "Changes"/"Screenshots"
   heading if the template has one, otherwise appended near the top, above any checklist/type
   boilerplate. See a
   [real example](https://github.com/kartenmacherei/dobby-backend/pull/2221) of the target
   shape. Push the result with `gh pr edit <number> --body-file <file>`, replacing only the raw
   dropped-in image list — leave the rest of the existing description untouched.

## Gotchas

- **Same data on both sides** is the whole point — if `before` hits different/empty state the
  comparison is meaningless. Reuse the running services, don't spin up fresh ones.
- Some changes are backend-gated (e.g. a new route/endpoint): `before` genuinely 404s or
  behaves differently. That *is* the before state — capture it.
- Behavioral changes with no static visual difference (a keyboard shortcut, a timing fix) still
  show a difference in *outcome*. Capture the outcome, and note invisible evidence (e.g. a
  response header, the URL) in the caption.
- Browser automation can only write inside allowed roots — save to a writable path, then move
  files to `~/Downloads/<name>/`.
- Drag-and-drop order is everything for step 8 — GitHub gives no other way to tell which
  upload is which, so a mis-ordered drop pairs the wrong before with the wrong after. Double
  check the extracted URL order against the file list before rewriting the body.

## Cleanup

Tear down the `before` instance and worktree when done. Leave the user's normal dev
environment as you found it.
