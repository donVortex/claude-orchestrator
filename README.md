# session-orchestrator

A Claude Code plugin that turns the session you talk to into an **orchestrator**. It plans the work with you, splits it into PR-sized tasks, and runs them in **worker sessions** (desktop app sessions, or headless `claude -p` runs). Workers build with subagents whose model is picked by effort, run independent subagents in parallel, open one PR per task, and report back with a short retro. The orchestrator does critical tasks itself, reviews every PR, leaves merging to you, and proposes improvements from the retros.

Design: [docs/superpowers/specs/2026-11-03-orchestrator-plugin-design.md](docs/superpowers/specs/2026-11-03-orchestrator-plugin-design.md)

## Install

```bash
claude plugin marketplace add D:\dev\claude-orchestrator
claude plugin install session-orchestrator@session-orchestrator
```

Requirements: `git`, `gh` (logged in), and a GitHub remote on the project you orchestrate. The CLI backend also needs `claude` on PATH.

## Use

```
/session-orchestrator:orchestrate <goal>
```

## CLI workers and permissions

Outside the desktop app, workers run as headless `claude -p` processes in their own git worktrees (`scripts/cli-worker.sh`). Headless runs can't ask you for permission, so each worker gets `--permission-mode acceptEdits` plus [settings/worker-allowlist.json](settings/worker-allowlist.json), which allows reading and editing files, `git` and `gh pr`. Add your project's test and build commands to that file (e.g. `"Bash(npm test*)"`), or workers will be denied when they try to run them. The plugin never uses a bypass mode.

## Tests

```bash
bash tests/run.sh
```
