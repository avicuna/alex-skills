---
name: handoff
description: Write a handoff capsule for the current worktree so another agent or tool (Claude Code, Codex, a fresh session) can pick up the work. Use when the user says "handoff", "hand this off", or wants to switch tools or sessions mid-task.
---

# Handoff

Write `.ai-handoff/context.md` in the current worktree. Make sure `.ai-handoff/` stays out of git: add it to `.git/info/exclude` if it isn't ignored already.

**Rewrite the file completely each time. Do not append.** An appended capsule piles up contradictory, stale decisions and soon costs more to read than it saves.

Use exactly these sections, in this order. Leave a section's body empty rather than deleting its heading or inventing content for it.

```markdown
# Goal
# Current state
# Decisions and constraints
# Approaches tried and rejected
# Repos touched
# Files changed
# Verification performed
# Runtime / local state
# Risks and open questions
# Suggested next action
```

Section rules:

- **Approaches tried and rejected:** give the reason each one failed. Without this the next agent retries the dead end you already ruled out. This is the most valuable section in the file.
- **Repos touched:** one repo path per line. A session opened at a workspace root often edits several repos. List every one you edited, even slightly, so the next agent checks each for drift. Leave it empty when you worked in a single repo.
- **Files changed:** a summary for orientation, not an inventory. The worktree is the source of truth; the next agent reads the diff.
- **Verification performed:** the exact commands and their actual results. "Tests pass" is useless; `bats tests/ → 151 passing` is not.
- **Runtime / local state:** anything that doesn't travel with the worktree: running dev servers and their ports, applied but uncommitted migrations, env vars set in this terminal, venv or node_modules assumptions, scratch files outside the repo.
- **Suggested next action:** one concrete action. "Suggested," not "exact": the next agent must check the current state first and may reasonably disagree.

Never put credentials, tokens, private keys, or connection strings in the capsule.

Don't write a version marker, sequence number, or timestamp into it. A counter kept in prose drifts.

When the file is written, tell the user how to resume: open the other tool in this worktree and ask it to read `.ai-handoff/context.md`, check the current state against it, and continue from the suggested next action.
