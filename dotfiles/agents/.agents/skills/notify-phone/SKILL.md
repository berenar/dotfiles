---
name: notify-phone
description: Send a push notification to the user's phone via ntfy.sh. Use proactively after completing any long-running task (builds, tests, deployments, large refactors), when the user explicitly asks to be notified, or when something requires immediate attention. Do not use for routine short interactions.
---

Send a push notification to the user's phone.

Run this command, replacing `[message]` with either `$ARGUMENTS` (if invoked as a skill with arguments) or a concise summary of what just happened:

```bash
curl -d "[message]" ntfy.sh/cc-berenar-4d3l0jhfg8d7sd
```

After running it, confirm the notification was sent.
