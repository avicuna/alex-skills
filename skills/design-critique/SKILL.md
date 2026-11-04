---
name: design-critique
description: Critique a UI screen, component, or user flow like a senior product designer. Use when the user asks for a design review, design critique, UX review, or design QA of a screenshot, mockup, running app, URL, or frontend code.
---

# Design Critique

Critique the screen, component, or user flow the user points at, the way a
senior product designer would. Find the design problems that matter, explain
why they matter, rank them, and recommend practical fixes.

This is a review, not a redesign. Do not edit code, styles, or design files
during a critique unless the user asks for changes.

## Get the design in front of you

Review what the user actually ships or plans to ship. In order of preference:

1. **The rendered UI.** If there is a running app or a URL, open it in a
   browser tool and take screenshots. Capture the states that matter: empty,
   loading, error, filled, hover and focus where you can reach them. Check a
   narrow width as well as desktop.
2. **Screenshots or mockups** the user attached or named on disk.
3. **Source code** (components, styles, design tokens). Use it to back up what
   you see, such as exact colors, sizes, and states. You can also use it alone
   when nothing renders, but then label visual conclusions as inferred from
   code.

If you cannot see the design at all, say so and ask for a screenshot or a way
to run it. Do not critique a design you have not seen.

Ask about the product and the user's goal only if it changes the review and
you cannot infer it. Otherwise state your assumption and continue.

## Reviewers

Two models from different providers review the same design on their own, and
you merge what they find. Use the latest Claude Opus and GPT Sol at high
reasoning effort, unless the user's instructions name other reviewers.

1. **Collect the evidence once.** Take the screenshots and gather the relevant
   files yourself. Save the screenshots to files, so both reviewers judge the
   same states and widths.
2. **Start the reviewers in parallel.** In T3 Code, call
   `orchestrator_capabilities` to resolve the models, then use `delegate_task`
   to start one read-only review delegate per model. Elsewhere, use the
   harness's subagent tools if they can run both models. Do not use a
   multi-model MCP server, such as AI Council. Give each reviewer the product
   context, the absolute paths to the screenshots and files, and the sections
   of this skill from "What to review" through "Each finding". Ask each one
   for findings only, not the full report. Tell them not to edit anything or
   start their own subagents.
3. **Merge.** Check every finding against the evidence yourself, and drop the
   ones the evidence does not support. Combine findings that describe the
   same problem. A finding both reviewers raised on their own gets higher
   confidence. When they disagree on severity, choose one and give the
   reason. Keep a real disagreement in the report rather than hiding it.

If a reviewer's model is unavailable, say so and continue with the other one.
Do not substitute a different model. If neither can run, do the review
yourself and say it had one reviewer.

## What to review

1. **Visual hierarchy.** Is the primary action obvious? Is content ordered by
   importance? Are headings, supporting text, and actions clearly different?
2. **Layout and spacing.** Alignment, grid, spacing rhythm, density, grouping,
   balance.
3. **Typography.** Type scale, readability, size, line height, weight, line
   length, wrapping.
4. **Color and contrast.** Contrast, semantic color, emphasis, surface and
   background relationships.
5. **Components.** Consistency, states, affordances, reuse, visual patterns.
6. **Interaction.** Discoverability, feedback, error prevention, expected
   behavior, cognitive load.
7. **Usability.** Clarity, learnability, efficiency, error recovery, effort.
8. **Accessibility.** Text and UI contrast, touch target size, keyboard and
   focus behavior, reliance on color alone, readability. With code or a
   running app, check what you can: contrast values, focus styles, labels,
   semantic elements.
9. **Responsive behavior.** Content that breaks at small widths, long text,
   navigation, component adaptability.

## Evidence

Every important finding needs visible evidence: what happens, where, why it
matters, and what should change. Name the element, and add the screenshot,
file and line, or style value when you have one.

Do not write findings like "this doesn't look good", "make it cleaner", or
"the spacing feels off".

If you cannot verify something from what you have, label it an assumption.

## Severity

- **Critical:** blocks users, causes serious errors, or prevents a core task.
- **High:** a significant usability, clarity, accessibility, or interaction
  problem likely to affect many users.
- **Medium:** friction, confusion, or inconsistency that does not prevent the
  task.
- **Low:** polish or a minor improvement with limited impact.

Rank by user impact. Do not inflate severity.

## Each finding

- **Issue:** a short description.
- **Evidence:** what you saw, and where.
- **Why it matters:** the user or business impact.
- **Severity:** Critical, High, Medium, or Low.
- **Recommendation:** a specific, actionable change. Name the component or
  style to change when you know it.
- **Confidence:** High, Medium, or Low, when the conclusion rests on
  assumptions.

## Output

### Overall assessment

- Overall quality
- Strongest aspect
- Biggest risk
- Most important next step

### Priority findings

| Priority | Area | Finding | Severity | Impact | Raised by |
|---|---|---|---|---|---|

`Raised by` names the reviewers, such as `Opus, Sol` or `Sol`.

### Detailed findings

Group by area, and skip areas with nothing worth saying:

- Visual hierarchy
- Layout and spacing
- Typography
- Color and accessibility
- Components and consistency
- Interaction and usability
- Responsive behavior

### Quick wins

The highest-value fixes that are fast to make.

### Recommended next steps

A practical order for working through the findings.

## Ground rules

- Do not invent user research, analytics, or usability test results.
- A design is not wrong because it differs from your taste. Separate objective
  problems from subjective suggestions.
- Use the product context and user goal when you have them.
- Prefer a few strong findings over a long list of nitpicks.
- Keep the existing design intent. Do not redesign the whole screen unless
  asked.
- If the user then asks you to fix the findings, make the changes in their
  code, then re-check the rendered result.
