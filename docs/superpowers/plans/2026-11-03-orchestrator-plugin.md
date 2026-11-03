# session-orchestrator Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Skill-writing tasks (5, 6) also use superpowers:writing-skills.

**Goal:** A Claude Code plugin that turns one session into an orchestrator which splits work, runs it in worker sessions (desktop or CLI) that use tiered, parallel subagents, collects one PR plus a retro per task, and proposes improvements from the retros.

**Architecture:** Mostly prompt artifacts (two skills, a command, three role agents, reference docs) plus two small bash scripts (a SessionStart hook that re-injects the ledger, and a CLI worker launcher). Scripts are tested with plain bash tests; skills are tested with `claude plugin eval` cases; the whole system is checked by a manual end-to-end run.

**Tech Stack:** Claude Code plugin format, Markdown, bash (Git Bash on Windows), git worktrees, `gh`, `claude -p`, `claude plugin eval`.

**Spec:** `docs/superpowers/specs/2026-11-03-orchestrator-plugin-design.md`

## Preconditions (user, before Task 1)

- Install the Claude Code CLI so `claude --version` works in Git Bash (it is not on PATH on this machine today). Needed for `claude plugin validate`, `claude plugin eval` and the CLI backend.
- `gh auth status` is already logged in as `donVortex` — nothing to do.

## Global Constraints

- Plugin `name`: `session-orchestrator`; marketplace `name`: `session-orchestrator`; install id `session-orchestrator@session-orchestrator`.
- Entry point: `/session-orchestrator:orchestrate`; skills: `session-orchestrator:orchestrating`, `session-orchestrator:working`.
- Scripts: bash only, bash 3.2 compatible (no associative arrays, no `${var,,}`), no `jq`. LF line endings enforced by `.gitattributes`.
- Hooks reference scripts as `bash "${CLAUDE_PLUGIN_ROOT}/..."` (quoted). No state is ever written under `${CLAUDE_PLUGIN_ROOT}`.
- Tiers: `fast` → subagent `haiku`, session `sonnet`/`low`; `standard` → `sonnet`, `sonnet`/`medium`; `deep` → `opus`, `opus`/`high`.
- Caps: `max_parallel_workers: 4`, `max_parallel_implementers_per_session: 3`.
- Agent default models: `orch-scout` haiku, `orch-implementer` sonnet, `orch-specialist` opus.
- Retro tags: `brief`, `split`, `tier`, `parallelism`, `tooling`, `codebase`, `process`.
- Ledger statuses: `planned`, `running`, `blocked`, `pr-open`, `in-review`, `changes-requested`, `reviewed`, `merged`, `failed`, `dropped`.
- Branch `orch/<task-id>`; worktree `<repo-root>-wt/<task-id>`; task ids match `^[A-Za-z0-9][A-Za-z0-9_-]*$`.
- State folder `.orchestration/` in the main checkout, excluded via `.git/info/exclude`.
- Never a bypass permission mode; CLI workers use `--permission-mode acceptEdits --settings <allowlist>`.
- The orchestrator never merges PRs and never applies retro-driven edits without approval.

## Review Focus

1. **CRLF on Windows** — a ledger written with CRLF, or scripts checked out with CRLF, must still work; expected: hook output has no `\r`, scripts run. (Task 1 `.gitattributes`; Task 3 test `crlf_ledger`.)
2. **Paths with spaces** — repo or plugin root under a path like `D:\My Projects\x`; expected: hook and launcher work unchanged. (Task 3 test `path_with_space`; Task 4 test `start_in_path_with_space`.)
3. **Re-spawning a task** — worktree/branch `orch/T2` already exists after a failed run; expected: `start` reuses it instead of failing. (Task 4 test `start_reuses_existing_worktree`.)
4. **Missing base branch / bad task id** — expected: clear error and distinct exit code, nothing created. (Task 4 tests `start_missing_base`, `start_rejects_bad_id`.)
5. **Hook in an unrelated session** — no repo, no ledger, or a `done` ledger; expected: silent, exit 0, never breaks session start. (Task 3 tests `no_ledger`, `done_ledger`, `not_a_repo`.)

---

### Task 1: Plugin scaffold and test harness

