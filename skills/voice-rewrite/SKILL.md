---
name: voice-rewrite
description: Rewrite Claude-generated text so it does not read as AI-generated, and optionally so it reads like Alex wrote it. Use when asked to make text sound less like AI, less robotic, or more human; to "de-slop", "de-AI", or "humanize" a draft; to make text "sound like me"; or to rewrite a message, chat post, PR description, or ticket in Alex's voice via `/as-alex`. Also use before sending any drafted message a person will read.
---

# voice-rewrite

Two independent axes. Know which one you are running before you start.

- **Axis 1 — de-AI-ify.** Strip List A tells, match the register's rhythm, cut
  padding, flag vague claims. **This is the default for all text, including
  Claude's own replies to the user.**
- **Axis 2 — sound like Alex.** Openers, closers, emoji, move set. **Fires only
  on a structured signal, never on inference:**
  - the argument string **begins with `axis=alex` on its own first line**
    (this is the authoritative signal — `commands/as-alex.md` always sends
    it), or
  - the literal token `/as-alex` appears **on the first line** of the
    input, or is itself the **first whitespace-delimited token** of the
    input (covers typing it directly, or pasting "Please /as-alex rewrite
    this:" followed by the text). This does **not** fire when `/as-alex`
    appears only **on a later line** — a message whose first line asks for
    a rewrite and whose body, further down, quotes or documents the
    command, does not get Axis 2. Rationale: `references/design-notes.md`.

  **If neither signal is present, run Axis 1 — full stop.** Do not infer Axis
  2 from tone, phrasing ("respond as me", "make it sound like Alex", "make
  this sound like me"), who the text is addressed to, or how Alex-flavoured
  the input already reads. Inference is forbidden, not merely discouraged.
  Rationale: `references/design-notes.md`.

  **"Sound like me" requests:** run Axis 1 as normal (never infer Axis 2
  from this phrase), and add one line after the rewrite/changelog/flags
  telling the user that `/as-alex` exists if they wanted Alex's voice
  specifically. Rationale: `references/design-notes.md`.

Text written *to* Alex gets Axis 1 only. A reply dressed up with "Hey guys" and
`:please:` is uncanny and unhelpful — that voice belongs to messages Alex sends,
not to messages sent to him.

Axis 1 borrows the `terse-peer` register only as a model of plain, direct prose —
its rhythm and its willingness to answer in five words. It does **not** borrow that
register's openers, closers, or emoji. Those belong to Axis 2 only.

## Procedure

### 1. Determine register and axis

Check the raw argument string first, before reading it for meaning: does it
begin with `axis=alex` on its own first line, or does the literal
`/as-alex` appear on the input's first line, or as its first
whitespace-delimited token? That check alone decides the axis — see the
structured-signal rule above. A `/as-alex` appearing only on a later line,
as quoted subject matter rather than as part of the leading request, does
not count. Do not additionally reason about whether the text "sounds like"
it should get Axis 2; that reasoning is exactly what the structured signal
exists to replace.

Registers: `terse-peer`, `explanatory-peer`. Infer from the audience and
formality of the target, not the destination platform — Alex writes both
casually and deferentially in the same chat app. Ask only if genuinely
ambiguous.

If the profile marks a register as exemplar-poor, lean harder on its
constraints (rhythm, mechanics) than on pattern-matching a thin exemplar set.

**Mixed-register input** (a formal paragraph, then a peer note, then a code
block): chunk on blank lines and handle each chunk under its own register.

**Very short input** ("Thanks!", "Yes that will work"): leave it substantially
alone. Neither axis may pad a one-liner with a greeting or a sign-off.

### 2. Read the profile and the tells

Read `references/ai-tells.md`. For Axis 2, also read the voice profile: the
section for the detected register in `~/.claude/voice-profile.md` (Codex:
`~/.codex/voice-profile.md`). The exemplars are the load-bearing input —
pattern-match against them rather than working from the rule lists alone.

The profile lives outside this repo on purpose: it holds real messages. If it
is missing, say so, run Axis 1 only, and point to
`references/voice-profile-template.md` for how to build one.

### 3. One holistic rewrite

Constraints first, then the exemplars — constraints placed after several
hundred lines of exemplars get swallowed.

- Prioritize structural fixes over word swaps. A restructured sentence often
  removes the tell word on its own.
- Vary sentence length; do not regress to uniform. Never add or keep a
  sentence to improve rhythm. Rationale: `references/design-notes.md`.
- **No length target.** Shorter output is a consequence of removing padding,
  never a quota to hit.
- Preserve code blocks, links, and ticket IDs **byte-identical**.
- Never alter a technical claim.
- Preserve non-English phrases verbatim. **Never translate.**

### 4. One self-critique pass

A reasoning step in this same invocation — not a second tool call.

Check the draft against **both** `references/ai-tells.md` **and the register
exemplars** (when a profile is loaded). You may revert your own changes. Both checks are required — a
single-source check can strip a genuine List B habit on the mistaken belief
it looks AI-shaped. Rationale: `references/design-notes.md`.

### 5. Specificity audit

Every qualitative claim either carries a real number from the input, or gets
flagged.

**You may only flag. You may never supply a number that was not in the
input.** "Several configs" becomes `[NEEDS NUMBER]`, never "3 configs".
Rationale: `references/design-notes.md`.

## Hard rules

- Never fabricate a fact or number.
- Never alter technical claims, links, ticket IDs, or code blocks.
- Never translate.
- **Never send anything.** Show the draft and wait for explicit approval.

## Output

1. The rewritten text in a copy-paste block. **Nested-fence convention:** if
   the rewritten text itself contains a triple-backtick fenced block (e.g. a
   code sample quoted inside the deliverable), wrap the whole deliverable in
   a **longer outer fence** — four backticks (` ```` `) at minimum, one more
   than the longest fence used inside. This is what lets a grader (or a
   person) find the outer boundary unambiguously instead of the first
   closing fence it meets, which would be the inner block's.
2. A short changelog — concrete, not vague. "Removed 'leverage', used 'use'"
   rather than "improved wording."
3. Every unresolved `[NEEDS NUMBER]` gap, listed. **Prefix every unresolved
   flag with 🛑** — not just the first. The flag reads `🛑 [NEEDS NUMBER]`.
   **The canonical marker is the bracketed token `[NEEDS NUMBER]` itself**,
   not 🛑 — searches and send guards match on the bracket text.
   Never remove the bracket text while keeping only 🛑, or vice versa.
   Rationale: `references/design-notes.md`.
