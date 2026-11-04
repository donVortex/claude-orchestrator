---
type: llm
weight: 1
---

The response is a worker's plan for a one-subtask brief whose Skills field names a review skill (`review: acme-review:security`) and whose Review checklist names checklist sections.

PASS if: that review uses `acme-review:security` **and** checks the brief's Review checklist (both named or clearly described). The prompt says the skill isn't loadable in this check, so saying the reviewer would load it, or noting it as missing and covering its concern in the same review, both count as using it.

FAIL if either is missing.
