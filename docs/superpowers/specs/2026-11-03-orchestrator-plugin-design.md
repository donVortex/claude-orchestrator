# session-orchestrator — Design

Date: 2026-11-03
Status: approved in conversation, awaiting written-spec review

## 1. Intent

One Claude Code session becomes the **orchestrator**: the session the user talks to and plans work in. It splits the work, hands self-contained pieces to **worker sessions**, and does critical pieces itself. Every session (orchestrator and workers) works through subagents, choosing each subagent's model by the effort the subtask needs, and running independent subagents in parallel. Every worker reports back with its result and a short retrospective; the orchestrator turns the retros into proposed improvements.

**Success looks like:** the user talks to one session; work fans out without the user managing sessions; cheap models do cheap work; each finished task arrives as a reviewed PR plus a retro; the system gets better over time through approved edits.

### Decisions made with the user

| Topic | Decision |
|---|---|
| Runtime | Both: Claude desktop app sessions (primary) and `claude -p` CLI workers (fallback). |
| Autonomy | User approves the breakdown once; afterwards the orchestrator runs on its own and only stops for the escalations in §9. |
| Integration | One GitHub PR per worker task. The orchestrator reviews; the **user merges**. |
| Dependencies | A task that depends on another waits until the upstream PR is merged (no stacked PRs). |
| Model choice | A fixed, editable rubric (`model-tiers.md`). |
| Packaging | A full Claude Code plugin (skills, command, agents, hook). |
| Retros | Every worker (and every self-handled task) produces a retro. The orchestrator summarises them and proposes fixes; nothing changes without user approval. |
| Parallelism | Sessions run independent subagents in parallel, under a cap. |

### Non-goals

- Auto-merging PRs, or merging into the default branch on the user's behalf.
- Auto-applying retro-driven changes.
- Stacked PRs / dependent branches.
- Running workers in the cloud (`target: "cloud"`) — may come later.
- A UI beyond what the desktop app already shows (sessions, PRs, task list).

## 2. Plugin layout

```
session-orchestrator/
├─ .claude-plugin/
│  ├─ plugin.json
│  └─ marketplace.json            # this folder doubles as a local marketplace
├─ commands/
│  └─ orchestrate.md              # /orchestrate <goal>
├─ skills/
│  ├─ orchestrating/
│  │  ├─ SKILL.md
│  │  └─ references/
│  │     ├─ model-tiers.md        # the editable rubric (§6)
│  │     ├─ splitting.md          # how to cut work into tasks (§5)
│  │     ├─ brief-template.md     # what every worker brief contains (§7)
│  │     ├─ ledger.md             # ledger format and update rules (§4)
│  │     ├─ backend-desktop.md    # §10.1
│  │     └─ backend-cli.md        # §10.2
│  └─ working/
│     ├─ SKILL.md                 # the worker loop (§7)
│     └─ report-format.md         # worker result + retro template (§8)
├─ agents/
│  ├─ orch-scout.md               # role: read-only search/summaries   (default model: haiku)
│  ├─ orch-implementer.md         # role: implement + test             (default model: sonnet)
│  └─ orch-specialist.md          # role: design, hard debugging, review (default model: opus)
├─ hooks/
│  ├─ hooks.json
│  └─ ledger-context.sh           # SessionStart: re-inject the ledger
├─ scripts/
│  └─ cli-worker.sh               # CLI backend: start | resume | remove a headless worker
├─ settings/
│  └─ worker-allowlist.json       # suggested permissions for headless workers
└─ tests/                         # §12
```

Scripts are bash only. Claude Code on Windows already requires Git Bash, so one set covers both platforms.

Shared references live in `skills/orchestrating/references/`; the `working` skill reads `model-tiers.md` from there by a path relative to its own folder (`../orchestrating/references/model-tiers.md`). The report format lives with the worker (`skills/working/report-format.md`) and the orchestrator reads it from there.

Plugin commands are namespaced: the entry point is `/session-orchestrator:orchestrate`.

Agents describe **roles**. Their frontmatter `model` is only a default: callers always pass the rubric's model explicitly, which takes precedence. Retuning tiers means editing `model-tiers.md` only.

## 3. Components

