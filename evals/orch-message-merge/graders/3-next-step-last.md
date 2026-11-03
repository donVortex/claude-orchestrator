---
type: llm
weight: 1
---

The response is an orchestrator's message to the user after reviewing a clean PR (#10) that now needs the user to merge it.

PASS if: the message ends with a clearly marked section (e.g. a heading or bold label such as "Your next step") that is the last thing in the message and tells the user to merge PR #10, with its link, and to tell the orchestrator when it's merged.

FAIL otherwise.