**Files:**
- Create: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.gitattributes`, `README.md`
- Create: `tests/lib.sh`, `tests/run.sh`, `tests/test_manifest.sh`

**Interfaces:**
- Produces: `tests/lib.sh` functions `assert_eq <expected> <actual> <msg>`, `assert_contains <haystack> <needle> <msg>`, `assert_not_contains <haystack> <needle> <msg>`, `assert_file <path> <msg>`, `make_tmp` (echoes a fresh temp dir, removed on exit). Each failing assert prints `FAIL: <msg>` and sets a failure flag; `finish` exits 1 if any failed.
- Produces: `tests/run.sh` runs every `tests/test_*.sh`, prints `PASS <file>`/`FAIL <file>`, exits non-zero if any file fails.

- [ ] **Step 1: Write `tests/lib.sh`, `tests/run.sh`, and the failing `tests/test_manifest.sh`**
  - `test_manifest.sh` asserts: `claude plugin validate .` exits 0; `plugin.json` contains `"name": "session-orchestrator"`; `marketplace.json` contains `"name": "session-orchestrator"` and `"source": "./"`; `.gitattributes` contains `*.sh text eol=lf`.
- [ ] **Step 2: Run `bash tests/run.sh`** — Expected: `FAIL tests/test_manifest.sh` (files missing).
- [ ] **Step 3: Create the files**
  - `plugin.json`: `name`, `version: "0.1.0"`, `description` (one sentence from the spec intent), `author: {"name": "donVortex"}`, `repository: "https://github.com/donVortex/claude-orchestrator"`, `license: "MIT"`. No component paths (default discovery).
  - `marketplace.json`: `name`, `owner: {"name": "donVortex"}`, `plugins: [{"name": "session-orchestrator", "source": "./", "description": ...}]`.
  - `.gitattributes`: `* text=auto eol=lf` and `*.sh text eol=lf`.
  - `README.md`: what it is (3 lines), install (`claude plugin marketplace add D:\dev\claude-orchestrator` then `claude plugin install session-orchestrator@session-orchestrator`), usage (`/session-orchestrator:orchestrate <goal>`), and "run tests: `bash tests/run.sh`". Later tasks append their sections.
- [ ] **Step 4: Run `bash tests/run.sh`** — Expected: `PASS tests/test_manifest.sh`.
- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat: plugin scaffold, marketplace and test harness"`

### Task 2: Model tier rubric and role agents

**Files:**
- Create: `skills/orchestrating/references/model-tiers.md`
- Create: `agents/orch-scout.md`, `agents/orch-implementer.md`, `agents/orch-specialist.md`
- Test: `tests/test_agents.sh`

**Interfaces:**
- Produces: `model-tiers.md` with exactly these machine-checked lines (prose around them is free):
  - table rows starting `| \`fast\` | haiku | sonnet / low |`, `| \`standard\` | sonnet | sonnet / medium |`, `| \`deep\` | opus | opus / high |`
  - `max_parallel_workers: 4` and `max_parallel_implementers_per_session: 3`
  - sections: "Use for" column per spec §6; "Escalation" (one retry one tier up, record with `[tier]` tag, second failure → orchestrator); "Session floor" (worker sessions never below sonnet).
- Produces: agents named `orch-scout`, `orch-implementer`, `orch-specialist` (later tasks call them by these names, always passing `model`).

- [ ] **Step 1: Write failing `tests/test_agents.sh`**
  - For each agent file: frontmatter `name:` equals the filename stem; `description:` non-empty; `model:` is `haiku` / `sonnet` / `opus` respectively.
  - `orch-scout` has a `tools:` line that does not contain `Edit` or `Write`.
  - `model-tiers.md` contains the three row prefixes and two cap lines above.
- [ ] **Step 2: Run `bash tests/run.sh`** — Expected: `FAIL tests/test_agents.sh`.
- [ ] **Step 3: Write the rubric and agents**
  - `orch-scout`: read-only search/summarise; `tools: Read, Glob, Grep, Bash`; returns findings with `file:line` refs, no edits.
  - `orch-implementer`: implement one subtask test-first within the files it is given; must not touch other files; returns changed files + test command output.
  - `orch-specialist`: design decisions, unknown-cause debugging, security, and code review; review output is a list of findings ranked by severity with a pass/fail verdict.
  - Each body states: "The caller sets your model per `model-tiers.md`; stay within the files you are given."
