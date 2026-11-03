# End-to-end checklist

A dry run of the whole system on a throwaway repo, once per backend. Tick each box with what you saw; anything that fails becomes a test or eval case before it is fixed.

## Setup

- [ ] `claude plugin marketplace add D:\dev\claude-orchestrator`
- [ ] `claude plugin install session-orchestrator@session-orchestrator`
- [ ] `claude plugin list` shows `session-orchestrator` enabled
- [ ] A throwaway GitHub repo (e.g. `donVortex/orch-sandbox`) with a tiny project, a working `npm test` (or equivalent), cloned locally
- [ ] The sandbox's test command is added to `settings/worker-allowlist.json` (CLI run only)

Goal to use (three tasks: one `self`, two workers):

> Add a `slugify(text)` utility with tests, a `truncate(text, n)` utility with tests, and a shared `src/strings/index.ts` that exports both.

## Desktop run

In a new desktop session opened on the sandbox folder: `/session-orchestrator:orchestrate <goal>`

- [ ] Intake checks `origin`, `gh auth status`, and picks the desktop backend
- [ ] The breakdown table appears and the orchestrator waits for approval
- [ ] `.orchestration/` exists and is listed in `.git/info/exclude`
- [ ] After approval, workers appear as sessions titled `T<n> · …` with the tier's model and effort
- [ ] Workers load `session-orchestrator:working` (confirms plugins load in sessions started by another session)
- [ ] A worker's batch plan runs independent subagents in one message (parallel)
- [ ] Each worker opens a PR and writes `.orchestration/reports/T<n>.md`
- [ ] `retros.md` gains one entry per finished task
- [ ] The orchestrator reviews each PR and asks you to merge; it never merges
- [ ] `/compact` in the orchestrator, then a message: the ledger is re-injected and work continues
- [ ] After merges: the wrap-up digest and proposed edits appear, and nothing is edited until you approve

## CLI run

In a terminal (Git Bash) in the sandbox: `claude`, then `/session-orchestrator:orchestrate <goal>`

- [ ] Intake picks the CLI backend
- [ ] Workers start via `cli-worker.sh start`, in `<repo>-wt/T<n>` on `orch/T<n>`, in the background
- [ ] `session_id` lands in the ledger
- [ ] A blocked worker is answered via `cli-worker.sh resume`
- [ ] PRs, reports and retros as in the desktop run
- [ ] After merge, `cli-worker.sh remove` cleans up the worktree

## Results

Record what passed, what failed, and what was fixed in the README's "Verified" section.
