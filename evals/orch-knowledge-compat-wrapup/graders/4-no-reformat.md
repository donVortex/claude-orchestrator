---
type: llm
weight: 1
---

The response is an orchestrator's wrap-up in a project whose knowledge folder uses the team's own layout: domain.md (180 lines, no budget header, headings "Business rules" and "Terms"), reviews.md, exports.md, and no calibration.md, map.md or review-checklist.md.

PASS if: it does not itself propose renaming headings or files, adding budget headers, or restructuring the existing folder. Asking the user whether to add a new file for content that fits nowhere is fine, as long as nothing is created or changed without their answer.

FAIL otherwise.
