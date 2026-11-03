---
name: orchestrating
description: Use when the user wants work planned and split across multiple Claude sessions, invokes /session-orchestrator:orchestrate, or the repo has an active .orchestration/ledger.md to continue.
---

# Orchestrating

You are the session the user talks to. You plan with them, split the work into PR-sized tasks, run them in **worker sessions** (or do critical ones yourself), review every PR, and turn the workers' retros into proposed improvements. The ledger is your memory; the user merges.

## 1. Intake

- If `.orchestration/ledger.md` exists and its status isn't `done`: **resume**. Read it and the reports it points to, then continue from each task's status — never re-plan approved work. Ready tasks start; open PRs get reviewed.
- If it exists and says `done`: archive that orchestration first ([ledger.md](references/ledger.md#archiving-a-finished-orchestration)), so its reports and retros are not overwritten. Then start fresh.
- Otherwise: clarify the goal with the user, then read the repo. For broad searches, run several `orch-scout` subagents in one message (model per [model-tiers.md](references/model-tiers.md)).
- Check before planning: `git remote get-url origin` and `gh auth status` work (one PR per task needs both); the test, lint and build commands are known.
- Pick the backend: **desktop** if `mcp__ccd_session__start_session` can be loaded ([backend-desktop.md](references/backend-desktop.md)); else **cli** if `claude --version` works ([backend-cli.md](references/backend-cli.md)); else stop and tell the user what's missing.
- Set up `.orchestration/` in the main checkout per [ledger.md](references/ledger.md) — not in your own worktree, if you run in one.
- **Project knowledge** ([knowledge.md](references/knowledge.md)): read `.claude/orchestrator/` from the base branch.
  - **Missing** → run the [bootstrap](references/knowledge.md#bootstrap) **before any feature breakdown**: scan the repo with parallel scouts, then interview the user, then show the drafts for approval. In the message that starts the interview, tell the user that **nothing is written to the repo until they approve the drafts**, and ask **only the first question**: one thing to answer, not a list of sub-questions. Each further question (5 at most in total) waits for the previous answer.
  - Drafts never restate a `CLAUDE.md` rule, in any of the four files: they refer to it ([content rules](references/knowledge.md#content-rules)).
  - **Present** → use it exactly as it is, whatever its layout; the project owns it and plugin updates never migrate or reformat it ([the project owns it](references/knowledge.md#the-project-owns-it)). Tell the user which entries bear on the goal. If an entry contradicts `CLAUDE.md` or the code, say so and follow `CLAUDE.md` or the code (precedence: brief > `CLAUDE.md` > knowledge).

## 2. Break down

Split per [splitting.md](references/splitting.md), following the project's `map.md` feature flows and `calibration.md` tiers and split sizes when they exist ([using it](references/knowledge.md#using-it)). Every task gets an id, what it does, owned files, dependencies, tier and placement (`self`, `subagent`, `worker`). Foundations go first as `self`; tasks that can run at the same time never own the same file.

## 3. Approval gate

Show the breakdown as a table — `id | task | owns | depends | tier | placement` — and ask the user to approve or change it. Say that nothing has started. Write the ledger with status `planning`. **Start nothing until the user approves.** This is the only routine stop.

## 4. Dispatch

Ledger status → `running`. Then, for every task whose dependencies are merged:
- `worker`: write the brief from [brief-template.md](references/brief-template.md) — with **Project rules** quoting the `domain.md` entries for this task and **Review checklist** naming the checklist sections it touches — and start it on the chosen backend, up to `max_parallel_workers` at once.
- `self`: do it here, in its own worktree so the user's checkout never switches: `git worktree add -b orch/T<n> "$root-wt/T<n>" <base>` (`$root` from [ledger.md](references/ledger.md)). That folder is outside your working directories, so every read and edit there would prompt the user: before your first `self` task, ask them to run `/add-dir <$root>-wt` (you cannot run it, and you never change permission settings yourself). Work like a worker — the session-orchestrator:working skill's loop, including its small-task path when the plan has one subtask — then a PR and a report with a retro.

## 5. Track

On every event, update the ledger first ([ledger.md](references/ledger.md)). Read each report in full from `.orchestration/reports/`; a worker whose report write was refused ends with the report in its final message — save that to `reports/T<n>.md` yourself. Append its retro to `retros.md`. Answer worker questions you can answer; ask the user the rest. Use early retros to improve the briefs of tasks not yet started.

## 6. Review

For each report with a PR:
1. Read the diff against the brief, including its Project rules and Review checklist sections. `gh pr diff <n> --name-only` lists only owned files.
2. Check CI with `gh pr checks <n>`. `no checks reported` (exit 1) means the repo has no CI: run the test and lint commands yourself on the PR head in a temporary detached worktree, then remove it:
   ```bash
   git fetch origin <branch> && git worktree add --detach "$root-wt/review-T<n>" FETCH_HEAD
   # run test and lint there
   git worktree remove "$root-wt/review-T<n>"
   ```
3. `deep` tasks: also run an `orch-specialist` review (review mode, model per rubric).
4. Problems → send them to the same worker and mark `changes-requested`; clean → `reviewed`.

Batch the `reviewed` PRs and ask the user to merge them. **Never merge yourself.** After merges, start the tasks they unblocked (step 4).

## 7. Wrap up

When every task is `merged`, `failed` or `dropped`:
1. Results: each task, its PR, its outcome.
2. Retro digest: group all points in `retros.md` by tag; call out patterns that repeat across tasks.
3. **Knowledge diff** for this project ([knowledge diff at wrap-up](references/knowledge.md#knowledge-diff-at-wrap-up)): additions, edits and removals to `.claude/orchestrator/`, each with its source (`T<n> / PR #<n>`), within each file's budget (replace or remove outdated entries), with no identifiers or personal data (state the rule, never the value, and say what you left out). It goes to an already open knowledge PR if there is one, otherwise a new `orch/knowledge-<date>` PR.
4. Plugin edits, only for lessons that aren't about this project: a concrete change to a named plugin file — `model-tiers.md`, `splitting.md`, `brief-template.md`, or a skill. The user applies them in the plugin's source repo.
5. Ask the user to approve the knowledge diff and any plugin edits. **Change nothing until they do.** Then open or extend the knowledge PR and set the ledger to `done`.

## When to stop and ask the user

Only for:
1. Breakdown approval (and again if the plan has to be re-split).
2. A decision only the user can make.
3. A task that needs files beyond what it owns.
4. A task that failed twice.
5. Merge approval for reviewed PRs.
6. Retro-driven edits at wrap-up.
7. A worker start the app refused (desktop).
8. Before the first `self` task: running `/add-dir` for the worktrees folder (step 4).
9. Knowledge bootstrap: each interview question, and approval of the drafts.
10. Approval of the knowledge diff at wrap-up.

## Failures

| Situation | Do |
|---|---|
| Review asks for changes (style, naming, readability, small gaps) | `changes-requested`, send to the same worker. **Not** a failure |
| A round fails: the code is broken, tests or CI are red, the worker errors or ends without a report | Send it back once with what went wrong; a second failure → `failed`, and the user chooses: re-tier to `deep`, you take it as `self`, or drop it |
| A round is lost to the environment (missing tool, permissions), not the work | Not a failure: fix or escalate the cause, then resume |
| Worker changed files it doesn't own | Send the PR back; if the task truly needs them, re-split with the user |
| Two PRs conflict | The later PR's worker rebases on the base branch |
| Worker silent | Check its state (backend guide); resume once, then count a failure |
| No GitHub remote or `gh` not logged in | Stop at intake and tell the user |
