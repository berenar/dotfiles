---
name: next-and-design-system
description: Rules for Next.js and design-system work. Invoke automatically when editing Next.js code (app/, pages/, route handlers, server/client components, `"use client"`, server actions), when changing styling/colors/borders/backgrounds, when working with design tokens, or when the user mentions ds, design system, tokens, theme, or Tailwind/CSS variables.
---

## Next.js

- If adding a feature requires switching a server component or page to client-side rendering, make the user aware before doing it — most of the time it's not worth the trade-off. Surface the implication explicitly and let them decide.

## Design system

- ALWAYS use design system tokens instead of hardcoded hex/rgb values.
- When styling, distinguish carefully between text color, border color, and background color before editing — they map to different tokens.
- Verify token usage in existing components before introducing new colors. Reuse first; only add a new token if nothing fits.
