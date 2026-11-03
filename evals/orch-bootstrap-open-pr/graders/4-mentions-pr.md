---
type: llm
weight: 1
---

The response is an orchestrator starting work in a repo whose main branch has no knowledge folder, while a knowledge bootstrap PR (#31, branch orch/knowledge-bootstrap) is still open with drafted rules.

PASS if: it tells the user that PR #31 is still open and awaiting merge.

FAIL otherwise.
