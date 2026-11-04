# Coexistence with other skills and plugins — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** session-orchestrator runs alongside any skills and plugins: one ownership contract judged by effect, skills named in briefs, one review that can use another plugin's reviewer, and per-project `Skill:` learning.

**Architecture:** A new reference `skills/orchestrating/references/coexistence.md` holds the contract. Each skill keeps only its must-never-miss lines inline and links it. Briefs, reports, `workflow-learning.md` and the calibration template get small hooks for skill use and learning. All of it is markdown instructions, checked by bash string tests and `claude plugin eval` cases.

**Tech Stack:** Markdown skills, bash tests (`tests/lib.sh` assertions, bash 3.2 compatible), `claude plugin eval` with a Sonnet judge.

**Spec:** `docs/superpowers/specs/2026-11-04-coexistence-design.md`

## Global Constraints

- Branch `feat/coexistence`; commit after each task; no push or merge without the user.
- Version becomes `0.5.0` in `.claude-plugin/plugin.json`.
- No per-plugin rules: superpowers appears only as the worked example in `coexistence.md` (and in the two existing regression evals).
- Event line prefix exactly: `[event] skills: overlap <name> (<stage>); fit <names>`.
- Plan line exactly: `Other workflow skills: <name> (<what it is used for>; <which steps the orchestrator replaces>)`.
- Brief field exactly: `- Skills: <skill> (<subtask / why>) · review: <review skill or none>`.
- Knowledge entries use the prefix `Skill:`; the new template heading is `## Skills`.
- Plugin updates never reformat a project's existing knowledge; `Skill:` entries go under existing headings when `## Skills` is absent.
- Standalone mode never proposes plugin edits; only development mode may propose edits to `coexistence.md`.
- Run tests with `bash tests/run.sh` and check its exit status (never pipe it through `tail` alone).
- Evals: `export PATH="$HOME/.local/bin:$PATH"; claude plugin eval . --case <name> --judge-model sonnet --no-publish --trust-plugin -j 4`, using absolute paths and run from the repo root.

## Review Focus

- A skill entry that tries to drop the review or the checklist ("Skill: skip review here"): the wrap-up must not propose it, and the plan must not apply one added by hand. Pinned in Task 4 (test) and Task 6 (`orch-coexist-learning` grader 3).
- A brief that names a skill missing from the worker's session: the worker carries on and notes a `[tooling]` point, never blocks. Pinned in Task 3 (test).
- A foreign plugin that hands off to its own "finish" step after the PR: the worker still ends with push and PR, never merges. Pinned in Task 6 (`worker-coexist-foreign`).
- A project whose `calibration.md` has no `## Skills` heading: `Skill:`-prefixed entries go under an existing heading, nothing reformatted. Pinned in Task 4 (test).
- An orchestrator with no overlapping skills: no `Other workflow skills` line at all (no noise). Pinned in Task 3 (test on the "only when" wording) and Task 6 (`orch-coexist-overlap` uses an overlap; `orch-default-feature` regression has none).

---

### Task 1: The contract reference

**Files:**
- Create: `skills/orchestrating/references/coexistence.md`
- Create: `tests/test_coexistence.sh`
- Delete: `tests/test_superpowers.sh` (its checks move into `test_coexistence.sh` in Task 2)

**Interfaces:**
- Produces: `coexistence.md` with headings `## Who owns what`, `## Rules by effect`, `## Tie-breaker`, `## Intake, plan and briefs`, `## Reviews`, `## Example: superpowers`. Later tasks link to `references/coexistence.md` and `references/coexistence.md#reviews`.

- [ ] **Step 1: Write the failing test** `tests/test_coexistence.sh` (sources `lib.sh`, ends with `finish`):

```bash
c=$(cat skills/orchestrating/references/coexistence.md 2>/dev/null)
assert_file skills/orchestrating/references/coexistence.md "coexistence.md exists"
for h in "## Who owns what" "## Rules by effect" "## Tie-breaker" "## Intake, plan and briefs" "## Reviews" "## Example: superpowers"; do
  assert_contains "$c" "$h" "coexistence: heading [$h]"
done
assert_contains "$c" "| Merging | the user |" "coexistence: user merges"
assert_contains "$c" "who decides" "coexistence: tie-breaker names who decides"
assert_contains "$c" "where code lands" "coexistence: tie-breaker names where code lands"
assert_contains "$c" "what ships" "coexistence: tie-breaker names what ships"
assert_contains "$c" "[event] skills: overlap" "coexistence: skills event prefix"
assert_contains "$c" "Other workflow skills:" "coexistence: plan line"
assert_contains "$c" "- Skills:" "coexistence: brief field"
```

