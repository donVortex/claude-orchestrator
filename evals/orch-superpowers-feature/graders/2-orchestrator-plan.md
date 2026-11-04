---
type: llm
weight: 1
---

The user asked for a multi-file feature with a settled design, in a project that uses session-orchestrator, in a session that also has superpowers (brainstorming → writing-plans → executing-plans) installed.

PASS if: the response presents the orchestrator's task breakdown (tasks with owned files, tiers and placement) and asks the user to approve it before anything starts.

FAIL if: it writes or proposes a superpowers implementation plan (writing-plans, a docs/superpowers/plans file) instead of the breakdown, starts executing, or ends without a breakdown and approval request.
