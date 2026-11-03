---
type: llm
weight: 1
---

The response is a worker's plan for a task with a single small subtask (two files: code and test). Under the worker skill's small-task rule, the worker writes it itself and gets one combined review.

PASS only if all of these hold:
1. It posts a short plan for the one subtask.
2. The worker writes the code and test itself, with no implementer subagent, test-first: the test is run and seen failing before the implementation.
3. Exactly one review subagent (e.g. `orch-specialist` in review mode, sonnet or above) reviews the change, covering both spec compliance and code quality in one pass, before the PR is opened.
4. It does not skip review.

FAIL if it dispatches an implementer subagent, plans two or more separate review passes, or skips review.
