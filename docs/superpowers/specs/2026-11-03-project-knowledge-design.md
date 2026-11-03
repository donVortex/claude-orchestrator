# Project knowledge — Design

Date: 2026-11-03
Status: approved in conversation, awaiting written-spec review
Builds on: [2026-11-03-orchestrator-plugin-design.md](2026-11-03-orchestrator-plugin-design.md)

## 1. Intent

Each project's orchestrator gets better **at that project** with every feature it delivers. A team building a healthcare product ends up with an orchestrator that knows healthcare as this codebase does it; an insurtech team's orchestrator becomes expert in insurtech. The plugin stays generic; the expertise lives in the project, is shared by everyone who works on it, and is reviewed like code.

**Success looks like:** the 10th feature in a project needs fewer worker questions, fewer failed rounds and fewer review fixes than the 1st, because the orchestrator already knows the project's rules, layout, review concerns and how its work should be split and tiered.

### Decisions made with the user

| Topic | Decision |
|---|---|
| Where knowledge lives | Committed in the project repo, shared by the whole team on every machine. |
| How it changes | A dedicated knowledge PR at each wrap-up, after the user approves the draft; the team reviews and merges it. |
| Cold start | A bootstrap: scouts read the repo and draft the files, the orchestrator asks the user a few domain questions, the user approves, and it lands as the first knowledge PR. |
| What is learned | Domain rules and glossary; codebase map and feature flows; a project review checklist; tier and split calibration. |
| Structure | A folder with one file per kind of knowledge (approach A). |

### Non-goals

- Sending project knowledge anywhere outside the project (to the plugin repo, to other projects, to the plugin author).
- Generating project skills or agents from the knowledge (possible later step, see §9).
- Storing records, secrets or personal data. Knowledge describes rules, never data.
- Changing the knowledge without human approval.

## 2. The knowledge folder

`.claude/orchestrator/`, committed to the project repo. The name is chosen to be clearly distinct from `.orchestration/` (local, uncommitted run state) and to sit beside the project's other Claude configuration.

```
.claude/orchestrator/
├─ README.md            for humans: what this is, how it grows, how to edit it by hand
├─ domain.md            ## Rules  ## Glossary
├─ map.md               ## Areas  ## Feature flows
├─ review-checklist.md  ## Always check  ## When touching <area>
└─ calibration.md       ## Tiers by task type  ## Split patterns  ## Briefs need
```

| File | Holds | Budget (lines) |
|---|---|---|
| `domain.md` | Business and regulatory rules; terms that mean something specific here | 150 |
| `map.md` | Where things live; how a typical feature flows through the layers (e.g. schema → service → route → tests) | 100 |
| `review-checklist.md` | What every review must check; extra checks per area | 60 |
| `calibration.md` | Which task types need which tier here; typical split sizes; the brief details workers keep needing | 60 |

Each file starts with a header line stating its budget, in a fixed form the plugin's tests and the wrap-up can read: `<!-- budget: 150 lines -->`.

### Entry format

One line, or a short block, ending with its source and date:

```markdown
- **PHI never appears in logs.** Use `redact()` from `src/phi/redact.ts`. _(bootstrap, 2026-11-03)_
- **Premiums are integer cents**, never floats. _(T2 / PR #42, 2026-11-10)_
```

Sources are `bootstrap`, `user`, or `T<n> / PR #<n>`. Hand-edited entries may use `user`.

### Rules for content

- **No secrets, credentials, records or personal data.** Entries describe rules and structure, never values from real data. The bootstrap and every wrap-up check drafted entries for anything that looks like a secret, an identifier or personal data; such entries are dropped and the user is told.
- **No duplicates of `CLAUDE.md`.** If a rule already lives there, the knowledge file links to it instead of restating it.
- **Within budget.** An addition that would exceed a file's budget must come with merges or removals in the same proposal.

### Precedence

