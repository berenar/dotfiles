## Clean Code

These rules add to the global coding preferences. They do not repeat them:
no comments, early returns, no nested ternaries, descriptive names, SOLID,
`const` only, named imports, no `any`, async/await. Those still apply.

### Scope: no boy scout rule

Apply these rules only to code you write or change for the current task.

- Do not refactor, rename, reformat or delete code outside the task, even when it breaks these rules.
- Exception: if your change makes code dead (you removed its last caller), delete it.
- Exception: if your change makes a comment wrong, fix or delete that comment.
- If you see a real problem outside the scope, mention it in one line at the end. Do not fix it.
- When the existing file uses a different convention, follow the file, not this skill.

When reviewing, report violations in the diff only. Pre-existing code is not part of the review.

### Names

- Choose names at the abstraction level of the caller: `getUserDirectory()`, not `getMapOfUserIdsToNames()`.
- Use domain terms and pattern names (`Factory`, `Repository`, `amortization`) when they fit.
- Make names unambiguous: `renameFile(oldPath, newPath)`, not `rename(source, target)`.
- Match name length to scope. One letter is fine in a short callback. Module-level names are long and specific.
- No encodings: no Hungarian notation (`strName`, `arrUsers`), no `I` prefix on interfaces.
- Name side effects: a function that creates when missing is `getOrCreateConfig`, not `getConfig`.
- Function names say what the function does. If the name needs "and", split the function.

### Functions

- Maximum 3 parameters. Use a typed object for more. The same applies to React component props spread over many loose values.
- No boolean flag parameters (`render(isTest)`). Write two functions instead.
- No selector parameters (enums or strings that pick a code path). Same fix.
- Do not mutate parameters. Return a new value.
- One thing per function. If you can extract a function with a meaningful name, the function does more than one thing.
- One level of abstraction per function. Do not mix high-level steps with low-level string or index work.
- Do not extract a helper for a one-line expression used once. Inline it.

### Structure

- DRY: one source of truth for each piece of knowledge. Do not copy logic between branches or files. Before you write a helper, search for an existing one.
- No magic numbers or strings. Use a named constant, an `as const` object, or a string literal union.
- Use explanatory variables to name parts of a complex expression.
- Encapsulate conditionals: `if (isEligibleForRefund(order))`, not a long inline boolean.
- Prefer positive conditionals: `isEnabled`, not `!isDisabled`.
- Branching on a type tag that grows: use a discriminated union with an exhaustive `switch` (`never` check), or a lookup `Record`. Use classes and polymorphism only when the codebase already uses them.
- Law of Demeter: do not reach through collaborators (`order.customer.account.billing.charge()`). Plain data access (`config.db.host`) is fine.
- Declare variables near their first use.
- Keep the public surface small. Export only what other modules use.
- Make temporal coupling explicit: when step B needs the result of step A, pass that result to B.
- Put config and constants at a high level. Pass them down. Do not read env vars deep inside logic.
- Code goes where a reader expects it. No feature envy: a function that mostly uses another module's data belongs in that module.
- Handle boundary conditions: empty arrays, `null`/`undefined`, zero, off-by-one. Put a boundary calculation in one named variable, not repeated `+ 1`/`- 1`.
- Do not disable safeties: no `@ts-ignore`, `eslint-disable`, `!` non-null assertions or skipped tests to make something pass.
- Be precise: no floats for money, handle the rejected promise, handle concurrency where it can happen.
- No clever code. Bit tricks and dense one-liners get a named function or a plain version.
- No commented-out code, no TODO banners, no dead code that you created.
- Type public interfaces explicitly: exported functions get explicit parameter and return types.

### Tests

These add to the `testing` skill.

- Test what can break, not only the happy path. Cover boundaries: empty input, zero, first and last item, one past the end, invalid input.
- When you fix a bug, add tests for the similar cases near it. Bugs cluster.
- One concept per test. Several asserts are fine when they check the same concept.
- Tests are fast, independent, repeatable and self-validating. Unit tests do not hit a real network or database.
- No `.only` in committed code. No `.skip` without a reason in the test name.
- If code is hard to test, report it as a design problem. Do not force the test with heavy mocks of internals.
