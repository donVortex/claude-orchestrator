# Coexistence with other skills and plugins — Design

Date: 2026-11-04
Status: implemented (v0.5.0)
Builds on: [plugin](2026-11-03-orchestrator-plugin-design.md) · [project knowledge](2026-11-03-project-knowledge-design.md) · [workflow learning](2026-11-03-workflow-learning-design.md)
Replaces: the superpowers-only rules added in v0.4.1 (they become a worked example)

## 1. Intent

Users install other skills and plugins: process workflows (superpowers and the like), domain and framework skills (Stripe, Cloudflare, design), reviewers, hooks. The orchestrator must run alongside **any** of them without either side interfering with the other's work or duplicating it, and without a per-plugin list we would have to maintain.

**Success looks like:**
- A plugin we have never seen cannot make a worker merge, write plan files into its PR, create its own worktree, or stall on a question to the user.
- Skills that help a task get used, named once by the orchestrator instead of rediscovered by every worker.
- Each project learns which skills help it, through the knowledge PRs the user already approves.

### Decisions made with the user

| Topic | Decision |
|---|---|
| Overall approach | **One shared reference** (`references/coexistence.md`) plus a few must-never-miss lines inline in each skill. Not a third skill (it could fail to fire), not full duplication in both skills. |
| Reviews | **One review per change, always ours**, done by our reviewer subagent; if the brief names a review skill, the reviewer loads it **and** applies the brief's review checklist in the same pass. Never two reviews of the same scope; the checklist is never dropped. |
| Visibility of overlap | **One line in the plan, only when something overlaps**: `Other workflow skills: …`. Once project knowledge covers it, it is shown as `Assumed from project knowledge: …`. Overridable in the same reply; no extra stop. |
| Skills in briefs | **The brief names the skills that fit; workers may also use others** within the contract and say so in the retro. |
| Learning | Skill use is learned per project as `Skill:` entries in `calibration.md`, proposed in the wrap-up's knowledge diff. |

### Assumptions and non-goals

- We can only instruct, not block: other plugins' skills and hooks still load. What we cannot control (a hook that blocks `git push`, a Stop hook) is detected and reported, then learned as a pre-flight check.
- No inspection of other plugins' files, no installing or disabling plugins, nothing sent anywhere.
- No per-plugin rules in the plugin. Superpowers appears only as an example of the general rules.
- Standalone installs never propose plugin edits (unchanged); plugin-related lessons become project entries.

## 2. The contract (`skills/orchestrating/references/coexistence.md`)

### Who owns what

The orchestrator and the worker skill own **how the work is organised**. Everything else happens inside their steps, where other skills are welcome.

| Stage | Owner | Other skills may… |
|---|---|---|
| Goal and design discussion | orchestrator | help (e.g. brainstorm an unclear goal with the user) |
| Breakdown and approval | orchestrator | inform it; their plans never replace it |
| Branches, worktrees, PRs | the backend's setup, then the worker's one PR | nothing |
| Building, testing, debugging inside a task | worker | do it their way (TDD, frameworks, domain skills) |
| Review | worker (one per change), then the orchestrator's PR review | be the reviewer; the brief's checklist is always applied |
| Merging | the user | nothing |
| Learning about the project | `.claude/orchestrator/` via knowledge PRs | keep their own memory; nothing is copied between the two |

### Rules by effect

Whatever plugin a skill comes from, judge it by what it would do:

| A skill wants to… | In the orchestrator | In a worker |
|---|---|---|
| ask the user questions | fine | the question goes into the report (`Status: blocked`), then end the turn |
| plan or run the whole goal | its thinking feeds the breakdown | the brief is the plan; skip it |
| write plan or spec documents | only where the project already keeps them | never in the PR |
| create a worktree or branch | no — the backend's setup does | no — already in one |
| commit to the base branch, merge, delete branches | never | never |
| open a PR | no | only to the brief's branch |
| hand off to its own next step | come back to the orchestrator's next stage | come back to the worker's next step |

**Tie-breaker for anything not listed:** if a skill would change *who decides*, *where code lands* or *what ships*, the owner's rule wins. If it only changes *how a step is done* inside the owned files, use it.

### Worked example: superpowers

