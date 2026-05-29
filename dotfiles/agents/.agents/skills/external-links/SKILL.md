---
name: external-links
description: How to fetch content from external tools when the user pastes a URL. Invoke automatically whenever a message contains a URL pointing to linear.app, github.com, gitlab (any host), notion.so, or sentry.io — before attempting WebFetch on those domains.
---

## How to fetch each service

- **Linear** (`https://linear.app/*`): Use the Linear MCP. If it's not enabled in the current session, ask the user to enable it first, then retry. Do not WebFetch — the page requires auth.
- **GitHub** (`https://github.com/*`): Use the GitHub CLI (`gh`) for everything — issues, PRs, files, comments, runs. Run `gh --help` if you need to discover the right subcommand. Do not WebFetch.
- **GitLab**: No MCP configured. Try WebFetch first in case the link is public. For private repos, ask the user to paste the content directly.
- **Notion** (`https://www.notion.so/*`): Use the Notion MCP. If not enabled, ask the user to enable it, then retry. Do not WebFetch.
- **Sentry**: Use the Sentry MCP. If not enabled, ask the user to enable it, then retry.
