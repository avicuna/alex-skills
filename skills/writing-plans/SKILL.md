---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code - creates implementation plans with task-level granularity
---

# Writing Plans

Write implementation plans that give an engineer everything they need to execute — which files to touch, what to build, how to test it, in what order. Assume the engineer is skilled but has no context on this codebase. The plan file is the handoff: a subagent or a Codex job should be able to pick up one task from it and finish without asking.

**Announce at start:** "Using the writing-plans skill to create the implementation plan."

**Save plans to:** `notes/<feature>-plan-YYYY-MM-DD.md` in the repo, kept out of git by a `/notes/` line in `.git/info/exclude`. User or repo preferences for plan location override this default.

## Don't Re-Plan What's Settled

When an approved spec exists, it is the decision. Don't re-explore code the design phase already mapped, don't re-debate its choices, and don't spawn research for topics it covers. Go straight to the task breakdown.

## Scope Check

If the spec covers multiple independent subsystems that weren't broken into sub-project specs during brainstorming, suggest breaking into separate plans. Each plan should produce working, testable software on its own.

## Subtract First

Before adding tasks, look for what can be reused or deleted. Mirror the existing code path; a task that deviates from it says why. A plan that adds new state, flags, config, subsystems or migrations for a simple change is a red flag: cut it back before handing it off.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This locks in decomposition decisions and informs the task breakdown.

- Clear boundaries, well-defined interfaces, one responsibility per file
- Files that change together should live together
- Follow established patterns in existing codebases

## Task Granularity

**Each task is a logical unit of work (15-30 minutes), not individual keystrokes.**

A task like "Implement the caching layer with tests" is the right size. Don't break it into separate steps for "write failing test", "run it", "write code", "run it again", "commit" — the engineer knows TDD.

Include enough detail that the engineer knows *what* to build and *how to verify it*, but trust them to write the code.

## Plan Document Header

Every plan starts with:

```markdown
# [Feature Name] Implementation Plan

> Execute one task at a time. Each task is a self-contained handoff for a subagent or a Codex job. Record any deviation back into this file before starting the next task.

**Goal:** [One sentence]

**Done when:** [The spec's checks, copied over. The last task's test command proves them.]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

````markdown
### Task N: [What This Accomplishes]

**Goal:** One sentence.

**Context and decisions:** What the engineer needs to know that isn't in the code, including any decision made in chat since the spec was written.

**Files:**
- Create: `exact/path/to/file.ext`
- Modify: `exact/path/to/existing.ext` (specific section/function)
- Test: `tests/exact/path/to/test.ext`

**What to build:**
Clear description of what this task produces. Include key interfaces, data structures, or logic that the engineer needs to get right. Show code for non-obvious parts — signatures, tricky algorithms, important type definitions.

**Key code** (only for non-obvious parts):
```python
# Show interfaces, signatures, or tricky logic — not every line
class CacheLayer:
    def get(self, key: str) -> Optional[CacheEntry]: ...
    def invalidate(self, pattern: str) -> int: ...
```

**Acceptance criteria:**
- Observable outcomes that prove the task is done.

**Out of scope:**
- Nearby work the engineer should not touch, even if it looks broken.

**Test command:**
```bash
pytest tests/path/test_cache.py -v
```
Expected: all tests pass, cache hit/miss behavior verified.

**Commit:** `feat: add caching layer with TTL support`
````

## What to Include vs. Skip

**Include:**
- Exact file paths always
- Key interfaces, type definitions, and signatures
- Code for non-obvious logic, tricky algorithms, or important patterns
- Exact test commands with what "pass" looks like
- Dependencies between tasks (what must come first)

**Skip:**
- Boilerplate the engineer can write from the description
- Step-by-step "now run the test, now write one line, now run again"
- Repeating code that's identical to a previous task — reference it
- Obvious implementations that follow directly from the interface

## Principles

- **DRY** — in the plan itself. Don't repeat code across tasks.
- **YAGNI** — only plan what the spec requires
- **TDD** — each task should include what to test, but don't script every keystroke
- **Frequent commits** — one commit per task

## Execution Handoff

After saving the plan:

> "Plan saved to `notes/<filename>.md`. Three options:
>
> 1. **Subagent-driven (recommended)** — a fresh subagent per task, with a review between tasks
> 2. **Codex jobs** — one background job per task, each in its own git worktree
> 3. **Inline** — execute tasks in this session with checkpoints
>
> Which approach?"

Whoever executes a task ends by reporting the files changed, the commands run and their results, any deviation from the plan and why, and open questions. Review the diff and rerun the task's test command before calling the task done. Judge the diff's size and new surface before its test results: if a simple task ballooned, cut it back.
