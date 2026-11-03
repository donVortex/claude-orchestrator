# Project knowledge

Each project keeps what the orchestrator has learned about it in `.claude/orchestrator/`, committed to the repo and shared by the whole team. You read it on every run, use it to plan, brief and review, and propose changes to it at every wrap-up. It is the project's expertise; the plugin stays generic.

## Layout a new bootstrap creates

```
.claude/orchestrator/
├─ README.md            for humans
├─ domain.md            ## Rules  ## Glossary
├─ map.md               ## Areas  ## Feature flows
├─ review-checklist.md  ## Always check  ## When touching <area>
└─ calibration.md       ## Tiers by task type  ## Split patterns  ## Briefs need
```

| File | Holds | Budget written into a new file (lines) |
|---|---|---|
| `domain.md` | Business and regulatory rules; terms that mean something specific here | 150 |
| `map.md` | Where things live; how a typical feature flows through the layers | 100 |
| `review-checklist.md` | What every review must check; extra checks per area | 60 |
| `calibration.md` | Which task types need which tier here; typical split sizes; brief details workers keep needing | 60 |

A new file's first line states its budget: `<!-- budget: N lines -->`. Starter files are in [knowledge-templates/](knowledge-templates/README.md): [domain.md](knowledge-templates/domain.md), [map.md](knowledge-templates/map.md), [review-checklist.md](knowledge-templates/review-checklist.md), [calibration.md](knowledge-templates/calibration.md).

## The project owns it

The knowledge belongs to the project, not to the plugin. Plugin updates never change it. Once the folder exists, its own files are the layout:

- **Read every file in the folder**, whatever its name, headings or extra files. Map each to the purpose it serves (rules, map, checklist, calibration) by its content, not its name.
- **A file's budget is the one in its own first line.** A file without a budget header has no budget: never apply the table's numbers to it, and never trim it for length.
- **Add entries to the existing file whose purpose fits**, under its existing headings. If no file fits, say so and ask the user whether to add one. Never create a template file in an existing folder on your own.
- **Never migrate.** Don't rename, reformat, restructure, re-template or add budget headers to existing knowledge, and don't propose it, even if the plugin's templates have changed. A layout change happens only when the user asks for it.
- **Bootstrap only when no folder exists anywhere** — not on the base branch, and not in an open knowledge PR (see Bootstrap).
- **Changes only through the knowledge diff**, approved by the user, for content the retros justify or a contradiction flagged at intake.

## Entry format

One line, or a short block, ending with its source and date:

```markdown
- **PHI never appears in logs.** Use `redact()` from `src/phi/redact.ts`. _(bootstrap, 2026-11-03)_
- **Premiums are integer cents**, never floats. _(T2 / PR #42, 2026-11-10)_
```

Sources: `bootstrap`, `user`, or `T<n> / PR #<n>`.

## Content rules

Apply to everything that goes into the repo or onto GitHub: entries, their sources and reasons, PR titles and bodies, and commit messages.

1. **No secrets, credentials, records or personal data, and no record identifiers** (patient, customer, account or claim numbers; code names like `redact()` or `src/phi/` are fine). State the rule, never the value: "MRNs may contain dashes", not "MRN 4471-882 failed". Drop such values wherever you find them, and tell the user what kind of value you left out ("an MRN"), without repeating it.
2. **Don't copy `CLAUDE.md`.** If a rule is already there, refer to it (`see CLAUDE.md: <rule>`) instead of restating it, in every file. A checklist item for such a rule reads `Check CLAUDE.md: <rule>`; add only what `CLAUDE.md` doesn't say (e.g. "also in error messages").
3. **Respect each file's own budget.** If a file has a budget header and an addition would push it over, the same proposal merges or removes entries in that file. Files without a header have no budget.

## Precedence

A task's brief > `CLAUDE.md` > knowledge files. When knowledge contradicts `CLAUDE.md` or the code:
- say so to the user at intake, and record it in the ledger's Events so it survives until wrap-up;
- follow `CLAUDE.md` or the code; **never quote the contradicted entry into a brief's Project rules** — quote `CLAUDE.md`'s version instead;
- fix the entry in the next knowledge diff.

## Reading from the base branch

Read the knowledge as the base branch has it, not as your local checkout happens to be:

```bash
git fetch origin <base>
git ls-tree --name-only origin/<base> .claude/orchestrator/      # which files exist (empty: no folder)
MSYS_NO_PATHCONV=1 git show "origin/<base>:.claude/orchestrator/<file>"   # one file's content
```

`MSYS_NO_PATHCONV=1` matters on Windows: Git Bash otherwise rewrites `origin/<base>:.claude/…` into a Windows path and `git show` fails. It is harmless elsewhere.

An open knowledge PR's branch is read the same way, with `origin/<branch>` in place of `origin/<base>`.

## Working in a worktree

Never `cd` into a worktree under `$root-wt/` in your own shell: it moves your session's working directory there, and the worktree then can't be removed until you move back. Point commands at it instead — `git -C "<dir>" …`, `npm --prefix "<dir>" test` — or run them in a subshell: `(cd "<dir>" && npm test)`.

## Bootstrap

Only at the intake of a **fresh** orchestration (never on resume), and only when the base branch has no `.claude/orchestrator/`. First check for an open knowledge PR:

```bash
gh pr list --state open --search "head:orch/knowledge-" --json number,headRefName,createdAt \
  --jq '[.[] | select(.headRefName | startswith("orch/knowledge-"))] | sort_by(.createdAt) | reverse'
```

