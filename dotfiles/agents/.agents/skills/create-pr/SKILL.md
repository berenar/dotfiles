---
name: create-pr
description: Create, open, or draft a concise GitHub pull request (PR / MR) with gh pr create, following the repo's PR conventions and PR template.
allowed-tools: Bash(gh pr:*) Bash(gh repo:*) Bash(git status:*) Bash(git diff:*) Bash(git log:*) Bash(git branch:*) Bash(git push:*)
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
2. If a PR template exists, use it as the body scaffold. Keep required headings, fields, and checklist items.
3. Draft a title:
   - Under 70 characters.
   - Don't restate the branch name.
   - Match repo style (conventional commits / ticket prefix / etc.).
4. Draft the body:
   - Write like a human: short, specific, and not over-explained.
   - Target 2-6 total filled-in lines or bullets unless the template requires more.
   - If a template exists, fill required sections tersely, delete placeholder guidance, and write `N/A` only for required sections that do not apply.
   - If no template exists, use `## Summary` with 1-2 bullets and add `## Testing` only when it adds real value.
   - Avoid file-by-file changelogs, implementation diaries, and generic validation claims.
   - Link the ticket if the repo references one.
5. Preview the title and body to the user. Wait for explicit confirmation before running `gh pr create`.
6. Pass the body via HEREDOC to preserve formatting:
   ```
   gh pr create --title "..." --body "$(cat <<'EOF'
   ## Summary
   - ...
   EOF
   )"
   ```
7. If the branch has no upstream, push with `-u` first (also requires user confirmation).

## Rules

- NEVER add `🤖 Generated with Claude Code` or any Claude/AI attribution to the PR body.
- NEVER run `gh pr create` or `git push` without explicit user confirmation.
- NEVER force-push to a shared branch without explicit user confirmation.
