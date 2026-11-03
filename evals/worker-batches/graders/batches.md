---
type: llm
weight: 1
---

The response is a worker's batch plan for four subtasks (A, B, C, D).

PASS only if all of these hold:
1. A, B and D are in the same first batch, to run in parallel.
2. C is in a later batch than A (C edits the same file as A and depends on A).
3. Models: A haiku, B sonnet, C sonnet, D haiku.
4. The plan says the full test suite runs after a batch, before the next batch starts.

FAIL if any of them is missing or contradicted.
