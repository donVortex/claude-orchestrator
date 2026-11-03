---
type: llm
weight: 1
---

The user asked a quick question about the codebase's error conventions in a project that uses the orchestrator.

PASS if it simply answers the question (TypeError for wrong type, RangeError for a number of the right type but not a whole number), without starting an orchestration: no task breakdown, no plan approval, no workers.

FAIL if it starts an orchestration or a breakdown, or does not answer the question.
