# session-orchestrator

A Claude Code plugin that turns the session you talk to into an **orchestrator**. It plans the work with you, splits it into PR-sized tasks, and runs them in **worker sessions** (desktop app sessions, or headless `claude -p` runs). Workers build with subagents whose model is picked by effort, run independent subagents in parallel, open one PR per task, and report back with a short retro. The orchestrator does critical tasks itself, reviews every PR, and leaves merging to you. Each project it works on builds up its own knowledge, so it gets better at that project with every feature.

Design: [plugin](docs/superpowers/specs/2026-11-03-orchestrator-plugin-design.md) · [project knowledge](docs/superpowers/specs/2026-11-03-project-knowledge-design.md) · [workflow learning](docs/superpowers/specs/2026-11-03-workflow-learning-design.md)

## Install

**You need:**
- Claude Code: the desktop app (Code tab) or the `claude` CLI;
- `git`, and the GitHub CLI `gh`, logged in (`gh auth login`);
- a project with a GitHub remote (every task becomes a pull request);
- for the CLI backend only: `claude` on your PATH.

**1. Add the marketplace and install the plugin** (in a terminal):

```bash
claude plugin marketplace add donVortex/claude-orchestrator
```

```bash
claude plugin install session-orchestrator@session-orchestrator --scope user
```

`--scope user` makes it available in every project, in both the desktop app and the `claude` CLI on that machine. Plugins don't load in cloud sessions (claude.ai/code).

**2. Restart** the desktop app, or start a new `claude` session.

**3. Check it's there:** `claude plugin list` shows `session-orchestrator`, and typing `/session-orchestrator` in a session suggests `/session-orchestrator:orchestrate`.

**Updating.** Turn on auto-update once: run `claude`, type `/plugin`, open Marketplaces → `session-orchestrator` and enable auto-update. The setting is shared by the CLI and the desktop app. To update by hand instead:

```bash
claude plugin marketplace update session-orchestrator
```

```bash
claude plugin update session-orchestrator@session-orchestrator
```

Then restart; sessions already open keep the old version.

**Uninstalling:** `claude plugin uninstall session-orchestrator@session-orchestrator`. The knowledge in your projects (`.claude/orchestrator/`) stays; it belongs to the projects.

## Use

### Your first run in a project

1. **Open the project:** in the desktop app, a Code session on the project's folder; in a terminal, `claude` in the repo.
2. **Start it with a goal:**
   ```
   /session-orchestrator:orchestrate add a refund flow
   ```
   Or without a goal (`/session-orchestrator:orchestrate`) to let it learn the project first.
