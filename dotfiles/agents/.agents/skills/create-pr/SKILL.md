---
name: create-pr
description: Create a concise draft GitHub pull request (PR / MR), then monitor its CI and fix failures caused by the branch.
---

## Repository context

Current branch and status:
!`git status -sb`

Commits ahead of main:
!`git log --oneline origin/HEAD..HEAD 2>/dev/null || git log --oneline main..HEAD 2>/dev/null || git log --oneline -10`

Recent merged PRs (for title/body convention):
!`gh pr list --state merged --limit 2 2>/dev/null || echo "gh not available or not a GitHub repo"`

PR template (if any):
!`find . -maxdepth 3 \( -path ./node_modules -o -path ./.git \) -prune -o -iname 'pull_request_template*' -print 2>/dev/null | head -5`

## Task

1. Inspect the recent merged PRs above to match this repo's title and body conventions (conventional commits prefix, ticket ID, etc.).
2. Find the Linear ticket for this branch, in this order: the ticket ID or URL in the conversation, the branch name (Linear branches look like `berenar/abc-123-some-title`), then the commit messages. If you find one, fetch it with the Linear MCP (`get_issue`) to read its real title. Don't guess the title from the branch slug.
3. If a PR template exists, use it as the body scaffold. Keep required headings, fields, and checklist items.
4. Draft a title:
   - If there's a Linear ticket, use its title verbatim, or very close to it. This is the default and it almost always wins.
   - Only deviate when the ticket title doesn't fit the PR: it's over 70 characters, the branch implements one part of a bigger ticket, or the work ended up different from what the ticket says. Then adapt it minimally and keep the ticket's wording.
   - No Linear ticket: name the symptom fixed or the behavior changed, as described in Writing style.
   - Under 70 characters.
   - Don't restate the branch name.
   - Match repo style (conventional commits / ticket prefix / etc.). Prefix or suffix the ticket ID only if merged PRs in this repo do it.
5. Draft the body following the Writing style section below:
   - Write like a human: short, specific, and not over-explained.
   - Default to as short as possible. Target 1-3 total filled-in lines or bullets unless the template requires more or the change warrants the bug-fix structure from Writing style.
   - If a template exists, fill required sections tersely, delete placeholder guidance, and write `N/A` only for required sections that do not apply.
   - If no template exists, use `## Summary` with 1 bullet (2 only if the change genuinely has two distinct parts).
   - Don't mention tests: no tests added or removed, test files, test counts, test results or test helpers. If the template has test checklist items, tick or leave them as the template wrote them, with no extra detail.
   - Avoid file-by-file changelogs, implementation diaries, and generic validation claims.
   - Link the Linear ticket (full URL) if there is one, or if the repo references tickets in its PRs.
6. Preview the title and body to the user. Ask for explicit confirmation to create the draft PR, push the branch if needed, and commit and push scoped CI fixes on that PR branch. Only include the CI fix authorization if the user wants automatic repairs. Wait for confirmation before creating or pushing anything.
7. Pass the body via HEREDOC to preserve formatting:
   ```
   gh pr create --draft --title "..." --body "$(cat <<'EOF'
   ## Summary
   - ...
   EOF
   )"
   ```
8. If the branch has no upstream, push with `-u` first under the confirmation from step 6.
9. After the PR is created, open it in the browser with `gh pr view --web` and record the PR URL.
10. Watch the checks for the PR's current head commit with `gh pr checks <PR URL> --watch`. If checks have not appeared yet, poll until they do. Stop watching after 30 minutes per head and report checks that remain pending. Distinguish failed, cancelled, skipped, and missing checks; do not treat the absence of checks as a pass.
11. For failed checks, inspect their links and logs (for GitHub Actions, `gh run view <run-id> --log-failed`). Confirm the failure belongs to the current head and is caused by this branch. Reproduce it locally when practical, fix the cause, and run the relevant local checks. Do not weaken assertions or skip checks just to get green CI. Leave unrelated working-tree changes alone.
12. If step 6 authorized CI fix commits and pushes, make a scoped commit and push it to the same PR branch, then watch the new head's checks. Repeat for at most three repair pushes. If that authorization was not given, keep the fix local and report what is ready to commit and push.
13. Stop and report the PR URL, latest head, check results, and remaining failure when a check needs secrets, permissions, an external service, or a change outside this PR's scope; when the cause is unclear; or when the repair or watch limit is reached. Do not merge or mark the draft ready.

## Writing style

Write for a reviewer who skims and doesn't know the internals of the change.

- Plain words over jargon. If a technical term isn't needed to act on the PR, replace it with what actually happens: "the test waits on a spinner that is already gone from the page", not "deadlocks on a detached subtree". Terms to avoid unless essential: deadlock, race window, macrotask/microtask, vacuous, detached, structurally, idempotent, invariant.
- Short sentences, one idea each. Break dense cause-and-effect paragraphs into 2-4 bullets that read in order: what happens, then what that causes, then why it fails.
- With a Linear ticket, the ticket title is the title. Reuse the team's wording instead of inventing your own.
- Without one, the title names the symptom fixed or the behavior changed, in words the whole team recognizes ("fix flaky add-to-cart spinner wait"), not the mechanism ("fix wait deadlocking on detached spinner").
- When library or framework internals matter, explain them in one plain sentence ("it remembers the element's parent and keeps checking if it still contains it - the answer stays yes forever"). Never narrate implementation code.
- Scale the body to the change:
  - Routine change: Summary with 1 bullet, nothing else.
  - Bug fix, flaky-test fix, or anything a reviewer might doubt: use sections `What was wrong`, `The fix`, `Evidence` - but keep each to 1 line, and drop any section that doesn't add information the reviewer needs.
- Keep hard facts verbatim, they are not jargon: exact error messages in code blocks, CI run IDs and dates (a table works well), commit hashes.
- Show minimal before/after code snippets when the fix changes a code pattern.
- Say what was deliberately left unchanged and why, in one plain sentence.
- If a root cause was proven (e.g. a deterministic repro), describe the proof in one or two sentences: what was done, what the old code did, what the new code did.
- Prefer concrete subjects: "the test", "the helper", "React" - not "the logic", "the flow", "the mechanism".

## Rules

- NEVER add `🤖 Generated with Claude Code` or any Claude/AI attribution to the PR body.
- NEVER describe tests in the PR body. The diff shows them, and reviewers don't need them summarised.
- NEVER run `gh pr create`, `git commit`, or `git push` without explicit user confirmation covering that action. Confirmation for the scoped CI repair loop can be given once in step 6.
- NEVER force-push to a shared branch without explicit user confirmation.
