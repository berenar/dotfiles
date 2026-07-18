---
name: challenge-this
description: Spawn a fresh subagent, in an unbiased context with no memory of the current conversation, to adversarially challenge the current plan, approach, or facts under discussion — then report back what holds up and what doesn't. Asks the user which model and reasoning effort to use for the challenger, recommending a more capable model than the current session. Use when the user wants a second opinion, wants to stress-test a plan with a sharper/independent reviewer, says "challenge this", "poke holes in this", "play devil's advocate", or wants an adversarial review.
allowed-tools: Agent, AskUserQuestion
---

## Goal

Get an unbiased, adversarial second opinion on the plan/approach/facts currently under
discussion, from a subagent that has no memory of how the current session arrived at them.

## 1. Determine the current model

Read it from your own self-description in the system context (the "You are powered by the
model named X" line). This is the only model-introspection mechanism available.

## 2. Compute the recommended model

Always recommend one tier more capable than the current session:

- haiku → recommend sonnet
- sonnet → recommend opus
- opus → recommend fable
- fable → recommend fable (already the top tier — no more capable model exists; still worth a
  fresh, bias-free look)

## 3. Ask which model to use

Call `AskUserQuestion` with one question, four options — one per model tier (`haiku`, `sonnet`,
`opus`, `fable`). Put the tier computed in step 2 first, labeled "(Recommended)", with a
description explaining it's one capability tier above the current session (or, in the
fable-already-top-tier case, that it's the same tier but still a fresh unbiased look).

## 4. Ask which reasoning effort to use

Call `AskUserQuestion` with one question, four options: `medium`, `high`, `xhigh`, `max`.
Recommend `xhigh` as the balance of rigor and turnaround for an adversarial review. (`low` is
deliberately not offered — too shallow to produce a useful challenge.)

The `Agent` tool has no direct effort parameter, so translate the chosen tier into an explicit
instruction embedded in the subagent's prompt (step 6), e.g.:

- `max` → "Reason exhaustively. Consider multiple angles before concluding anything."
- `xhigh` → "Reason carefully and thoroughly before concluding."
- `high` → "Think it through properly, but don't over-deliberate."
- `medium` → "Give a direct, focused pass without excessive deliberation."

## 5. Compose a neutral brief

Write a self-contained summary of the plan/approach/facts currently under discussion: the goal,
constraints, and the proposed approach with its key decisions — stated as plain facts. Do NOT
include the reasoning or justification the current session used to arrive at them, and do NOT
frame it as already decided or approved. This is what keeps the subagent unbiased instead of
just re-validating prior reasoning.

## 6. Spawn the challenger

Use the `Agent` tool with `subagent_type: general-purpose` — never `fork`, since a fork always
inherits the parent's full conversation *and* runs on the parent's model regardless of any
`model` override, which would defeat the point here.

- `subagent_type`: `general-purpose`
- `model`: the tier the user picked in step 3
- `description`: short, e.g. "Challenge the migration plan"
- `prompt`: the neutral brief from step 5, the effort instruction from step 4, and explicit
  adversarial instructions:
  - Find flawed assumptions, weak points, missing edge cases, factual errors, and viable
    alternative approaches.
  - Also note what's genuinely solid — this isn't a demand to find fault where none exists.
  - Respond in a structured way: strengths / weaknesses / risks / alternatives worth considering.

## 7. Report back

Present the subagent's findings to the user under clear **Good** / **Bad** headers (plus
risks/alternatives if surfaced), naming which model and effort produced the review. If the user
picked the same tier as the current session (including the fable-already-top-tier case), say so
plainly — "reviewed at the same tier — a fresh look rather than a more capable one."
