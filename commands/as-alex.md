---
description: >-
  Invoke voice-rewrite with Axis 2 (Alex's voice) active. Sends the
  structured `axis=alex` marker as the first line of the skill's argument
  string -- SKILL.md's authoritative signal for Axis 2, never inferred from
  prose. If no text follows the command, ask what to rewrite instead of
  rewriting nothing. Rationale: references/design-notes.md in voice-rewrite.
allowed-tools: Skill, Read
---

axis=alex
$ARGUMENTS

If no text follows this command, ask what to rewrite instead of rewriting nothing.