- [ ] **Step 4: Run `bash tests/run.sh`** — Expected: all PASS.
- [ ] **Step 5: Commit** — `git commit -m "feat: model tier rubric and role agents"`

### Task 3: Ledger re-injection hook

**Files:**
- Create: `hooks/hooks.json`, `hooks/ledger-context.sh`
- Test: `tests/test_ledger_context.sh`

**Interfaces:**
- Produces: `ledger-context.sh [project-dir]` — project dir defaults to `${CLAUDE_PROJECT_DIR:-$PWD}`. Always exits 0.
  - Ledger missing, unreadable, or its first 5 lines contain `Status: done` → prints nothing.
  - Otherwise prints, with every `\r` stripped:
    1. `[session-orchestrator] An orchestration is in progress. Ledger (.orchestration/ledger.md):`
    2. the first 150 lines of the ledger, then `... (truncated — read .orchestration/ledger.md for the rest)` if longer
    3. `Continue with the session-orchestrator:orchestrating skill. The ledger is the source of truth.`
- Produces: `hooks.json` with top-level `"hooks"` → `SessionStart` → two matcher groups (`"compact"` and `"resume"`), each with handler `{"type": "command", "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/ledger-context.sh\""}`.

- [ ] **Step 1: Write failing tests** in `tests/test_ledger_context.sh`, each in its own `make_tmp` dir:
  - `no_ledger`: output empty, exit 0.
  - `not_a_repo`: arg points to a dir that does not exist → empty, exit 0.
  - `done_ledger`: header has `Status: done` → empty.
  - `running_ledger`: output contains the intro line, the goal line `# Orchestration: add login`, a table row `| T2 |`, and the closing line.
  - `crlf_ledger`: ledger written with `\r\n` → output contains no `\r` (`assert_not_contains "$out" $'\r'`).
  - `long_ledger`: 300-line ledger → output contains the truncation line and not line 200's text.
  - `path_with_space`: project dir `"$tmp/my repo"` → same as `running_ledger`.
  - `hooks_json`: `hooks/hooks.json` contains `"compact"`, `"resume"` and `ledger-context.sh`.
- [ ] **Step 2: Run `bash tests/run.sh`** — Expected: `FAIL tests/test_ledger_context.sh`.
- [ ] **Step 3: Implement `hooks/ledger-context.sh` and `hooks/hooks.json`** — use `tr -d '\r'`, `head -n 5 | grep -q 'Status: done'`, `head -n 150`, `wc -l`.
- [ ] **Step 4: Run `bash tests/run.sh`** — Expected: all PASS. Also `claude plugin validate .` exits 0.
- [ ] **Step 5: Commit** — `git commit -m "feat: SessionStart hook re-injects the orchestration ledger"`

### Task 4: CLI worker launcher

**Files:**
- Create: `scripts/cli-worker.sh`, `settings/worker-allowlist.json`, `skills/orchestrating/references/backend-cli.md`
- Test: `tests/test_cli_worker.sh`, `tests/stub-claude.sh`

**Interfaces:**
- Produces `scripts/cli-worker.sh`, run from anywhere inside the main checkout:
  - `start <task-id> <base-branch> <model> <effort> <brief-file>` — validates id; repo root = `git rev-parse --show-toplevel`; dir = `<root>-wt/<task-id>`. If dir is already a worktree on `orch/<task-id>` → reuse; else `git worktree add -b orch/<task-id> <dir> <base>` (if the branch exists without a worktree: `git worktree add <dir> orch/<task-id>`). Then in `<dir>` runs `"$CLAUDE_BIN" -p "<brief contents>" --model <model> --effort <effort> --output-format json --permission-mode acceptEdits --settings "<allowlist>"`. Stdout = claude's JSON; progress to stderr.
  - `resume <task-id> <session-id> <message-file>` — in `<dir>` runs `"$CLAUDE_BIN" -p "<message>" --resume <session-id> --output-format json --permission-mode acceptEdits --settings "<allowlist>"`.
  - `remove <task-id>` — `git worktree remove <dir>` (no `--force`; branch kept).
  - Env: `CLAUDE_BIN` (default `claude`), `ORCH_ALLOWLIST` (default `<script dir>/../settings/worker-allowlist.json`).
  - Exit codes: `2` usage or invalid id; `3` base branch not found; `4` dir exists but is not a worktree on `orch/<task-id>`; `5` worktree missing for `resume`/`remove`; otherwise claude's exit code.
