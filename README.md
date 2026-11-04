# session-orchestrator

A Claude Code plugin that turns the session you talk to into an **orchestrator**. It plans the work with you, splits it into PR-sized tasks, and runs them in **worker sessions** (desktop app sessions, or headless `claude -p` runs). Workers build with subagents whose model is picked by effort, run independent subagents in parallel, open one PR per task, and report back with a short retro. The orchestrator does critical tasks itself, reviews every PR, and leaves merging to you. Each project it works on builds up its own knowledge, so it gets better at that project with every feature.

Design: [plugin](docs/superpowers/specs/2026-11-03-orchestrator-plugin-design.md) · [project knowledge](docs/superpowers/specs/2026-11-03-project-knowledge-design.md) · [workflow learning](docs/superpowers/specs/2026-11-03-workflow-learning-design.md)

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

- **First run in a project:** scouts read the repo, the orchestrator asks you up to 5 domain questions (one at a time), shows you the drafts, and opens a knowledge PR after you approve. Start it without a goal (`/session-orchestrator:orchestrate`) and it learns the project first, then asks what to build.
- **Project-rules skill (optional):** the orchestrator offers a small `.claude/skills/project-rules/SKILL.md` that points every session in the repo, even ones not using the orchestrator, to the project's rules. Decline it once and it isn't offered again.
- **Every run:** briefs quote the relevant rules, reviews use the checklist, and splits follow the codebase map.
- **Every wrap-up:** proposes additions, edits and removals, each with its source. After you approve, it opens (or extends) a knowledge PR for the team to review.
- **Hand edits are welcome** and always win. Never put secrets, identifiers or personal data in it.

**The project owns its knowledge.** Plugin updates never rewrite, reformat or migrate it, whatever its layout. The plugin's templates only shape a brand-new bootstrap; after that, the knowledge changes only through PRs you approve.

**Standalone by design.** Installed from GitHub, the plugin works on its own and improves only within each project, through that project's knowledge. It never proposes changes to the plugin itself and never sends anything anywhere. Lessons about tooling that help your project become entries in its own knowledge (for example a pre-flight check). Only the plugin's own development checkout, which has a git-ignored `.plugin-dev` marker, runs in development mode and proposes plugin edits.

## Workflow learning

Besides the domain, each project's orchestrator learns **how work goes best there**, aiming at fewer interruptions for you and less rework, with the same output.

- **Measured, not guessed:** every ledger event carries a kind tag (`[ask-user]`, `[prompt]`, `[failed]`, `[changes]`, …). Each wrap-up shows a table of your attention and the rework per task. Expected stops (approving the plan, merges, the knowledge diff) don't count against it.
- **What it learns,** all in the project's `calibration.md`:
  - **Recipes:** how a kind of task goes through cleanly.
  - **Learned defaults:** answers you gave twice, so it stops asking.
  - **Pre-flight checks:** environment problems to catch at intake.
  - **Brief rules:** to prevent rework.
- **What you see:** the plan says `Following recipe: …` and `Assumed from project knowledge: …`, so you can override either in the same reply.
- **Guardrails:** everything still goes through the approved knowledge PR. Learned defaults never override `CLAUDE.md` or project rules, and never cover safety, data handling or money.

## With superpowers

The orchestrator works alongside [superpowers](https://github.com/obra/superpowers) and similar process-skill plugins. In the orchestrator session you may brainstorm an unclear goal first, but the breakdown, approval and dispatch replace superpowers' writing-plans and executing-plans. Workers treat the brief as the approved design and plan: they skip brainstorming, plan documents, their own worktree setup and the finishing step (they push and open a PR, never merge), and keep test-driven development, subagent-driven development, code review and verification.

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

**Project knowledge, end to end** (sandbox PRs #9–#13): the first orchestration bootstrapped the knowledge (repo scan, an interview one question at a time, your approval, knowledge PR #9); feature 1 (`formatMoney`, #10) briefed its worker with those rules and its wrap-up added what it learned (knowledge PR #11); feature 2 (`sumPrices`, #12) quoted a rule feature 1 had taught, and its wrap-up added more (#13). Found and fixed along the way: structured messages ending in "Your next step", reading the base branch with `MSYS_NO_PATHCONV=1` on Windows, never `cd`-ing into a worktree, starting every task from GitHub's latest base, and the orchestrator as the default workflow in projects with knowledge.

**Workflow learning, end to end** (sandbox PRs #14–#17, on a project whose knowledge predates v0.3.0): run 1 (`maxPrice`, #14) tagged every ledger event, counted 1 question to you and 0 rework, turned that question into a domain rule, and learned a "Money helper" recipe, filed under the project's existing heading with a `Recipe:` prefix (#15). Run 2 (`minPrice`, #16) followed that recipe and finished with **0 questions and 0 rework**, and its wrap-up updated the recipe's track record (#17). Found and fixed along the way: a recipe may be learned when its only question became a domain rule; workers wait for their review subagents in the same turn; a branch-cleanup question you left unanswered isn't asked again.

## Tests

```bash
bash tests/run.sh
```

Skill behaviour evals (each case runs with and without the plugin; this costs roughly $3–4 per full run on your account). Use a Sonnet judge: the default Haiku judge splits its votes on correct answers. `--no-publish` keeps the report local.

```bash
claude plugin eval . --judge-model sonnet --no-publish
```
