---
type: llm
weight: 1
---

The response is an orchestrator's message to the user after reviewing a clean PR (#10) that now needs the user to merge it.

PASS if: the body between the status line and the closing section is short bullet points (about 8 bullets or fewer, each one or two lines), with no long paragraphs, tables of every detail, or pasted report text.

FAIL otherwise.
