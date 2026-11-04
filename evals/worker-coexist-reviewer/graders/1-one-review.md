---
type: llm
weight: 1
---

The response is a worker's plan for a one-subtask brief whose Skills field names a review skill (`review: acme-review:security`) and whose Review checklist names checklist sections.

PASS if: it plans exactly one review of the change before the PR, not a separate security review plus another review of the same change.

FAIL otherwise.
