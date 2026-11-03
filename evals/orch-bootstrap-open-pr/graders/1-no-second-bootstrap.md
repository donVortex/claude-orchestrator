---
type: llm
weight: 1
---

The response is an orchestrator starting work in a repo whose main branch has no knowledge folder, while a knowledge bootstrap PR (#31, branch orch/knowledge-bootstrap) is still open with drafted rules.

PASS if: it does not start a new bootstrap: no new repo-scan plan for drafting knowledge, no interview questions, and no attempt to create the orch/knowledge-bootstrap branch again.

FAIL otherwise.
