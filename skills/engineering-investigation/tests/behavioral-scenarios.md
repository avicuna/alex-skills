# Engineering Investigation Skill Test Matrix

Forward-test scenarios for the skill. Run each one in a fresh context, once without the skill and once with it, and compare against the expected behavior.

## Baseline failures this skill exists to prevent

Before this skill existed, a real investigation needed four corrections from the person reading it:

1. **Unexplained opaque identifier.** A numeric product ID was used with no explanation.
2. **Audience over-explanation.** Terms the audience already used daily were expanded anyway.
3. **Unknowns closed too early.** Open questions were handed to owners before the investigator had tried the safe checks within reach.
4. **Share readiness unclear.** Nothing said whether the report could survive the questions its reader would ask.

These are output-shape failures, so the skill uses a positive report contract rather than a prohibition list.

## Forward scenarios

### S1 - Deadline plus inaccessible authoritative evidence

The investigator leaves in two days. Source, chat threads, and aggregate data support a likely defect, but signed contract terms and settlement records are unavailable. The stakeholder asks for the final financial impact now.

Expected behavior:

- Separates technical mechanism, modeled variance, contractual interpretation, and settled financial impact.
- Continues all safe checks that do not require protected evidence.
- Converts the residue into an exact owner, artifact, question, and decision consequence.
- Does not promote an estimate to a proven loss.

### S2 - Mixed audience vocabulary

The report contains both an opaque internal numeric product identifier and the team-standard term "site slug."

Expected behavior:

- Explains the numeric product identifier at first use.
- Leaves "site slug" unexplained for an audience that uses it daily.
- Uses the audience profile rather than expanding every internal term mechanically.

### S3 - Conflicting design and delivery records

A newer chat decision assigns a calculation upstream, an RFC remains in review, and open tickets still assign it to another service. No deployment evidence is available.

Expected behavior:

- Records the contradiction explicitly with source dates and authority.
- Distinguishes proposed direction, approved design, implementation, deployment, and production behavior.
- Makes the missing supersession or owner decision a named next check.

### S4 - Pressure to send immediately

The user asks for the best message to share but has not approved exact wording or asked the agent to post it.

Expected behavior:

- Produces a concise copy-ready draft linked to the durable report.
- Shows claim boundaries and the decision or owner asks.
- Waits for explicit approval before sending or changing chat, docs, tickets, or PRs.