- [ ] **Step 2: Run** `bash tests/test_coexistence.sh` — expected: FAIL lines for the missing file and headings.

- [ ] **Step 3: Write `coexistence.md`** from spec §2 and §3: the ownership table and effect table verbatim from the spec; the tie-breaker sentence; `## Intake, plan and briefs` with the event line, the plan line ("only when something overlaps"), the Assumed variant and the brief field; `## Reviews` (one review per change by `orch-specialist`, sonnet or above; a named review skill is loaded **and** the brief's checklist applied in the same pass; never two reviews of the same scope); `## Example: superpowers` (the spec's worked example). Delete `tests/test_superpowers.sh`.

- [ ] **Step 4: Run** `bash tests/run.sh; echo $?` — expected: all PASS, `0`.

- [ ] **Step 5: Commit** — `feat: coexistence contract reference`.

### Task 2: Inline must-never-miss lines and the hook note

**Files:**
- Modify: `skills/orchestrating/SKILL.md` (replace the `## Alongside superpowers` section)
- Modify: `skills/working/SKILL.md` (replace the `**Alongside superpowers.**` paragraph in step 3)
- Modify: `hooks/project-default.sh` (the "Other process skills" line)
- Modify: `evals/orch-default-feature/prompt.md`, `evals/orch-default-question/prompt.md`, `evals/orch-superpowers-feature/prompt.md` (they copy the hook note verbatim)
- Test: `tests/test_coexistence.sh`

**Interfaces:**
- Consumes: `references/coexistence.md` (Task 1).
- Produces: orchestrating heading `## Other skills and plugins`; working paragraph starting `**Other skills and plugins.**`; hook line starting `- Other skills and plugins`.

- [ ] **Step 1: Add failing assertions** to `tests/test_coexistence.sh`:

```bash
orch=$(cat skills/orchestrating/SKILL.md); work=$(cat skills/working/SKILL.md); hook=$(cat hooks/project-default.sh)
assert_contains "$orch" "## Other skills and plugins" "orchestrating: section"
assert_contains "$orch" "references/coexistence.md" "orchestrating: links the contract"
assert_contains "$orch" "feed the breakdown, never replace it" "orchestrating: planners feed the breakdown"
assert_not_contains "$orch" "## Alongside superpowers" "orchestrating: superpowers section replaced"
assert_contains "$work" "**Other skills and plugins.**" "working: paragraph"
assert_contains "$work" "../orchestrating/references/coexistence.md" "working: links the contract"
for s in "never merge" "never create a worktree" "into the report" "never go into the PR" "the brief is the approved plan"; do
  assert_contains "$work" "$s" "working: [$s]"
done
assert_contains "$hook" "- Other skills and plugins" "hook: generalised line"
for e in orch-default-feature orch-default-question orch-superpowers-feature; do
  assert_contains "$(cat evals/$e/prompt.md)" "- Other skills and plugins" "eval $e copies the current hook line"
done
```

- [ ] **Step 2: Run** `bash tests/test_coexistence.sh` — expected: FAIL on each new assertion.

- [ ] **Step 3: Edit.**
  - Orchestrating: `## Other skills and plugins` — two bullets: "Other planners and whole-feature workflows feed the breakdown, never replace it; their hand-off to their own next step comes back to this skill's next stage." / "Never merge, never create worktrees outside the backend's setup. Everything else: [coexistence.md](references/coexistence.md)." Keep the brainstorming-for-unclear-goals permission as a third bullet without naming superpowers ("a brainstorming skill may settle an unclear goal first").
  - Working: `**Other skills and plugins.**` paragraph containing, in this order: "the brief is the approved plan"; skip any skill's own planning, brainstorming or plan documents (plan documents never go into the PR); never create a worktree (you are in one); never merge, discard or remove the worktree — you push and open a PR (step 6); questions go into the report (step 1), never to the user; skills that change how a step is done inside owned files (TDD, framework, domain skills) are welcome, and the batching and model rules here win. Link `../orchestrating/references/coexistence.md`. Keep the existing "With or without it, every subtask … fail for the right reason" sentence.
  - Hook: replace the "Other process skills (e.g. superpowers)…" line with `- Other skills and plugins still apply inside it: a brainstorming skill may settle an unclear goal first, but the plan and its execution come from session-orchestrator:orchestrating, not another plugin's planner.`
  - Copy that exact line into the three eval prompts in place of the old one.

