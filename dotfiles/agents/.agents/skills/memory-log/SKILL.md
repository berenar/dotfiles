---
name: memory-log
description: Answer questions about RAM and memory usage on this Mac from the memlog history (a SQLite db sampled every minute by a LaunchAgent). Use when the user asks which apps or processes use the most memory, why the Mac is slow or swapping, memory pressure, swap, leaks, memory growth over time, what happened at a given time, or anything about RAM usage history. Also use to check, start or stop the memlog recorder.
---

# memory-log

`~/.local/bin/memlog` records one sample per minute into `~/.local/share/memlog/memlog.db`.
The LaunchAgent `com.berenar.memlog` runs it at login and every 60s after.
Samples older than 14 days are deleted (`MEMLOG_RETENTION_DAYS`).
Source: `~/dotfiles/dotfiles/memlog/`.

## Commands

```bash
memlog status            # agent loaded?, sample range, last sample
memlog summary 24        # top 20 apps by avg footprint + swap/pressure over last N hours
memlog sql "SELECT ..."  # read-only query, tab-separated output
```

Start with `memlog status`. If the agent is not loaded, tell the user and offer:

```bash
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.berenar.memlog.plist
```

Errors from the agent go to `~/.local/state/memlog/error.log`.

## Schema

All sizes are bytes. `ts` and `boot_ts` are unix seconds (use `datetime(ts, 'unixepoch', 'localtime')`).

`samples`: one row per minute, whole system.
- `total_bytes`, `free_bytes`, `active_bytes`, `inactive_bytes`, `wired_bytes`, `speculative_bytes`
- `file_backed_bytes` (cache, cheap to drop), `anonymous_bytes` (app memory)
- `compressor_bytes`: RAM the compressor occupies. `compressed_bytes`: data stored in it (before compression).
- `swap_total_bytes`, `swap_used_bytes`
- `pressure_level`: 1 normal, 2 warning, 4 critical (the Activity Monitor pressure graph)
- `free_pct`: "System-wide memory free percentage" from `memory_pressure -Q`
- `pageins`, `pageouts`, `swapins`, `swapouts`: cumulative counters since boot. Use the delta between rows (`LAG`) within the same `boot_ts`.
- `boot_ts`: a change means a reboot. A gap in `ts` greater than about 2 min means sleep or shutdown.
- `process_count`

`processes`: the top 50 processes by footprint per sample.
- `sample_id`, `pid`, `ppid`, `app`, `name`, `footprint_bytes` (the "Memory" column of Activity Monitor), `compressed_bytes`, `rss_bytes`, `cpu_pct`, `command` (full path)

`apps`: all processes grouped by app, top 40 apps per sample.
- `sample_id`, `app`, `footprint_bytes`, `compressed_bytes`, `process_count`

`app` is the outermost `.app` bundle name in the path (all "Google Chrome Helper" processes count as "Google Chrome"). Otherwise it is the binary name. All `WebKit.framework` processes are "WebKit": these are Safari tabs, Mail and other apps that embed web views. The owning app is not known.

## Answering questions

- Prefer `apps` for "which app uses the most". Use `processes` to drill into one app or to follow a single `pid` over time (leak detection).
- An app absent from `apps` in a sample was not in the top 40. Treat it as small, not as zero, and say so if it matters.
- A process missing from `processes` in a sample was not in the top 50 at that moment.
- Footprint includes compressed memory. A large `compressed_bytes` means the app holds memory that it does not touch.
- Signs of real memory trouble: `pressure_level` 2 or 4, swap that grows, and large `swapouts` deltas. High "used" memory alone is normal on macOS.
- Give numbers in GB/MB with local times. Mention the time window and the sample count you used.
- Keep queries bounded by time (`WHERE s.ts >= strftime('%s','now','-24 hours')`).

## Query recipes

Top apps by average and peak footprint, last 24h:

```sql
SELECT a.app, ROUND(AVG(a.footprint_bytes)/1073741824.0, 2) avg_gb, ROUND(MAX(a.footprint_bytes)/1073741824.0, 2) peak_gb
FROM apps a JOIN samples s ON s.id = a.sample_id
WHERE s.ts >= strftime('%s','now','-24 hours')
GROUP BY a.app ORDER BY avg_gb DESC LIMIT 15;
```

Pressure, swap and compressor per hour:

```sql
SELECT strftime('%Y-%m-%d %H:00', ts, 'unixepoch', 'localtime') hour,
       MAX(pressure_level) max_pressure, ROUND(MAX(swap_used_bytes)/1073741824.0, 2) swap_gb,
       ROUND(AVG(compressor_bytes)/1073741824.0, 2) compressor_gb, MIN(free_pct) min_free_pct
FROM samples WHERE ts >= strftime('%s','now','-3 days') GROUP BY hour ORDER BY hour;
```

Swap activity (swapouts per minute) during the same boot:

```sql
SELECT datetime(ts, 'unixepoch', 'localtime') t,
       swapouts - LAG(swapouts) OVER (PARTITION BY boot_ts ORDER BY ts) swapouts_delta
FROM samples WHERE ts >= strftime('%s','now','-6 hours') ORDER BY swapouts_delta DESC LIMIT 10;
```

Leak check: processes whose footprint grew the most during their lifetime:

```sql
WITH p AS (
  SELECT pr.pid, pr.name, pr.app, s.ts, pr.footprint_bytes,
         FIRST_VALUE(pr.footprint_bytes) OVER w first_fp, LAST_VALUE(pr.footprint_bytes) OVER w last_fp,
         MIN(s.ts) OVER w first_ts, MAX(s.ts) OVER w last_ts
  FROM processes pr JOIN samples s ON s.id = pr.sample_id
  WHERE s.ts >= strftime('%s','now','-2 days')
  WINDOW w AS (PARTITION BY s.boot_ts, pr.pid ORDER BY s.ts ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
)
SELECT DISTINCT pid, name, app, ROUND(first_fp/1048576.0) first_mb, ROUND(last_fp/1048576.0) last_mb,
       ROUND((last_fp-first_fp)/1048576.0) growth_mb, ROUND((last_ts-first_ts)/3600.0, 1) hours
FROM p ORDER BY growth_mb DESC LIMIT 10;
```

What used the memory at a given moment (closest sample):

```sql
SELECT a.app, ROUND(a.footprint_bytes/1048576.0) mb, a.process_count
FROM apps a WHERE a.sample_id = (
  SELECT id FROM samples ORDER BY ABS(ts - strftime('%s', '2026-10-15 14:30', 'utc')) LIMIT 1
) ORDER BY mb DESC LIMIT 15;
```

(`strftime('%s', <local time>, 'utc')` converts a local time to unix seconds.)

One app over time, hourly average:

```sql
SELECT strftime('%Y-%m-%d %H:00', s.ts, 'unixepoch', 'localtime') hour, ROUND(AVG(a.footprint_bytes)/1048576.0) avg_mb
FROM apps a JOIN samples s ON s.id = a.sample_id
WHERE a.app = 'Google Chrome' AND s.ts >= strftime('%s','now','-2 days')
GROUP BY hour ORDER BY hour;
```

Reboots and gaps:

```sql
SELECT datetime(ts, 'unixepoch', 'localtime') t, (ts - LAG(ts) OVER (ORDER BY ts)) / 60 gap_min, boot_ts != LAG(boot_ts) OVER (ORDER BY ts) rebooted
FROM samples ORDER BY gap_min DESC LIMIT 10;
```