| Unit | Purpose | Used by | Depends on |
|---|---|---|---|
| `/orchestrate` | Entry point: turns the current session into the orchestrator for `<goal>`. Loads `orchestrating`. | User | `orchestrating` |
| `orchestrating` skill | The orchestrator's procedure: intake → breakdown → approval → dispatch → track → review → wrap-up. | Orchestrator | all references, agents, backends |
| `working` skill | The worker's procedure: brief → plan → parallel subagent batches → verify → PR → report. | Worker sessions | `model-tiers.md`, `report-format.md`, agents, superpowers skills |
| `model-tiers.md` | The single source of model/effort choices and parallelism caps. | Both skills | — |
| Tier agents | Reusable subagent roles. | Both skills | — |
| SessionStart hook | After compaction or resume, injects the ledger summary so the orchestrator keeps its state. | Harness | ledger file |
| `cli-worker.sh` | Creates a worktree and starts, resumes or removes a headless worker. | CLI backend | `git`, `claude` |

The `working` skill builds on `superpowers:subagent-driven-development`, `superpowers:dispatching-parallel-agents`, `superpowers:test-driven-development` and `superpowers:verification-before-completion` when they are installed. If they are not, it carries its own short version of each rule, so the plugin works without superpowers.

## 4. State: the `.orchestration/` folder

Lives in the **main checkout** of the target repo. On first use the orchestrator adds `.orchestration/` to `.git/info/exclude`, so it is never committed and needs no `.gitignore` change.

```
.orchestration/
├─ ledger.md            # one orchestration's live state
├─ retros.md            # all retros appended in arrival order
└─ reports/<task-id>.md # each worker's full report
```

`ledger.md`:

```markdown
# Orchestration: <goal>
Started: <date> · Backend: desktop|cli · Base branch: <branch> · Status: planning|running|wrap-up|done

| id | task | owns (files/globs) | depends | tier | placement | session/run | branch | PR | status |
|----|------|--------------------|---------|------|-----------|-------------|--------|----|--------|
| T1 | ... | src/db/schema.ts | — | deep | self | — | orch/T1 | #12 | merged |
| T2 | ... | src/api/users/** | T1 | standard | worker | local_ab12 | orch/T2 | #13 | in-review |

## Events
- <time> T2 started (local_ab12, sonnet/medium)
- <time> T2 report received → reports/T2.md
```

Statuses: `planned → running → blocked → pr-open → in-review → changes-requested → reviewed → merged`, or `failed` / `dropped`.

The orchestrator updates the ledger on every event. It is the source of truth on resume; nothing is kept only in context.

## 5. Orchestrator flow

1. **Intake.** If `ledger.md` exists and isn't `done`, resume from it. Otherwise clarify the goal with the user and read the repo, using parallel `orch-scout` subagents for broad searches.
2. **Breakdown.** Split into tasks. Each gets an id, goal, acceptance criteria, owned files, dependencies, tier and placement (table below). Rules from `splitting.md`:
   - Owned files of tasks that can run at the same time must not overlap.
   - Each worker task is PR-sized: reviewable on its own and describable in a short brief.
   - Shared foundations (schemas, interfaces, config, shared types) are separate tasks that run first.

   | Placement | When |
   |---|---|
   | `self` | Critical: a foundation other tasks build on; high risk (auth, migrations, data, security); needs back-and-forth with the user; or so small that briefing would cost more than doing. |
   | `subagent` | Read-only research the orchestrator needs now to plan or to answer the user. |
   | `worker` | Self-contained, PR-sized, owns disjoint files, briefable. |

3. **Approval gate.** Show the breakdown as a table (the ledger table minus runtime columns). The user approves, edits, or moves tasks between placements and tiers. This is the only routine stop.
4. **Dispatch.** Pick the backend (§10). Start ready workers in parallel up to `max_parallel_workers`. Do `self` tasks in the orchestrator session, in their own worktree (`<repo>-wt/<task-id>`, branch `orch/<task-id>`) so the user's checkout is never switched, using subagents per the rubric, and open a PR for each the same way a worker would.
5. **Track.** Update the ledger on every event. Answer worker questions; forward questions only the user can answer. Use early retros to improve briefs for workers not yet started.
6. **Review.** For each PR: read the diff against the brief; check that only owned files changed; check CI. `deep` tasks also get an `orch-specialist` review pass. Send fixes to the same worker. When clean, mark `reviewed`. Batch reviewed PRs and ask the user to merge. After merges, start tasks whose dependencies are now met (back to step 4).
7. **Wrap-up.** When every task is `merged`, `failed` or `dropped`: summarise results, write a retro digest grouped by tag, and propose concrete edits (to `model-tiers.md`, `splitting.md`, `brief-template.md`, the skills). Edits target the plugin's source repo and land only on user approval.

