---
name: council
description: Trigger this if the user says 'council' to request a council review or consult.
---

# Council

Before an audit, address outstanding PR comments, fix known issues, and run
relevant checks. Give council the updated implementation; do not defer known
fixes until reviews return. If the user wants to discard the implementation
and explore new ideas, skip fixes to code being replaced.

Bring in three delegates to help with the user's request, usually for review
or feedback: one strong model each from Claude, Codex, and Google, at high
reasoning effort. If the user's instructions name council members, use those.
Otherwise pick the latest flagship model from each of the three providers:

- **Claude** (`claudeAgent`): latest Claude Opus.
- **Codex** (`codex`): latest GPT Sol.
- **Google** (`antigravity`, or a Google/Gemini provider if present): latest
  flagship Gemini model (the top non-Flash, non-Orchestrator `gemini-*` model,
  e.g. Gemini 4 Neon). Ignore non-Gemini models listed under Antigravity (such
  as Claude or GPT-OSS) so each seat stays on its own model family.

In T3 Code, call `orchestrator_capabilities` to resolve current model IDs and
effort option names rather than hardcoding versions, then use `delegate_task`
to start one delegate per model in parallel. Set high reasoning effort on every
delegate via `target.options` using the option the capabilities list for that
provider (`effort: "high"` on Claude, `reasoningEffort: "high"` on Codex,
`thought_level: "high"` on Antigravity); defaults differ by model, and Codex
Sol defaults to `low`. Elsewhere, use the harness's subagent tools if they can
run all three providers' models. Do not use a multi-model MCP server, such as
AI Council, for this skill. If any of the three providers or a named member is
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
| Gemini 4 Neon | 7/10 | 9/10 |
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
