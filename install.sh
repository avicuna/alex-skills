#!/bin/sh
# Links this checkout into Claude Code and Codex. Safe to re-run.
set -eu
cd "$(dirname "$0")"
repo=$PWD

for h in "$HOME/.claude/skills" "$HOME/.codex/skills"; do
  mkdir -p "$h"
  for s in skills/*/; do
    ln -sfn "$repo/${s%/}" "$h/$(basename "$s")"
  done
done
mkdir -p "$HOME/.claude/commands"
ln -sfn "$repo/commands/as-alex.md" "$HOME/.claude/commands/as-alex.md"

mkdir -p "$HOME/.claude/hooks"
ln -sfn "$repo/claude-hooks/protect-secrets.sh" "$HOME/.claude/hooks/protect-secrets.sh"

if [ -f "$HOME/.codex/AGENTS.personal.md" ]; then
  cat guidelines/AGENTS.md "$HOME/.codex/AGENTS.personal.md" > "$HOME/.codex/AGENTS.md"
else
  cp guidelines/AGENTS.md "$HOME/.codex/AGENTS.md"
fi

git config --global core.hooksPath "$repo/hooks"
echo "Linked skills and the secrets guard, rebuilt ~/.codex/AGENTS.md, set core.hooksPath to $repo/hooks"
