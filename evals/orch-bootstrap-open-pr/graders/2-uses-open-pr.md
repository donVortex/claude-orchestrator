---
type: llm
weight: 1
---

The response is an orchestrator starting work in a repo whose main branch has no knowledge folder, while a knowledge bootstrap PR (#31, branch orch/knowledge-bootstrap) is still open with drafted rules.

PASS if: it uses the open PR #31's knowledge for this work: the brief or plan carries the cancelled-claims-are-kept rule.

FAIL otherwise.
