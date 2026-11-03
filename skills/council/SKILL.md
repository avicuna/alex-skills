---
name: council
description: Trigger this if the user says 'council' to request a council review or consult. Your own proactive calls to a multi-model tool are not this skill.
---

# Council

Before an audit, address outstanding PR comments, fix known issues, and run
relevant checks. Give council the updated implementation; do not defer known
fixes until reviews return. If the user wants to discard the implementation
and explore new ideas, skip fixes to code being replaced.

Bring in three delegates to help with the user's request, usually for review
or feedback. Use one strong model from each of three different providers, at
high reasoning effort. If the user's instructions name council members, use
those. Otherwise pick the latest flagship model from each provider, for
example Claude Opus, GPT Sol, and Gemini Pro.

In T3 Code, use `orchestrator_capabilities` to resolve the models, then
`delegate_task` to start one delegate per model in parallel. Elsewhere, use
the harness's subagent tools if they can run other providers' models. If they
cannot, and the user asked for council directly, use a multi-model tool that
returns each model's own answer, such as the AI Council MCP's `council_ask`
with `verbose: true`, and put the diff and context in the prompt. These tools
spend the user's paid credits, so never use them when another skill sent you
here as a fallback. If you cannot reach three providers, or a named member is
unavailable, report it instead of substituting.

Give each delegate the request and relevant context. For review or feedback,
keep their work read-only. Collect their responses and summarize the useful
findings, disagreements, and recommended next steps.

For a code review, ask each delegate for a score out of 10, and to label each
finding `blocker` (the intended case is wrong), `should` (a real bug callers
will hit), or `nit` (everything else).
Count each full review pass as one round.
A fresh review after fixes starts a new round.

If the work ends in a pull request, put the results in the PR description.
Put this section before the model and harness line at the end:

```markdown
## Council review

Rounds: 2

| Delegate | Round 1 | Round 2 |
| --- | --- | --- |
| Claude Opus | 7/10 | 9/10 |
| GPT Sol | 8/10 | 10/10 |
| Gemini Pro | 7/10 | 9/10 |
```

If a delegate gives no score, write `no score`. Do not invent one.
If the PR is open, edit the description. Do not post a comment for this.
If there is no PR, put the same results in the final reply only.

If you agree with their recommendations, make the changes and request a fresh
review after. Check each finding and its label yourself, and decline nits in
one line.

A delegate is satisfied when it has no `blocker` or `should` open on the
current diff. Scores are reported, not a gate. Stop when all delegates are
satisfied, or after 3 rounds unless the user asked for more. If findings are
still disputed then, show both sides in 2-3 lines each. The user decides.

Do not let repeated reviews result in scope creep. It is your job to fight to
keep scope limited.