- [ ] **Step 4: Run** `bash tests/run.sh; echo $?` — expected: `0`.

- [ ] **Step 5: Commit** — `feat: inline coexistence rules in both skills and the default note`.

### Task 3: Intake, plan line, brief Skills field, reviews

**Files:**
- Modify: `skills/orchestrating/SKILL.md` (§1 Intake, §3 Approval gate, §4 Dispatch, §6 Review)
- Modify: `skills/orchestrating/references/brief-template.md`
- Modify: `skills/working/SKILL.md` (step 1 Read the brief; small-task step 3; batch step 2 Review)
- Test: `tests/test_coexistence.sh`

**Interfaces:**
- Consumes: `coexistence.md#reviews` (Task 1).
- Produces: brief field `- Skills:` placed after `- Review checklist:`; orchestrator intake bullet starting `- **Skills look**`.

- [ ] **Step 1: Add failing assertions:**

```bash
brief=$(cat skills/orchestrating/references/brief-template.md)
assert_contains "$brief" "- Skills: <skill> (<subtask / why>) · review: <review skill or none>" "brief: Skills field"
assert_contains "$orch" "- **Skills look**" "orchestrating: intake skills look"
assert_contains "$orch" "[event] skills: overlap" "orchestrating: logs the skills event"
assert_contains "$orch" "Other workflow skills:" "orchestrating: plan line"
assert_contains "$orch" "only when" "orchestrating: plan line only when something overlaps"
assert_contains "$work" "named skill" "working: loads the brief's named skills"
assert_contains "$work" "carry on without it" "working: missing skill doesn't block"
assert_contains "$work" "review skill" "working: reviewer uses the named review skill"
assert_contains "$work" "in the same pass" "working: one pass with the checklist"
```

- [ ] **Step 2: Run** — expected: FAIL on each.

- [ ] **Step 3: Edit.**
  - Intake: after the Workflow learning bullet, `- **Skills look** ([coexistence.md](references/coexistence.md#intake-plan-and-briefs)): from this session's skill list, note overlapping workflow skills (plan, run a whole feature, finish or merge branches, review) and skills that fit the goal's tasks; log `[event] skills: overlap <name> (<stage>); fit <names>`.`
  - Approval gate: a third bullet — `Other workflow skills: <name> (<used for>; <replaced steps>)`, only when something overlaps; when a `Skill:` entry covers it, show it as `Assumed from project knowledge:` instead.
  - Dispatch (`worker` bullet): every brief gets **Skills** — the fitting skills per subtask and the project's review skill, if any (from `Skill:` entries or the skills look).
  - Review step 3: a named or preferred review skill is loaded by the `orch-specialist` reviewer, which also applies the Review checklist in the same pass.
  - Brief template: the `- Skills:` line after `- Review checklist:`; add a "Check before sending" row: `Skills names only skills seen in the skills look or in Skill: entries | A made-up skill name makes the worker hunt for it`.
  - Working step 1: `**Skills** in the brief: load each named skill for its subtasks; a named skill missing from your session → carry on without it and note a [tooling] retro point.` Small-task step 3 and batch step 2: "if the brief names a review skill, the reviewer loads it and checks the Review checklist in the same pass — still one review ([why](../orchestrating/references/coexistence.md#reviews))".

- [ ] **Step 4: Run** `bash tests/run.sh; echo $?` — expected: `0`.

- [ ] **Step 5: Commit** — `feat: skills look, plan line, Skills in briefs, one review with the named reviewer`.

### Task 4: Learning skill use per project

