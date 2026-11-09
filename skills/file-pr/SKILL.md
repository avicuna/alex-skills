---
name: file-pr
description: File a concise pull request. Use when the user asks to file, open, or create a PR.
---

# File PR

Before filing, check whether a PR for this branch already exists. Review the
diff locally against the base branch (usually `origin/main`) to make sure its
contents match the goal.

PR titles usually become commit messages, so follow the repository's title
conventions. Look at recently merged PRs and Git history for examples. Prefer a
concise, human-readable title that explains why the change matters:

BAD

> ❌ perf(server): negotiate permessage-deflate on the websocket

GOOD

> ✅ perf(server): cut websocket frame size by 70%+ with gzipping

Open the description with a simple explanation of the problem based on the
user's original prompt, then briefly explain the solution. Do not lead with an
implementation inventory:

BAD

> ❌ Removed implicit workspace carry-over from every "new thread" entry point (cmd+n / cmd+shift+o, sidebar v1/v2 buttons, command palette). New threads inherit only the project from context; branch, worktree, and env mode always come from the configured defaults. Deleted buildContextualThreadOptions, startNewThreadInProjectFromContext, and the v1 sidebar's seed-context machinery.

GOOD

> ✅ My "new worktree" default was ignored when starting new threads on existing worktrees. Super unintuitive. Now your preferences always apply.

Keep that opener short enough to read at a glance. When there's detail a
reviewer might want, such as test commands and their results, what was checked
by hand, or why a file changed, put it after the opener in a collapsed block
whose summary names the model and harness:

```html
<details><summary>Created with <model> in <harness></summary>

Tested against a scratch repo: a push to main is refused with exit 1, ...

</details>
```

Leave the block out when the opener already says everything; it is not a place
to bring back the long description. Without a block, end the description with
the plain line `Created with <model> in <harness>.`

Either way, name the public model and harness that made the changes, and
include subagent models that wrote part of the change. Use the model name the
harness reports, and add an effort level only if the harness reports one. If
model identity is unavailable, name the harness without guessing a model. This
is the only attribution. Do not add a harness's default line, such as
"Generated with Claude Code", as well.

Before submission, check the title, description, quotes, and attachments for
secrets and private details.

Open a real PR rather than a draft so review bots run. If `gh pr create` fails
because the GraphQL rate limit is used up, open it through REST with
`gh api repos/<owner>/<repo>/pulls -f title=... -f head=... -f base=... -F body=@<file>`. If the user also asked
to babysit it, continue with the `babysit-pr` skill.

Do not post a follow-up PR comment unless it serves the user's request. When a
comment is needed, use the `leaving-pr-comments` skill.
