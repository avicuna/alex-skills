# alex-skills

The agent skills I use every day, cleaned up so anyone can use them, plus the
engineering guidelines I work by. They work in Claude Code and Codex. Some use
[T3 Code](https://github.com/pingdotgg/t3code) features when they are
available and fall back to native tools when they are not.

This started as a fork of [tstack](https://github.com/t3dotgg/tstack).

## Skills

| Skill | Say | What it does |
|---|---|---|
| `full-send` | "full send" | Takes a change to a merged PR with nobody watching: proves it, reviews it, files it, babysits it, merges it. |
| `full-stop` | "full stop" | Same as `full-send`, but stops when the PR is ready for you to merge. |
| `council` | "council" | Gets review from three models from different providers, and loops until they agree. |
| `sol-loop` | "sol loop" | Reviews a change with GPT Sol in a loop until both agents agree. |
| `file-pr` | "file a PR" | Files a short PR that leads with the problem, not an inventory of changes. |
| `takeover` | "take over" | Finishes someone else's PR, branch, or agent thread, and keeps their credit. |
| `babysit-pr` | "babysit" | Watches a PR through CI and review bots, and fixes the real findings. |
| `modernize` | "modernize" | Rebases an old PR and decides if it should still exist. |
| `design-critique` | "design review" | Has Opus and Sol critique a screen, component, or flow like senior product designers, then merges their findings into one ranked report. |
| `mockups` | "make mockups" | Turns inspiration images into four options to pick from, then a draft, a critique, and a final mockup. Works for websites, app screens, and app icons, and finds inspiration on the web if you have none. |
| `brainstorming` | "let's design X" | Works out intent, requirements and design before building something new. |
| `writing-plans` | "write the plan" | Turns a spec into a task-by-task plan where each task can be handed to a subagent or a Codex job. |
| `engineering-investigation` | "investigate" | Writes an evidence-backed investigation report where every claim is labelled Proven, Derived, Hypothesis or Unknown. |
| `qa-tester` | "QA this" | Tests an app or PR like a QA engineer: a test plan, a run through it, and a bug report. |
| `voice-rewrite` | "de-AI this" | Rewrites a draft so it stops reading like AI, or so it sounds like you with `/as-alex`. |
| `handoff` | "handoff" | Writes a capsule so another agent or tool can pick up the work mid-task. |
| `leaving-pr-comments` | (automatic) | Formats comments that an agent posts on your behalf. |

Some skills call others. Install the ones they need too:

- `full-send` uses `sol-loop`, `file-pr`, and `babysit-pr`, and `council` when
  no route runs Sol.
- `full-stop` uses `full-send`.
- `mockups` uses `design-critique`.
- `takeover` uses `modernize`, `file-pr`, `babysit-pr`, and `leaving-pr-comments`.
- `file-pr`, `babysit-pr`, and `modernize` use `leaving-pr-comments`.
- `brainstorming` hands off to `writing-plans`, and offers `mockups` for visual questions.
- `qa-tester` can use `council` to review its test plan.

`brainstorming` and `writing-plans` started as trimmed versions of the
[superpowers](https://github.com/obra/superpowers) skills of the same name.

## Guidelines

[`guidelines/`](guidelines) is how I work:

- [`AGENTS.md`](guidelines/AGENTS.md) holds the global rules I give every agent:
  engineering principles, scope, evidence, delegation, git and writing. Copy it
  to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` and edit it from there.
- [`how-i-work.md`](guidelines/how-i-work.md) is the process behind those rules,
  and which skill I use at each step.

## Extras

- `commands/as-alex.md` is the `/as-alex` slash command for Claude Code. It turns on
  `voice-rewrite`'s second axis. Codex picks it up from `/as-alex` at the start of
  a message.
- `hooks/block-unresolved-flags.sh` is a PreToolUse hook that blocks a send while
  the text still has a `[NEEDS NUMBER]` flag in it. Run
  `hooks/test-block-unresolved-flags.sh` to test it.
- `bin/quiet-run` runs a noisy build or test command, saves the full log, and
  prints only the status and test counts unless it fails.

## Install

```bash
git clone https://github.com/avicuna/alex-skills ~/dev/alex-skills
cp -R ~/dev/alex-skills/skills/* ~/.claude/skills/   # Claude Code
cp -R ~/dev/alex-skills/skills/* ~/.codex/skills/    # Codex
cp ~/dev/alex-skills/commands/as-alex.md ~/.claude/commands/
```

Symlink a skill folder instead of copying it if you want `git pull` to update it.

To use the hook, register it in `~/.claude/settings.json` for the tools that send
messages for you, for example:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "mcp__.*slack.*send.*|mcp__.*gmail.*send.*",
        "hooks": [{ "type": "command", "command": "~/dev/alex-skills/hooks/block-unresolved-flags.sh" }]
      }
    ]
  }
}
```

## Requirements

- An authenticated [GitHub CLI](https://cli.github.com) (`gh`).
- `python3` for `babysit-pr`'s `pr-wait` script, the hook, and
  `engineering-investigation`'s report validator. `pr-wait` runs on macOS and
  Linux, not Windows.
- `council`, `sol-loop`, and `design-critique` need subagents on other
  providers' models. T3 Code does this with `delegate_task`. Otherwise you
  need a harness that can run those models.
- `mockups` puts mockups on a claude.ai Design canvas when the claude-artifacts
  connector is available, and writes local HTML files either way. A browser
  tool lets it screenshot the draft for review, and web search plus a browser
  tool let it find inspiration when you have none.
- `qa-tester` uses the Playwright MCP for web apps and falls back to manual
  steps without it.
- `voice-rewrite`'s own-voice mode needs a voice profile at
  `~/.claude/voice-profile.md` (Codex: `~/.codex/voice-profile.md`). It holds
  real messages, so it isn't in this repo.
  [`references/voice-profile-template.md`](skills/voice-rewrite/references/voice-profile-template.md)
  shows how to build one. The de-AI mode works without it.

## Make them yours

These are starting points. Edit them. Put personal settings, like which models
sit on your council, in your `CLAUDE.md` or `AGENTS.md`, so you can update the
skills without losing them.

## License

[MIT](LICENSE)
