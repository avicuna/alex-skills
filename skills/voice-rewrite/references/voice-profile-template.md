# Voice profile template

Axis 2 reads a voice profile from `~/.claude/voice-profile.md` (Codex: `~/.codex/voice-profile.md`). The profile holds real messages, so it never goes in this repo. Copy this template there and fill it in.

## Where the samples come from

Use writing you are sure you wrote yourself, without an AI drafting it. Personal chats, email, and old posts all work. Anything sent after you started drafting with AI is suspect: check each long message by hand and keep only the ones you wrote. In the original profile, 63% of the long-form sent messages turned out to be AI drafts, and two "habits" came from a single AI-written message.

Work messages are fine as long as you scrub them before they leave your work computer. Swap every person, repo, service, ticket, customer, channel and URL for a placeholder like `<name>` or `<repo>` but leave the wording and punctuation alone. Your style comes from how you build sentences and not from the nouns.

Aim for about 60 short messages and 20 or more long ones. Fewer is fine. Say how many you have, so the skill knows how much to trust them.

## Measuring

Count by hand or with a short script over the samples:

- Sentence length: median, p5 and p95, and burstiness (standard deviation divided by mean).
- Per 100 words: contractions and commas.
- Per message: em dashes, en dashes, and emoji.
- The most common two-word openers and closers.

Rates beat raw counts. A list of words you "use" means nothing without a rate compared to AI text.

## Template

```markdown
# Voice profile — <your name>

Built <YYYY-MM-DD> from <source>, <N> short and <N> long messages, all checked by hand as written by me.

## Register: terse-peer

Short replies to peers: acknowledgements, confirmations, quick answers, corrections.

**Rhythm** (n=<messages>, <sentences> sentences)
- median sentence length: <n> words
- sentence length p5-p95: <a>-<b> words
- burstiness (stdev/mean): <x>

**Mechanics**
- contractions: <x> per 100 words
- commas: <x> per sentence
- em dashes: <x> per message
- emoji: <which ones, and how often>

**Openers**
- <most common openers, with counts>

**Closers**
- <how messages usually end, or "no sign-off">

**Move set**
- <habits: e.g. answers first and explains after, asks one direct question, apologizes briefly>

**Quantification rule**
- <e.g. always gives the real number; never "a few">

**VERBATIM EXEMPLARS — do not paraphrase**
> <message>
> <message>

## Register: explanatory-peer

Longer messages to peers that explain, propose or report something.

<same sections as above; mark the register exemplar-poor if it has fewer than about 20 messages>

VOICE_PROFILE_LOADED_v1
```

Keep the `VOICE_PROFILE_LOADED_v1` line at the very end. It shows the whole file was read, not only the top of it.
