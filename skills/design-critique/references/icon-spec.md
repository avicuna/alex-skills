# UI icon spec

Eight rules that keep a set of UI icons (toolbar, nav, button and status
glyphs) looking like one family. They don't cover app icons, which are
full-color artwork judged at large sizes.

The numbers are a common starting point on a 24px grid. What matters is that
the set picks one value per rule and every icon follows it. When a product
already has its own values, review against those.

1. **Box.** Every icon sits in the same square frame with the same padding,
   such as a 24px box with a 20px live area (2px on each side). Export every
   icon with that padding, never trimmed to its artwork.
2. **Optical size.** Shapes follow keylines so they carry the same visual
   weight: on a 24px grid, a 20px circle, an 18px square, and a 20×16px
   rectangle (16×20px upright). A circle drawn as wide as the square looks
   smaller than it.
3. **Stroke.** One stroke weight for the whole set, such as 2px at 24px.
   Mixed weights read as icons from different libraries.
4. **Ends and corners.** One cap style (round or square), one corner radius
   (such as 2px), and one angle for diagonals (such as 45°).
5. **Fill logic.** Fill carries meaning, applied the same way everywhere, such
   as outlined for inactive and filled for selected. Fill used at random
   reads as a state change that didn't happen.
6. **Detail and viewpoint.** Flat and front-facing. Remove any detail that
   blurs into noise at the smallest size, usually 16px.
7. **Size ladder.** A fixed set of sizes, such as 16, 20, and 24px, each placed
   on whole pixels. Scaling a 24px icon down to 16px turns a 2px stroke into
   1.33px and blurs it, so the small sizes need their own drawings or a stroke
   that lands on whole pixels.
8. **Color.** A few named roles, such as default, selected, disabled, and
   error, not one-off colors. An icon that carries meaning needs at least 3:1
   contrast against its background (WCAG 1.4.11), and an icon-only control
   needs an accessible name.

## Reviewing a set against it

Look at the icons side by side at each size on the ladder, not one at a time.
Inconsistency shows up in comparison: a circle that looks smaller than its
neighbors, one heavier stroke, one square cap among round ones. With source
SVGs, check the values directly (`viewBox`, `stroke-width`,
`stroke-linecap`, `rx`) and name the icons that break the rule.