3. **Project setup (first run only):** scouts read the repo, then it asks you up to 5 questions about the domain, one at a time, and shows you the drafted knowledge. Nothing is written until you approve; then it opens a knowledge PR for you to merge.
4. **Approve the plan:** it shows the tasks as a table (what each does, which files it owns, its model tier, where it runs). Approve it or ask for changes. Nothing starts before you approve.
5. **Work runs:**
   - **Desktop app:** each task gets its own worker session, listed in the sidebar as `T<n> · <task>`. You can open one to watch it; you don't have to.
   - **CLI:** workers run headless in their own git worktrees ([permissions](#cli-workers-and-permissions)).
   - The orchestrator does small or critical tasks itself. Before the first one it asks you once to run `/add-dir <repo>-wt`, so its worktrees don't prompt for every edit.
   - Workers that get stuck ask the orchestrator; it asks you only what it can't answer.
6. **Reviews and merging:** each task ends in one pull request. The orchestrator reviews it (diff, tests, CI) and sends problems back to the worker. Clean PRs are batched and you're asked to merge them. **You merge; it never does.** After a merge it starts the tasks that were waiting on it.
7. **Wrap-up:** when every task is done it shows the results, what went well or badly, and a **knowledge diff**: what it learned about the project, each change with its source. Approve it and it opens a knowledge PR.

### Every run after that

- **Just describe the feature** in any new session in that project ("add CSV export"): once a project has `.claude/orchestrator/`, it plans and delegates without the command. Questions, explanations, reviews and small one-file fixes stay normal, quick work.
- **Pick the mode** that fits the run: full or lite ([Modes](#modes-full-and-lite)).
- **Pick up where you left off:** the run's state lives in `.orchestration/ledger.md`. When the orchestrator's context fills up or you resume its session, the plan is loaded back automatically. In a new session, run `/session-orchestrator:orchestrate` (or say "continue the orchestration") and it continues from each task's state.
- **Task numbers keep counting** across runs (T1–T8, then T9…), so sessions in the sidebar never share a number.

To keep a project manual (no orchestrator unless you run the command), add this to its `.claude/settings.json`:

```json
{ "env": { "ORCH_DEFAULT": "off" } }
```

## Modes: full and lite

**Full** (the default) puts the effort where the work needs it. Hard tasks (design, cross-cutting changes, unknown bugs, security) run on opus and get an extra specialist review. That pays off on complex products.

**Lite** is for runs where speed matters more than depth: a simple codebase, small changes, a time crunch.

| | Full | Lite |
|---|---|---|
| Models | opus for `deep` work | sonnet for everything (`deep` runs as `standard`) |
| Tasks | PR-sized, one worker session each | as few tasks as the work allows; small ones done in the orchestrator session |
| Reviews | spec review + quality review per subtask, specialist review of `deep` PRs | one combined review per subtask, no specialist PR review |
| Knowledge setup | interview and drafts on a project's first run | skipped (the wrap-up mentions it) |

**Turning it on**

- **One run:** `/session-orchestrator:orchestrate lite: <goal>`, or say "lite" in your request.
- **A whole project:** add a `Mode: lite` entry to `.claude/orchestrator/calibration.md`. After you choose lite twice in a project, the wrap-up proposes this entry for you.
- **During a run:** say "lite" or "full" at any time. Tasks that haven't started switch; workers already running finish on their current model.
- **Back to full:** say "full", for one run or mid-run. The plan always shows the mode and where it came from: `Mode: lite (from project knowledge) — say "full" to switch`.

**Lite never cuts the safety net.** Work that touches security, authentication, money, deleting data or migrations keeps its normal model and the specialist review. A subtask that fails can still move up to opus once. Tests, one PR per task, your plan approval, your merges and the wrap-up learning all stay.

**Tip:** the orchestrator session can't change its own model, so for lite runs start that session on sonnet. If it runs on opus, the plan reminds you once.

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

## Alongside other skills and plugins

The orchestrator runs alongside whatever other skills and plugins you use, without either getting in the other's way or doing the same work twice. It judges every skill by **what it would do**, not by its name ([the contract](skills/orchestrating/references/coexistence.md)):

- **The orchestrator owns how work is organised**: the plan and your approval, branches, worktrees, one PR per task, reviews, and project knowledge. You merge. Another planner's ideas feed the breakdown but never replace it, and no skill merges, creates its own worktree, or writes plan files into a PR.
- **Everything inside a task is open to other skills**: test-driven development, framework and domain skills (Stripe, Cloudflare, design), debugging.
- **When a workflow skill overlaps,** the plan says so in one line (`Other workflow skills: …`), and you can override it in the same reply.
- **Briefs name the skills that fit each task,** so workers don't each go looking for them.
- **Still one review per change:** if the project has a preferred review skill, the reviewer uses it **and** the project's checklist.
- **Each project learns its own skill set:** wrap-ups propose `Skill:` entries ("use payments-kit for refunds", "skip that plugin's worktree step"), which you approve in the usual knowledge PR.

[superpowers](https://github.com/obra/superpowers) is the worked example: brainstorming helps with an unclear goal; its planning, worktree and finishing steps are replaced by the orchestrator's; its TDD, review and verification skills are used inside tasks.

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

## License

[MIT](LICENSE)
