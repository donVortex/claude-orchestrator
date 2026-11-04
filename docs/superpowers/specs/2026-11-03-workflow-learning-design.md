# Workflow learning — Design

Date: 2026-11-03
Status: implemented (v0.3.0)
Builds on: [2026-11-03-project-knowledge-design.md](2026-11-03-project-knowledge-design.md)

## 1. Intent

Project knowledge makes the orchestrator expert in a project's domain. Workflow learning makes it better at **how work gets done** in that project: each kind of task should need less of the user's attention and less rework over time, with the same output. Today that only happens when a worker happens to notice something in its retro; this design measures it and turns what it finds into proposals.

**Success looks like:** the same kind of task in the same project, run again, finishes with fewer questions to the user, fewer extra stops, and fewer failed or sent-back rounds, and when it doesn't, the wrap-up says why and proposes a fix.

### Decisions made with the user

| Topic | Decision |
|---|---|
| What "better" means | **The user's attention** (questions, extra approvals, permission prompts, start clicks) and **rework** (failed rounds, changes requested, escalations, worker questions). Not wall-clock time or token cost. |
| What is learned | Task recipes; fewer interruptions (learned defaults); pre-flight checks; rework causes. |
| Learned answers at runtime | Used automatically and listed under "Assumed from project knowledge" in the plan the user approves anyway; the user can override in the same reply. |
| Where it lives | Extends `calibration.md` (approach A); rework causes go to `calibration.md` "Briefs need" or `review-checklist.md`. |
| Approval | Unchanged: everything is proposed in the wrap-up's knowledge diff and lands only through an approved knowledge PR. |

### Non-goals

- Optimising wall-clock time or token cost.
- Trading quality for fewer stops: only tasks that passed review with the same acceptance criteria and checklist count.
- Workers measuring or reporting anything new.
- Cross-project learning (each project learns for itself; plugin lessons still go to plugin edits).

## 2. Measurement

### Event kinds in the ledger

Every ledger Events line starts with a kind tag, so the wrap-up can count without interpreting prose:

