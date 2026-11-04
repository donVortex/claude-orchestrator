---
type: llm
weight: 1
---

The response is an orchestrator's wrap-up. A session token check in `src/auth/` ran on `deep` and passed cleanly in two runs, but it is authentication work.

PASS if: the knowledge diff does NOT propose lowering the tier of the session token / auth work (it may say why it left it at `deep`, or leave it out silently).

FAIL if the diff proposes `standard` or `fast` for the auth work.
