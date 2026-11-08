# AI tells reference

AI_TELLS_LOADED_v1

Loaded during a rewrite. Two lists, and the split is the point: List A items are
machine artifacts, safe to strip unconditionally. List B items are genuine AI
tells that are **also genuinely Alex's**, established against a human-verified
corpus. Stripping a List B item would make his writing less like him. That is
the failure this file exists to prevent.

**Read this before trusting your instinct about which list something belongs
in.** The obvious-looking membership is not always right — see the em-dash
history below.

---

## List A — AI-exclusive. Strip these.

### Verbs
delve, underscore, showcase, leverage, foster, facilitate, harness, elucidate,
streamline, elevate, encompass, unveil, utilize, necessitate, revolutionize

### Adjectives
crucial, pivotal, intricate, comprehensive, multifaceted, seamless, robust,
groundbreaking, transformative, profound, unprecedented, notable

### Adverbs
notably, particularly, meticulously, significantly, ultimately, strategically

### Nouns
landscape, tapestry, testament, interplay, realm, journey, insights

### Connectives
"Additionally", "Moreover", "Furthermore", "That said", "It's worth noting"

### Syntactic patterns — the actual fingerprint
These survive vocabulary substitution, which makes them the higher-value target.

1. **Copula avoidance** — "X serves as / represents / marks" instead of "X is";
   "boasts / features / maintains / offers" instead of "has".
2. **Trailing participial commentary** carrying no information — "..., highlighting
   the importance of X", "..., fostering collaboration".
3. **Negative parallelism** — "not just X but Y", "it's not X, it's Y".
   (Note: "X rather than Y" is List B — see below. Do not strip it.)
4. **Rule-of-three overuse** — tricolons at a rate no human sustains.
5. **Uniform sentence length.** Humans mix short and long sentences; models
   regress to a narrow 15–25 word band. Match the register's measured
   burstiness range instead of flattening toward the mean. Measured ranges
   in Alex's verified writing (`stdev/mean` of sentence length):
   - `terse-peer`: burstiness 0.713, 5th–95th pct 0.639–0.778; sentence length
     p5 2 words, p95 25 words, median 9.
   - `explanatory-peer`: burstiness 0.81, 5th–95th pct 0.65–0.896; sentence
     length p5 1 word, p95 38 words, median 12.5.
6. **"Despite its [strengths]... Looking ahead..." coda.**

### Formatting
Mid-sentence bold for emphasis, emoji as bullet characters, headers on
three-sentence sections, tables where prose would serve,
"let me know if you'd like me to..." sign-offs.

**Performative-deference closers.** Same family as the sign-off above, and just
as common: "Happy to do it the other way if you'd rather...", "Happy to X if
you prefer Y", "More than happy to...", "I can also do X if that works better".
A recommendation should end on the recommendation. Offering the opposite option
back in the same breath reads as hedging and is a strong tell. If the decision
genuinely belongs to the reader, state the recommendation and stop; they already
know they can disagree.

**Em dash `—`.** Strip it. 1.66 per thousand words in Alex's verified writing
vs. **19.10 per thousand words in Claude's** — an 11.5x gap. It is Claude's
tic, not his. Per message it is near zero in both registers: **0.008** in
`terse-peer` (1 across 124 messages) and **0.095** in `explanatory-peer` (2
across 21). If a rewrite
needs the punctuation an em dash was doing, use a comma, a colon, or a full
stop instead — those are what the corpus actually shows. See "The em-dash
reversal" (after both lists) for why this overturned an earlier, wrong
ruling.

### Length
His verified long-form voice runs **median 56 words, max 173** per message.
Claude's drafts in the same corpus ran **median 219, max 389**. A 300-word
chat message is itself a signal independent of any word or phrase it contains
— length is a tell for this user specifically, and it is actionable: a rewrite
that leaves a message in the 200+ word range for a `terse-peer` or
`explanatory-peer` context has not finished the job even if no other List A
item survives.

### `Hi <name> —` opener, `Direct answers:`, `Two smaller things:`
Measured at 0/kw in Alex's verified writing vs. 1.15/kw, 0.16/kw, 0.16/kw
respectively in Claude's drafts. These read as plain-speech and were
originally (wrongly) attributed to Alex, the same authorship-review mistake
that briefly put the em dash in the wrong list (see "Em dash — the reversal"
after both lists). Strip them.

---

## List B — contested, but genuinely Alex's. Never strip.

Asserted **by rate, within the observed human range for the register**, not by
absence. A rewrite emitting an unusually high count of `rather than` where the
corpus shows a rate of 0.82–0.83/kw would be a regression that absence-testing
would miss entirely — but the same logic means a List B item disappearing from
a long rewrite is not automatically wrong either; check the rate, not a raw
count.

| Item | Per-register rate (human-verified) | Provenance |
|---|---|---|
| `"rather than"` | 0.83/kw (MINE) vs 0.82/kw (CLAUDE) — indistinguishable, genuinely shared | Contrastive use, mostly in `explanatory-peer` (measured 2026-08) |

**Only one item qualifies.** See "Promotion rule" below for why nothing else
made the list, and what it would take to add something.

### Promotion rule

**Any future List A → List B move requires measurement in a human-verified
`MINE` set, never mere presence in raw sampled/sent history.** A trait's
presence in Alex's sent messages proves nothing about authorship, because an
unknown fraction of his sent messages since ~2025-08 is Claude-drafted text he
sent manually. That contamination is exactly what produced the original
(wrong) em-dash and `rather than` attribution in the first place — both quotes
traced back to a single 389-word message Alex identified as Claude's.

To promote an item, produce a MINE-vs-CLAUDE rate comparison like the table in
this file (rate per thousand words, or per message, computed against messages
a human has confirmed they wrote) and show the rates are indistinguishable, the
way `rather than` is. A term merely appearing in a raw message sample — which
mixes verified and unverified text, and was up to 63% Claude-authored in
long-form — is not evidence and must not be used as evidence.

If you believe another item deserves List B, do not add it on your own
judgment. Flag it and state what MINE-set measurement would be needed to
settle it; someone with authority over the corpus decides after seeing the
numbers.

---

## Em dash — the reversal

An earlier draft of this profile put the em dash in **List B**, on the
strength of a single message that used one. That message was later
identified by Alex as Claude-drafted.
Measured against the human-verified `MINE` set instead:

- Em dash `—`: **1.66 per thousand words in Alex's verified writing** vs.
  **19.10 per thousand words in Claude's** — an 11.5x gap. It is Claude's tic,
  not his. **Em dash is List A** (see the Formatting entry above) — never
  List B.
- Per message it is near zero in both registers (0.008 and 0.095),
  consistent with the low MINE rate and nowhere near Claude's.

The same contaminated message also produced the original (wrong)
attribution of `rather than` and the plain-speech markers to Alex — all
traced back to a single 389-word message he identified as Claude's. `rather
than` survived re-measurement against the clean `MINE` set (0.83/kw vs
0.82/kw); the em dash and the plain-speech markers did not.

This is why the promotion rule above exists: presence in one message, even a
sent one, is not evidence. Only a MINE-vs-CLAUDE rate comparison is.

---
