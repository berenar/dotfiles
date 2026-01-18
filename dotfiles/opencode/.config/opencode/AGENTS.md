# OpenCode Agent Instructions

This document consolidates all instructions and preferences for assisting users with OpenCode. Please refer to the relevant sections below for detailed guidelines.

---

## Plan Mode

- Make the plan extremely concise. Sacrifice grammar for the sake of concision.
- At the end of each plan, give me a list of unresolved questions to answer, if any.

---

## General Coding Preferences

If I don't specify it, assume I want a Typescript answer.
Do not add code comments, the code should be self-explanatory
Except for very simple one-level ternary operators, avoid nested ternary operators, use IF ELSE instead.
Avoid using complex if else flows, use if only on one level and early return to avoid nesting.
Keep the code simple and maintainable
Use descriptive variable and function names
Use built-in modules and avoid external dependencies where possible
Ask the user if you require any additional dependencies before adding them

Follow the SOLID principles when coding:

- Single Responsibility Principle: Each class or module should have one and only one reason to change.
- Open/Closed Principle: Software should be open for extension but closed for modification.
- Liskov Substitution Principle: Subclasses must be usable in place of their base classes without altering correctness.
- Interface Segregation Principle: Prefer many small, specific interfaces over a single, large, general one.
- Dependency Inversion Principle: High-level modules should not depend on low-level modules; both should depend on abstractions.

---

## TypeScript and JavaScript Preferences

I prefer async/await to promise/then.
I prefer `import` than using "require(something)".
I prefer named imports, avoid default imports if possible.
In Typescript, don't use `any`, try to use the correct type, and use `unknown` as last resource.
Don't use `let` if you can use `const`.

---

## Git Commit Workflow

Important! On Build mode, never ever commit anything, unless I explicitly ask for it.

- Don't add description of your changes to the commit
- The commit message should say why this change was done, if not obvious.
- Commits should be small, but not 1 file per commit. Group them by scope and logically. The changes should make sense together.
- Check first the repository history to know which commit style does it use and follow it.
- Remember to follow conventional commits/add the ticket ID if this repository uses that.
- The ticket ID can be found in the current git branch name.

---

## Identity and Environment

I'm a senior software developer working in MVST Gmbh.
I have 6 years of experience in software development, mainly in Typescript.
I have experience in: TypeScript, Javascript, Node, Python, AWS, Docker, Terraform, React, Next.JS, Postgres
I live in Mallorca, Spain
I speak English, Spanish and Catalan

### My Environment

- macOS Tahoe 26
- brew as package manager
- zsh as shell
- neovim as code editor
- kitty as terminal emulator
- OrbStack as Docker
- Arc as my default browser
- pnpm, yarn and npm as package managers (depends on the project)
- git for version control
- Github as git hosting service

---

## Response Preferences

When responding to user queries, please adhere to the following preferences:

- Never ever use emojis in your responses, unless explicitly requested by the user.
- Don't be overly verbose; keep responses concise and to the point.
- Don't be overly formal.

---

## Testing

Always check existing tests before creating one.
Never delete an existing test to make them pass. If you find a unnecessary test, ask the user first before deleting it.
If you are trying to fix a specific test, run the specific test file to verify, instead of running the whole test suite (saves time). After the specific test passes, run the whole suite to verify nothing else is broken.
When asked to test something, it's not expected that you change any code files to make the tests pass. If you think you found a bug that prevents the tests form passing, report it instead of fixing it.

---

## Tool Use

When the user sends a link to a tool or service, use the following methods to fetch its contents:

- Linear (https://linear.app/*): Use the Linear MCP, if not available in the current session, ask the user to enable it first, then retry.
- GitHub (https://github.com/*): Use the GitHub CLI (`gh`) for everything. Use `gh --help` to check available commands if needed.
- GitLab: There's nothing configured for it, so try with WebFetch in case the link is public. But for private repos, the user will need to provide the content directly.
- Notion (https://www.notion.so/*): Use the Notion MCP, if not available in the current session, ask the user to enable it first, then retry.
- Sentry

---

## Tooling Preferences

### Make

If the repository contains a Makefile, prefer using `make` commands instead of `npm` or `yarn` scripts.
Use `make help` to check the repository make commands. Use the package.json scripts as fallback.

### Code Snippet Sharing

When your answer contains a single code snippet that's likely to be run by the user and not something you already changed on a file, copy it to my clipboard:
`echo "<the code snippet>" | pbcopy`

### File Deletion

Except for `node_modules` and any other project dependencies, prefer using `trash` instead of `rm`. It's safer and it allows to restore from the trash if you need to recover anything.

### Docker

If you ever get an error like `Cannot connect to the Docker daemon at ... run/docker.sock. Is the docker daemon running?`,
you can run `open -a OrbStack` to start the Docker daemon (I'm using OrbStack on macOS).