Brief (for that one task) > `CLAUDE.md` > knowledge files. A contradiction between `CLAUDE.md` or the code and the knowledge is flagged at intake and fixed in the next knowledge PR; the stale rule is never followed silently.

## 3. Bootstrap

Runs at the intake of a fresh orchestration (never on resume) when the repo has no `.claude/orchestrator/` on its base branch **and no knowledge PR is open**. If a knowledge PR is open, its files are used for the run instead, and its checklist items are quoted into briefs.

1. **Scan.** Parallel `orch-scout` subagents read the README, `docs/`, `CLAUDE.md`, the folder structure, test layout, and the last 50 commits. They return draft content for `map.md` and the written-down parts of `domain.md` and `review-checklist.md`, each claim with a `path:line` source.
2. **Interview.** The orchestrator asks the user **at most 5** questions, one at a time, choosing from: rules that aren't written down, risky or regulated areas, terms with a specific meaning here, what reviewers must always check, and work that has gone wrong before.
3. **Draft.** It fills the four files from the templates (§6), applies the content rules (§2), and shows them to the user.
4. **Approve.** The user approves or edits. Nothing is written to the repo before this.
5. **PR.** The orchestrator commits the folder on `orch/knowledge-bootstrap` in its own worktree and opens a PR.
6. **Continue.** Feature work waits for that PR to merge, unless the user says to use the approved draft now; then the orchestrator works from the draft and names the open PR in every brief's Project rules field.

If the user declines the bootstrap, the orchestrator starts from the empty templates and only wrap-ups fill them.

## 4. Use during an orchestration

| Step | Uses |
|---|---|
| Intake | Reads all four files from the base branch; tells the user what in them bears on the goal; flags contradictions (§2 Precedence) |
| Breakdown | `map.md` for where the change belongs and the usual flow; `calibration.md` for tiers and split sizes |
| Briefs | New **Project rules** field: the `domain.md` entries relevant to this task, quoted; plus `calibration.md` "Briefs need" items written into the brief's fields |
| Reviews | Every review subagent's prompt includes `review-checklist.md` "Always check" plus the sections for the areas the PR touches |
| Workers | Read the knowledge files in their own worktree when the brief points to them; report domain learnings with the `[domain]` retro tag |

## 5. Update at wrap-up

1. The retro digest groups points by tag, including the new `[domain]` tag.
2. Besides any plugin edits, the wrap-up drafts a **knowledge diff**: additions, edits and removals across the four files, each with its source and a one-line reason, within budget, with the content rules applied.
3. The user approves or edits the diff.
4. The orchestrator commits it on `orch/knowledge-<YYYY-MM-DD>` in its own worktree and opens a PR whose body lists each change and its reason. If an earlier knowledge PR is still open, it adds to that branch instead of opening a second one.
5. The team reviews and merges it like code. Hand edits on the base branch always win; the orchestrator reads what is there.

Project knowledge never leaves the project. Plugin edits keep their existing path (proposed to the user, applied in the plugin repo).

## 6. Plugin changes

| File | Change |
|---|---|
| `skills/orchestrating/SKILL.md` | Intake loads the knowledge or runs the bootstrap; breakdown, briefs and review use it; wrap-up drafts the knowledge diff and opens the knowledge PR; stop-and-ask list gains "bootstrap approval" and "knowledge diff approval" |
| new `skills/orchestrating/references/knowledge.md` | Folder layout, entry format, budgets, content rules, precedence, the bootstrap steps, curation rules, the knowledge PR steps |
| new `skills/orchestrating/references/knowledge-templates/` | `README.md`, `domain.md`, `map.md`, `review-checklist.md`, `calibration.md`: section headings and budget headers, no entries |
| `skills/orchestrating/references/brief-template.md` | New fields: **Project rules** (quoted `domain.md` entries, or "none") and **Review checklist** (path and the relevant sections) |
| `skills/working/SKILL.md` | Review subagents get the checklist named in the brief; `[domain]` retro tag |
| `skills/working/report-format.md` | `domain` added to the tag list |

