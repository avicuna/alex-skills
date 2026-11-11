---
name: brainstorming
description: Use before creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation. Skip for well-defined tasks where the user already has a clear spec.
---

# Brainstorming Ideas Into Designs

Help turn ideas into fully formed designs through collaborative dialogue. Understand context, ask questions, present design, get approval.

**Announce at start:** "Using the brainstorming skill to explore this idea."

## When to Skip

If the user provides a detailed spec, clear requirements, or says "just build it" — skip straight to writing-plans. This skill is for when the *what* or *how* is unclear, not a mandatory gate on all work.

## Scope Check (Do First)

Before deep-diving, assess scope. If the request spans multiple independent subsystems, flag it and help decompose into sub-projects. Each sub-project gets its own spec and plan.

## Process

1. **Explore project context** — check relevant files, docs, recent commits. Look for what can be reused or deleted before proposing anything new.
2. **Ask clarifying questions** — start with the outcome, not the task list: what should be true when this is done, who it's for, and how we'll check it. Then constraints. Batch related questions together (2-3 per message is fine). Prefer multiple choice when possible.
3. **Propose 2-3 approaches** — with trade-offs and your recommendation. Lead with the simplest one that fits the problem as the user sees it.
4. **Present design** — scale detail to complexity. A simple feature gets a short design. Cover: architecture, components, data flow, error handling, testing approach.
5. **Write design doc** — open it with the four sections under "Spec Header", then the design. Save to `notes/<topic>-design-YYYY-MM-DD.md` in the repo. `notes/` stays out of git: add a `/notes/` line to `.git/info/exclude` before the first file. User or repo preferences for location override this default.
6. **Quick sanity check** — scan for placeholders, contradictions, or missing requirements. Fix inline.
7. **User reviews spec** — ask user to review before proceeding
8. **Transition** — invoke writing-plans skill

## Spec Header

Every design doc starts with these, before any architecture:

- **Goal** — the outcome in one or two sentences, in the user's words.
- **Non-goals** — what this deliberately leaves out.
- **Assumptions** — anything you filled in that the user didn't say. Each one is a guess until the user confirms it during review.
- **Done when** — checks someone can run or observe. They're written before the build so the result is judged against them, not against whatever got built.

## Visual Questions

If upcoming questions involve visual content (screens, layouts, icons), offer once to use the `mockups` skill for them. Conceptual questions stay in the terminal.

## Design Principles

- **Subtract first** — reuse or delete before adding; new state, flags, config or subsystems need a stated reason
- **YAGNI** — remove unnecessary features
- **Isolation** — units with clear boundaries and well-defined interfaces
- **Follow existing patterns** in established codebases
- **Scale to complexity** — a simple feature gets a few paragraphs, not a novel

## After Approval

Write the spec, ask the user to review it, then invoke the **writing-plans** skill. No other skill.
