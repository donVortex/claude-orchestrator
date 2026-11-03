---
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, default]
---

[session-orchestrator] This project uses session-orchestrator; its knowledge is in .claude/orchestrator/.
- When the user asks for feature work (new or changed behaviour, more than a one-file fix), use the session-orchestrator:orchestrating skill: plan the breakdown, get approval, then delegate.
- Questions, explanations, reviews and small one-file fixes are normal work; don't orchestrate them.
- If .orchestration/ledger.md exists and isn't done, an orchestration is in progress: continue it with that skill.
- If this session was started with a task brief that names session-orchestrator:working, you are a worker: ignore this note.

---

Quick question: in this codebase, what's the difference between a `RangeError` and a `TypeError` for bad arguments? (The repository isn't checked out here; the project's rule is: a wrong type throws `TypeError('<fn>: <arg> must be a number')`, and a fraction, `NaN` or `Infinity` where a whole number is needed throws `RangeError('<fn>: <arg> must be an integer')`.)