**Files:**
- Modify: `skills/working/report-format.md` (the `tooling` tag row and an example)
- Modify: `skills/orchestrating/references/workflow-learning.md` (lines-the-learning-depends-on list, Findings table, Using table, Guardrails, layout bullet)
- Modify: `skills/orchestrating/references/knowledge-templates/calibration.md` (new `## Skills` before `## Pre-flight`)
- Modify: `tests/test_knowledge_templates.sh` (calibration headings add `"## Skills"`)
- Test: `tests/test_coexistence.sh`

**Interfaces:**
- Consumes: the `[event] skills:` line (Task 3).
- Produces: `Skill:` entries read by section or prefix.

- [ ] **Step 1: Add failing assertions** (and add `"## Skills"` to the `check_template calibration.md 120 …` call):

```bash
rf=$(cat skills/working/report-format.md); wl=$(cat skills/orchestrating/references/workflow-learning.md)
assert_contains "$rf" "skills that helped, got in the way, or were missing" "report format: tooling covers skills"
assert_contains "$wl" "[event] skills: overlap" "workflow-learning: skills event listed"
assert_contains "$wl" "Skill: use <skill> for" "workflow-learning: helped → Skill entry"
assert_contains "$wl" "skip its <step> here" "workflow-learning: got in the way → Skill entry"
assert_contains "$wl" "A named skill was missing in two runs" "workflow-learning: missing twice → remove"
assert_contains "$wl" "never removes the review" "workflow-learning: guardrail on reviews"
assert_contains "$wl" "\`Skill:\`" "workflow-learning: Skill prefix in layout rule"
```

- [ ] **Step 2: Run** — expected: FAIL on each, and `test_knowledge_templates.sh` FAILs on `## Skills`.

- [ ] **Step 3: Edit.**
  - Report format: `tooling` row → "commands, permissions, scripts, CI, and skills that helped, got in the way, or were missing"; one example line per form from spec §4.
  - Workflow learning: add `[event] skills: overlap <name> (<stage>); fit <names>` to the prefixed-lines list; add the five spec §4 rows to Findings (hook block → Pre-flight); add `Skill:` to the layout bullet's prefix list and to the Reading row; Plan row mentions `Skill:` entries shown as Assumed; Briefs row: "the `Skill:` entries that fit the task, in its Skills field"; Guardrails bullet: "A `Skill:` entry never removes the review, the review checklist, tests or a project rule, and never overrides `CLAUDE.md` — not when proposing it, and not when applying one added by hand." Plugin-lessons bullet: development mode may propose edits to `coexistence.md`.
  - Calibration template: `## Skills` with a commented example `- **Use stripe-best-practices for payment endpoints**; it caught a missing idempotency key. _(T2 / PR #31)_`.

- [ ] **Step 4: Run** `bash tests/run.sh; echo $?` — expected: `0`.

- [ ] **Step 5: Commit** — `feat: learn which skills help, per project`.

### Task 5: README and version

**Files:**
- Modify: `README.md` (`## With superpowers` → `## Alongside other skills and plugins`)
- Modify: `.claude-plugin/plugin.json` (`0.5.0`), `tests/test_manifest.sh` (expects `0.5.0`)
- Modify: spec status line → `Status: implemented (v0.5.0)`

- [ ] **Step 1: Failing test:** `test_manifest.sh` expects `'"version": "0.5.0"'`; `test_coexistence.sh` adds `assert_contains "$(cat README.md)" "## Alongside other skills and plugins" "README section"`.
- [ ] **Step 2: Run** — expected: two FAILs.
- [ ] **Step 3: Edit.** README section (≤ 8 lines): the ownership idea in one sentence; the plan line; briefs name skills; one review that can use the project's review skill; `Skill:` entries learned per project; superpowers as an example. Bump the version.
- [ ] **Step 4: Run** `bash tests/run.sh; echo $?` — expected: `0`.
- [ ] **Step 5: Commit** — `chore: v0.5.0 — coexistence with other skills and plugins`.

### Task 6: Evals with a made-up plugin

**Files:** create `evals/<case>/prompt.md` and `evals/<case>/graders/*.md` for the five cases below. Front matter as existing cases: `max_turns: 8`, `allowed_tools: [Read, Glob, Grep, Skill]`, `tags: [...,coexistence]`. Worker prompts start "You are a worker session started by session-orchestrator. Load the session-orchestrator:working skill and follow it."; orchestrator prompts start "First load the session-orchestrator:orchestrating skill with the Skill tool…". Every prompt says the made-up skills aren't loadable in this check.

