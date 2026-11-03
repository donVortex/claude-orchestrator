# session-orchestrator

A Claude Code plugin that turns the session you talk to into an **orchestrator**. It plans the work with you, splits it into PR-sized tasks, and runs them in **worker sessions** (desktop app sessions, or headless `claude -p` runs). Workers build with subagents whose model is picked by effort, run independent subagents in parallel, open one PR per task, and report back with a short retro. The orchestrator does critical tasks itself, reviews every PR, and leaves merging to you. Each project it works on builds up its own knowledge, so it gets better at that project with every feature.

Design: [plugin](docs/superpowers/specs/2026-11-03-orchestrator-plugin-design.md) · [project knowledge](docs/superpowers/specs/2026-11-03-project-knowledge-design.md)

## Install

The repo is private, so first give git access to it on the machine (once):

```bash
gh auth login
gh auth setup-git
```

Then install from GitHub:

```bash
claude plugin marketplace add donVortex/claude-orchestrator
claude plugin install session-orchestrator@session-orchestrator --scope user
```

`--scope user` makes it available in every project, in both the desktop app and the `claude` CLI on that machine. Restart the desktop app afterwards. Plugins don't load in cloud sessions (claude.ai/code).

**Updates:** turn on auto-update under `/plugin` → Marketplaces → `session-orchestrator`. Machines receive a new version when the `version` in `.claude-plugin/plugin.json` changes.

Requirements: `git`, `gh` (logged in), and a GitHub remote on the project you orchestrate. The CLI backend also needs `claude` on PATH.

## Use

```
/session-orchestrator:orchestrate <goal>
```

**After the first run, it's the project's default.** Once a project has `.claude/orchestrator/` (created by the first orchestration's bootstrap), every new session there is told the project uses the orchestrator. Describe a feature ("add a refund flow") and it plans, asks for your approval and delegates, with no command needed. Questions, explanations, reviews and small one-file fixes stay normal, quick work.

To keep a project manual, add this to its `.claude/settings.json`:

```json
{ "env": { "ORCH_DEFAULT": "off" } }
```

## Project knowledge

Each project keeps what the orchestrator has learned about it in `.claude/orchestrator/`, committed to the project's repo: domain rules and glossary, a codebase map, a review checklist, and tier and split calibration. A healthcare team's orchestrator becomes expert in their healthcare product; an insurtech team's in theirs.

- **First run in a project:** scouts read the repo, the orchestrator asks you up to 5 domain questions (one at a time), shows you the drafts, and opens a knowledge PR after you approve.
- **Every run:** briefs quote the relevant rules, reviews use the checklist, and splits follow the codebase map.
- **Every wrap-up:** proposes additions, edits and removals, each with its source. After you approve, it opens (or extends) a knowledge PR for the team to review.
- **Hand edits are welcome** and always win. Never put secrets, identifiers or personal data in it.

**The project owns its knowledge.** Plugin updates never rewrite, reformat or migrate it, whatever its layout. The plugin's templates only shape a brand-new bootstrap; after that, the knowledge changes only through PRs you approve.

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
