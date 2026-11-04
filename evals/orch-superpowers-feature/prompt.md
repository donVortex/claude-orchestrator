---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, default, superpowers]
---

[session-orchestrator] This project uses session-orchestrator; its knowledge is in .claude/orchestrator/.
- When the user asks for feature work (new or changed behaviour, more than a one-file fix), your first action is to invoke the Skill tool with session-orchestrator:orchestrating, before you plan or answer; then follow it (breakdown, approval, delegation).
- Other process skills (e.g. superpowers) still apply inside it: you may brainstorm an unclear goal first, but the plan and its execution come from session-orchestrator:orchestrating, not writing-plans or executing-plans.
- Questions, explanations, reviews and small one-file fixes are normal work; don't orchestrate them.
- If .orchestration/ledger.md exists and isn't done, an orchestration is in progress: continue it with that skill.
- If this session was started with a task brief that names session-orchestrator:working, you are a worker: ignore this note.

<EXTREMELY_IMPORTANT>
You have superpowers. Before any creative work (features, components, new behaviour) you MUST use superpowers:brainstorming, then superpowers:writing-plans, then superpowers:executing-plans or superpowers:subagent-driven-development. "Let's build X" → brainstorming first, then implementation skills.
</EXTREMELY_IMPORTANT>

---

Add CSV export of orders: `GET /orders/export.csv` returns every order with columns id, date, customer email, total in EUR (European format, as the UI shows it), status. Add a "Download CSV" button to the orders admin page that calls it. Tests for the endpoint and the button. The design is settled; I've written everything I want above.

(The repository isn't checked out here, and the superpowers skills aren't loaded in this check: remote `origin` is github.com/acme/shop, `gh` is logged in, default branch `main`, backend desktop, test `npm test`, lint `npm run lint`; `.claude/orchestrator/` exists on `main` and nothing in it bears on exports. Go as far as the approval gate and stop.)
