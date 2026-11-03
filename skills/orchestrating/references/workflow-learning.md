# Workflow learning

Project knowledge makes you expert in the project's domain. Workflow learning makes you better at **how work gets done** there: each kind of task should need less of the user's attention and less rework over time, with the same output. You measure both from the ledger, and turn what you find into proposals in the knowledge diff. Everything lands in the project's `calibration.md` (or `review-checklist.md`), and only through the approved knowledge PR.

## Event kinds

Every line in the ledger's Events list starts with one of these tags:

| Tag | Counts toward | Log it when |
|---|---|---|
| `[ask-user]` | attention | you ask the user something you need answered (interview, product decision, a worker question you forward). Write `[ask-user] <question> → <answer>` and add the answer when it comes. |
| `[approval]` | attention | the user must approve something beyond the expected stops: a re-split, a scope change, a tier above your own model |
| `[prompt]` | attention | the user hits a permission prompt, a folder-trust stop, or you ask them to run `/add-dir` |
| `[start-click]` | attention | a refused worker start becomes a card the user must click |
| `[failed]` | rework | a round fails: broken code, red tests or CI, a worker error, no report |
| `[changes]` | rework | review sends work back as changes requested |
| `[escalate]` | rework | a tier escalation, or you take a task over as `self` |
| `[worker-q]` | rework | a worker blocks with a question to you |
| `[event]` | — | everything else: started, report received, merge requested, merged, archived |

**Expected stops are `[event]`, not `[approval]`:** the one breakdown approval, each merge request, and the knowledge-diff approval.

Add the task id after the tag when an event belongs to one task: `[failed] T2 tests red on the PR head`.

## Counts table

At wrap-up, count the tags per task and for the whole run, and show the table above the knowledge diff:

```markdown
| task | recipe | ask-user | approval | prompt | start-click | failed | changes | escalate | worker-q |
|------|--------|----------|----------|--------|-------------|--------|---------|----------|----------|
| T1   | Money helper | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| run  |        | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
```

Events with no task id (intake, the interview) count only in the `run` row. Attention is the sum of the first four counts, rework the sum of the last four.

## Recipes

A recipe is a proven way to do one kind of task in this project, kept in `calibration.md` → Recipes:

```markdown
- **Money helper** (`src/money/<fn>.js`): one worker, `standard`, small-task path; brief quotes the number-argument and display rules, names `format.js` as style reference, folds the barrel line in. Last 2 runs: 0 attention, 0 rework. _(T1 / PR #10; T1 / PR #12)_
```

- **Match by area and kind of change.** At breakdown, match each task to at most one recipe. A task in the same area but of a different kind (an export instead of a helper) has no recipe.
- **Track record:** the last runs' attention and rework totals, updated at wrap-up.
- **Same output is the bar.** Propose, change or credit a recipe only for tasks that passed review with the same acceptance criteria and checklist.

## Findings to proposals

At wrap-up, compare each task's counts with its recipe (or with zero if it had none). Turn each cause into **one** concrete proposal in the knowledge diff, with its source:

| Finding | Proposal | Lands in |
|---|---|---|
| The user was asked the same question and gave the same answer in two or more runs (this ledger's `[ask-user]` lines against the archived ledgers' `[ask-user]` lines) | A **learned default**: "<answer> unless told otherwise" | `calibration.md` → Learned defaults |
| A stall from the environment: a `[prompt]`, a `[start-click]`, or a `[failed]` round lost to permissions, tools, an untrusted folder, a stale branch, a missing `/add-dir` | A **pre-flight check** for intake, with what to tell the user up front | `calibration.md` → Pre-flight |
| A `[failed]`, `[changes]` or `[worker-q]` caused by the work or the brief | A **brief rule** (what the worker needed to be told) or a **checklist item** (what review should catch earlier) | `calibration.md` → Briefs need, or `review-checklist.md` |
| A task with zero attention and zero rework, of a kind with no recipe | A **new recipe** | `calibration.md` → Recipes |
| A task that followed its recipe and did as well or better | Update the recipe's track record | `calibration.md` → Recipes |
| A task that did clearly worse than its recipe | The cause, and a fix to the recipe or the brief | as above |
| A learned default the user overrode in two runs | Remove it | `calibration.md` → Learned defaults |

- **Older ledgers without tags:** skip their untagged lines. Never guess a question or an answer from prose.
- **The project's own layout wins:** if `calibration.md` lacks a section, put the entry under the closest existing heading, or ask the user once whether to add the section. Respect the file's own budget, or none if it has no header ([the project owns it](knowledge.md#the-project-owns-it)).
- **Plugin lessons stay plugin edits** (tooling, scripts, the skills), never project knowledge.

## Using what was learned

| Step | Use |
|---|---|
| Intake | Run every **Pre-flight** check before planning. Fix what you can; tell the user up front what they'll need to do (e.g. `/add-dir`, trusting the folder). |
| Breakdown | Match tasks to **Recipes**; follow a recipe's split, tier and placement unless the goal needs otherwise. |
| The plan the user approves | One line per learned default you rely on — `Assumed from project knowledge: <default>` — and per matched task — `Following recipe: <name>`. The user can override either in the same reply. |
| Briefs | Carry the recipe's must-haves and the "Briefs need" items. |

## Guardrails

- Nothing is learned without the user's approval of the knowledge diff.
- Never apply a learned default that contradicts `CLAUDE.md`, a project rule or the goal: flag the contradiction and follow `CLAUDE.md` (precedence: brief > `CLAUDE.md` > knowledge).
- Learned defaults never cover safety, data handling or money. Those are rules and belong in `domain.md`.
- A default the user overrides twice is proposed for removal.
- The content rules of project knowledge apply unchanged: no secrets, record identifiers or personal data; state the rule, never the value.
