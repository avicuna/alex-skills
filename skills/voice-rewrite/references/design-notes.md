# Design notes

Maintainer rationale for decisions in SKILL.md, moved out of it. SKILL.md is read by the model on every
invocation; rationale that doesn't change what the model should DO dilutes
the imperatives around it. This file is for a human (or a future editor)
deciding whether to change something, not for the model deciding what to
do right now. Keep SKILL.md imperative; put the "why" here.

## Why Axis 2 fires only on a structured signal

The original design let the model infer Axis 2 from tone, phrasing, or
context. That failed for a simple reason: there is an endless supply of
near-miss phrasings a prose rule can never fully enumerate ("respond as
me," "make it sound like Alex," "make this sound like me," and every
paraphrase not yet tried). A prose-only gate will eventually be talked
past by one of them, not because the model is careless, but because the
rule itself has no hard edge. The fix is a structured signal the model
checks mechanically before reasoning about meaning at all: either the
argument string begins with `axis=alex` on its own first line, or the
literal `/as-alex` token is in leading position. Both are boolean checks
on the raw string, not judgment calls.

## Why the `/as-alex` fallback is restricted to leading position

The original fallback fired if `/as-alex` appeared **anywhere** in the
input. That flips the axis on text that merely mentions the command as
subject matter rather than invoking it -- documentation, a review comment,
a pasted chat message quoting it. The user writes about his own tooling
constantly, so "anywhere" is a live, frequent false-positive path, not a
theoretical one. Restricting to the first line / first token keeps the
common real usage (typing the command directly, or "Please /as-alex
rewrite this:") working while closing the documentation false-positive.

## Why "sound like me" is handled explicitly rather than by inference

The skill's own frontmatter `description` lists "make text sound like me"
as a trigger phrase -- and the body forbids inferring Axis 2 from exactly
that kind of phrasing. That's not a bug in either half; it's two different
jobs. The description's job is to get the skill triggered at all when
someone asks in those words. The body's job, once triggered, is to decide
which axis runs, and inference from phrasing is what the structured-signal
rule exists to replace. The resolution is to serve the request without
inferring: run Axis 1 (the always-safe default), and tell the user
afterward that `/as-alex` exists if they wanted Alex's voice specifically.
This keeps the frontmatter's promise to the user without smuggling
inference back in through the body.

## Why burstiness is guidance, not a number

Two earlier attempts at gating rewrite quality on measured "burstiness"
(sentence-length variance) both failed in opposite directions.

1. **Absolute band** (bootstrapped p5-p95 range per register): failed a
   correct rewrite outright on 2026-08-21 -- the range was bootstrapped
   over whole messages, and a single short real message mixes prose with
   non-prose lines (bare links, ticket lines, code) that inflate variance
   in a way pure prose never does. A correct terse rewrite landed outside
   the band.
2. **Directional** (output burstiness > input burstiness, `gate: false`
   demoting it to reported-not-gated): still had two problems even as an
   informational metric. It was trivially easy to pass on the fixture
   input (deliberately near-uniform, so almost any real rewrite "won"),
   and it could false-FAIL a genuinely correct terse rewrite that
   collapsed the input to fewer than two sentences, since the burstiness
   formula (stdev/mean) returns 0.0 by construction below two data points,
   and 0.0 is never greater than a positive input value.

Both attempts were removed rather than trying a third numeric design. SKILL.md's replacement instruction -- "vary sentence
length, do not regress to uniform, never add or keep a sentence to improve
rhythm" -- is qualitative on purpose. The instruction not to pad for
rhythm exists because a metric that can be gamed by adding a sentence
purely to move a number is worse than no metric.

## Why the self-critique pass checks two sources, not one (step 4)

A critique that validates only against `references/ai-tells.md` will
strip an em dash to satisfy List A -- correct, since the em dash is an AI
tell, not one of Alex's. But that same single-source check has no way to
tell List A tells apart from Alex's own List B habits (things that *look*
AI-shaped but are genuinely his, like "rather than"), and will strip those
too on the mistaken belief they need fixing. The register exemplars are
what keep the critique honest in that direction -- they're the only source
that shows what Alex actually writes, as opposed to what AI-generated text
typically avoids.

## Why the specificity rule only allows flagging, never supplying (step 5)

"Prefer a counted number over a vague claim" sounds like reasonable
guidance, but it is active pressure toward fabrication: a model under that
pressure will guess a plausible-sounding number, and a guessed number
reads clean enough to survive review undetected. The rule is deliberately
asymmetric -- flag freely, never invent -- because the failure mode of
under-flagging (a `[NEEDS NUMBER]` that should have been removed) is
visible and correctable, while the failure mode of a fabricated number is
silent and only surfaces if someone happens to check the original input.

## Why `[NEEDS NUMBER]` is the canonical marker and 🛑 is not

`hooks/block-unresolved-flags.sh` greps for the literal bracketed text
`[NEEDS NUMBER]` -- that string, not the 🛑 emoji, is what the send-guard's
coverage depends on. 🛑 is a visual aid layered on top for a human
skimming a long reply; it was never meant to carry the guard's logic. Two
representations of one contract are free to drift apart if either one is
treated as optional -- an editor who "simplifies" by dropping the bracket
text in favor of the emoji (or vice versa) would silently break the hook
without breaking anything the model itself checks. Keep both, and keep the
bracket text as the one the hook (and any future guard) matches on.
