# Project knowledge

Each project keeps what the orchestrator has learned about it in `.claude/orchestrator/`, committed to the repo and shared by the whole team. You read it on every run, use it to plan, brief and review, and propose changes to it at every wrap-up. It is the project's expertise; the plugin stays generic.

## Layout and budgets

```
.claude/orchestrator/
├─ README.md            for humans
├─ domain.md            ## Rules  ## Glossary
├─ map.md               ## Areas  ## Feature flows
├─ review-checklist.md  ## Always check  ## When touching <area>
└─ calibration.md       ## Tiers by task type  ## Split patterns  ## Briefs need
```

| File | Holds | Budget (lines) |
|---|---|---|
| `domain.md` | Business and regulatory rules; terms that mean something specific here | 150 |
| `map.md` | Where things live; how a typical feature flows through the layers | 100 |
| `review-checklist.md` | What every review must check; extra checks per area | 60 |
| `calibration.md` | Which task types need which tier here; typical split sizes; brief details workers keep needing | 60 |

The first line of each file states its budget: `<!-- budget: N lines -->`. Starter files are in [knowledge-templates/](knowledge-templates/README.md): [domain.md](knowledge-templates/domain.md), [map.md](knowledge-templates/map.md), [review-checklist.md](knowledge-templates/review-checklist.md), [calibration.md](knowledge-templates/calibration.md).

## Entry format

One line, or a short block, ending with its source and date:

```markdown
- **PHI never appears in logs.** Use `redact()` from `src/phi/redact.ts`. _(bootstrap, 2026-11-03)_
- **Premiums are integer cents**, never floats. _(T2 / PR #42, 2026-11-10)_
```

Sources: `bootstrap`, `user`, or `T<n> / PR #<n>`.

## Content rules

Apply to every entry you draft, at bootstrap and at every wrap-up:

1. **No secrets, credentials, identifiers, records or personal data.** State the rule, never the value: "MRNs may contain dashes", not "MRN 4471-882 failed". Drop any drafted entry that contains such a value, and tell the user what you removed and why.
2. **Don't copy `CLAUDE.md`.** If a rule is already there, refer to it (`see CLAUDE.md: <rule>`) instead of restating it, in all four files. A review-checklist item for such a rule reads `Check CLAUDE.md: <rule>`; add only what `CLAUDE.md` doesn't say (e.g. "also in error messages").
3. **Stay within budget.** An addition that would push a file over its budget comes with merges or removals in the same proposal.

## Precedence

A task's brief > `CLAUDE.md` > knowledge files. When knowledge contradicts `CLAUDE.md` or the code, say so to the user at intake, follow `CLAUDE.md` or the code, and fix the entry in the next knowledge diff. Never follow a stale rule silently.

## Bootstrap

Run at intake when the base branch has no `.claude/orchestrator/`, before the feature breakdown.

1. **Scan.** In one message, start parallel `orch-scout` subagents to read the README, `docs/`, `CLAUDE.md`, the folder structure, the test layout and the last 50 commits. Ask each for draft entries with `path:line` sources.
2. **Interview.** Ask the user at most **5** questions, **one at a time** — each one thing to answer, never a bundle of sub-questions — picking from: rules that aren't written down; risky or regulated areas; terms with a specific meaning here; what reviewers must always check; work that has gone wrong before.
3. **Draft.** Fill the four files from the templates, applying the content rules.
4. **Approve.** Show the drafts and ask the user to approve or edit them. Write nothing to the repo before they do.
5. **PR.** Commit the folder in its own worktree and open a PR:
   ```bash
   git worktree add -b orch/knowledge-bootstrap "$root-wt/knowledge-bootstrap" <base>
   # copy the approved files into .claude/orchestrator/, commit, push, gh pr create --body-file <file>
   ```
6. **Continue.** Feature work waits until that PR is merged, unless the user says to use the approved draft now. Then work from the draft and mention the open PR in every brief's Project rules field.

If the user declines the bootstrap, start from the empty templates; wrap-ups fill them over time.

## Using it

| Step | Use |
|---|---|
| Intake | Read all four files from the base branch. Tell the user which entries bear on the goal. Flag contradictions (see Precedence). |
| Breakdown | `map.md` for where the change belongs and the usual feature flow; `calibration.md` for tiers and split sizes. |
| Briefs | **Project rules:** quote the `domain.md` entries relevant to the task. **Review checklist:** name the checklist sections that apply (`Always check` plus the areas the task touches). Write `calibration.md` "Briefs need" items into the brief's fields. |
| Reviews | Your own review and any `orch-specialist` pass check the same checklist sections. |

## Knowledge diff at wrap-up

1. Group the retros by tag; `[domain]` points are knowledge candidates, and so are repeated `[brief]`, `[split]` and `[tier]` patterns.
2. Draft the **knowledge diff**: additions, edits and removals across the four files, each with its source and a one-line reason. Apply the content rules. Show each file's line count against its budget.
3. Ask the user to approve or edit the diff. Change nothing before they do.
4. Find an open knowledge PR first:
   ```bash
   gh pr list --state open --search "head:orch/knowledge-" --json number,headRefName
   ```
   - One is open: add the approved changes to its branch, and say which PR you extended.
   - None: commit on `orch/knowledge-<YYYY-MM-DD>` in its own worktree (`"$root-wt/knowledge-<YYYY-MM-DD>"`) and open a PR whose body lists each change and its reason.
5. The team reviews and merges it. You never merge it.

Project knowledge never leaves the project. Plugin edits are separate and go to the user as before.

## When things go wrong

| Situation | Do |
|---|---|
| A knowledge PR is still open at the next intake | Use the base branch's version, mention the open PR, and extend it at wrap-up |
| A file would go over budget | Propose merges or removals in the same diff |
| Knowledge contradicts `CLAUDE.md` or the code | Flag it, follow `CLAUDE.md` or the code, fix it in the next diff |
| User declines the bootstrap | Start from the empty templates |
| A drafted entry contains a secret, identifier or personal data | Drop it, tell the user, never propose it |
