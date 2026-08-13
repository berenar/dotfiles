---
name: scout
description: Send a cheap read-only subagent (Haiku by default) to explore the codebase and report back only file paths, line ranges and a one-line reason each — so the expensive main session learns what to read without burning its own context exploring. Use when the user says "scout", "go find where X is", "gather context on X", "which files handle X", or before planning/implementing in an unfamiliar area of the code.
argument-hint: "What are you looking for?"
---

## Goal

Keep exploration tokens out of the expensive session. A cheap subagent does the grepping and
skimming; it returns a **map** (paths, line ranges, one-line reasons), not code. The main session
then reads only the files that matter.

The output is a map, never a substitute for reading. Never act on a scout report alone.

## 1. Sharpen the question

Turn the request into a concrete search target: a behaviour, symbol, flow, config, or convention.
Only ask the user for clarification if two readings would send the scout to completely different
parts of the codebase. Otherwise pick the most likely reading and say which one you assumed.

## 2. Pick the model

Default to `haiku` — that's the whole point. State the choice in one line, don't ask.

Escalate to `sonnet` only when the search genuinely needs judgement rather than grep:

- the target is a concept with no obvious keyword ("where does the retry policy actually live")
- a previous haiku scout came back empty or clearly wrong
- the codebase is a large monorepo where picking the right package is itself the hard part

## 3. Split into scouts

One scout per **independent search angle**, max 4, all dispatched in a single message so they run
concurrently. Angles are things like: the API/route layer, the data model, the UI surface, the
tests, the config/infra. Do not split the same angle across scouts — they'll return duplicates.

If it's a single narrow question, one scout is correct. Don't fan out for the sake of it.

- Claude Code: `Agent` tool, `subagent_type: Explore` (read-only by construction), `model: haiku`.
  Fall back to `general-purpose` if `Explore` isn't available.
- OpenCode: `@general` subagents.

## 4. The brief

Give each scout the target, the repo area to start from if you know it, and this output contract
verbatim:

> You are gathering context for another agent. You are **not** solving the problem.
>
> Report back, in this order:
>
> 1. **Start here** — 1-3 files to read first, with a line range each.
> 2. **Relevant files** — max 15, ranked by relevance. Format: `path/to/file.ts:120-180` followed
>    by at most one line explaining what's there.
> 3. **Vocabulary** — the actual names this codebase uses for the concept (types, functions,
>    env vars, table names, routes).
> 4. **Dead ends** — what you searched that turned out to be irrelevant, so nobody repeats it.
>
> Hard rules:
>
> - Do not paste code. Quote at most 3 lines total, and only if a line is the answer itself.
> - Do not propose a plan, a fix, a refactor, or an opinion on code quality.
> - Do not edit anything.
> - If you can't find it, say "not found" and list where you looked. Never guess a path.
> - Prefer precision over coverage: 5 correct files beat 15 speculative ones.

## 5. Synthesise

Merge the reports: dedupe overlapping paths, drop anything a scout flagged as low confidence,
and re-rank across angles. Present to the user as a compact list of `path:lines — why`, plus the
vocabulary the codebase uses and any dead ends worth remembering.

Then read the top files yourself before doing any work on them. Scout reports point; they don't
prove.

## When not to use this

- You already know the file — just open it.
- The answer is one symbol lookup — grep is cheaper than a subagent.
- The task is to review, audit, or judge code — that needs the expensive model reading the real
  thing, not a map of it.