- Produces `worker-allowlist.json`: `{"permissions": {"allow": [...]}}` with `Read`, `Edit`, `Write`, `Glob`, `Grep`, `Bash(git status*)`, `Bash(git diff*)`, `Bash(git add *)`, `Bash(git commit *)`, `Bash(git push *)`, `Bash(gh pr create *)`, `Bash(gh pr view *)`, `Bash(gh pr checks *)`. README tells the user to add their test/build commands.

- [ ] **Step 1: Write `tests/stub-claude.sh` and failing `tests/test_cli_worker.sh`**
  - Stub: appends `pwd` and each arg (one per line) to `$STUB_LOG`, prints `{"session_id":"s-1","result":"ok"}`, exits 0.
  - Each test builds a temp repo with one commit on `main` (`git -c user.name=t -c user.email=t@t commit`), sets `CLAUDE_BIN=tests/stub-claude.sh`.
  - `start_creates_worktree`: dir `<repo>-wt/T1` exists on branch `orch/T1`; stdout contains `"session_id":"s-1"`; log shows pwd = worktree and contains `-p`, the brief text, `--model` `sonnet`, `--effort` `medium`, `--output-format` `json`, `--permission-mode` `acceptEdits`, `--settings`.
  - `start_rejects_bad_id`: id `../x` → exit 2, no `-wt` dir.
  - `start_missing_base`: base `nope` → exit 3, no worktree.
  - `start_reuses_existing_worktree`: run `start` twice → second exits 0, one worktree.
  - `start_in_path_with_space`: repo under `"$tmp/my repo"` → same as `start_creates_worktree`.
  - `resume_runs_in_worktree`: after start, `resume T1 s-1 msg.txt` → log has pwd = worktree, `--resume` `s-1`, message text.
  - `resume_without_worktree`: → exit 5.
  - `remove_deletes_worktree`: dir gone, branch `orch/T1` still exists.
- [ ] **Step 2: Run `bash tests/run.sh`** — Expected: `FAIL tests/test_cli_worker.sh`.
- [ ] **Step 3: Implement `scripts/cli-worker.sh` and `settings/worker-allowlist.json`**
- [ ] **Step 4: Run `bash tests/run.sh`** — Expected: all PASS.
- [ ] **Step 5: Write `backend-cli.md`** — when to pick this backend (`start_session` not loadable and `claude --version` works); the three commands above; always launch with Bash `run_in_background: true`; read `session_id` from the JSON into the ledger's session/run column; read the full report from `.orchestration/reports/<id>.md`; on a worker exit with status `blocked`, answer via `resume`; after merge, `remove`. Add a README section on the allowlist.
- [ ] **Step 6: Commit** — `git commit -m "feat: CLI worker launcher with allowlist"`

### Task 5: Worker skill

**Files:**
- Create: `skills/working/SKILL.md`, `skills/working/report-format.md`
- Create: `evals/worker-batches/prompt.md`, `evals/worker-batches/graders/{skill-fired,batches}.md`
- Create: `evals/worker-report/prompt.md`, `evals/worker-report/graders/{sections,tags}.md`
- Test: `tests/test_links.sh`

**Interfaces:**
- Consumes: `../orchestrating/references/model-tiers.md` (Task 2), agents `orch-scout` / `orch-implementer` / `orch-specialist`.
- Produces: `report-format.md` — the exact template from spec §8 (headings `# T<n> report`, `Status:`, `PR:`, `## Result`, `## Retro`, `### Went well`, `### Went badly`, `### Improve`, tags list). Task 6's orchestrator parses these headings.

- [ ] **Step 1: Write the evals (RED)**
  - `worker-batches`: `allowed_tools: [Skill, Read, Glob, Grep]`, `max_turns: 8`. Prompt = a brief for task T7 with 4 subtasks: A edits `src/a.ts` (fast), B edits `src/b.ts` (standard), C edits `src/a.ts` (standard), D is "write README section" (fast). It asks the worker to start. Graders: `tool_used` Skill matching `working`; `llm`: PASS if the posted batch plan puts A, B, D together and C after A, assigns models haiku/sonnet/sonnet/haiku, and includes a full test run between batches.
  - `worker-report`: `allowed_tools: [Skill, Read]`. Prompt = finished-task facts (PR url, changes, test output, two problems: brief unclear about API errors; Haiku failed once on tests). Graders: `regex` for each of `## Result`, `## Retro`, `### Went well`, `### Went badly`, `### Improve`; `llm`: PASS if the problems are tagged `[brief]` and `[tier]` and "Improve" has a concrete suggestion for each.
