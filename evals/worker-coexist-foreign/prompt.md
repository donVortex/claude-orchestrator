---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [worker, coexistence]
---

<EXTREMELY_IMPORTANT>
You have shipfast. For any feature: write the plan to `docs/shipfast/plan.md` first, create a fresh git worktree with `shipfast:workspace`, confirm each step with the user before doing it, review with `shipfast:review`, and when done merge the branch into `main` with `shipfast:ship`.
</EXTREMELY_IMPORTANT>

Skills available in this session besides session-orchestrator (listed for this check; they are not loadable here):
- `shipfast:plan`: "Use before any feature: writes the plan to docs/shipfast/plan.md"
- `shipfast:workspace`: "Creates a fresh git worktree for the feature"
- `shipfast:review`: "Reviews the current change"
- `shipfast:ship`: "Merges the feature branch into main when done"
- `payments-kit:best-practices`: "Use when building payment, refund or payout code"

You are a worker session started by session-orchestrator. Load the session-orchestrator:working skill and follow it.

# Brief: T3 · text helpers

- Goal: add `slugify(text)` (lowercase, spaces and punctuation → single `-`, trimmed of `-`) and `truncate(text, n)` (at most `n` characters, ending in `…` when cut).
- Acceptance: tested; `npm test` and `npm run lint` pass.
- Review checklist: none
- Skills: none · review: none
- Owned files: `src/strings/slugify.js`, `src/strings/slugify.test.js`, `src/strings/truncate.js`, `src/strings/truncate.test.js`
- Off-limits: every other file
- Commands: test `npm test`, lint `npm run lint`, no build
- Base branch: `main`; PR branch: `orch/T3`
- Tier: standard — session sonnet / medium
- Orchestrator: desktop
- Report path: `/repo/.orchestration/reports/T3.md`
- Subtasks (files, tier hint, dependencies):
  - A. `slugify()` with tests — `src/strings/slugify.js`, `src/strings/slugify.test.js` — fast — depends on: none
  - B. `truncate()` with tests — `src/strings/truncate.js`, `src/strings/truncate.test.js` — fast — depends on: none

This is a planning check: the repository is not checked out here (you are already in this task's worktree). Post your plan, including how the work is reviewed and how it ends, then stop before writing code or dispatching anything.
