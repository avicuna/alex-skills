---
name: engineering-investigation
description: Use when an engineering investigation needs a cross-source, evidence-backed report, decision brief, incident review, or stakeholder handoff; especially when impact, causality, contradictory records, unresolved claims, and owner decisions must be defensible. Not for routine debugging, simple alert triage, or public-web literature reviews.
---

# Engineering Investigation

Produce a stand-alone decision brief with an auditable evidence appendix.

## Core principle

Treat every material statement as a bounded claim. Keep these questions separate: **Does the condition exist? Did it cause this incident? What population did it affect? What financial, contractual, or customer consequence followed?** Evidence for one does not prove the others.

## Choose the mode

Read [references/investigation-modes.md](references/investigation-modes.md). Default to deep investigation; use formal incident mode for a postmortem or incident review, and refresh mode for an existing report.

When the investigation spans sessions, keeps coming back inconclusive, or needs a stopping decision, also read [references/investigation-loop.md](references/investigation-loop.md).

## Investigation contract

1. State the exact question, audience, decision, scope, time window, and requested deadline.
2. Build a source map. Search the anchor thread and linked artifacts, then the systems that can prove or disprove each claim. Record unavailable or partial sources.
3. Read [references/evidence-standard.md](references/evidence-standard.md). Assign stable finding IDs (`F1`, `F2`, ...) and label each finding **Proven**, **Derived**, **Hypothesis**, or **Unknown**.
4. Reconcile conflicts by authority, time, environment, population, and data grain. Preserve unresolved contradictions.
5. Exhaust safe, in-scope checks. An Unknown must name the missing artifact or observation, owner, exact question, and decision consequence.
6. Draft from [assets/investigation-report-template.md](assets/investigation-report-template.md). Put decisions and plain language first; keep query details in the appendix.
7. Answer likely stakeholder questions from the ledger; route unsupported answers to the correct owner.
8. Run `python3 scripts/validate_report.py --strict <report.md>` before calling it share-ready. Fix errors; resolve or explain every warning.

## Completion gates

A report is ready to propose for sharing when:

- Every material claim has evidence, support boundary, non-proof boundary, and disproof check.
- Quantities identify unit, population, window, timezone where relevant, filters, and source freshness.
- Proposed design, approval, implementation, deployment, and production behavior are not conflated.
- Modeled variance is not called loss, payment, liability, or customer impact without matching evidence.
- Remaining Unknowns are owner-bound evidence requests.
- The handoff links to the report and states the requested decision or action.

Drafting is not authorization for external action. Show exact text, wait for explicit approval, and verify afterward.

## Common mistakes

| Mistake | Correction |
|---|---|
| A plausible mechanism becomes “root cause” | Prove the chain and temporal/population match, or qualify it. |
| A dashboard number becomes incident impact | Preserve query, grain, window, refresh time, and exclusions. |
| An open ticket becomes delivery evidence | Require merge, deployment, configuration, and production readback appropriate to the claim. |
| Every acronym is expanded | Explain opaque identifiers, not shared team vocabulary. |
| “Needs owner input” ends research | Exhaust safe checks, then name the owner, artifact, question, and consequence. |
