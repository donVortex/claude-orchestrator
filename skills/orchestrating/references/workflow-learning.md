# Workflow learning

Project knowledge makes you expert in the project's domain. Workflow learning makes you better at **how work gets done** there: each kind of task should need less of the user's attention and less rework over time, with the same output. You measure both from the ledger, and turn what you find into proposals in the knowledge diff. Everything lands in the project's `calibration.md` (or `review-checklist.md`), and only through the approved knowledge PR.

## Event kinds

Every line in the ledger's Events list starts with one of these tags:

| Tag | Counts toward | Log it when |
|---|---|---|
| `[ask-user]` | attention | you ask the user something you need answered (interview, product decision, a worker question you forward). **One line per question:** `[ask-user] <question> → <answer>`; add `→ <answer>` to that same line when it comes, never a second line. |
| `[approval]` | attention | the user must approve something beyond the expected stops: a re-split, a scope change, a tier above your own model |
| `[prompt]` | attention | the user hits a permission prompt or a folder-trust stop **mid-run**, unannounced |
| `[start-click]` | attention | a refused worker start becomes a card the user must click |
| `[failed]` | rework | a round fails because of the work: broken code, red tests or CI, a worker error, no report |
| `[changes]` | rework | review sends work back as changes requested |
| `[escalate]` | rework | a tier escalation, or you take a task over as `self` |
| `[worker-q]` | rework | a worker blocks with a question to you |
| `[env]` | — (feeds pre-flight) | a round lost to the environment, not the work: missing tool or login, permissions, an untrusted folder, a stale branch. Not a failure, not rework. |
| `[event]` | — | everything else: started, report received, merge requested, merged, archived |

**Expected stops are `[event]`, not `[approval]`:** the one breakdown approval, each merge request, and the knowledge-diff approval.

**Lines the learning depends on**, all `[event]`, written with these exact prefixes so a resumed or later run can read them:
- `[event] pre-flight: <what you asked or checked up front>` — an up-front pre-flight ask is planned, not an interruption;
- `[event] T<n> following recipe: <name>` — at the approval gate, per matched task;
- `[event] assumed default: <default>` — at the approval gate, per default relied on;
- `[event] user overrode default: <default> → <what they chose>`.

Add the task id after the tag when an event belongs to one task: `[failed] T2 tests red on the PR head`.

## Counts table

At wrap-up, count the tags per task and for the whole run. Write the full table to `.orchestration/counts.md`; in your message show only the `run` row and the rows of tasks with any non-zero count, and link the file:

```markdown
| task | recipe | ask-user | approval | prompt | start-click | failed | changes | escalate | worker-q |
|------|--------|----------|----------|--------|-------------|--------|---------|----------|----------|
| T1   | Money helper | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| run  |        | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
```

The `run` row is the total over all events; events with no task id (intake, the interview) appear only there. Attention is the sum of the first four counts, rework the sum of the last four. The recipe column comes from the `following recipe:` lines.

If the ledger has untagged lines (an orchestration started before tags existed and resumed after), say the counts are partial, and propose no recipe or track-record update from them.

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
| The user was asked the same question and gave the same answer in two or more runs (this ledger's `[ask-user]` lines against the archived ledgers' `[ask-user]` lines) — except bootstrap interview questions (their answers belong in `domain.md`), the plugin's own confirmations (merges, branch deletion, the bootstrap offer, the knowledge diff), and anything touching safety, data handling, money or a destructive action | A **learned default**: "<answer> unless told otherwise" | `calibration.md` → Learned defaults |
| A stall from the environment: a `[prompt]`, a `[start-click]`, or an `[env]` round | A **pre-flight check** for intake, with what to tell the user up front | `calibration.md` → Pre-flight |
| A `[failed]`, `[changes]` or `[worker-q]` caused by the work or the brief | A **brief rule** (what the worker needed to be told) or a **checklist item** (what review should catch earlier) | `calibration.md` → Briefs need, or `review-checklist.md` |
| A task with zero rework and no attention except product decisions that this same diff records as `domain.md` rules, of a kind with no recipe | A **new recipe** | `calibration.md` → Recipes |
| A task that followed its recipe and did as well or better | Update the recipe's track record | `calibration.md` → Recipes |
| A task that did clearly worse than its recipe | The cause, and a fix to the recipe or the brief | as above |
| A learned default the user overrode in two runs (the `user overrode default:` lines in this and the archived ledgers) | Remove it | `calibration.md` → Learned defaults |

- **Don't propose what's already there.** If an existing recipe, default, pre-flight check or brief rule already covers a finding, don't propose it again; if it's there and the problem still happened, propose a fix to that entry.
- **Older ledgers without tags:** skip their untagged lines. Never guess a question or an answer from prose.
- **The project's own layout wins:** if `calibration.md` lacks a section, put the entry under the closest existing heading with its kind as a prefix — `Recipe: …`, `Learned default: …`, `Pre-flight: …` — or ask the user once whether to add the section. If they say no, use prefixed entries from then on without asking again. Respect the file's own budget, or none if it has no header ([the project owns it](knowledge.md#the-project-owns-it)).
- **Plugin lessons stay plugin edits** (tooling, scripts, the skills), never project knowledge.

## Using what was learned

| Step | Use |
|---|---|
| Reading | Read entries by section **or** by prefix: a `Pre-flight:`, `Recipe:` or `Learned default:` entry under another heading counts the same. |
| Intake | Run every **Pre-flight** check before planning. Fix what you can; tell the user up front what they'll need to do (e.g. `/add-dir`, trusting the folder), and log it as `[event] pre-flight: …`. |
| Breakdown | Match tasks to **Recipes** by area **and** kind of change; a different kind of change in the same area matches nothing. Follow a recipe's split, tier and placement unless the goal needs otherwise. |
| The plan the user approves | One line per learned default you rely on — `Assumed from project knowledge: <default>` — and per matched task — `Following recipe: <name>`. Never assume a default that touches safety, data handling, money or a destructive action, or contradicts `CLAUDE.md`, a project rule or the goal: ask or flag it instead. Log each line as its `[event]` (see Event kinds); an override as `user overrode default:`. |
| Briefs | Carry the recipe's must-haves, the "Briefs need" items, and every learned default the task relies on. |

## Guardrails

- Nothing is learned without the user's approval of the knowledge diff.
- Never apply a learned default that contradicts `CLAUDE.md`, a project rule or the goal: flag the contradiction and follow `CLAUDE.md` (precedence: brief > `CLAUDE.md` > knowledge).
- Learned defaults never cover safety, data handling, money or destructive actions — not when proposing them, and not when applying them, even if one was added by hand. Those are rules (`domain.md`) or the user's call.
- A default the user overrides twice is proposed for removal.
- The content rules of project knowledge apply unchanged: no secrets, record identifiers or personal data; state the rule, never the value.
