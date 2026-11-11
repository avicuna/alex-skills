---
name: file-issue
description: File a clean, easy-to-read GitHub issue from a task the user explains. Use when the user asks to file, open, create, or write up a GitHub issue, or to turn a task, bug, or idea into one.
---

# File Issue

The user explains a task, often loosely and out of order. Turn it into an
issue that someone who never saw the conversation can read in a minute and
act on, then file it. Keep the decisions and drop the thinking out loud.

## Before writing

Pick the repo: the one the user names, or else the current directory's
(`gh repo view --json nameWithOwner,visibility,isFork`). If there is neither,
ask. If the repo is a fork, ask whether the issue goes to the fork or upstream.

When the task touches code in this checkout, read enough of it to name the
right files and functions.

Look for an existing issue:
`gh issue list --repo <repo> --state all --search "<keywords>"`. If an open
one already covers the task, show it to the user and ask before filing
another. Link related ones under Notes.

Follow the repo's habits:

- **Templates.** If a template in `.github/ISSUE_TEMPLATE/` fits the task, use
  its headings in its order and apply its labels. Delete its placeholder text
  and comments. For a YAML issue form, use each field's label as a `###`
  heading.
- **Titles.** Match the style of recent issues (`gh issue list --repo <repo>`).
- **Labels.** Add an existing label when it plainly fits, like `bug` or
  `enhancement` (`gh label list --repo <repo>`).

If you cannot tell what the issue is for, ask, with all your questions in one
message. Anything else that is unclear goes under Open questions.

## Title

Say what the issue is in plain words, in under about 70 characters. Start a
task with a verb. Name a bug by its symptom.

BAD

> ❌ Export issue
>
> ❌ [Feature Request] Implement CSV export functionality for the reports page to allow users to analyze data

GOOD

> ✅ Add CSV export to the reports page
>
> ✅ CSV export leaves out the date column

## Body

Open with one to three sentences, with no heading, that say what needs to
happen and why. A reader who stops there should know what the issue is about.

Then add the sections that have something to say, in this order, with these
headings:

| Heading | What goes in it |
|---|---|
| `### Context` | What happens today and why it matters, if the opening did not cover it. |
| `### Steps to reproduce` | Bugs only. Numbered steps, then **Expected:** and **Actual:** lines. |
| `### Done when` | A task list (`- [ ]`) of outcomes someone can check. |
| `### Out of scope` | What the user ruled out. |
| `### Open questions` | Decisions the user has not made yet. |
| `### Notes` | Relevant code, related issues and PRs, and any approach the user suggested. |

Write it so it scans:

- Every requirement comes from the user or from code you read. Guesses go
  under Open questions, not Done when.
- Write in the user's voice, since the issue posts from their account: "Safari
  may be blocking the popup", not "The user suspects Safari blocks the popup".
- Short sentences. One idea per bullet.
- Write each paragraph and each bullet on one line. GitHub turns every newline
  in an issue into a line break, so wrapped text comes out ragged.
- Put code, paths, commands, and error text in backticks. Put long logs in a
  `<details>` block.
- Link code with permalinks at a pushed commit, like
  `https://github.com/<owner>/<repo>/blob/<sha>/<path>#L10-L20`. Write related
  issues and PRs as `#123`.
- Mention someone with `@login` only when the user asks. A mention notifies
  them.
- `gh` cannot upload images. If the user shared a screenshot, describe what it
  shows and tell them to drag it into the issue.

End with `<sub>Created with <model> in <harness>.</sub>`, using the public model
name the harness reports. If it reports none, name only the harness.

Example:

```markdown
The reports page only exports PDF, so finance retypes the numbers into a spreadsheet every month. Add a CSV export next to the PDF one.

### Done when
- [ ] The reports page has an **Export CSV** button next to **Export PDF**.
- [ ] The CSV has the same columns and filters as the table on screen.
- [ ] Dates are ISO 8601, like `2026-11-04`.

### Out of scope
- Excel (`.xlsx`) export.

### Open questions
- Should exports over 10,000 rows stream, or is a row limit fine?

### Notes
- PDF export lives in [`src/reports/export.ts`](https://github.com/acme/app/blob/4f2c1ab/src/reports/export.ts#L40-L88).
- Finance asked for this in #212.

<sub>Created with <model> in <harness>.</sub>
```

## File it

Check the title and body for secrets and private details, such as tokens,
internal URLs, and customer names. Be strict when the repo is public.

If the user asked to see a draft first, show it and wait. Otherwise, write the
body to a file, so backticks and `$` survive the shell, and file it:

```bash
gh issue create --repo <owner/repo> --title "<title>" --body-file <file> --label <label>
```

Add `--assignee`, `--milestone`, or `--project` only when the user asks;
"assign it to me" is `--assignee @me`. If filing fails, report the error. Do
not create labels or change repo settings to get past it.

Several unrelated tasks get one issue each. Steps toward one goal share one.

Reply with the issue title and link, and repeat any open questions so the user
can answer them.
