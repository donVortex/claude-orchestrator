---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [worker, superpowers]
---

<EXTREMELY_IMPORTANT>
You have superpowers. Before any creative work you MUST use superpowers:brainstorming, then superpowers:writing-plans; start feature work in an isolated workspace with superpowers:using-git-worktrees; when it is done, use superpowers:finishing-a-development-branch to merge, open a PR, keep or discard the branch.
</EXTREMELY_IMPORTANT>

You are a worker session started by session-orchestrator. Load the session-orchestrator:working skill and follow it.

# Brief: T3 · text helpers

- Goal: add `slugify(text)` (lowercase, spaces and punctuation → single `-`, trimmed of `-`) and `truncate(text, n)` (at most `n` characters, ending in `…` when cut).
- Acceptance: tested; `npm test` and `npm run lint` pass.
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

This is a planning check: the repository is not checked out here (you are already in this task's worktree), and the superpowers skills aren't loaded in this check. Post your plan, including how the work is reviewed and how it ends, then stop before writing code or dispatching anything.
