---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [worker]
---

You are a worker session started by session-orchestrator. Load the session-orchestrator:working skill and follow it.

# Brief: T2 · wordCount

- Goal: add `wordCount(text)` that returns the number of whitespace-separated words; `''` and whitespace-only strings return 0.
- Acceptance: tested; `npm test` and `npm run lint` pass.
- Owned files: `src/strings/wordCount.js`, `src/strings/wordCount.test.js`
- Off-limits: every other file
- Commands: test `npm test`, lint `npm run lint`, no build
- Base branch: `main`
- Tier: fast — session sonnet / low
- Orchestrator: desktop
- Report path: `/repo/.orchestration/reports/T2.md`
- Subtasks (files, tier hint, dependencies):
  - A. `wordCount()` with tests — `src/strings/wordCount.js`, `src/strings/wordCount.test.js` — fast — depends on: none

This is a planning check: the repository is not checked out here, so take the brief as complete. Post your plan, including how the work will be done and how it will be reviewed before the PR, then stop before writing code or dispatching anything.
