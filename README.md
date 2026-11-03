# session-orchestrator

A Claude Code plugin that turns the session you talk to into an **orchestrator**. It plans the work with you, splits it into PR-sized tasks, and runs them in **worker sessions** (desktop app sessions, or headless `claude -p` runs). Workers build with subagents whose model is picked by effort, run independent subagents in parallel, open one PR per task, and report back with a short retro. The orchestrator does critical tasks itself, reviews every PR, leaves merging to you, and proposes improvements from the retros.

Design: [docs/superpowers/specs/2026-11-03-orchestrator-plugin-design.md](docs/superpowers/specs/2026-11-03-orchestrator-plugin-design.md)

## Install

```bash
claude plugin marketplace add D:/dev/claude-orchestrator
claude plugin install session-orchestrator@session-orchestrator
```

Requirements: `git`, `gh` (logged in), and a GitHub remote on the project you orchestrate. The CLI backend also needs `claude` on PATH.

## Use

```
/session-orchestrator:orchestrate <goal>
```

## CLI workers and permissions

Outside the desktop app, workers run as headless `claude -p` processes in their own git worktrees (`scripts/cli-worker.sh`). Headless runs can't ask you for permission, so each worker gets `--permission-mode acceptEdits` plus [settings/worker-allowlist.json](settings/worker-allowlist.json). That allows reading and editing files, skills and subagents, `git` commits, pushing to `orch/*` branches only (no force-push, nothing to `main`/`master`), and `gh pr`. The plugin never uses a bypass mode.

Workers also need your project's test, lint and build commands. Don't edit the plugin's allowlist (an installed plugin runs from a cached copy that updates replace); add them to the project's `.claude/settings.json`, which workers pick up from their worktree:

```json
{ "permissions": { "allow": ["Bash(npm test*)", "Bash(npm run lint*)", "Bash(npm run build*)"] } }
```

To replace the whole allowlist, point `ORCH_ALLOWLIST` at your own file.

## Tests

```bash
bash tests/run.sh
```
