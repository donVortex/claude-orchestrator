---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, knowledge, rule-change]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are in github.com/acme/shop (standalone install, desktop backend). The user's goal: **"Let guests buy gift cards at checkout; they get the code by email."**

Intake facts (you can't run commands here; these are their results):
- No `.orchestration/ledger.md`; the previous orchestration is archived. `git remote` and `gh auth status` work; test, lint and build are `npm test`, `npm run lint`, `npm run build`. No pre-flight entries, no overlapping workflow skills.
- `.claude/orchestrator/domain.md` on `main` (60 of 150 lines) has, among others:
  - "**Gift cards can only be bought by signed-in customers.** Guest checkout rejects them in `src/checkout/guards.ts`. _(bootstrap, 2026-09-02)_"
  - "**Prices are integer cents**, never floats. _(bootstrap, 2026-09-02)_"
  - "**Refunds go through `refundOrder()` in `src/orders/refund.ts`.** _(T3 / PR #44, 2026-10-01)_"
- Checks against `origin/main`: `git cat-file -e origin/main:src/checkout/guards.ts` succeeds; `git cat-file -e origin/main:src/orders/refund.ts` fails; `git grep -q 'refundOrder' origin/main` finds nothing.
- A scout found: the guest checkout flow is in `src/checkout/` (`guards.ts` rejects gift cards for guests), gift-card codes are issued in `src/giftcards/issue.ts`, emails go out through `src/email/send.ts`.

Do the intake and show the plan for approval.
