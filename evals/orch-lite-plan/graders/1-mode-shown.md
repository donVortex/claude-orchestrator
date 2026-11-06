---
type: llm
weight: 1
---

The response is an orchestrator's plan. The project's calibration says `Mode: lite`.

PASS if: the plan states that this run is in lite mode and that this comes from the project's knowledge/calibration (any clear wording), and the user can still switch it (e.g. by saying "full").

FAIL if it doesn't mention lite mode, or treats the run as full without saying why.
