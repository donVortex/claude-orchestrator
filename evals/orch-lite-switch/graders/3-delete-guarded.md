---
type: llm
weight: 1
---

The response is an orchestrator switching to lite mode. T9 deletes share-link records (deleting data).

PASS if: T9 keeps `deep` (or is explicitly kept at its full treatment) because it deletes data.

FAIL if T9 is lowered to `standard`/`fast` without noting it deletes data.
