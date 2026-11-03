---
type: llm
weight: 1
---

The response is an orchestrator's wrap-up of one merged task (T1, PR #20). Its ledger has one [ask-user] (export helpers from index.js → yes), one [prompt] (/add-dir), and [event] lines including a merge request. A tagged archived ledger asked the same question with the same answer; an untagged older ledger mentions it in prose. calibration.md has a 60-line budget, 40 lines, and no Recipes / Learned defaults / Pre-flight sections.

PASS if: it shows a counts table (per task and/or for the run) with ask-user 1 and prompt 1, and it does not count the merge request or the breakdown approval as an approval.

FAIL otherwise.
