# alex-skills

These are the agent skills and engineering guidelines I use every day in Claude
Code and Codex. Some of the skills use [T3 Code](https://github.com/pingdotgg/t3code)
features when they're available and fall back to native tools when they aren't.

It started as a fork of [tstack](https://github.com/t3dotgg/tstack), which is
why my checkout is still at `~/Dev/tstack`.

## Skills

| Skill | Say | What it does |
|---|---|---|
| `full-send` | "full send" | Takes a change all the way to a merged PR with nobody watching: proves it, reviews it, files it, babysits it, merges it. |
| `full-stop` | "full stop" | Same as `full-send`, but stops when the PR is ready for me to merge. |
| `council` | "council" | Gets a review from three models from different providers and loops until they agree. |
| `sol-loop` | "sol loop" | Reviews a change with GPT Sol in a loop until both agents agree. |
| `file-pr` | "file a PR" | Files a short PR that leads with the problem, not a list of changes. |
| `file-issue` | "file an issue" | Turns a task I explain into a GitHub issue that's quick to read: a plain title, a short summary and a checklist of what done means. |
| `takeover` | "take over" | Finishes someone else's PR, branch or agent thread and keeps their credit. |
| `babysit-pr` | "babysit" | Watches a PR through CI and review bots and fixes the real findings. |
| `modernize` | "modernize" | Rebases an old PR and decides whether it should still exist. |
| `design-critique` | "design review" | Has Opus and Sol critique a screen, component or flow like senior product designers, then merges their findings into one ranked report. |
| `mockups` | "make mockups" | Turns inspiration into four options to pick from, then a draft, a critique and a final mockup. Works for websites, app screens and app icons, and finds inspiration on the web if I don't have any. |
| `brainstorming` | "let's design X" | Works out intent, requirements and design before building something new. |
| `writing-plans` | "write the plan" | Turns a spec into a task-by-task plan where each task can go to a subagent or a Codex job. |
| `engineering-investigation` | "investigate" | Writes an evidence-backed investigation report where every claim is labelled Proven, Derived, Hypothesis or Unknown. |
| `qa-tester` | "QA this" | Tests an app or PR like a QA engineer: a test plan, a run through it and a bug report. |
| `voice-rewrite` | "de-AI this" | Rewrites a draft so it stops reading like AI, or so it sounds like me with `/as-alex`. |
| `handoff` | "handoff" | Starts a new T3 Code thread with a handoff capsule, or writes the capsule to a file for another tool. |
| `leaving-pr-comments` | (automatic) | Formats comments an agent posts on my behalf. |

Some skills call others:

- `full-send` uses `sol-loop`, `file-pr` and `babysit-pr`, and falls back to
  `council` when nothing can run Sol.
- `full-stop` uses `full-send`.
- `mockups` uses `design-critique`.
- `takeover` uses `modernize`, `file-pr`, `babysit-pr` and `leaving-pr-comments`.
- `file-pr`, `babysit-pr` and `modernize` use `leaving-pr-comments`.
- `brainstorming` hands off to `writing-plans` and offers `mockups` for visual questions.
- `qa-tester` can use `council` to review its test plan.

`brainstorming` and `writing-plans` started as trimmed versions of the
[superpowers](https://github.com/obra/superpowers) skills with the same names.
I've turned the superpowers plugin off: its session hook pushed every turn
toward a skill and its copies of these two competed with mine.

## Guidelines

[`guidelines/`](guidelines) is how I work:

- [`AGENTS.md`](guidelines/AGENTS.md) has the rules every agent gets:
  engineering principles, scope, evidence, delegation, git and writing.
- [`how-i-work.md`](guidelines/how-i-work.md) is the process behind those
  rules and which skill I use at each step.

## How it's wired up on my machines

Nothing gets copied over. Everything links back to this repo so a `git pull`
updates both harnesses at once. [`install.sh`](install.sh) does all of the
linking below in one go. Run it again after adding a skill or changing the
guidelines.

**Skills** are symlinked one folder at a time into both harnesses. Skills that
only live on one machine sit next to them as normal folders.

```bash
cd ~/Dev/tstack
for h in ~/.claude/skills ~/.codex/skills; do
  mkdir -p "$h"
  for s in skills/*/; do
    ln -sfn "$PWD/${s%/}" "$h/$(basename "$s")"
  done
done
ln -sfn "$PWD/commands/as-alex.md" ~/.claude/commands/as-alex.md
```

`install.sh` runs this loop. If a skill is already there as a copied
folder you'll need to delete it first since `ln` won't replace a real directory.

**Claude Code rules.** `~/.claude/CLAUDE.md` imports the guidelines, then adds
the rules that are only mine:

```markdown
# Global Rules

@~/Dev/tstack/guidelines/AGENTS.md

The sections below are personal to this machine. Where they differ from the
guidelines, they win.

## Git
## Cloudflare
## AI Council
```

**Codex rules.** Codex can't import files so `~/.codex/AGENTS.md` gets built
from the guidelines plus my personal sections in `~/.codex/AGENTS.personal.md`.
`install.sh` rebuilds it, so rerun it whenever the guidelines change:

```bash
cat ~/Dev/tstack/guidelines/AGENTS.md ~/.codex/AGENTS.personal.md > ~/.codex/AGENTS.md
```

**Push guard.** [`hooks/pre-push`](hooks/pre-push) refuses any push to `main`
or `master`, so the branch-and-PR rule holds even on repos where GitHub can't
enforce branch protection. `install.sh` sets it globally with
`git config --global core.hooksPath ~/Dev/tstack/hooks`. That setting makes git
ignore `.git/hooks`, so the script runs a repo's own `pre-push` after its
check. Other hook types in `.git/hooks` won't run while it's set, and a repo
that sets its own `core.hooksPath` (husky does) skips the guard.

**Secrets guard.** [`claude-hooks/protect-secrets.sh`](claude-hooks/protect-secrets.sh)
is a Claude Code `PreToolUse` hook. It blocks reads and edits of `.env` files
(the `.env.example` kind are fine), anything in `~/.secrets/` or a `secrets/`
folder, and plain force pushes. It checks Bash commands as well as the file
tools, because a deny rule like `Read(./.env)` doesn't stop `cat .env`.
`install.sh` links it to `~/.claude/hooks/`. It needs `jq`, and it only runs
once `~/.claude/settings.json` has this:

```json
"hooks": {
  "PreToolUse": [
    {
      "matcher": "Bash|Read|Edit|Write|NotebookEdit|Grep",
      "hooks": [{ "type": "command", "command": "$HOME/.claude/hooks/protect-secrets.sh" }]
    }
  ]
}
```

The Bash check matches on the command text, so it also stops harmless commands
that only mention those names, like `cp .env.example .env`. Run those yourself.

**Voice profile.** `/as-alex` needs `~/.claude/voice-profile.md`. It holds real
messages, so it stays out of this repo. `~/.codex/voice-profile.md` is a
symlink to it.
[`references/voice-profile-template.md`](skills/voice-rewrite/references/voice-profile-template.md)
shows how to build one.

The links point at whatever branch the checkout is on, so if I'm editing a skill
on a branch that's the version both harnesses run until I switch back.

## What the skills need

- An authenticated [GitHub CLI](https://cli.github.com) (`gh`).
- `python3` for `babysit-pr`'s `pr-wait` script and
  `engineering-investigation`'s report validator. `pr-wait` runs on macOS and
  Linux, not Windows.
- `council`, `sol-loop` and `design-critique` need subagents on other
  providers' models. T3 Code does this with `delegate_task`. Otherwise you
  need a harness that can run those models.
- `mockups` puts mockups on a claude.ai Design canvas when the
  claude-artifacts connector is available and writes local HTML files either
  way. A browser tool lets it screenshot the draft for review, and web search
  plus a browser tool let it find inspiration.
- `qa-tester` uses the Playwright MCP for web apps and falls back to manual
  steps without it.
- `voice-rewrite`'s de-AI mode works without a voice profile. Only `/as-alex`
  needs one.

## Using these yourself

Clone the repo and run the same linking loop from your checkout. Then copy
`guidelines/AGENTS.md` into your own `~/.claude/CLAUDE.md` or
`~/.codex/AGENTS.md` and edit it. It's written for how I work so treat it as a
starting point. `/as-alex` is built around my voice too, so you'll want to
build your own profile for it.

## License

[MIT](LICENSE)
