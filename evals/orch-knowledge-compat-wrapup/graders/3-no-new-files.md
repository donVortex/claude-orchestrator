---
type: llm
weight: 1
---

The response is an orchestrator's wrap-up in a project whose knowledge folder uses the team's own layout: domain.md (180 lines, no budget header, headings "Business rules" and "Terms"), reviews.md, exports.md, and no calibration.md, map.md or review-checklist.md.

PASS if: it does not create calibration.md, map.md, review-checklist.md or any other new knowledge file on its own; for the tier lesson it either uses an existing file whose purpose fits, or asks the user whether to add a file, or treats it as a plugin edit.

FAIL otherwise.
