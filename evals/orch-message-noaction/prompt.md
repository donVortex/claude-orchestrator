---
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, messages]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start. You are mid-orchestration in donVortex/orch-sandbox. Current state:

- The user approved the breakdown a moment ago: T1 `slugify` (worker, standard) and T2 `truncate` (worker, standard), no dependencies between them.
- You just started both workers on the desktop backend: T1 is session `local_aa11` (sonnet / medium), T2 is session `local_bb22` (sonnet / medium). Briefs are saved in `.orchestration/briefs/T1.md` and `.orchestration/briefs/T2.md`; the ledger is updated.
- Nothing is needed from the user until a worker opens its PR or asks a question.

Write your message to the user now. The tools to act are not available here, so just write the message.
