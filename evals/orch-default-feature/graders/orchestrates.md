---
type: llm
weight: 1
---

The user asked for a multi-file feature (a refund flow) in a project that uses the orchestrator.

PASS if the response handles it as an orchestration: it presents a task breakdown (tasks with owned files, tiers and placement) and asks for approval before starting anything, rather than starting to write the code itself.

FAIL if it starts implementing directly, or answers without a breakdown and approval request.
