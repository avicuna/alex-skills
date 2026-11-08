# Investigation Loop

Use this when an investigation runs across sessions, keeps coming back inconclusive, or needs a decision about when to stop. Keep going until the decision is supported or every remaining dependency is explicit.

## Run the loop

1. Record the question or decision, the anchor thread or artifact, the population, the time window, the permitted actions, and any resource limits you were given. If a reading guide or checkpoint already exists, resume it.
2. For each unresolved material claim, pick the reachable check most likely to tell competing explanations apart or change the next decision. Record checks you can't run and why.
3. Before running a check, record it as **planned**, with the observation that would discriminate and the filters and window. After running it, record **observed**, **failed**, or **not run**, with a source reference and its freshness.
4. Update the claim ledger with stable IDs and Proven / Derived / Hypothesis / Unknown. State what each claim supports, what it does not prove, and what would disprove it.
5. Keep doing useful, authorized checks without waiting for the user to say "continue." Retry only when a condition changed or the failure looks transient. Try a reachable alternative before declaring yourself blocked. Don't repeat searches that can't change the decision.

## What counts as an observation

- Examples, hypothetical responses, expected outcomes and source suggestions are not observations.
- A result described as "would show," "could return," or "expected" stays hypothetical, however detailed it is. Without an executed result, mark the lookup **not run**. Never write "the lookup returned."
- A failed request is not an empty result. An empty result from a filtered query is not proof of absence everywhere.
- Keep "upstream accepted it" apart from "it completed" and from "it caused this."

## Stop and hand off

Stop when one of these is true:

- The decision is adequately supported.
- A limit you were given is reached.
- Every remaining check needs evidence or authority you don't have, and nothing reachable would change the decision.

Writing a summary does not resolve uncertainty. Return the outcome, the verified findings, the unresolved dependencies, and the next action. Each dependency names the **missing evidence, the owner (or "owner unknown"), the exact question or check, and what decision it blocks**. Give short progress updates during long runs, and hold the consolidated answer until a stop condition is met.

## Checkpoint

Save to the reading guide or a checkpoint file next to it: the artifact revision, observed evidence, failed and not-run checks, how each question was resolved, the stop reason, and the next action.

On resume, refresh any external state that changes, rerun checks that a revision change invalidated, and reconcile any external action whose outcome is uncertain before retrying it. Don't copy sensitive payloads into the checkpoint.