- [ ] **Step 2: Run `claude plugin eval . --case worker-batches --case worker-report`** — Expected: low score (skill missing / baseline).
- [ ] **Step 3: Write `skills/working/SKILL.md`** (frontmatter `name: working`, a description that triggers on "you are a worker" / a brief from session-orchestrator) covering spec §7 in order:
  1. Read the brief; the off-limits list is binding. On ambiguity, ask: desktop → `SendMessage` to the orchestrator id in the brief and wait; CLI → write the question to the report path with `Status: blocked`, then end.
  2. Read `../orchestrating/references/model-tiers.md`. Post the batch plan: subtasks, owned files, tier/model, batches.
  3. Batches: disjoint + independent → one message with several Agent calls (≤ `max_parallel_implementers_per_session`); shared files or dependencies → sequential; scouts and reviews always parallel. Every Agent call passes `model`. Each subtask: `orch-implementer` (TDD) → spec-compliance review → code-quality review (`orch-specialist` for deep work). Full test suite after each batch.
  4. Escalation per rubric.
  5. Verify: full test/lint/build, show output (use superpowers:verification-before-completion if installed).
  6. Push `orch/<task-id>`, `gh pr create` with goal / changes / verification / risks.
  7. Write the report per `report-format.md` to the brief's path; send the one-line done message.
  - Short fallback rules for when superpowers is not installed (TDD, review order, verification) — 1–2 lines each.
- [ ] **Step 4: Write failing `tests/test_links.sh`, then make it pass** — every relative Markdown link in `skills/**/*.md` resolves to an existing file relative to that `.md` file.
- [ ] **Step 5: Run `claude plugin eval . --case worker-batches --case worker-report`** — Expected: both pass (threshold 1.0); iterate the skill text until they do. Run `bash tests/run.sh` — all PASS.
- [ ] **Step 6: Commit** — `git commit -m "feat: working skill with report format and evals"`

### Task 6: Orchestrator skill and command

**Files:**
- Create: `skills/orchestrating/SKILL.md`
- Create: `skills/orchestrating/references/{splitting,brief-template,ledger,backend-desktop}.md`
- Create: `commands/orchestrate.md`
- Create: `evals/orch-breakdown/`, `evals/orch-resume/`, `evals/orch-wrapup/` (each `prompt.md` + `graders/`)

**Interfaces:**
- Consumes: `model-tiers.md` (Task 2), `backend-cli.md` + `scripts/cli-worker.sh` (Task 4), `../working/report-format.md` (Task 5), hook output format (Task 3).
- Produces: `/session-orchestrator:orchestrate <goal>`; the ledger format that `ledger-context.sh` reads (header line containing `Status:` within the first 5 lines).

- [ ] **Step 1: Write the evals (RED)**, all with `allowed_tools: [Skill, Read, Glob, Grep]`:
  - `orch-breakdown`: prompt invokes `/session-orchestrator:orchestrate add user profiles` with an inline repo tree (`src/db/schema.ts`, `src/api/users/*`, `src/ui/profile/*`, `docs/`) and "stop at the approval gate". Graders: `tool_used` Skill matching `orchestrat`; `llm`: PASS if it shows a table with id / task / owns / depends / tier / placement; the schema change is `self` and has no dependencies; tasks that can run at once own disjoint files; each tier fits the rubric; it asks for approval and starts nothing.
  - `orch-resume`: prompt pastes a ledger where T1 is `merged`, T2 `in-review`, T3 `planned` depending on T1. `llm`: PASS if it names T3 as ready to start, T2 as awaiting review, and does not re-plan.
  - `orch-wrapup`: prompt pastes `retros.md` with three `[tier]` notes "haiku too weak for test writing" and one `[brief]` note. `llm`: PASS if it groups by tag, proposes editing `model-tiers.md` to move test writing to `standard`, proposes a brief-template fix, asks for approval, and edits no files.