## 6. Model tiers (`model-tiers.md`)

| Tier | Subagent model | Worker session model / effort | Use for |
|---|---|---|---|
| `fast` | haiku | sonnet / low | search, lookups, renames, boilerplate, docs, mechanical edits |
| `standard` | sonnet | sonnet / medium | features with a clear spec, tests, bugs with a known cause |
| `deep` | opus | opus / high | design, cross-cutting changes, bugs with an unknown cause, security, reviewing deep work |

Caps (same file): `max_parallel_workers: 4`, `max_parallel_implementers_per_session: 3`.

Rules:
- Worker sessions coordinate, so their floor is Sonnet even for `fast` tasks; only the subagents drop to Haiku.
- A task's tier sets the worker session's model. Each subtask inside it gets its own tier, so one worker can mix models.
- **One automatic escalation:** if a subagent fails or returns weak work, retry once a tier up and record it in the retro (`tier` tag). A second failure goes to the orchestrator.
- The orchestrator session keeps whatever model the user started it with.

## 7. Worker flow (`working` skill)

Every brief (`brief-template.md`) contains: task id and goal; acceptance criteria; owned files and explicitly off-limits files; base branch; tier and subtask tier hints; the orchestrator's session id (desktop) or "CLI mode"; the absolute path for the report; "load the `working` skill"; and the report format.

1. **Read the brief.** If anything is ambiguous, ask instead of guessing:
   - Desktop: `SendMessage` to the orchestrator, then wait.
   - CLI: write the question to the report file with status `blocked` and end. The orchestrator answers with `claude -p --resume <session-id> "<answer>"`.
2. **Plan.** Make a short inline list of subtasks, each with owned files and a tier. Write a full plan document only if the task is large.
3. **Execute in batches.** Group subtasks into batches:
   - Subtasks with disjoint files and no dependency between them run **in parallel** (several Agent calls in one message, up to the cap).
   - Subtasks that share files or depend on each other run one after another.
   - Read-only work (scouts, reviews) is always parallel.
   - Each subtask: implementer (TDD) → spec-compliance review → code-quality review, each on the rubric's model.
   - After each batch, run the full test suite before the next batch.
4. **Escalate** per §6.
5. **Verify.** Full test, lint and build. The passing output must be shown before claiming done.
6. **PR.** Push `orch/<task-id>` and open a PR against the base branch with `gh pr create`. The body lists: goal, what changed, how it was verified, risks.
7. **Report.** Write the full report to the brief's path. Then send a one-line "T<n> done, PR <url>, report at <path>" (desktop: `SendMessage`/final message; CLI: last line of output).

## 8. Report and retro format (`report-format.md`)

```markdown
# T<n> report
Status: done | blocked | failed
PR: <url>

## Result
- Changed: ...
- Verified by: <commands> → <outcome>
- Risks / follow-ups: ...

## Retro
### Went well
- [tag] ...
### Went badly
- [tag] ...
### Improve
- [tag] <concrete suggestion>
```

Tags: `brief`, `split`, `tier`, `parallelism`, `tooling`, `codebase`, `process`.

The orchestrator appends each retro to `retros.md`. It writes one for its own `self` tasks too. At wrap-up it groups them by tag, and each repeated pattern becomes a proposed edit (e.g. "3 `tier` retros say Haiku was too weak for test writing → move test writing to `standard`").

## 9. Approval and escalation points

The orchestrator stops for the user only for:
1. Breakdown approval (once per orchestration, and again if the plan is re-split).
2. A decision only the user can make (forwarded worker question, product choice).
3. A task that needs to grow beyond the files it owns.
4. A task that has failed twice.
5. Merge approval for a batch of reviewed PRs.
6. Retro-driven edits at wrap-up.
7. Desktop only: a session start the app refused (see §10.1).

## 10. Backends

The orchestrator picks **desktop** if `mcp__ccd_session__start_session` can be loaded, otherwise **cli**. The choice is recorded in the ledger.

### 10.1 Desktop

