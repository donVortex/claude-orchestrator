---
name: working
description: Use when this session was started by session-orchestrator as a worker, or its prompt is a task brief that names session-orchestrator:working.
---

# Working a task

You deliver **one task as one PR**, using subagents whose model is picked by tier, then report back to the orchestrator with a retro. The brief is your contract.

## 1. Read the brief

- **Owned files** are the only files you and your subagents may change. The off-limits list is binding.
- Unclear goal, acceptance criteria, or a need to touch a file you don't own → ask; never guess. Write the report with `Status: blocked` and a `## Question` section (see [report-format.md](report-format.md)), then end your turn. Ending the turn wakes the orchestrator; its answer arrives in this same conversation.

## 2. Plan in batches

Read [model-tiers.md](../orchestrating/references/model-tiers.md). Split the task into subtasks; give each its files, a tier and what it depends on.

- **Same batch**: subtasks whose files don't overlap and that don't depend on each other — up to `max_parallel_implementers_per_session`.
- **Later batch**: a subtask that shares a file with, or depends on, an earlier one.

Before dispatching anything, post the plan:

| Batch | Subtask | Files | Tier | Model |
|---|---|---|---|---|

followed by the line: `The full test suite runs after each batch, before the next one starts.`

## 3. Run each batch

1. **Implement** — send all of the batch's Agent calls **in one message**; that is what runs them in parallel. Every call passes `model` from the rubric:
   - `fast`, `standard` → `orch-implementer`; `deep` → `orch-specialist` (build mode).
   - Its prompt: the subtask goal, its files (and that nothing else may change), the test command, "do not commit".
2. **Review** — for each finished subtask, a spec-compliance review (does exactly what the subtask says, only in its files), then a code-quality review. Use `orch-specialist` in review mode, model = the subtask's tier model but never below sonnet. Reviews of different subtasks run in parallel.
3. **Fix** — send findings back to an implementer; review again.
4. **Gate** — commit the batch, run the full test suite. Not green → fix before the next batch.

If superpowers is installed, its subagent-driven-development and test-driven-development skills apply inside each subtask; the batching and model rules here win. Without it: test first, watch it fail, minimal code, watch it pass.

## 4. Escalate

A subagent that fails or returns weak work: retry once on the next tier up and note it as a `[tier]` retro point. A second failure: report `Status: failed` with what happened.

## 5. Verify

Run the full test, lint and build commands and read the output. You may only claim done with that output in hand (superpowers:verification-before-completion, if installed). Check `git diff --name-only <base>...HEAD` lists only owned files.

## 6. Open the PR

`git push -u origin HEAD:orch/<task-id>` (your local branch name may differ; the remote branch is always `orch/<task-id>`), then `gh pr create --base <base> --head orch/<task-id> --title "T<n>: <task>"` with a body of: Goal, Changes, Verification (commands → results), Risks. Never force-push, and never push to the base branch.

## 7. Report

Write the report in [report-format.md](report-format.md) to the brief's report path. Then end your turn with one line: `T<n> done, PR <url>, report at <path>`.

Review fixes from the orchestrator arrive in this same conversation: fix on the same branch, push, re-verify, and rewrite the report (add new retro points; keep the old ones).

## Common mistakes

| Mistake | Instead |
|---|---|
| Agent calls in separate messages | One message per batch, or nothing runs in parallel |
| Leaving out `model` | Every Agent call passes the rubric's model |
| A subagent changed a file it doesn't own | Revert that change; redo the subtask inside its files |
| "Tests should pass" | Run them; quote the real result |
| Guessing on an unclear brief | Ask (step 1) |
| Retro like "brief could be clearer" | Say exactly what was missing, tagged |