### 6a. The project owns its knowledge (added at the user's request)

Updating the plugin must never interfere with what a project has already learned:

- The orchestrator uses an existing knowledge folder exactly as it is, whatever its headings, file names, extra files or missing budgets. The §2 layout only shapes a **new** bootstrap.
- It never renames, reformats, restructures, re-templates or adds budgets to existing knowledge, and never proposes that as part of a feature.
- It bootstraps only when the folder is missing.
- Knowledge changes only through the approved knowledge diff, for content the retros justify; layout changes only when the user asks.
- Every file in the folder is read; budgets apply only to files with their own budget header; new entries go into the existing file whose purpose fits, and no template file is created in an existing folder without asking.
- Extending an open knowledge PR drafts against that PR's branch and applies the changes as edits, never whole-file writes, so pending changes and teammates' review commits are kept.
- Content rules cover everything that leaves the machine: entries, sources, reasons, PR text and commit messages.
- Guarded by evals `orch-knowledge-compat` (intake on an older layout) and `orch-knowledge-compat-wrapup` (wrap-up on an older layout: no budget trimming, no new files, no reformatting).

## 7. Failure handling

| Situation | Response |
|---|---|
| A knowledge PR is still open when the next orchestration starts | Use the base branch's version; mention the open PR; add new changes to that PR rather than opening another |
| A file would go over budget | The wrap-up proposes merges or removals in the same diff |
| Knowledge contradicts `CLAUDE.md` or the code | Flag at intake; follow `CLAUDE.md` or the code; fix in the next knowledge PR |
| User declines the bootstrap | Start from empty templates; wrap-ups fill them |
| A drafted entry contains something that looks like a secret, identifier or personal data | Drop it, tell the user, never propose it |
| No GitHub remote or `gh` not logged in | Same as today: stop at intake |

## 8. Testing

1. **Script tests** (`tests/`): every template exists, has its `<!-- budget: N lines -->` header with the budget from §2, and has the section headings from §2; links in the new reference resolve (existing `test_links.sh`).
2. **Evals** (run with `--judge-model sonnet`):
   - `orch-bootstrap`: given a described repo with no knowledge folder, it plans the scan, asks at most 5 domain questions one at a time, and writes nothing before approval.
   - `orch-knowledge-use`: given knowledge files, the breakdown follows `map.md`'s feature flow, briefs quote the relevant `domain.md` rules in Project rules, and the review instructions include the checklist.
   - `orch-knowledge-wrapup`: given retros with `[domain]` points and a `domain.md` at its budget, it proposes an addition and a removal with sources, stays within budget, and asks before opening the PR.
   - `orch-knowledge-secrets`: a retro containing a fake patient identifier; the proposed diff must not contain it, and the response says it was dropped.
3. **End to end** on the sandbox: bootstrap, then two features in a row. The second must visibly use something the first one taught (a rule quoted in a brief, or a checklist item in a review).

## 8a. Default workflow (added at the user's request)

A project with `.claude/orchestrator/` has opted in. A SessionStart hook (`startup`, `clear`) tells every new session there that the project uses the orchestrator: feature work goes through the orchestrating skill; questions, explanations, reviews and one-file fixes stay normal work; an in-progress ledger is continued.

- **Off for a project:** `ORCH_DEFAULT=off`, e.g. via the project's `.claude/settings.json` `env`.
- **Workers are excluded:** CLI workers run with `ORCH_ROLE=worker`, which silences the hook; desktop workers can't be given an environment variable, so the note itself tells a session started with a `session-orchestrator:working` brief to ignore it.
- **Tests:** `tests/test_project_default.sh`; evals `orch-default-feature` (a feature request starts an orchestration) and `orch-default-question` (a question gets a plain answer).

## 9. Later (not in this design)

- Publishing a mature `domain.md` as a project skill under `.claude/skills/`, so sessions that don't use the orchestrator also benefit.
- Sharing generic, non-project lessons back to the plugin author (e.g. via an issue on the plugin repo).
