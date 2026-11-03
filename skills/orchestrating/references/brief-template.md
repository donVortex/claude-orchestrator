# Worker brief template

The brief is the worker's whole contract; it sees nothing else from this conversation. Workers block and ask on anything missing or contradictory, so fill every field. Save each brief to `.orchestration/briefs/T<n>.md` before sending it.

```markdown
# Brief: T<n> · <short task>

Load the session-orchestrator:working skill and follow it.

- Goal: <one or two sentences, with the concrete names and values the work needs: field names, setting names, request/response and error shapes>
- Acceptance: <checkable criteria, each with how it is verified>
- Owned files: <files/globs, including their test files>
- Off-limits: every other file (name tempting neighbours explicitly, e.g. `src/db/schema.ts`)
- Commands: test `<cmd>`, lint `<cmd>`, build `<cmd>`
- Base branch: `<branch>` (already contains: <merged dependency PRs, or "nothing extra">)
- Tier: <fast|standard|deep> — session <model> / <effort>
- Orchestrator: desktop | CLI mode
- Report path: `<$root>/.orchestration/reports/T<n>.md` (absolute; `$root` as resolved in ledger.md)
- Subtasks (files, tier hint, dependencies):
  - A. <what> — <files> — <tier> — depends on: none
  - B. <what> — <files> — <tier> — depends on: A
- Context: <what earlier tasks produced that this one uses: signatures, table columns, endpoints, with file paths>
- Lessons from earlier tasks: <retro points that apply here, or "none">

Report in the format of the working skill's report-format.md, then send: `T<n> done, PR <url>, report at <path>`.
```

## Check before sending

| Check | Why |
|---|---|
| Every test the acceptance criteria require has its test file in **Owned files** | Otherwise the worker can't write the tests and blocks |
| Test, lint and build commands are given | Otherwise the worker can't verify and blocks |
| Every subtask lists its files and dependencies (`none` is a value) | Workers batch on these; a missing dependency gets guessed |
| Names, shapes and values the work needs are written out | "use the settings from the goal" fails when the goal has none |
| Owned files don't overlap any task that can run at the same time | See [splitting.md](splitting.md) |
| Report path is absolute and points at the **main** checkout | Workers run in their own worktrees |
