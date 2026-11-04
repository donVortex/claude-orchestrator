---
type: llm
weight: 1
---

The response is the orchestrator's first move after being started with no goal, in an existing project that has no orchestrator knowledge yet.

PASS if: it asks exactly one domain question about the project (the first of the interview), not a list of questions, and not 'what is your goal?' as its only question.

FAIL otherwise.
