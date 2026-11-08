# Investigation Modes

## Mode router

| Observable request | Mode | Deliverable |
|---|---|---|
| “Investigate,” “deep dive,” “what happened,” or “is this report enough?” | Deep investigation | One document with executive brief first and evidence appendix second. |
| Postmortem, incident review, or PIR | Formal incident | Incident narrative plus timeline, impact, cause, detection gaps, corrections, and owned actions. |
| “Update,” “refresh,” “latest discussion,” or an existing report is supplied | Refresh | Change ledger plus revised report; preserve stable finding IDs. |

Use formal incident mode only when the incident process requires it. A deep investigation can establish facts before an incident owner has accepted a root cause.

## Source map

Start with the task's anchor and follow explicit links before broad search. Add sources according to the claim being tested:

| Claim | Strong sources |
|---|---|
| What was requested or decided | Exact chat or email thread, meeting record, approved decision record |
| Intended behavior | Approved design/RFC, contract, schema, source code at a named ref |
| Implemented behavior | Merge commit, configuration, tests, artifact or image digest |
| Deployed state | Deployment record, environment inventory, release readback |
| Runtime behavior | Scrubbed traces/logs, API observation, database state, controlled production check |
| Population and impact | Reproducible query, BI model definition, finance/accounting record |

Use purpose-built authenticated connectors, APIs, and repository tools when available. Respect access and production-safety boundaries; never bypass permissions. Mark each source `complete`, `partial`, `fallback`, or `unavailable` when coverage matters.

## Deep investigation output

Use the report template in this order:

1. Decision summary and one plain-language paragraph.
2. Current status, scope, and relevant system flow.
3. Numbered claim ledger and contradiction ledger.
4. Impact and remediation, separated by evidence type.
5. Open questions converted to owner-bound evidence requests.
6. Ordered next checks and likely stakeholder questions.
7. Copy-ready handoff and source index.

The executive opening should make sense without the appendix. The appendix should let another engineer reproduce or challenge the conclusion.

## Formal incident additions

Add:

- Detection and incident timeline using meaningful state changes, not every message.
- Customer, partner, system, and financial impact as distinct sections.
- Root cause and contributing factors with the causality ladder.
- Immediate mitigation versus permanent correction.
- Why tests and alerts did not prevent or detect the issue sooner.
- Recurrence risk and action table with priority, owner, expected outcome, and tracking link.

If your team has its own postmortem template, follow it and map these sections onto it.

## Refresh mode

Do not rewrite from memory. For each existing `F#`:

1. Re-open the strongest source if it is mutable or time-sensitive.
2. Mark the claim unchanged, strengthened, weakened, superseded, or split.
3. Preserve the ID when the claim meaning is stable; create a new ID for a materially different claim.
4. Add newer contradictory evidence rather than erasing the former state.
5. Update the report's “as of” time and source-coverage notes.

Lead the refreshed handoff with what changed since the previous version.
