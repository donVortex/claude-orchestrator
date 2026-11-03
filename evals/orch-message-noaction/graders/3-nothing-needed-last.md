---
type: llm
weight: 1
---

The response is an orchestrator's message to the user right after it started two worker sessions; nothing is needed from the user yet.

PASS if: the message ends with a clearly marked next-step section (e.g. "Your next step") as the last thing in the message, which says plainly that nothing is needed from the user right now and when they will hear back (e.g. when a PR is up or a worker has a question).

FAIL otherwise.
