# tstack

The agent skills I use every day, cleaned up so anyone can use them. They work
in Claude Code and Codex. Some use [T3 Code](https://github.com/pingdotgg/t3code)
features when they are available and fall back to native tools when they are
not.

## Skills

| Skill | Say | What it does |
|---|---|---|
| `full-send` | "full send" | Takes a change to a merged PR with nobody watching: proves it, reviews it, files it, babysits it, merges it. |
| `full-stop` | "full stop" | Same as `full-send`, but stops when the PR is ready for you to merge. |
| `council` | "council" | Gets review from three models from different providers, and loops until they agree. |
| `sol-loop` | "sol loop" | Reviews a change with GPT Sol in a loop until both agents agree. |
| `file-pr` | "file a PR" | Files a short PR that leads with the problem, not an inventory of changes. |
| `file-issue` | "file an issue" | Turns a task you explain into a GitHub issue that is quick to read: a plain title, a short summary, and a checklist of what done means. |
| `takeover` | "take over" | Finishes someone else's PR, branch, or agent thread, and keeps their credit. |
| `babysit-pr` | "babysit" | Watches a PR through CI and review bots, and fixes the real findings. |
| `modernize` | "modernize" | Rebases an old PR and decides if it should still exist. |
| `design-critique` | "design review" | Has Opus and Sol critique a screen, component, or flow like senior product designers, then merges their findings into one ranked report. |
| `mockups` | "make mockups" | Turns inspiration images into four options to pick from, then a draft, a critique, and a final mockup. Works for websites, app screens, and app icons, and finds inspiration on the web if you have none. |
| `leaving-pr-comments` | (automatic) | Formats comments that an agent posts on your behalf. |

Some skills call others. Install the ones they need too:

- `full-send` uses `sol-loop`, `file-pr`, and `babysit-pr`, and `council` when
  no route runs Sol.
- `full-stop` uses `full-send`.
- `mockups` uses `design-critique`.
- `takeover` uses `modernize`, `file-pr`, `babysit-pr`, and `leaving-pr-comments`.
- `file-pr`, `babysit-pr`, and `modernize` use `leaving-pr-comments`.

## Install

```bash
git clone https://github.com/avicuna/tstack
cp -R tstack/skills/* ~/.claude/skills/   # Claude Code
cp -R tstack/skills/* ~/.codex/skills/    # Codex
```

## Requirements

- An authenticated [GitHub CLI](https://cli.github.com) (`gh`).
- `python3` for `babysit-pr`'s `pr-wait` script. It runs on macOS and Linux,
  not Windows.
- `council`, `sol-loop`, and `design-critique` need subagents on other
  providers' models. T3 Code does this with `delegate_task`. Otherwise you
  need a harness that can run those models.
- `mockups` puts mockups on a claude.ai Design canvas when the claude-artifacts
  connector is available, and writes local HTML files either way. A browser
  tool lets it screenshot the draft for review, and web search plus a browser
  tool let it find inspiration when you have none.

## Make them yours

These are starting points. Edit them. Put personal settings, like which models
sit on your council, in your `CLAUDE.md` or `AGENTS.md`, so you can update the
skills without losing them.

## License

[MIT](LICENSE)
