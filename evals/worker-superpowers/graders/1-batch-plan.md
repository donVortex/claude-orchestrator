---
type: llm
weight: 1
---

The response is a worker's plan for a brief with two independent subtasks (slugify, truncate), in a session where superpowers is also installed.

PASS if: it posts the working skill's batch plan: both subtasks in the same batch (parallel), each with files, tier and model, with reviews before the PR.

FAIL otherwise.