| Tag | Counts toward | Logged when |
|---|---|---|
| `[ask-user]` | attention | the orchestrator asks the user a question it needs answered (interview questions, product decisions, forwarded worker questions); the line records the question and, once given, the answer: `[ask-user] <question> → <answer>` |
| `[approval]` | attention | the user is asked to approve something beyond the expected stops (e.g. a re-split, a scope change, a tier above the orchestrator's own) |
| `[prompt]` | attention | the user hits a permission prompt or a folder-trust stop mid-run, unannounced (an up-front pre-flight ask is `[event] pre-flight: …`) |
| `[start-click]` | attention | a refused worker start becomes a card the user must click |
| `[failed]` | rework | a round fails because of the work (broken code, red tests/CI, worker error, no report) |
| `[env]` | — (feeds pre-flight) | a round lost to the environment (missing tool or login, permissions, untrusted folder, stale branch); not a failure, not rework |
| `[changes]` | rework | review sends work back as changes-requested |
| `[escalate]` | rework | a tier escalation or a `self` takeover |
| `[worker-q]` | rework | a worker blocks with a question to the orchestrator |
| `[event]` | — | everything else (started, report received, merged, …) |

The expected stops are logged as `[event]`, not `[approval]`: the one breakdown approval, each merge request, and the knowledge-diff approval at wrap-up.

Lines the learning depends on are `[event]` lines with fixed prefixes, so resumed and later runs can read them: `pre-flight:`, `T<n> following recipe:`, `assumed default:`, `user overrode default:`. The full counts table goes to `.orchestration/counts.md`; the wrap-up message shows the `run` row and non-zero tasks.

### The wrap-up table

```markdown
| task | recipe | ask-user | approval | prompt | start-click | failed | changes | escalate | worker-q |
|------|--------|----------|----------|--------|-------------|--------|---------|----------|----------|
| T1   | Money helper | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| run  |        | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
```

Events not tied to one task (intake, interview) count only in the `run` row.

## 3. Recipes

A recipe is a proven way to do one kind of task in this project:

```markdown
## Recipes
- **Money helper** (`src/money/<fn>.js`): one worker, `standard`, small-task path; brief quotes the number-argument and display rules, names `format.js` as style reference, folds the barrel line in. Last 2 runs: 0 attention, 0 rework. _(T1 / PR #10; T1 / PR #12)_
```

- **Name and match:** a short name plus the area and kind of change it covers. At breakdown, each task is matched to at most one recipe by area and kind. A match reuses its split, tier, placement and brief must-haves; the plan shows `following recipe: <name>`.
- **Track record:** the last runs' totals (attention / rework), updated by the wrap-up.
- **Same output is the bar:** a recipe is proposed, changed or credited only for tasks that passed review with the same acceptance criteria and checklist.

## 4. Turning counts into proposals (wrap-up)

The wrap-up compares each task's counts with its recipe (or with zero if it had none) and turns each cause into one concrete proposal in the existing knowledge diff:

| Finding | Proposal | Lands in |
|---|---|---|
| The user was asked the same question with the same answer in two or more runs (this run's `[ask-user]` events against the ledgers in `.orchestration/archive/`) | A **learned default**: "assume X unless told otherwise" | `calibration.md` → Learned defaults |
| A stall caused by the environment (`[prompt]`, `[start-click]`, or an `[env]` round) | A **pre-flight check** for intake, with what to tell the user up front | `calibration.md` → Pre-flight |
| A `[failed]`, `[changes]` or `[worker-q]` with an identifiable cause in the work | A **brief rule** (what the worker needed to be told) or a **checklist item** (what review should catch earlier) | `calibration.md` → Briefs need, or `review-checklist.md` |
| A task with zero rework and no attention except product decisions that this same diff records as `domain.md` rules, of a kind with no recipe | A **new recipe** | `calibration.md` → Recipes |
| A task that matched a recipe and did as well or better | An update to the recipe's track record | `calibration.md` → Recipes |
| A task that did clearly worse than its recipe | The cause, and a fix to the recipe or the brief | as above |
| A learned default the user overrode in two runs | Its removal | `calibration.md` → Learned defaults |

Lessons about the plugin itself (tooling, scripts, the skills) stay plugin edits, not project knowledge.

## 5. Using what was learned

| Step | Use |
|---|---|
| Intake | Run every **pre-flight** check; fix what can be fixed, and tell the user up front what they'll need to do (e.g. `/add-dir`, trust the folder). |
| Breakdown | Match tasks to **recipes**; follow a recipe's split, tier and placement unless the goal needs otherwise. |
| The plan the user approves | Lists `Assumed from project knowledge: …` (each **learned default** used) and `Following recipe: …` per matched task. The user can override either in the same reply. |
| Briefs | Carry the recipe's must-haves and the "Briefs need" items. |

## 6. Guardrails

- Nothing is learned without the user's approval of the knowledge diff.
- A learned default is never applied where it contradicts `CLAUDE.md`, a project rule, or the goal; precedence stays brief > `CLAUDE.md` > knowledge. Defaults never cover safety, data handling, money or destructive actions — checked both when proposing and when applying them. Bootstrap interview questions and the plugin's own confirmations never become defaults. A finding an existing entry already covers is not proposed again.
- A default the user overrides twice is proposed for removal.
- The content rules of project knowledge apply unchanged (no secrets, record identifiers or personal data; rule, not value).
- The ownership rules apply unchanged: in an existing folder, entries go into the existing file whose purpose fits; a missing section is added under the closest existing heading, or the user is asked once before a new section is added. Budgets come only from a file's own header.

## 7. Plugin changes

| File | Change |
|---|---|
| `skills/orchestrating/references/knowledge-templates/calibration.md` | New sections `## Recipes`, `## Learned defaults`, `## Pre-flight`; budget header `120 lines` |
| `skills/orchestrating/references/knowledge.md` | Layout table: calibration budget 120 for new files; section on recipes, defaults and pre-flight; how they are used |
| new `skills/orchestrating/references/workflow-learning.md` | Event kinds, the wrap-up table, the findings → proposals table, guardrails |
| `skills/orchestrating/references/ledger.md` | Every Events line starts with a kind tag |
| `skills/orchestrating/SKILL.md` | Intake runs pre-flight; breakdown matches recipes; plan lists assumed defaults and followed recipes; wrap-up adds the counts table and the workflow proposals to the knowledge diff |
| `tests/test_knowledge_templates.sh` | New sections and the 120 budget |

## 8. Testing

1. **Script tests:** the calibration template has the three new sections and `<!-- budget: 120 lines -->`; links resolve.
2. **Evals** (Sonnet judge):
   - `orch-workflow-wrapup`: a ledger with tagged events — one question the archived ledgers show was asked before with the same answer, a `[prompt]` for `/add-dir`, and one clean task of a kind with no recipe. PASS if the wrap-up shows the counts table and proposes a learned default, a pre-flight check and a new recipe, each with a source, and asks for approval.
   - `orch-workflow-use`: `calibration.md` with a recipe, a learned default and a pre-flight check. PASS if intake runs the pre-flight, the plan lists `Assumed from project knowledge` and `Following recipe`, and the brief carries the recipe's must-haves.
   - `orch-workflow-default-guard`: a learned default that contradicts a `CLAUDE.md` rule. PASS if it isn't applied, the contradiction is flagged, and `CLAUDE.md` is followed.
3. **End to end** on the sandbox: a third money-helper feature after the recipe is learned. It should follow the recipe, list it in the plan, and finish with zero `[ask-user]` and zero rework.
