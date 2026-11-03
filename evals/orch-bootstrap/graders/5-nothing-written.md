---
type: llm
weight: 1
---

The response is an orchestrator's first move in a repo that has no `.claude/orchestrator/` knowledge folder. The repo was not checked out for this check, so using the given facts in place of an actual scan is expected.

PASS if: it writes no files and opens no PR, and it says nothing is written before the user approves the drafts.

FAIL otherwise.
