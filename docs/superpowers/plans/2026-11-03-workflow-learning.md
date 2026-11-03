# Workflow Learning Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Skill-text tasks (2, 3) also use superpowers:writing-skills.

**Goal:** The orchestrator measures each task's demand on the user's attention and its rework from tagged ledger events, and turns what it finds into recipes, learned defaults, pre-flight checks and rework fixes in the project's `calibration.md`, proposed through the existing knowledge diff.

**Architecture:** Prompt artifacts plus bash tests: the calibration template gains three sections; a new reference `workflow-learning.md` defines event kinds, the counts table and the findings→proposals rules; `ledger.md`, `knowledge.md` and the orchestrating skill are wired to it. Behaviour is checked by three new evals and a sandbox run.

**Tech Stack:** Claude Code plugin (Markdown skills/references), bash tests, `claude plugin eval --judge-model sonnet`.

**Spec:** `docs/superpowers/specs/2026-11-03-workflow-learning-design.md`

## Global Constraints

- Event kind tags, exactly: `[ask-user]`, `[approval]`, `[prompt]`, `[start-click]`, `[failed]`, `[changes]`, `[escalate]`, `[worker-q]`, `[event]`.
- `[ask-user]` line format: `[ask-user] <question> → <answer>`.
- Expected stops are `[event]`: the one breakdown approval, each merge request, the knowledge-diff approval.
- Counts table columns, in order: `task | recipe | ask-user | approval | prompt | start-click | failed | changes | escalate | worker-q`, plus a `run` row.
- New calibration sections: `## Recipes`, `## Learned defaults`, `## Pre-flight`; a new calibration file's budget header: `<!-- budget: 120 lines -->`.
- Plan labels, exactly: `Assumed from project knowledge:` and `Following recipe:`.
- Learned default threshold: same question, same answer, in two or more runs; removal after two overrides.
- Defaults never override `CLAUDE.md`, a project rule or the goal, and never cover safety, data handling or money rules.
- Existing projects keep their own files, headings and budgets (project knowledge §6a).
- Plugin version `0.3.0`.

## Review Focus

1. **Archived ledgers written before event tags existed** — old lines have no kind tag; detection of repeated questions must skip them, never guess. (Task 3, eval `orch-workflow-wrapup` includes an untagged archived ledger.)
2. **An existing `calibration.md` at budget 60 without the new sections** — no budget change, entries go under the closest heading or the user is asked once before a new section. (Task 3, eval `orch-workflow-wrapup` grader.)
3. **A learned default contradicting `CLAUDE.md`** — not applied, flagged. (Task 3, eval `orch-workflow-default-guard`.)
4. **A task that doesn't fit its area's recipe** (different kind of change) — no `Following recipe` label for it. (Task 3, eval `orch-workflow-use` grader.)
5. **Merge requests counted as attention** — they are expected stops. (Task 3, eval `orch-workflow-wrapup` grader.)

---

### Task 1: Calibration template

**Files:**
- Modify: `skills/orchestrating/references/knowledge-templates/calibration.md`, `skills/orchestrating/references/knowledge.md` (layout table budget)
- Test: `tests/test_knowledge_templates.sh`

**Interfaces:**
- Produces: calibration sections `## Recipes`, `## Learned defaults`, `## Pre-flight` that Tasks 2–3 refer to.

- [ ] **Step 1: Failing test** — change `check_template calibration.md 60 ...` to budget `120` and add the three new headings to its heading list; assert `knowledge.md` layout table row for `calibration.md` contains `| 120 |`.
- [ ] **Step 2: Run `bash tests/run.sh`** — Expected: FAIL on the budget and headings.
- [ ] **Step 3: Edit** — template: budget header 120, three new sections each with a commented example entry (recipe, default, pre-flight) in the spec's formats; `knowledge.md` layout tree and table: calibration budget 120 and the new section names.
- [ ] **Step 4: Run `bash tests/run.sh`** (check the exit status, not the last line) — Expected: exit 0.
- [ ] **Step 5: Commit** — `git commit -m "feat: calibration template gains recipes, learned defaults, pre-flight"`

### Task 2: Workflow-learning reference and ledger tags

**Files:**
- Create: `skills/orchestrating/references/workflow-learning.md`
- Modify: `skills/orchestrating/references/ledger.md`
- Test: `tests/test_workflow_learning.sh`

**Interfaces:**
- Consumes: Task 1 section names.
- Produces: anchors `#event-kinds`, `#counts-table`, `#findings-to-proposals`, `#using-what-was-learned` for the skill (Task 3).

- [ ] **Step 1: Failing `tests/test_workflow_learning.sh`** — `workflow-learning.md` exists and contains each of the nine tags, the counts-table header line exactly as in Global Constraints, both plan labels, and the headings `## Event kinds`, `## Counts table`, `## Findings to proposals`, `## Using what was learned`, `## Guardrails`; `ledger.md` contains `[ask-user]` and the sentence about kind tags.
- [ ] **Step 2: Run** — Expected: FAIL.
- [ ] **Step 3: Write `workflow-learning.md`** — spec §2 (tags table, `[ask-user]` format, expected stops), §2 counts table and per-task vs `run` rows, §3 recipes (match by area and kind, track record, same-output bar), §4 findings→proposals table including "skip untagged lines from older ledgers" and the two-run threshold, §5 use table, §6 guardrails. **Edit `ledger.md`**: Events section says every line starts with a kind tag from workflow-learning.md, with three example lines.
- [ ] **Step 4: Run `bash tests/run.sh`** — Expected: exit 0 (links resolve).
- [ ] **Step 5: Commit** — `git commit -m "feat: workflow-learning reference and tagged ledger events"`

