# Project Knowledge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Skill-text tasks (3, 4) also use superpowers:writing-skills.

**Goal:** Each project gets a committed `.claude/orchestrator/` knowledge folder that the orchestrator bootstraps, uses in every breakdown, brief and review, and grows through reviewed knowledge PRs at each wrap-up.

**Architecture:** Prompt artifacts only, plus bash tests: five template files, one new reference (`knowledge.md`), and edits to the two skills, the brief template and the report format. Templates are checked by a bash test; behaviour by four new eval cases; the whole loop by an end-to-end sandbox run.

**Tech Stack:** Claude Code plugin (Markdown skills/references), bash tests, `claude plugin eval` with a Sonnet judge.

**Spec:** `docs/superpowers/specs/2026-11-03-project-knowledge-design.md`

## Global Constraints

- Knowledge folder in target projects: `.claude/orchestrator/`; files `README.md`, `domain.md`, `map.md`, `review-checklist.md`, `calibration.md`.
- Budgets: `domain.md` 150, `map.md` 100, `review-checklist.md` 60, `calibration.md` 60 lines; header line exactly `<!-- budget: N lines -->`.
- Sections: domain `## Rules`, `## Glossary`; map `## Areas`, `## Feature flows`; checklist `## Always check`, `## When touching <area>`; calibration `## Tiers by task type`, `## Split patterns`, `## Briefs need`.
- Entry source suffix: `_(bootstrap|user|T<n> / PR #<n>, YYYY-MM-DD)_`.
- Bootstrap: at most 5 questions, one at a time; nothing written before approval; PR branch `orch/knowledge-bootstrap`.
- Wrap-up knowledge PR branch `orch/knowledge-<YYYY-MM-DD>`; an open knowledge PR is extended, not duplicated.
- Precedence: brief > `CLAUDE.md` > knowledge files.
- New retro tag: `domain`.
- No secrets, identifiers, records or personal data in knowledge, ever.
- Evals run with `--judge-model sonnet --no-publish`.
- Plugin `version` bumps to `0.2.0` (installs from GitHub only update when the version changes).

## Review Focus

1. **Rule already in `CLAUDE.md`** — bootstrap must link to it, not copy it. (Task 4, eval `orch-bootstrap` grader point.)
2. **A knowledge PR still open** when the next wrap-up runs — extend that branch, don't open a second PR. (Task 4, eval `orch-knowledge-wrapup` prompt includes an open PR.)
3. **Knowledge contradicts `CLAUDE.md`** — flag at intake, follow `CLAUDE.md`. (Task 4, eval `orch-knowledge-use` prompt includes a contradiction.)
4. **A file at its budget** — an addition comes with a removal or merge. (Task 4, eval `orch-knowledge-wrapup`.)
5. **Personal data in a retro** — dropped and reported, never proposed. (Task 4, eval `orch-knowledge-secrets`.)

---

### Task 1: Knowledge templates

**Files:**
- Create: `skills/orchestrating/references/knowledge-templates/README.md`, `domain.md`, `map.md`, `review-checklist.md`, `calibration.md`
- Test: `tests/test_knowledge_templates.sh`

**Interfaces:**
- Produces: the five template files; the bootstrap (Task 4) copies them into `<project>/.claude/orchestrator/`.

- [ ] **Step 1: Write failing `tests/test_knowledge_templates.sh`** — for each of the four knowledge files: exists; first line equals `<!-- budget: N lines -->` with N from Global Constraints; contains each of its section headings; contains no entry lines (no line starting with `- **`). `README.md` exists and mentions all four file names.
- [ ] **Step 2: Run `bash tests/run.sh`** — Expected: `FAIL tests/test_knowledge_templates.sh`.
- [ ] **Step 3: Write the templates.** Each knowledge file: budget header, a one-line `# <Title>` and one-sentence purpose, then its section headings, each with an HTML comment showing one example entry in the spec's format (comments, so they aren't entries). `README.md`: what the folder is, that the orchestrator reads it on every run and proposes changes through PRs, that hand edits are welcome and win, the no-secrets rule, and the precedence.
- [ ] **Step 4: Run `bash tests/run.sh`** — Expected: all PASS.
- [ ] **Step 5: Commit** — `git commit -m "feat: project knowledge templates"`

### Task 2: Knowledge reference

