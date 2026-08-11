---
name: test-or-code
description: Adjudicates a failing test — decides whether the test is wrong, the code is wrong, both, or neither (flake/environment) — using evidence independent of both artifacts. Report-only, never edits. Use before changing a failing test's assertions, expected values, selectors, timeouts or retries; before changing production code just to turn a test green; when e2e or unit tests fail on a PR or in CI; when the user asks "is the test wrong or is it a real bug?"; and as a double-check on any already-proposed fix to a failing test.
---

# Test or Code

A failing test is a **disagreement between two artifacts**. Neither is the authority. You cannot settle it by reading them harder — you settle it by finding a third source that says what the behaviour is supposed to be.

**Hard rule: this skill changes nothing.** No edits, no "let me just try". Read, run, reason, report, stop. The user decides the fix.

Works for any test type — e2e, integration, unit. Detect the stack from the repo and the conversation.

## Phase 1 — State the delta precisely

One sentence: which assertion, expected X, got Y, at `file:line`. Quote the actual failure output; never work from a paraphrase.

- If it's a timeout or crash rather than an assertion, name the last step that succeeded and the first that didn't.
- E2e failures surface far from their cause. The failing line is a **symptom location**, not the fault location.
- If you can't state the delta in one sentence, you don't have the failure yet — go get the report, trace, screenshot, or log.

## Phase 2 — Find the third source

In order. Stop at the first that actually speaks to this behaviour.

1. **Intent artifacts** — the ticket/PR this branch implements, acceptance criteria, ADRs, API schema or type contract, design docs, copy/translations.
2. **The test's own stated contract** — its name and enclosing `describe` blocks. A test called "rejects an invalid email" that asserts a 200 has drifted from its own intent; one of the two is a lie.
3. **Sibling consistency** — other tests of the same behaviour, other call sites of the changed function, the same flow elsewhere in the app. Code that contradicts five siblings is the outlier.
4. **Observed reality** — drive the real app or endpoint. This shows what *is*, never what *should be*. Use it to confirm the delta is real, not to pick a winner.

**If no third source exists, say so explicitly.** The verdict is then "likely" at best. Never manufacture authority for whichever artifact is easier to change.

## Phase 3 — Timeline

Cheap and often decisive.

- `git log -p` on both the test file and the implicated source. What changed, when, and in **this** branch?
- Did this test pass on the merge base? Check out the base (or a worktree) and run it.
- Old test passing on main + code changed in this branch → **burden of proof is on the code**.
- Test added or edited in this branch → **burden of proof is on the test**.
- Both changed here: read commit order. A test edited *after* the failure appeared is a fix-it-to-pass smell.

## Phase 4 — Rule out the other two answers

Do this **before** picking a side.

**Neither (flake / environment).** Re-run the spec alone; re-run 5–10×; run isolated vs in-suite. Passing alone but failing in-suite is state leakage, not a logic bug. Check: shared fixtures, leftover seed data, time/timezone/locale, test ordering, races with animation or network, CI-only resources and secrets.

**Both.** Happens when the test was written *from* the implementation: it asserts the wrong thing about code that is also broken. Suspect this when the test and the code arrived in the same commit and mirror each other's structure.

## Phase 5 — Argue both sides

Mandatory. Write the strongest case for "the test is wrong" **and** the strongest case for "the code is wrong", each citing specific evidence from Phases 2–3. Then state which case you could not refute. Skipping the side you don't believe is how the real bug gets shipped.

### The code is probably wrong when

- The test encodes a requirement traceable to a spec, ticket or contract, and the code doesn't meet it.
- The proposed fix is to change the expected value to whatever the code just produced.
- The proposed fix is a longer timeout, an added wait, or a retry — those hide slow queries, missing loading states, and real races.
- Fixing it requires weakening the assertion: `toContain` for `toEqual`, dropping a field, soft assertions, `.skip`.
- It fails only on edge inputs — empty, null, unicode, boundaries, concurrency. Those are exactly the tests that catch real bugs.
- Other tests or call sites agree with the test, not the code.
- It reproduces when you drive the real app by hand.

### The test is probably wrong when

- The intended behaviour changed deliberately in this branch and the ticket says so; the test still encodes the old contract.
- It asserts implementation detail: internal call counts, DOM structure, ordering never guaranteed, private state.
- It depends on what it never controlled: real dates, live network, random ids, unordered query results, hardcoded seed data.
- A selector, route or factory is stale after a legitimate rename.
- Its name contradicts its assertion.
- It was written from the implementation — it proves the code does what it does, not what it should.

## Phase 6 — Report and stop

```
Verdict:        CODE IS WRONG | TEST IS WRONG | BOTH | NEITHER (flake/env)
Confidence:     high | medium | low
Delta:          expected X, got Y — file:line
Source of truth: <what it was, quoted or linked> | NONE FOUND
Evidence:       <2-4 bullets>
Counter-case:   <the strongest argument for the other side, and why it fails>
Proposed fix:   <one specific change, in the artifact the verdict blames>
```

End with: nothing has been changed — confirm the direction and I'll implement it.

If confidence is low, or no third source was found, present both options and ask. Do not choose for the user.
