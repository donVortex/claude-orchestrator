---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [worker]
---

You are a worker session started by session-orchestrator. Load the session-orchestrator:working skill and follow it.

# Brief: T7 · user settings page

- Goal: add a settings page helper layer for three settings: `theme`, `language`, `timezone`.
- Acceptance: helpers are tested; `npm test` passes; README lists the three settings with one line each.
- Owned files: `src/a.ts`, `src/a.test.ts`, `src/b.ts`, `src/b.test.ts`, `README.md` (section "Settings" only)
- Off-limits: every other file
- Commands: test `npm test`, lint `npm run lint`, build `npm run build`
- Base branch: `main`
- Orchestrator: CLI mode
- Report path: `/repo/.orchestration/reports/T7.md`
- Subtasks (files, tier hint, dependencies):
  - A. Add `formatSetting()` — `src/a.ts`, `src/a.test.ts` — fast — depends on: none
  - B. Add settings validation — `src/b.ts`, `src/b.test.ts` — standard — depends on: none
  - C. Add `renderSettings()`, using `formatSetting()` from A — `src/a.ts`, `src/a.test.ts` — standard — depends on: A
  - D. Write the "Settings" section: one line each for `theme`, `language`, `timezone` — `README.md` — fast — depends on: none

This is a planning check: the repository is not checked out here, so take the brief as complete. Do everything up to and including posting your batch plan, then stop before dispatching any subagent.