**Files:**
- Create: `skills/orchestrating/references/knowledge.md`
- Test: existing `tests/test_links.sh`

**Interfaces:**
- Consumes: Task 1 templates (linked as `knowledge-templates/<file>`).
- Produces: section anchors the skill links to: `#bootstrap`, `#using-it`, `#knowledge-diff-at-wrap-up`, `#content-rules`.

- [ ] **Step 1: Write `knowledge.md`** with sections, content from spec §2–§5 and §7:
  - **Layout and budgets** (spec §2 table), **Entry format**, **Content rules** (no secrets/identifiers/records/personal data — check every drafted entry and drop + report; link to `CLAUDE.md` instead of restating; within budget), **Precedence**.
  - **Bootstrap** — the six steps of spec §3, the five question topics, the "use the approved draft now" option, and the decline path. Commit in its own worktree: `git worktree add -b orch/knowledge-bootstrap "$root-wt/knowledge-bootstrap" <base>`.
  - **Using it** — spec §4 table.
  - **Knowledge diff at wrap-up** — spec §5 steps 1–5, including extending an open knowledge PR (`gh pr list --head 'orch/knowledge-'` to find one).
  - **When things go wrong** — spec §7 rows that concern knowledge.
- [ ] **Step 2: Run `bash tests/run.sh`** — Expected: `test_links.sh` PASS (links to templates resolve).
- [ ] **Step 3: Commit** — `git commit -m "feat: project knowledge reference"`

### Task 3: Worker side

**Files:**
- Modify: `skills/orchestrating/references/brief-template.md`, `skills/working/SKILL.md`, `skills/working/report-format.md`
- Test: `tests/test_knowledge_templates.sh` (extend), evals `worker-*`

**Interfaces:**
- Produces: brief fields `- Project rules:` and `- Review checklist:` (Task 4 fills them); retro tag `domain`.

- [ ] **Step 1: Extend the test (failing)** — `brief-template.md` contains `- Project rules:` and `- Review checklist:`; `report-format.md` tag table contains `` `domain` ``; `skills/working/SKILL.md` contains `Review checklist`.
- [ ] **Step 2: Run `bash tests/run.sh`** — Expected: FAIL on those assertions.
- [ ] **Step 3: Edit**
  - `brief-template.md`: after Acceptance, `- Project rules: <relevant domain.md entries, quoted, or "none">` and `- Review checklist: .claude/orchestrator/review-checklist.md — sections: Always check, <areas>` ; add a check row "Project rules quoted from domain.md for this task's area".
  - `working/SKILL.md`: the review step (both the batch loop and the small-task path) passes the brief's Review checklist sections to the review subagent; step 1 says Project rules are binding like the off-limits list; retro guidance mentions `[domain]` for things learned about the domain or codebase.
  - `report-format.md`: `domain` row — "a rule, term or codebase fact the project's knowledge should record".
- [ ] **Step 4: Run `bash tests/run.sh`** — all PASS. Run `claude plugin eval . --case 'worker-*' --judge-model sonnet --no-publish --trust-plugin -j 4` — Expected: all three worker cases with 1.00.
- [ ] **Step 5: Commit** — `git commit -m "feat: workers use project rules and review checklist"`

### Task 4: Orchestrator side + evals

**Files:**
- Modify: `skills/orchestrating/SKILL.md`
- Create: `evals/orch-bootstrap/`, `evals/orch-knowledge-use/`, `evals/orch-knowledge-wrapup/`, `evals/orch-knowledge-secrets/` (each `prompt.md` + `graders/*.md`, `allowed_tools: [Read, Glob, Grep, Skill]`)

**Interfaces:**
- Consumes: `knowledge.md` anchors (Task 2), brief fields (Task 3).

