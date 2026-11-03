# Desktop backend

Workers are real Claude desktop app sessions, each in its own git worktree. The user can open, watch and steer them from the sidebar.

## When to use it

Use it when `mcp__ccd_session__start_session` can be loaded (ToolSearch `select:mcp__ccd_session__start_session`). Load the session tools you need in one ToolSearch call: `start_session`, `mcp__ccd_session_mgmt__set_session_model`, `mcp__ccd_session_mgmt__set_session_effort`, `mcp__ccd_session_mgmt__list_sessions`, `mcp__ccd_session_mgmt__get_session`, `SendMessage`. Record `Backend: desktop` in the ledger header.

## Starting a worker

1. Write the brief to `.orchestration/briefs/T<n>.md` ([brief-template.md](brief-template.md)) with `Orchestrator: desktop`.
2. `start_session` with:
   - `initiation: "user_asked"` — the user's approval of the breakdown is the instruction to start it
   - `context: "fresh"`
   - `use_worktree: true`
   - title `T<n> · <short task>`
   - the brief as the prompt
3. With the returned session id: `set_session_model` and `set_session_effort` to the task tier's **worker session** values in [model-tiers.md](model-tiers.md).
4. Ledger: session id, `running`, an event line.

Start independent ready tasks in the same turn, up to `max_parallel_workers`.

## While workers run

- The app wakes you when a worker ends a turn. The wake-up note is truncated: read `.orchestration/reports/T<n>.md` for the full report.
- A worker with a question writes its report with `Status: blocked` and a `## Question`, then ends its turn, which wakes you. Answer with `SendMessage` to its `local_…` id if you can; if only the user can decide, ask the user, then forward their answer quoting their words.
- Review fixes go back with `SendMessage` to the same worker.
- Liveness: `list_sessions {"linked": true}` or `get_session`. A worker that ended its turn without a report, or errored, counts as a failure round.
- Never poll or sleep; wait for the app's wake-up.

## When the app refuses a start

The app may refuse `start_session` on a turn it triggered itself (not one started by the user's message). Then:
1. Propose each refused start as a card: `start_session` with `initiation: "own_initiative"` and the same brief.
2. Tell the user in one line that T<n> is waiting for them to click Start.
3. Ledger: `blocked` with the event `needs start click`.

## Cleanup

Workers' worktrees belong to their sessions. After the user merges a task's PR, you may offer to archive that session; do it only on the user's yes.