GitHub's `head:` search can match more loosely than the prefix; the `--jq` filter keeps only branches that really start with `orch/knowledge-`, newest first.

- **One is open** (from an earlier bootstrap or wrap-up): don't bootstrap. Read its branch's files (see Reading from the base branch), use them for this run, tell the user the PR is still awaiting merge, and quote the checklist items into briefs (workers' worktrees won't have the file).
- **More than one is open:** treat the newest as the knowledge PR (as above), and list the others to the user, suggesting they merge or close them. Never open another knowledge PR while any is open.
- **None is open:** bootstrap.

1. **Scan.** In one message, start parallel `orch-scout` subagents to read the README, `docs/`, `CLAUDE.md`, the folder structure, the test layout and the last 50 commits. Ask each for draft entries with `path:line` sources.
2. **Interview.** Ask the user at most **5** questions, **one at a time** — each one thing to answer, never a bundle of sub-questions — picking from: rules that aren't written down; risky or regulated areas; terms with a specific meaning here; what reviewers must always check; work that has gone wrong before.
3. **Draft.** Fill `README.md` and the four files from the templates, applying the content rules. Remove a template heading that ends up with no entries (e.g. an unused `## When touching <area>`).
4. **Approve.** Show the drafts and ask the user to approve or edit them. Write nothing to the repo before they do.
5. **PR.** The worktree sits outside your working directories: if the user hasn't run `/add-dir <$root>-wt` yet, ask them to now. Then:
   ```bash
   git worktree add -b orch/knowledge-bootstrap "$root-wt/knowledge-bootstrap" origin/<base>
   ```
   Write the approved content into `.claude/orchestrator/` there, commit, push, and open the PR with its body in `$root/.orchestration/knowledge-pr.md` (`gh pr create --body-file`). Remove the worktree afterwards. If the branch name is taken (an earlier bootstrap PR was closed), use `orch/knowledge-bootstrap-<YYYY-MM-DD>`.
6. **Continue.** Feature work waits until that PR is merged, unless the user says to use the approved draft now. Then work from the draft, mention the open PR in every brief's Project rules field, and quote the checklist items into briefs.

`$root` is the main checkout, resolved as in [ledger.md](ledger.md#setup-once-per-repo).

If the user declines the bootstrap, run without knowledge for this orchestration. At the next fresh orchestration, ask once, in one line, whether to bootstrap now; don't start the interview unless they say yes.

## Using it

| Step | Use |
|---|---|
| Intake | Read every file in the folder from the base branch. Tell the user which entries bear on the goal. Flag contradictions (see Precedence). |
| Breakdown | The map's feature flows for where the change belongs; the calibration's tiers and split sizes. |
| Briefs | **Project rules:** quote the rule entries relevant to the task (never a contradicted one). **Review checklist:** name the project's checklist file and the sections that apply; when the knowledge isn't on the base branch yet (open bootstrap PR, approved draft), quote the checklist items themselves. Write the calibration's "briefs need" items into the brief's fields. |
| Reviews | Your own review and every `orch-specialist` pass, `deep` tasks included, check the same checklist items. |

## Knowledge diff at wrap-up

1. Group the retros by tag; `[domain]` points are knowledge candidates, and so are repeated `[brief]`, `[split]` and `[tier]` patterns, plus contradictions recorded at intake.
2. Find an open knowledge PR (same `gh pr list` as in Bootstrap). If one is open, read its branch's files: you will draft against them, not against the base branch. If more than one is open, use the newest and list the others to the user, suggesting they merge or close them.
3. Draft the **knowledge diff**: additions, edits and removals, each in the existing file whose purpose fits (see The project owns it), with its source and a one-line reason. Apply the content rules. For files with a budget header, show the line count against it.
4. Ask the user to approve or edit the diff. Change nothing before they do.
5. Apply it:
   - **Extending an open PR** — check out its branch in its own worktree and apply the approved changes there as **edits to the existing entries**, never by writing whole files (that would undo the PR's pending changes and teammates' review commits):
     ```bash
     git fetch origin <branch>
     git worktree add -B <branch> "$root-wt/knowledge-pr" origin/<branch>
     ```
     Commit, push, tell the user which PR you extended, and remove the worktree.
   - **No open PR** — `git worktree add -b orch/knowledge-<YYYY-MM-DD> "$root-wt/knowledge-<YYYY-MM-DD>" origin/<base>` (add `-2` if the name is taken), apply the edits, commit, push, and open a PR whose body (in `$root/.orchestration/knowledge-pr.md`) lists each change and its reason. Remove the worktree.
6. The team reviews and merges it. You never merge it.

Project knowledge never leaves the project. Plugin edits are separate and go to the user as before.

## When things go wrong

| Situation | Do |
|---|---|
| A knowledge PR is open at the next intake | Use the base branch's knowledge, plus the PR's if the base has none; mention the PR; extend it at wrap-up |
| A file with a budget header would go over it | Propose merges or removals in the same diff |
| Knowledge contradicts `CLAUDE.md` or the code | Flag it, record it in the ledger, follow `CLAUDE.md` or the code, fix it in the next diff |
| User declines the bootstrap | Run without knowledge; ask once, in one line, at the next fresh orchestration |
| A drafted entry, reason or PR text contains a secret, record identifier or personal data | Drop the value, tell the user what kind of value you left out |
