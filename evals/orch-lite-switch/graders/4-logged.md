---
type: llm
weight: 1
---

The response is an orchestrator switching a running orchestration to lite mode.

PASS if: it records the switch in the ledger (the header's mode and/or an event line such as `[event] mode: lite from T8 on`), or clearly says it does so.

FAIL if the ledger is not mentioned or updated.
