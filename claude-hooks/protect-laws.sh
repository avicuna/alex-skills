#!/bin/sh
# Claude Code PreToolUse hook. Keeps agents from changing the laws they are
# checked against: property tests under any repo's tests/laws/ folder. I write
# the laws; an agent that has to change one asks me. Exit 2 blocks the call
# and shows stderr to the agent. A session started with ALLOW_LAW_EDITS=1 in
# its environment may edit them; an agent can't set that from its own shell.
[ "${ALLOW_LAW_EDITS:-}" = 1 ] && exit 0
input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')

block() {
  echo "protect-laws: blocked, $1. Laws under tests/laws/ are mine to change: stop and ask me, and say which law and why." >&2
  exit 2
}

case "$tool" in
  Edit|Write|NotebookEdit)
    path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')
    case "$path" in
      tests/laws/*|*/tests/laws/*) block "$path is a law" ;;
    esac
    ;;
  apply_patch)
    # Codex edits files with a patch whose header lines name each file.
    patch=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
    if printf '%s\n' "$patch" | grep -Eq '^\*\*\* (Add File|Update File|Delete File|Move to): (.*/)?tests/laws/'; then
      block "the patch changes a law"
    fi
    ;;
  Bash)
    cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
    printf '%s' "$cmd" | grep -q 'tests/laws' || exit 0
    # Reading and running the laws is fine. Writing to them is not: a redirect
    # into the folder, or a command that edits, moves, deletes or restores files.
    if printf '%s' "$cmd" | grep -Eq '>[[:space:]]*[^[:space:]]*tests/laws'; then
      block "the command writes into tests/laws/"
    fi
    if printf '%s' "$cmd" | grep -Eq '(^|[^[:alnum:]_-])(sed[[:space:]]+(-[[:alpha:]]*[[:space:]]+)*-i|perl[[:space:]]+-[[:alpha:]]*i|rm|mv|cp|tee|truncate|ln|git[[:space:]]+(checkout|restore|rm|mv|apply|stash))([[:space:]]|$)'; then
      block "the command may change files in tests/laws/"
    fi
    ;;
esac
exit 0
