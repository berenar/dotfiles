---
name: localhost
description: Find out how to run the current project locally, start it if it isn't already running, and open it in the browser on localhost. Use when the user says "localhost", "open it locally", "run the app", "start the dev server", "open the project in the browser", or wants to see the app running on their machine.
---

# localhost

Get the current project running on localhost and open it in the browser. Reuse anything
that's already running. Don't start a second copy.

## 1. Check if it's already running

List listening ports and see if any belong to this repo:

```bash
lsof -iTCP -sTCP:LISTEN -P -n
```

For each candidate PID, check its working directory:

```bash
lsof -a -p <pid> -d cwd -Fn | tail -1
```

If a process is serving from this repo (or one of its subpackages), skip to step 4 with that
port. Also check `docker compose ps` if the project uses compose, the app may run in a
container.

## 2. Find out how to run it

Look in this order and stop at the first clear answer:

1. Project docs: `CLAUDE.md`, `AGENTS.md`, `README.md`, `CONTRIBUTING.md`. Look for a
   "Getting started" or "Development" section.
2. `Makefile`: run `make help` and look for `dev`, `start`, `run`, `up` targets. Prefer make
   over package scripts when both exist.
3. `package.json` scripts: `dev`, `start`, `serve`, `develop`. In a monorepo (`pnpm-workspace.yaml`,
   `turbo.json`, `nx.json`, `apps/*`), find the web app package and its dev script. Ask if
   there are several apps and it's not obvious which one the user wants.
4. Other stacks: `docker-compose.yml` / `compose.yaml`, `Procfile`, `manage.py` (Django),
   `pyproject.toml` scripts, `Gemfile` (Rails), `go.mod`, `Cargo.toml`.

Work out the expected port from the config (`vite.config.*`, `next.config.*`, `.env`
`PORT=`, script flags like `--port`, compose port mappings). Defaults: Next 3000, Vite
5173, Astro 4321, Django 8000, Rails 3000, Flask 5000.

## 3. Start it

Before starting:

- **Deps**: if `node_modules` is missing or older than the lockfile, install with the package
  manager from the lockfile (`pnpm-lock.yaml`, `yarn.lock`, `package-lock.json`, `bun.lock*`).
- **Env**: if there's a `.env.example` and no `.env`, list the missing keys and ask the user.
  Never invent secret values.
- **Services**: if the app needs a database or other containers, run `docker compose up -d`.
  If Docker isn't running, `open -a OrbStack`, wait, and retry.
- **Port conflict**: if the expected port is taken by another project, tell the user and
  pick a free one if the tool supports a port flag.

Start the dev server with `run_in_background: true` and log to a file in the scratchpad.
Poll until it responds (up to about 60s):

```bash
curl -s -o /dev/null -w '%{http_code}' http://localhost:<port>
```

Read the log too, since the real URL (and port) is often printed there, e.g. `Local:
http://localhost:5173`. If it fails to start, show the last lines of the log and stop.

## 4. Open it

```bash
open "http://localhost:<port>"
```

Use the real path if the app's root isn't useful (e.g. a base path, or `/admin`).

## 5. Report

Keep it short:

- URL
- whether it was already running or you started it, and the command used
- anything the user needs to know (login credentials from seeds, missing env keys, other
  services started)
