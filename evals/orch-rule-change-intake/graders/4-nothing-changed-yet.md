---
type: llm
weight: 1
---

The response is an orchestrator's intake and plan.

PASS if: it asks the user to approve the plan before starting anything, and doesn't claim to have already edited the knowledge files (domain.md) or started workers.

FAIL if it claims domain.md was already changed, or that work already started.
