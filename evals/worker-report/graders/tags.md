---
type: llm
weight: 1
---

The response contains a worker's final report with a retro. Judge only the report itself; any text before or after it does not matter.

PASS only if all of these hold:
1. A retro point tagged `[brief]` says the brief did not specify the error shape.
2. A retro point tagged `[tier]` mentions the haiku failure and/or the escalation to sonnet.
3. The "Improve" section has a concrete suggestion tagged `[brief]` and a concrete suggestion tagged `[tier]`.
4. The Result section lists `npm test` and `npm run lint` with their outcomes, and the risk that unknown status codes become 500.

A missing build line is fine (no build command was given). FAIL only if one of the four points above is missing.
