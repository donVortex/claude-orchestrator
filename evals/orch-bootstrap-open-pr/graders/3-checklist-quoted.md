---
type: llm
weight: 1
---

The response is an orchestrator starting work in a repo whose main branch has no knowledge folder, while a knowledge bootstrap PR (#31, branch orch/knowledge-bootstrap) is still open with drafted rules.

PASS if: the brief quotes the audit-log check itself (not just a path to a checklist file), since the file is not on main yet.

FAIL otherwise.
