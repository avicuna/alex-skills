# Evidence Standard

Use this standard for every material finding. The goal is not maximum certainty; it is a precise account of what the available evidence can and cannot establish.

## Claim labels

| Label | Meaning | Required treatment |
|---|---|---|
| **Proven** | Direct evidence establishes the scoped statement. | Name the source, window/environment, and population. Do not generalize beyond them. |
| **Derived** | Evidence plus a reproducible calculation or inference establishes the statement. | Show inputs, method, assumptions, and sensitivity. Qualify confidence when useful. |
| **Hypothesis** | A plausible explanation is not yet distinguished from alternatives. | Name competing explanations and the cheapest discriminating check. |
| **Unknown** | Available evidence cannot answer the question. | Name the missing artifact/observation, owner, exact ask, and decision consequence. |

A finding may use a scoped composite status, such as “source mechanics Proven; production causality Derived.” Each clause must have its own boundary.

## Required finding shape

Every `F#` finding contains:

- **Status:** one or more labels above.
- **Evidence:** dated or versioned artifacts, observations, and reproducible query/calculation references.
- **Supports:** the narrow conclusion those artifacts establish.
- **Does not prove:** nearby claims a reader could otherwise over-infer.
- **Could be disproved by:** a concrete counter-observation or check.

Prefer one claim per finding. Split a finding when its clauses have different evidence or confidence.

## Source quality is claim-specific

Evaluate evidence on five axes:

1. **Authority:** Is this the controlling source for the claim, such as a signed term for contractual treatment or a deployment record for release state?
2. **Directness:** Does it observe the claimed behavior, or merely discuss it?
3. **Time:** Does its timestamp cover the incident and current state?
4. **Coverage:** Is it one example, a sample, or the full scoped population?
5. **Reproducibility:** Can another engineer repeat the query, calculation, or source lookup?

A chat message can prove that a decision was communicated, not that code shipped. Source can prove mechanics, not the production version. CI can prove a test passed, not that production behaved the same way. A dashboard can prove the result of its documented query, not an unseen causal mechanism.

## Scope and impact

For every quantitative claim preserve:

- Numerator, denominator, and unit.
- Population definition and exclusions.
- Start/end timestamps and timezone.
- Query filters, aggregation grain, and refresh time.
- Currency and whether the figure is gross, net, modeled, booked, invoiced, settled, or recovered.
- Whether the value is measured, estimated, extrapolated, or scenario-modeled.

Keep separate ledgers for technical blast radius, observed transaction variance, customer impact, partner obligation, accounting impact, and settled cash movement.

## Contradictions

When sources conflict, record a row with: claim, source A and date, source B and date, authority for this claim, current interpretation, and decisive next evidence. Do not silently select the newest source: a newer discussion may still be less authoritative than an approved or deployed record.

## Causality ladder

Use the strongest rung actually supported:

1. The defect or data condition exists.
2. It can produce the observed symptom.
3. Its activation matches the incident boundary in time and population.
4. Alternatives were tested or bounded.
5. Correcting it removes the symptom on the relevant deployed path.

Call something a production root cause only when the evidence reaches the rung required by the audience and incident process. Otherwise state the exact proven mechanics and label the causal attribution Derived or Hypothesis.

## Source records

The source index should make artifacts retrievable and state access limitations. For queries, retain a sanitized query or durable query link, execution time, environment, window, filters, grain, result count, and known omissions. For source code, record repository, commit/ref, file, and relevant line or symbol. For conversations, link the exact message/thread and capture its date and author.

Do not expose secrets, PII, booking/payment details, or sensitive raw logs. Use scrubbed aggregates or protected links and state the limitation.
