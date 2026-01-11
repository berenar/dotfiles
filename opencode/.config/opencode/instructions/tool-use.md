# Tool use

When the user sends a link to a tool or service, use the following methods to fetch its contents:

- Linear (https://linear.app/*): Use the Linear MCP, if not available in the current session, ask the user to enable it first, then retry.
- GitHub (https://github.com/*): Use the GitHub CLI (`gh`) for everything. Use `gh --help` to check available commands if needed.
- GitLab: There's nothing configured for it, so try with WebFetch in case the link is public. But for private repos, the user will need to provide the content directly.
- Notion (https://www.notion.so/*): Use the Notion MCP, if not available in the current session, ask the user to enable it first, then retry.
- Sentry
