---
type: llm
weight: 1
---

The response is an orchestrator switching a running orchestration to lite mode. T7 is already running on `deep`.

PASS if: T7 keeps running as it is (it finishes on its current tier); the switch applies to tasks not started yet.

FAIL if it changes T7's tier or model mid-run, restarts it, or stops it.
