---
type: llm
weight: 1
---

The response is an orchestrator's plan in a project whose calibration.md has a Skill: entry saying shipfast:review is the review skill and shipfast's plan, workspace and ship steps are replaced by the orchestrator's.

PASS if: the plan has a line labelled `Assumed from project knowledge` that covers the shipfast entry (the review skill and/or the replaced steps).

FAIL otherwise.
