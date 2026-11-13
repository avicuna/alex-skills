---
name: handoff
description: Hand the current task to a fresh agent. By default, writes a handoff capsule and starts a new T3 Code thread with it; outside T3 Code, or when the user asks for a file, writes the capsule to `.ai-handoff/context.md` so another tool (Claude Code, Codex, a fresh session) can pick it up. Use when the user says "handoff", "hand this off", or wants to switch threads, tools or sessions mid-task.
---

# Handoff

Every handoff starts with the same capsule. Where it goes depends on the mode.

## Pick the mode

- **T3 thread (default).** Use this whenever T3 Code's `t3_thread_launch` tool exists. It's
  usually deferred, so load it with ToolSearch (`select:mcp__t3-code__t3_thread_launch`) before
  you decide it's missing.
- **Capsule file.** Use this when the user asks for a file or names another tool, or when
  `t3_thread_launch` isn't available.

## The capsule

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

Use absolute paths for every file the next agent needs, and full URLs for PRs, CI runs and threads.

## T3 thread mode

The capsule travels as the new thread's first message, so write no `.ai-handoff/` file. At a
workspace root that isn't one repo, many threads share one `.ai-handoff/context.md`, and writing
it overwrites another task's capsule.

Call `t3_thread_launch` with:

- `title`: the task in a few words, such as "Billing: retry failed webhooks".
- `message`: one opening line, then the capsule. The opening line says this is a handoff from
  another thread. It tells the next agent to check the current state against the capsule before
  it acts, then continue from the suggested next action, and to ask the user before anything
  outward-facing.
- `clientRequestId`: a stable slug for the task, so a retry doesn't start a second thread.
- Workspace:
  - When you're in a project worktree, pass `workspaceStrategy: {type: "existing_worktree",
    worktreePath: <path>}`.
  - Otherwise, omit it, so the thread opens at the project root.
  - Never create a new worktree for a handoff.
- Model and modes: omit `projectId`, `modelSelection` and the mode fields, so the thread inherits
  yours. Pass `modelSelection` only when the user names a model or provider ("handoff to Codex").

Then reply with the returned `link` verbatim and one line on what the new thread does first.
Don't wait on it or read it back. Stop working on the handed-off task in this thread.

## Capsule file mode

Write the capsule to `.ai-handoff/context.md` in the current worktree. Make sure `.ai-handoff/` stays out of git: add it to `.git/info/exclude` if it isn't ignored already. If a capsule for a different task is already there, tell the user before you overwrite it.

**Rewrite the file completely each time. Do not append.** An appended capsule piles up contradictory, stale decisions and soon costs more to read than it saves.

When the file is written, tell the user how to resume: open the other tool in this worktree and ask it to read `.ai-handoff/context.md`, check the current state against it, and continue from the suggested next action.