- [ ] **Step 2: Run `claude plugin eval . --case orch-breakdown --case orch-resume --case orch-wrapup`** — Expected: low score.
- [ ] **Step 3: Write the references**
  - `splitting.md`: spec §5 step 2 rules and the placement table, plus 2 short worked examples (one good split, one with overlapping files and its fix).
  - `ledger.md`: spec §4 format verbatim, status list, "update on every event", `.git/info/exclude` setup, `retros.md` and `reports/` layout.
  - `brief-template.md`: spec §7 brief contents as a fill-in template, including "Load the session-orchestrator:working skill" and the absolute report path `<main checkout>/.orchestration/reports/<task-id>.md`.
  - `backend-desktop.md`: spec §10.1 — load `mcp__ccd_session__start_session` via ToolSearch; `start_session` (`initiation: "user_asked"`, `context: "fresh"`, `use_worktree: true`, title `T<n> · <short task>`); `set_session_model` / `set_session_effort` per tier; on worker turn end read the report file; follow-ups via `SendMessage` to `local_…`; liveness via `list_sessions {"linked": true}`; refused start → `own_initiative` card + one-line notice + ledger `blocked: needs start click`.
- [ ] **Step 4: Write `skills/orchestrating/SKILL.md`** (frontmatter `name: orchestrating`) — spec §5 steps 1–7 as the procedure, each step linking its reference; the §9 escalation list as the only reasons to stop; intake checks (`git remote get-url origin`, `gh auth status`, backend detection: desktop if `start_session` loads, else CLI if `claude --version` works, else stop and tell the user); `self` tasks in their own worktree via `git worktree add`; parallel `orch-scout` at intake and parallel reviews; the spec §11 failure table (two-failure limit counting review/CI rounds, off-limits edits, conflicts, silent workers); retro handling (append to `retros.md`, write a retro for each `self` task too, use early retros to improve later briefs, wrap-up digest + proposed edits to the plugin source repo, approval required).
- [ ] **Step 5: Write `commands/orchestrate.md`** — frontmatter `description`, `argument-hint: <goal>`; body: "Use the session-orchestrator:orchestrating skill to orchestrate: $ARGUMENTS".
- [ ] **Step 6: Run evals and tests** — `claude plugin eval . --case orch-breakdown --case orch-resume --case orch-wrapup` all pass (iterate on skill text); `bash tests/run.sh` all PASS; `claude plugin validate .` exits 0.
- [ ] **Step 7: Commit** — `git commit -m "feat: orchestrating skill, references and /orchestrate command"`

### Task 7: Install and end-to-end dry run (with the user)

**Files:**
- Modify: `README.md` (add "Verified" section with results and any caveats found)
- Create: `docs/e2e-checklist.md`

- [ ] **Step 1: Write `docs/e2e-checklist.md`** — the checks below as checkboxes.
- [ ] **Step 2: Install** — `claude plugin marketplace add D:\dev\claude-orchestrator` and `claude plugin install session-orchestrator@session-orchestrator`; `claude plugin list` shows it enabled.
- [ ] **Step 3: User creates a throwaway GitHub repo** (e.g. `donVortex/orch-sandbox`) with a tiny project that has a test command; clone it locally.
- [ ] **Step 4: Desktop run** — in a new desktop session in the sandbox: `/session-orchestrator:orchestrate <3-task goal>` (one `self`, two workers). Check:
  - the breakdown waits for approval
  - workers appear as sessions with the right model/effort
  - workers load `working` (confirms the open point in spec §13)
  - parallel Agent calls happen inside a worker
  - PRs open; reports land in `.orchestration/reports/`; `retros.md` fills up
  - the orchestrator reviews and asks you to merge
  - running `/compact` in the orchestrator re-injects the ledger
  - after merges, the wrap-up digest and proposed edits appear
- [ ] **Step 5: CLI run** — same goal in a terminal session with the desktop session tools absent (`claude` in Git Bash). Check that the workers start via `cli-worker.sh`, finish in the background, and that `resume` works for a blocked worker.
- [ ] **Step 6: Record results** in `README.md`; fix anything found (each fix gets a test or eval case first); commit `docs: end-to-end verification results`.
- [ ] **Step 7: Push** `main` to `origin` (with the user's OK).