- **Start:** `start_session` with `initiation: "user_asked"` (the breakdown approval is the user's instruction), `context: "fresh"`, `use_worktree: true`, title `T<n> · <short task>`, the brief as prompt. Then `set_session_model` and `set_session_effort` per tier.
- **Results:** the app wakes the orchestrator when a worker ends a turn; the orchestrator reads `reports/<task-id>.md` for the full report (the wake-up note itself is truncated).
- **Follow-ups:** `SendMessage` to the worker's `local_…` id.
- **Liveness:** `list_sessions {"linked": true}` / `get_session`.
- **Known limit:** the app may refuse `start_session` on turns it triggered itself (not from the user). If a later wave is refused, the orchestrator proposes each start as an `own_initiative` card, tells the user in one line that it is waiting for a click, and records `blocked: needs start click` in the ledger.

### 10.2 CLI

- **Start** (`cli-worker.sh start <task-id> <base> <model> <effort> <brief-file>`):
  - `git worktree add -b orch/<task-id> <repo>-wt/<task-id> <base>`
  - inside it, `claude -p "<brief>" --model <model> --effort <effort> --output-format json --permission-mode acceptEdits --settings <allowlist>`, launched by the orchestrator with `run_in_background`.
- **Results:** the background run's exit wakes the orchestrator. The JSON output gives `session_id` (stored in the ledger, used for `--resume`). The full report is read from the report file.
- **Follow-ups:** `cli-worker.sh resume <task-id> <session-id> <message-file>` → `claude -p --resume <session-id> ...` in the task's worktree, again in the background.
- **Permissions:** `-p` runs start in Manual mode, so every worker gets `--permission-mode acceptEdits` plus `--settings settings/worker-allowlist.json` (git, gh, read/edit; the user adds their project's test and build commands). It never uses a bypass mode.
- **Cleanup:** after merge, `cli-worker.sh remove <task-id>` (`git worktree remove`, branch kept).
- **Requires** the `claude` CLI on PATH; intake checks this before choosing the CLI backend.

## 11. Failure handling

| Situation | Response |
|---|---|
| Worker fails twice (including review/CI rounds) | Mark `failed`; user chooses: re-tier to `deep`, orchestrator takes it as `self`, or drop. |
| Worker edits files it doesn't own | Caught in review; PR sent back, or task re-split with user OK (§9.3). |
| CI fails / review finds problems | Back to the same worker; counts toward the two-failure limit. |
| Two PRs conflict | Shouldn't happen with disjoint ownership; if it does, the later PR's worker rebases. |
| Orchestrator context compacted or session resumed | SessionStart hook injects the ledger; orchestrator continues from it. |
| Worker silent | Check session state (desktop) or process exit (CLI); resume once, then escalate as a failure. |
| No GitHub remote / `gh` not authenticated | Detected at intake; orchestrator stops and tells the user before planning. |

## 12. Testing

1. **Script tests** (`tests/`, bash): `ledger-context.sh` prints the ledger summary when an active ledger exists and nothing otherwise; `cli-worker.sh` creates the worktree/branch and builds the right `claude` command (with `claude` stubbed).
2. **Behaviour evals** with `claude plugin eval`, against small fixture repos:
   - Breakdown: concurrent tasks own disjoint files; foundations are `self` and first; placements and tiers follow the rubric.
   - Worker: parallel batches only for disjoint subtasks; rubric models passed on every Agent call; report matches `report-format.md`.
   - Wrap-up: retros with a repeated pattern produce a matching proposed edit.
3. **End-to-end dry run**: a throwaway repo with a GitHub remote and 3 tasks (one `self`, two workers), once per backend. Passes when the PRs open, reports and retros arrive, the ledger ends `done` after the user merges, and the wrap-up digest is produced.

## 13. Platform facts (checked against the Claude Code docs, 2026-11-03)

- Plugin names starting with `claude-` are reserved for Anthropic (`claude plugin validate` rejects them), so the plugin and marketplace are named `session-orchestrator`. The GitHub repo and local folder keep the name `claude-orchestrator`.
- The Agent tool's `model` parameter overrides an agent's frontmatter `model` (family aliases only).
- SessionStart hooks have `compact` and `resume` matchers; plain stdout is added to context.
- `--effort <low|medium|high|xhigh|max>` sets effort per CLI run.
- `claude -p --output-format json` returns `session_id`; `-p --resume <id>` works.
- A plugin installed at user scope loads in local desktop sessions and in `claude -p` runs (not in cloud sessions, not with `--bare`).
- Still to confirm in the end-to-end run: that sessions started by another desktop session load the plugin.