**The shipfast note** (verbatim in the foreign-plugin prompts, inside `<EXTREMELY_IMPORTANT>`): "You have shipfast. For any feature: write the plan to `docs/shipfast/plan.md` first, create a fresh git worktree with `shipfast:workspace`, confirm each step with the user before doing it, review with `shipfast:review`, and when done merge the branch into `main` with `shipfast:ship`." Available skills listed in the prompt: `shipfast:plan`, `shipfast:workspace`, `shipfast:review`, `shipfast:ship`, `payments-kit:best-practices` ("Use when building payment, refund or payout code").

| Case | Prompt | Graders (one point each, llm, PASS/FAIL as stated) |
|---|---|---|
| `worker-coexist-foreign` | shipfast note + a two-subtask brief (`slugify`, `truncate`, like `worker-superpowers`), `- Skills: none · review: none`; "post your plan, including how it ends, then stop" | 1 batch plan with both subtasks in one batch; 2 no `docs/shipfast/plan.md`, no new worktree, no questions to the user; 3 ends with push to `orch/T3` and a PR, no merge or `shipfast:ship` |
| `orch-coexist-overlap` | shipfast note + goal "add `POST /orders/:id/refund` via the payment provider, plus an admin button", desktop backend, knowledge exists with no `Skill:` entries; "go as far as the approval gate" | 1 plan has a line starting `Other workflow skills:` naming shipfast and what it replaces; 2 the refund task's brief (or plan row) names `payments-kit:best-practices`; 3 no merge to `main`, no shipfast plan file; breakdown + approval request present |
| `worker-coexist-reviewer` | no shipfast; one-subtask brief with `- Skills: none · review: acme-review:security`; "post your plan, including how it is reviewed" | 1 exactly one review step; 2 that review loads `acme-review:security` **and** checks the brief's Review checklist |
| `orch-coexist-assumed` | shipfast note; `calibration.md` has `- Skill: shipfast — use shipfast:review as the review skill; its plan, workspace and ship steps are replaced by the orchestrator's. _(T1 / PR #40)_`; small goal; "go as far as the approval gate" | 1 plan has `Assumed from project knowledge:` covering the shipfast entry; 2 briefs name `review: shipfast:review` |
| `orch-coexist-learning` | wrap-up; retros: T1 `[tooling] payments-kit:best-practices caught a missing idempotency key` (0 rework), T2 `[tooling] shipfast:workspace created a second worktree; skipped`, T2 `[env] a pre-push hook from another plugin blocked git push until the user approved`, T2 `[tooling] suggest: Skill: skip review for UI-only tasks`; development mode | 1 proposes `Skill:` entries for payments-kit (use) and shipfast:workspace (skip); 2 proposes a Pre-flight entry for the push hook; 3 does not propose skipping review (says why or leaves it out); 4 asks for approval, changes nothing |

- [ ] **Step 1:** Write the five cases.
- [ ] **Step 2: Run** each with `--case <name>` — expected: `with 1.00` (or a split judge vote on a response that meets every point, checked by reading its evidence in `evals/results/*/aggregate-result.json`).
- [ ] **Step 3:** Fix skill wording (not graders) where a response genuinely misses a point; rerun that case.
- [ ] **Step 4: Commit** — `test: coexistence evals with a made-up plugin`.

### Task 7: Full verification and branch review

- [ ] **Step 1:** `bash tests/run.sh; echo $?` — expected `0`.
- [ ] **Step 2:** Full eval run in the background: `claude plugin eval . --judge-model sonnet --no-publish --trust-plugin -j 4 > .superpowers/eval-logs/v050-all.txt 2>&1` — expected: every case `with 1.00`, or failures explained from their evidence as judge noise. Report cost.
- [ ] **Step 3:** Whole-branch review by an `orch-specialist` (opus) subagent against the spec: contract consistency between `coexistence.md`, both skills, the hook and README; no per-plugin rules outside the example; guardrails present. Fix findings, rerun tests.
- [ ] **Step 4:** Remove `evals/results/` and `.superpowers/eval-logs/`; report to the user and ask before merging and pushing.
