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

Outside the desktop app, workers run as headless `claude -p` processes in their own git worktrees (`scripts/cli-worker.sh`). Headless runs can't ask you for permission, so each worker gets `--permission-mode acceptEdits` plus [settings/worker-allowlist.json](settings/worker-allowlist.json). Edits are limited to the worker's worktree and the `.orchestration/` folder. The allowlist adds skills and subagents, `git` commits, pushing to `orch/*` branches only (no force-push, nothing to `main`/`master`), and `gh pr`. The plugin never uses a bypass mode.

Workers also need your project's test, lint and build commands. Don't edit the plugin's allowlist (an installed plugin runs from a cached copy that updates replace); add them to the project's `.claude/settings.json`, which workers pick up from their worktree:

```json
{ "permissions": { "allow": ["Bash(npm test*)", "Bash(npm run lint*)", "Bash(npm run build*)"] } }
```

To replace the whole allowlist, point `ORCH_ALLOWLIST` at your own file.

On Windows, workers use Git Bash for shell commands (the PowerShell tool is turned off for them). The launcher finds Git Bash itself; if your Git install is unusual, set `CLAUDE_CODE_GIT_BASH_PATH` to its `bash.exe`.

## Verified

**CLI backend, end to end** (2026-11-03, sandbox repo, 2 workers + 1 `self` task, all merged). Checklist: [docs/e2e-checklist.md](docs/e2e-checklist.md).

Found and fixed during the run:
- Workers started from Git Bash couldn't find Git Bash and got only PowerShell, which no `Bash(...)` allow rule matches. The launcher now sets `CLAUDE_CODE_GIT_BASH_PATH` and turns PowerShell off.
- Blanket `Edit`/`Write` allow rules let a worker write outside its worktree. Removed; edits are scoped to the worktree and `.orchestration/`.
- `self` worktrees sit outside the orchestrator's working directories, so it now asks you to `/add-dir` them first.
- A review nit counted as a failed round. Now only broken code, red tests/CI, worker errors or missing reports count.
- From the run's own retros: workers may run `gh pr diff`, open PRs with `--body-file`, must see a failing test before any implementation, and check exact source text with grep.

**Desktop backend, end to end** (2026-11-03, sandbox PRs #4–#6): worker sessions start on their tier's model and load the plugin; the previous run is archived first. Found and fixed: folder trust is now handled as a blocked start, tiny tasks get a small-task path that still has one review, and branch names from an earlier run no longer collide.

**Worker behaviour** (third run, sandbox PRs #7–#8): a worker with three independent subtasks sent three implementer subagents in a single response, each on its tier's model, followed by a review. A one-subtask worker took the small-task path and still ran one review.

## Tests

```bash
bash tests/run.sh
```

Skill behaviour evals (each case runs with and without the plugin; this costs roughly $3–4 per full run on your account). Use a Sonnet judge: the default Haiku judge splits its votes on correct answers. `--no-publish` keeps the report local.

```bash
claude plugin eval . --judge-model sonnet --no-publish
```
