---
name: mockups
description: Turn inspiration into mockups of a website, an app screen, or an app icon. Makes four options to pick from, builds a draft from the picks, critiques it with design-critique, and delivers a final mockup. Use when the user asks for mockups or design directions, whether they share inspiration images, moodboards, or reference sites, or have no inspiration yet and want you to find some.
---

# Mockups

Turn inspiration into a mockup in four stages. The subject is a website, an
app screen, or an app icon; "page" below means whichever one it is.

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
  inspiration/   (only when you found the inspiration yourself)
  options/a-<name>.html ... d-<name>.html
  draft.html
  critique.md
  final.html
```

**Design canvas.** If the claude-artifacts connector offers the Design
artifact type (`list_types`), also put each stage on one Design canvas, so the
user can view the options side by side in claude.ai. Create the canvas once,
named after the site or app, and follow the type's own instructions for its file
format. Put the four options in one row, and put the draft and the final in
a row below it. Do not make a new canvas for each stage. If the connector or
the type is unavailable, say so once and use the HTML files alone. Give the
user file paths in that case.

The canvas is behind the user's login, so you cannot screenshot it. Always
render and review the HTML copies.

## Stage 0: Brief

Collect the inspiration: attached images, image paths, or URLs (take a
screenshot of each URL). Look at every image.

**If the user gave no inspiration, find it yourself; do not ask for it, and
do not fall back on your own taste alone.** Gather 6 to 8 references:

1. Search the web for the subject and the mood the user asked for, for
   example "sleek macOS app icon dark gradient" or "developer tool landing
   page". Look in curated galleries: Dribbble and Behance for any subject,
   Mobbin for app screens, Land-book or Godly for websites, macOSicons or
   Apple's design resources for icons. Also look at well-made real products
   in the same space.
2. Pick references that differ from each other in direction, so the four
   options have room to differ. Take them from at least 3 sources.
3. Screenshot each one with a browser tool into `mockups/inspiration/`,
   named `01-<short-name>.png` and so on. Look at every screenshot. Drop any
   you could not view.
4. In `brief.md`, list each reference with its URL and creator.

If no web search or browser tool works, say so once and use directions
derived from the user's words instead. Label them as such in `brief.md`.

Learn what the site or app is for, who it serves, and what goes on the page. Ask
only for what you cannot infer, in one message. If the user gave real
content, use it. For missing facts, use visible placeholders like
`[YOUR PRICE]`. Never use lorem ipsum, invented stats, or fake testimonials.

For each image, note what is worth borrowing: layout, type pairing, color,
density, imagery style, mood, a specific pattern. Save the notes and the
brief to `brief.md`.

Inspiration is not a template. Borrow qualities, not a site. Never copy
another company's logo, branding, copy, illustrations, or photos, or recreate
a specific site's or app's look; for icons, never reuse another app's
symbol. Use labelled placeholders where images go.

## Stage 1: Options

Make four options. Each one is a clearly different direction, not a color
swap. For example, vary layout structure, type, density, and tone. Each
option can lean on a different image, or mix several.

What each option shows depends on the subject:

| Subject | Each option shows |
|---|---|
| Website | The first screen and one or two key sections below it, at desktop width. |
| App screen | The key screen at the target device's width. |
| App icon | The artwork large (512 to 1024px) in the platform's shape: a rounded square on Apple's macOS icon grid, a full square for iOS and Android, which mask it. Below it, the icon at 128, 64, 32, and 16px on light and dark backgrounds, and once in a Dock or home-screen row beside neutral placeholder icons. Draw it as inline SVG. |

All four use the same content, so the user compares design,
not copy. Give each option a short name that says the direction, like
`a-editorial` or `b-dense-grid`.

Follow good craft in every option: real `<button>`, `<a>`, and `<label>`
elements, text contrast of at least 4.5:1, and touch targets of at least
44px. An icon must still read at 16px; avoid text in it except a single
glyph.

Present the options with the canvas link or the file paths. For each one,
write one line on the direction and which inspiration it draws from. If you
found the inspiration, list the references with their links first, so the
user can see where the options came from. Then ask
the user to pick. They can pick one, or mix parts: "B's layout with D's
colors". Stop here until they answer.

## Stage 2: Draft

Build `draft.html` from the picks. For a website or app screen, this is the
full page: every section from the brief, the states that matter (such as
hover, focus, and empty or error states for forms), and a layout that works
at phone width. For an app icon, it is the refined artwork with the full set
of sizes, the light and dark backgrounds, and the platform's variants (dark
and tinted on iOS; on macOS a single icon that holds up in light and dark
mode). Save the artwork as `icon.svg` beside it too. Keep the picked
direction. When picks conflict, choose and note the choice in one line.

## Stage 3: Critique

Run the `design-critique` skill on the draft. Open `draft.html` in a browser
tool and take screenshots at desktop and phone widths (for an icon: the
whole sheet, plus a close crop of the 32 and 16px sizes). Give the reviewers the
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
once to confirm the fixes landed and nothing broke at phone width or, for an
icon, at 16px. For an icon, also export `icon.svg` to a 1024px PNG.

Deliver:

- The canvas link and the path to `final.html` (and, for an icon, the SVG
  and PNG).
- What changed after the critique, in a few bullets.
- Declined findings, one line each.
- Choices you made for the user and placeholders still to fill in.
