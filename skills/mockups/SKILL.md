---
name: mockups
description: Turn website inspiration images into UI mockups. Makes four options to pick from, builds a draft from the picks, critiques it with design-critique, and delivers a final mockup. Use when the user shares inspiration images, moodboards, or reference sites and asks for mockups or design directions.
---

# Mockups

Turn inspiration images into a website mockup in four stages:

1. Four options for the user to pick from.
2. A full draft built from the picks.
3. A design critique of the draft.
4. A final mockup with the useful feedback folded in.

Stop and wait for the user only after stage 1. Run stages 2 to 4 without
stopping.

## Where mockups live

Keep a plain HTML file for every mockup in a working folder: `mockups/` in the
working directory, unless the user names another. Each file is a single page
with no dependencies except Google Fonts, so it opens straight from disk.
These files are what you render and review. Do not commit them unless the
user asks.

```
mockups/
  brief.md
  options/a-<name>.html ... d-<name>.html
  draft.html
  critique.md
  final.html
```

**Design canvas.** If the claude-artifacts connector offers the Design
artifact type (`list_types`), also put each stage on one Design canvas, so the
user can view the options side by side in claude.ai. Create the canvas once,
named after the site, and follow the type's own instructions for its file
format. Put the four options in one row, and put the draft and the final in
a row below it. Do not make a new canvas for each stage. If the connector or
the type is unavailable, say so once and use the HTML files alone. Give the
user file paths in that case.

The canvas is behind the user's login, so you cannot screenshot it. Always
render and review the HTML copies.

## Stage 0: Brief

Collect the inspiration: attached images, image paths, or URLs (take a
screenshot of each URL). Look at every image.

Learn what the site is for, who it serves, and what goes on the page. Ask
only for what you cannot infer, in one message. If the user gave real
content, use it. For missing facts, use visible placeholders like
`[YOUR PRICE]`. Never use lorem ipsum, invented stats, or fake testimonials.

For each image, note what is worth borrowing: layout, type pairing, color,
density, imagery style, mood, a specific pattern. Save the notes and the
brief to `brief.md`.

Inspiration is not a template. Borrow qualities, not a site. Never copy
another company's logo, branding, copy, illustrations, or photos, or recreate
a specific site's look. Use labelled placeholders where images go.

## Stage 1: Options

Make four options. Each one is a clearly different direction, not a color
swap. For example, vary layout structure, type, density, and tone. Each
option can lean on a different image, or mix several.

Each option shows the first screen and one or two key sections below it, at
desktop width. All four use the same content, so the user compares design,
not copy. Give each option a short name that says the direction, like
`a-editorial` or `b-dense-grid`.

Follow good craft in every option: real `<button>`, `<a>`, and `<label>`
elements, text contrast of at least 4.5:1, and touch targets of at least
44px.

Present the options with the canvas link or the file paths. For each one,
write one line on the direction and which inspiration it draws from. Then ask
the user to pick. They can pick one, or mix parts: "B's layout with D's
colors". Stop here until they answer.

## Stage 2: Draft

Build `draft.html` from the picks. This is the full page: every section from
the brief, the states that matter (such as hover, focus, and empty or error
states for forms), and a layout that works at phone width. Keep the picked
direction. When picks conflict, choose and note the choice in one line.

## Stage 3: Critique

Run the `design-critique` skill on the draft. Open `draft.html` in a browser
tool and take screenshots at desktop and phone widths. Give the reviewers the
brief, the user's picks, the screenshots, and the HTML. Tell them the picked
direction is intentional, so they review how well the draft carries it out,
not whether they like it. Save the report to `critique.md`.

If no browser tool can render the page, review from the HTML and label
visual findings as inferred, as `design-critique` says.

## Stage 4: Final

Fold in the useful feedback and write `final.html`:

- Fix every Critical and High finding.
- Fix Medium and Low findings when they are cheap and fit the direction.
- Decline findings that fight the user's picks, or that are only taste. Keep
  a one-line reason for each.

Do one critique round only, unless the user asks for more. Render the final
once to confirm the fixes landed and nothing broke at phone width.

Deliver:

- The canvas link and the path to `final.html`.
- What changed after the critique, in a few bullets.
- Declined findings, one line each.
- Choices you made for the user and placeholders still to fill in.
