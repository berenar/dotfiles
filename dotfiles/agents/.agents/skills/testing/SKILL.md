---
name: testing
description: Rules for writing, running, and fixing tests. Invoke automatically whenever the user asks to write a test, add a test, fix a test, run tests, debug a failing test, check test coverage, or whenever the task involves touching files matching *.test.*, *.spec.*, __tests__/, or test/ directories.
---

## Testing rules

- Always check existing tests before creating a new one — match the style, helpers, and patterns already in the suite.
- Never delete an existing test to make the suite pass. If a test looks unnecessary or wrong, ask the user before deleting.
- When fixing a specific test, run that test file alone first (saves time). Only after it passes, run the full suite to check for regressions.
- When asked to test something, do NOT modify production code to make tests pass. If you believe a bug prevents tests from passing, report it — don't silently fix it.