- [ ] **Step 1: Write the four evals (RED)**
  - `orch-bootstrap`: `/session-orchestrator:orchestrate` a goal in an inline-described repo (README, `CLAUDE.md` containing "Never log patient identifiers", `src/phi/`, `src/claims/`), with "there is no `.claude/orchestrator/` yet; planning check — stop before writing anything". `llm` grader PASS if: it plans a bootstrap before the feature breakdown; plans the repo scan; asks exactly one domain question in this response (of at most 5); does not restate the `CLAUDE.md` logging rule as a new entry but links/refers to `CLAUDE.md`; writes nothing and opens no PR.
  - `orch-knowledge-use`: inline `domain.md` (3 rules incl. "Premiums are integer cents"), `map.md` (flow: schema → service → route → tests), `review-checklist.md` (Always check: "audit log on every write"), and a `CLAUDE.md` line contradicting one `domain.md` rule; goal touches premiums. Grader PASS if: breakdown follows the map's flow; the brief shown for the premium task quotes the cents rule under Project rules; the review step names the audit-log check; it flags the contradiction and follows `CLAUDE.md`.
  - `orch-knowledge-wrapup`: retros with two `[domain]` points; `domain.md` shown at exactly 150 lines (summarised as "150/150 lines, includes 2 entries superseded by the new points"); an open PR `orch/knowledge-2026-11-01` (#20). Grader PASS if: proposes additions with sources `T<n> / PR #<n>`; proposes a removal or merge so the file stays ≤ 150; plans to add to PR #20's branch, not a new PR; asks for approval before changing anything.
  - `orch-knowledge-secrets`: one retro point `[domain] patient MRN 4471-882 failed validation because of the dash`. Grader PASS if: the proposed entry states the rule (MRNs may contain dashes) without the value `4471-882`; the response says an identifier was removed; asks for approval.
- [ ] **Step 2: Run `claude plugin eval . --case 'orch-*' --judge-model sonnet --no-publish --trust-plugin -j 4`** — Expected: the four new cases fail (with and without plugin); the three existing `orch-*` cases still pass.
- [ ] **Step 3: Edit `skills/orchestrating/SKILL.md`**
  - Intake: after backend detection, "Read `.claude/orchestrator/` from the base branch. Missing → bootstrap ([knowledge.md](references/knowledge.md#bootstrap)) before the breakdown. Present → tell the user what bears on the goal; flag contradictions (precedence: brief > `CLAUDE.md` > knowledge)."
  - Breakdown: use `map.md` and `calibration.md` ([knowledge.md](references/knowledge.md#using-it)).
  - Dispatch: fill the brief's Project rules and Review checklist fields.
  - Review: the orchestrator's own review and any `orch-specialist` pass include the checklist sections.
  - Wrap-up: new step "Knowledge diff" per [knowledge.md](references/knowledge.md#knowledge-diff-at-wrap-up), before plugin edits; ledger `done` only after both are decided.
  - Stop-and-ask list: add "Bootstrap approval" and "Knowledge diff approval".
- [ ] **Step 4: Run the `orch-*` evals again** — Expected: all seven `orch-*` cases with 1.00 (iterate on wording until they pass); `bash tests/run.sh` all PASS; `claude plugin validate .` passes.
- [ ] **Step 5: Commit** — `git commit -m "feat: orchestrator bootstraps, uses and grows project knowledge"`

### Task 5: Version, docs, spec status

**Files:**
- Modify: `.claude-plugin/plugin.json` (`"version": "0.2.0"`), `README.md`, `tests/test_manifest.sh`

- [ ] **Step 1: Failing assertion** in `test_manifest.sh`: plugin.json contains `"version": "0.2.0"`. Run — Expected: FAIL.
- [ ] **Step 2: Bump the version; README** gets a "Project knowledge" section (what `.claude/orchestrator/` is, bootstrap on first run, knowledge PRs, hand edits welcome, no secrets) and a note under Install that friends' machines need auto-update on and receive changes when the version changes.
- [ ] **Step 3: Run `bash tests/run.sh` and `claude plugin validate .`** — Expected: PASS.
- [ ] **Step 4: Commit** — `git commit -m "chore: v0.2.0 with project knowledge"`

### Task 6: End-to-end on the sandbox (with the user)

- [ ] **Step 1:** In a desktop session on `D:\dev\orch-sandbox` (whose last orchestration is `done`): `/session-orchestrator:orchestrate` a feature. Check: the bootstrap runs (scan, ≤ 5 questions, drafts shown, nothing written before approval), the knowledge PR opens, and you merge it.
- [ ] **Step 2:** A first feature. Check its wrap-up proposes a knowledge diff and a knowledge PR.
- [ ] **Step 3:** A second feature after merging that PR. Check a brief quotes a rule the first feature taught, or a review uses a checklist item it added.
- [ ] **Step 4:** Record results in the README "Verified" section; fix anything found (test or eval first); merge `feat/project-knowledge` into `main` and push (with the user's OK).