### Task 3: Orchestrator wiring + evals

**Files:**
- Modify: `skills/orchestrating/SKILL.md`
- Create: `evals/orch-workflow-wrapup/`, `evals/orch-workflow-use/`, `evals/orch-workflow-default-guard/` (prompt + one grader file per point)

**Interfaces:**
- Consumes: Task 2 anchors and labels.

- [ ] **Step 1: Write the evals (RED)**, each `allowed_tools: [Read, Glob, Grep, Skill]`, prompt starting "First load the session-orchestrator:orchestrating skill with the Skill tool":
  - `orch-workflow-wrapup`: wrap-up after one merged task T1 (PR #20) of a kind with no recipe. Ledger events (tagged): `[ask-user] Export new helpers from the area's index.js? → yes`, `[prompt] user ran /add-dir for the worktrees folder`, `[event] merge requested for PR #20`. Archived ledger (from before tags) contains the untagged line `- 10:02 asked user: export new helpers from the area's index.js? yes`, and a tagged archived ledger contains `[ask-user] Export new helpers from the area's index.js? → yes`. Existing `calibration.md` has `<!-- budget: 60 lines -->`, 40 lines, sections Tiers / Split patterns / Briefs need only. Graders: (1) shows the counts table with ask-user 1, prompt 1 and the merge not counted; (2) proposes a learned default "export new helpers from the area's index.js" with sources; (3) proposes a pre-flight check for `/add-dir`; (4) proposes a new recipe for T1's kind with track record 0 rework; (5) keeps `calibration.md` within its own 60-line budget and either places the new entries under the closest existing heading or asks once before adding the new sections; (6) asks for approval, changes nothing.
  - `orch-workflow-use`: new goal "add `averagePrice(cents)` in `src/money/`" plus "add a CSV export of prices in `src/export/`". `calibration.md` has a recipe "Money helper (`src/money/<fn>.js`)", a learned default "export new helpers from the area's index.js", a pre-flight "ask for `/add-dir <repo>-wt` before the first self task". Graders: (1) intake applies the pre-flight (mentions `/add-dir` up front); (2) the plan lists `Assumed from project knowledge:` with the index.js export; (3) the money task shows `Following recipe: Money helper`; (4) the CSV task shows no recipe label; (5) the money task's brief carries the recipe's must-haves.
  - `orch-workflow-default-guard`: `calibration.md` learned default "assume rounding half-up"; `CLAUDE.md` says "Round money half-even"; goal touches rounding. Graders: (1) does not list the half-up default as assumed; (2) flags the contradiction; (3) follows `CLAUDE.md`.
- [ ] **Step 2: Run `run-cases`-style eval for the three cases, `--ablation none`** — Expected: low scores.
- [ ] **Step 3: Edit `SKILL.md`** — Intake: run calibration Pre-flight checks before planning and tell the user up front ([using what was learned](references/workflow-learning.md#using-what-was-learned)). Breakdown: match tasks to Recipes. Approval gate: list `Assumed from project knowledge:` and `Following recipe:` lines. Track: every ledger event gets its kind tag ([event kinds](references/workflow-learning.md#event-kinds)). Wrap-up: before the knowledge diff, show the [counts table](references/workflow-learning.md#counts-table) and add the [findings→proposals](references/workflow-learning.md#findings-to-proposals) to the diff.
- [ ] **Step 4: Run the three cases with baseline** — Expected: each 1.00 with the plugin (iterate wording). Run all evals (`claude plugin eval . --judge-model sonnet --no-publish --trust-plugin -j 4`, in the background) — Expected: no case below its previous result except judge variance confirmed by a re-run.
- [ ] **Step 5: Commit** — `git commit -m "feat: orchestrator measures attention and rework and learns workflows"`

### Task 4: Version and docs

**Files:**
- Modify: `.claude-plugin/plugin.json` (`0.3.0`), `tests/test_manifest.sh`, `README.md`, `docs/superpowers/specs/2026-11-03-workflow-learning-design.md` (status)

- [ ] **Step 1: Failing assertion** — `test_manifest.sh` expects `"version": "0.3.0"`. Run — Expected: FAIL.
- [ ] **Step 2: Bump version; README** — "Workflow learning" section (what is measured, recipes, learned defaults shown as "Assumed from project knowledge", pre-flight, all approved via knowledge PRs); spec status "implemented".
- [ ] **Step 3: Run tests and `claude plugin validate .`** — Expected: exit 0, validation passed.
- [ ] **Step 4: Commit** — `git commit -m "chore: v0.3.0 with workflow learning"`

### Task 5: Final review

- [ ] Whole-branch review by a fresh reviewer on the most capable model (executing-plans "Final Review"), with this plan's Review Focus verbatim; one fix pass, each fix with a failing check first.

### Task 6: End-to-end on the sandbox (with the user)

- [ ] **Step 1:** In the sandbox (knowledge on `main` from PRs #9–#13), a feature run whose wrap-up proposes a recipe (and any defaults/pre-flight found); merge the knowledge PR.
- [ ] **Step 2:** A further money-helper feature: check the plan shows `Following recipe:` and `Assumed from project knowledge:`, intake runs the pre-flight, and the wrap-up's counts table shows zero `[ask-user]` and zero rework.
- [ ] **Step 3:** Record results in README "Verified"; merge into `main` and push (with the user's OK).
