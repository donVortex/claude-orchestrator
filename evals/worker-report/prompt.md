---
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
tags: [worker]
---

You are a worker session started by session-orchestrator. Load the session-orchestrator:working skill and follow it.

You have finished task T4 (CLI mode). Facts:

- PR: https://github.com/acme/app/pull/42
- Changed: `src/api/errors.ts` (new error mapper), `tests/api/errors.test.ts`
- Verified: `npm test` → 48 passed, 0 failed; `npm run lint` → clean
- Risk: the mapper treats unknown status codes as 500.
- Problems during the task:
  - The brief did not say how API errors should be shaped, so you had to ask the orchestrator and wait for the answer.
  - The haiku implementer failed on the test file; you escalated to sonnet, which got it right first try.

Write your final report now, exactly as your skill specifies. File writing is disabled in this check, so show the complete report text in your reply.
