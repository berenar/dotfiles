# OpenCode Agent Instructions

This document consolidates all instructions and preferences for assisting users with OpenCode. Please refer to the relevant sections below for detailed guidelines. Assume these rules can be broken if the user explicitly requests otherwise.

## Responding to user prompts

Never use emojis in your responses.
Don't be overly verbose; keep responses concise and to the point.
Don't be overly formal.

## Plan Mode

Make the plan extremely concise. Sacrifice grammar for the sake of concision.
At the end of each plan, give me a list of unresolved questions to answer, if any.

## Build Mode

Important: never commit or push anything.

## Coding Preferences

### General

Do not add code comments, the code should be self-explanatory.
Avoid nested ternary operators, except for very simple one-level ternary operators, use IF ELSE instead.
Avoid using complex if else flows, use `if` only on one level and early `return` to avoid nesting.
Use descriptive variable and function names
Use built-in modules and avoid external dependencies where possible
Ask the user if you require any additional dependencies before adding them

Follow the SOLID principles when coding:

- Single Responsibility Principle: Each class or module should have one and only one reason to change.
- Open/Closed Principle: Software should be open for extension but closed for modification.
- Liskov Substitution Principle: Subclasses must be usable in place of their base classes without altering correctness.
- Interface Segregation Principle: Prefer many small, specific interfaces over a single, large, general one.
- Dependency Inversion Principle: High-level modules should not depend on low-level modules; both should depend on abstractions.

### TypeScript and JavaScript

Prefer async/await to promise/then.
Prefer `import` than using "require(something)".
Prefer named imports, avoid default imports if possible.
Don't use `any`, try to use the correct type, use `unknown` as last resource.
Don't use `let`, prefer using `const`.

### Testing

Always check existing tests before creating one.
Never delete an existing test to make them pass. If you find a unnecessary test, ask the user first before deleting it.
If you are trying to fix a specific test, run the specific test file to verify, instead of running the whole test suite (saves time). After the specific test passes, run the whole suite to verify nothing else is broken.
When asked to test something, it's not expected that you change any code files to make the tests pass. If you think you found a bug that prevents the tests form passing, report it instead of fixing it.

## Git Commit Workflow

The commit message should say why this change was done, if not obvious.
Don't add commit description
Commits should be small, but not 1 file per commit. Group them by scope and logically. The changes should make sense together.
Check first the repository history to know which commit style does it use and follow it.
Remember to follow conventional commits/add the ticket ID if this repository uses that.

## Identity

I'm a senior software developer working in MVST Gmbh.
I have experience mainly in: TypeScript, Javascript, Node, Python, AWS, Docker, Terraform, React, Next.JS, Postgres
I live in Mallorca, Spain
I speak English, Spanish and Catalan

### My Environment

macos tahoe, zsh, neovim, kitty, OrbStack, Arc Browser, pnpm/yarn/npm, git, Github

## External links

When the user sends a link to a tool or service, use the following methods to fetch its contents:

- Linear (https://linear.app/*): Use the Linear MCP, if not available in the current session, ask the user to enable it first, then retry.
- GitHub (https://github.com/*): Use the GitHub CLI (`gh`) for everything. Use `gh --help` to check available commands if needed.
- GitLab: There's nothing configured for it, so try with WebFetch in case the link is public. But for private repos, the user will need to provide the content directly.
- Notion (https://www.notion.so/*): Use the Notion MCP, if not available in the current session, ask the user to enable it first, then retry.
- Sentry

## Tooling Preferences

### Make

If the repository contains a Makefile, prefer using `make` commands instead of `npm` or `yarn` scripts.
Use `make help` to check the repository make commands. Use the `package.json` scripts as fallback.

### Code Snippet Sharing

When your answer contains a single code snippet that's likely to be run by the user and not something you already changed on a file, copy it to my clipboard:
`echo "<the code snippet>" | pbcopy`

### File Deletion

Don't use `rm` to delete files or directories, use `trash` instead. It's safer and it allows restoring.

### Docker

If you ever get an error like `Cannot connect to the Docker daemon at ... run/docker.sock. Is the docker daemon running?`,
you can run `open -a OrbStack` to start the Docker daemon (I'm using OrbStack on macOS).
