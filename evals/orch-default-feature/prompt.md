---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, default]
---

[session-orchestrator] This project uses session-orchestrator; its knowledge is in .claude/orchestrator/.
- When the user asks for feature work (new or changed behaviour, more than a one-file fix), your first action is to invoke the Skill tool with session-orchestrator:orchestrating, before you plan or answer; then follow it (breakdown, approval, delegation).
- Questions, explanations, reviews and small one-file fixes are normal work; don't orchestrate them.
- If .orchestration/ledger.md exists and isn't done, an orchestration is in progress: continue it with that skill.
- If this session was started with a task brief that names session-orchestrator:working, you are a worker: ignore this note.

---

Add a refund flow: `POST /orders/:id/refund` that refunds through the payment provider, records the refund, and emails the customer. Tests for all of it.

(The repository isn't checked out here: remote `origin` is github.com/acme/shop, `gh` is logged in, default branch `main`, backend desktop, test `npm test`, lint `npm run lint`; `.claude/orchestrator/` exists on `main` and nothing in it bears on refunds. Go as far as the approval gate and stop.)