brainstorming → allowed in the orchestrator for an unclear goal; its hand-off to writing-plans returns to the breakdown. writing-plans / executing-plans / subagent-driven-development at goal level → replaced by breakdown, approval and dispatch. using-git-worktrees → replaced by the backend's setup. finishing-a-development-branch → replaced by the worker's push-and-PR (never merge). Inside a worker: test-driven-development, subagent-driven-development (within a batch; the worker's batching and model rules win), code review and verification-before-completion apply.

### Inline must-never-miss lines

- **Worker skill:** the brief is the approved plan; never merge, discard or remove the worktree; never create a worktree; questions go into the report; plan documents never go into the PR. Link to `coexistence.md`.
- **Orchestrating skill:** other planners feed the breakdown, never replace it; never merge. Link to `coexistence.md`.
- **Project-default hook note:** the existing "Other process skills" line is generalised to "other skills and plugins" and points at the same rule.

## 3. Intake, plan and briefs

### Intake: a skills look

The orchestrator reads the skill list its own session already has (names and descriptions). It notes:
- **overlapping workflow skills** — descriptions that plan, run a whole feature, finish or merge branches, or review;
- **fitting skills** — framework, domain or tool skills that match the goal's tasks.

It logs one line: `[event] skills: overlap <name> (<stage>); fit <names>` (fixed prefix, like the other `[event]` lines).

### The plan

- When an overlap exists: `Other workflow skills: <name> (<what it is used for>; <which steps the orchestrator replaces>)`.
- When a `Skill:` entry in the project's knowledge already covers it: `Assumed from project knowledge: <entry>` instead, logged as `[event] assumed default: …`.
- The user can override either in the same reply; an override is logged `[event] user overrode default: … → …`.

### Briefs

A new brief field:

```
- Skills: <skill> (<subtask / why>) · review: <review skill or none>
```

- The worker loads each named skill for the subtasks listed. A named skill missing from its session → carry on without it and note a `[tooling]` retro point.
- The worker may use other skills it finds, within the contract, and mentions them in the retro.

### Reviews

Still one review per change, by `orch-specialist` in review mode on its usual model (sonnet or above). When the brief names a review skill, the reviewer prompt tells it to load that skill **and** to check the brief's review checklist in the same pass. The orchestrator's own PR review follows the same rule with the project's preferred review skill, if any.

## 4. Learning per project

### Retro points

`[tooling]` points cover skills in three forms:
- helped — "stripe-best-practices caught a missing idempotency key";
- got in the way — "X tried to write a plan file; skipped";
- missing — "named skill X not available in this session".

### Findings → proposals (added to `workflow-learning.md`)

| Finding | Proposal | Goes to |
|---|---|---|
| A skill helped on a task that passed with no rework | `Skill: use <skill> for <area / kind of task>`; also added to a matching recipe's must-haves | `calibration.md` → Skills |
| A skill got in the way (caused rework, a failure, or a skipped step) | `Skill: <skill> — skip its <step> here` or `Skill: don't use <skill> for <kind>` | `calibration.md` → Skills |
| An overlapping workflow skill was handled and the user did not override | `Skill: <skill> — <used for>; <replaced steps>` (next run shows it as Assumed) | `calibration.md` → Skills |
| A hook or plugin blocked something (e.g. `git push`) | a Pre-flight entry, not a `Skill:` entry | `calibration.md` → Pre-flight |
| A named skill was missing in two runs | remove its `Skill:` entry | — |

One observation is enough to propose; the user approves every entry in the knowledge diff.

### Where entries go

- The `calibration.md` template gains a `## Skills` heading (new bootstraps only).
- Existing projects get `Skill:`-prefixed entries under their own headings; never reformatted (the ownership rule from the project-knowledge design).

### Guardrails

- A `Skill:` entry never removes the review, the review checklist, tests or a project rule, and never overrides `CLAUDE.md`.
- Standalone mode: plugin-related lessons become project entries only. Development mode may also propose edits to `coexistence.md`.

## 5. Plugin changes

| File | Change |
|---|---|
| `skills/orchestrating/references/coexistence.md` | new: sections 2–3 above |
| `skills/orchestrating/SKILL.md` | replace "Alongside superpowers" with "Other skills and plugins" (inline lines + link); intake skills look; plan line; brief Skills field; PR review with preferred review skill |
| `skills/working/SKILL.md` | replace the superpowers paragraph with the inline lines + link; load the brief's Skills; reviewer loads the named review skill and applies the checklist |
| `skills/orchestrating/references/brief-template.md` | `- Skills:` field |
| `skills/working/report-format.md` | `[tooling]` skill examples (helped / got in the way / missing) |
| `skills/orchestrating/references/workflow-learning.md` | the findings rows, the `[event] skills:` line, guardrails |
| `skills/orchestrating/references/knowledge-templates/calibration.md` | `## Skills` heading |
| `hooks/project-default.sh` | generalised line |
| `README.md` | "With superpowers" → "Alongside other skills and plugins" |
| `.claude-plugin/plugin.json` | 0.5.0 |

## 6. Testing

### Bash

`tests/test_coexistence.sh` replaces `tests/test_superpowers.sh`: the reference exists with the ownership table, the effect rules and the tie-breaker; both skills keep their inline lines and link it; the brief template has `- Skills:`; the report format has the three skill forms; the calibration template has `## Skills`; `workflow-learning.md` has the new rows and guardrails; the hook line mentions other skills. `test_knowledge_templates.sh` adds `## Skills`; `test_manifest.sh` expects 0.5.0.

### Evals

A made-up workflow plugin, **shipfast**, whose instructions (in the prompt) write a plan to `docs/shipfast/`, create their own worktree, ask the user to confirm each step, merge to `main` when done and review with `shipfast:review`; and a made-up domain skill, **payments-kit**.

| Case | Checks |
|---|---|
| worker-coexist-foreign | batch plan kept; no worktree, no plan file, no questions to the user; push and PR, no merge |
| orch-coexist-overlap | plan has `Other workflow skills: shipfast (…)`; the payment task's brief names `payments-kit`; no merge |
| worker-coexist-reviewer | brief names a review skill → exactly one review that uses it and the checklist |
| orch-coexist-assumed | a `Skill:` entry in knowledge → shown as `Assumed from project knowledge` |
| orch-coexist-learning | retros with helped / got-in-the-way / push blocked by a hook → two `Skill:` proposals and one Pre-flight proposal; the review is never dropped |

`orch-superpowers-feature` and `worker-superpowers` stay as regression cases. Before merging: a full eval run (about 35 cases, roughly $40).

### Optional end to end

One sandbox orchestration on this PC, where superpowers and the Stripe skills are really installed, to see real skills rather than simulated ones.
