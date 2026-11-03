# Desktop backend

Workers are real Claude desktop app sessions, each in its own git worktree. The user can open, watch and steer them from the sidebar.

## When to use it

Use it when `mcp__ccd_session__start_session` can be loaded (ToolSearch `select:mcp__ccd_session__start_session`). Load the session tools you need in one ToolSearch call: `start_session`, `mcp__ccd_session_mgmt__set_session_model`, `mcp__ccd_session_mgmt__set_session_effort`, `mcp__ccd_session_mgmt__list_sessions`, `mcp__ccd_session_mgmt__get_session`, `SendMessage`. Record `Backend: desktop` in the ledger header.

## Starting a worker

1. Write the brief to `.orchestration/briefs/T<n>.md` ([brief-template.md](brief-template.md)) with `Orchestrator: desktop`.
2. `start_session` with:
   - `initiation: "user_asked"` — the user's approval of the breakdown is the instruction to start it
   - `context: "fresh"`, `use_worktree: true`
   - `source_branch`: the ledger's base branch, so the worktree starts from the right commit
   - `branch_name`: `orch-T<n>` (the app adds its own prefix and suffix)
   - `model` and `effort`: the task tier's **worker session** values from [model-tiers.md](model-tiers.md), set here so they apply to the worker's first turn (setting them after the start only applies from the next turn). `model` takes a full model id, not an alias: use the current id of that family (e.g. `claude-sonnet-5-5` for `sonnet`).
   - `title`: `T<n> · <short task>`
   - `prompt`: the brief
   - `background` (required, 80+ characters): the orchestration goal in one sentence, how this task fits (what it depends on, what depends on it), and "You are a session-orchestrator worker; the brief is your contract."
3. The app only allows a model and effort **at or below this session's own**. If a tier asks for more (e.g. a `deep` task while you run on sonnet), tell the user before starting it: they can raise this session's model, or accept the lower tier.
4. Ledger: session id, the worktree branch name the start result reports, `running`, and an event line.

Before cutting worktrees, the app may fast-forward `source_branch` in the user's main checkout to its upstream — it doesn't always. Don't promise either: when you show the breakdown, say the app may move their local base branch forward. Check what a worker actually started from (`git -C <worktree> log -1`) rather than assuming, and briefs need no reset-to-origin step.

Start independent ready tasks in the same turn, up to `max_parallel_workers`.

## While workers run

- The app wakes you when a worker ends a turn. The wake-up note is truncated: read `.orchestration/reports/T<n>.md` for the full report.
- A worker with a question writes its report with `Status: blocked` and a `## Question`, then ends its turn, which wakes you. Answer with `SendMessage` to its `local_…` id if you can; if only the user can decide, ask the user, then forward their answer quoting their words.
- Review fixes go back with `SendMessage` to the same worker.
- Liveness: `list_sessions {"linked": true}` or `get_session`. A worker that ended its turn without a report, or errored, counts as a failure round.
- Never poll or sleep; wait for the app's wake-up.

## Reports and permissions

Workers write their report to the main checkout's `.orchestration/reports/`, which is outside their worktree. Depending on the worker's permission mode, the app may ask the user to approve that write the first time. Mention this to the user when the first workers start.

## When the app refuses a start

The app may refuse `start_session` on a turn it triggered itself (not one started by the user's message). Then:
1. Propose each refused start as a card: `start_session` with `initiation: "own_initiative"` and the same brief.
2. Tell the user in one line that T<n> is waiting for them to click Start.
3. Ledger: `blocked` with the event `needs start click`.

The app also refuses starts in a folder the user hasn't trusted yet. Trusting a folder is the user's decision; you cannot do it. Then:
1. Tell the user, once for all refused tasks, that the app needs them to trust `<repo folder>` before workers can start, and that the briefs are ready.
2. Ledger: `blocked` with the event `needs folder trust`. This is not a failure.
3. When they confirm, retry the same starts.

Workers' first report writes, outside their worktree, may also ask the user to approve them. Mention both when you show the breakdown for approval, so neither comes as a surprise.

## Cleanup

Workers' worktrees belong to their sessions. After the user merges a task's PR, you may offer to archive that session; do it only on the user's yes.
