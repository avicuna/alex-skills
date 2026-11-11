#!/bin/sh
# Claude Code PreToolUse hook. Blocks reading or editing secret files and
# plain force pushes, whichever tool the agent reaches for. Permission deny
# rules only match one tool and one spelling; `cat .env` walks past a
# Read(.env) rule. Exit 2 blocks the call and shows stderr to the agent.
input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')

block() {
  echo "protect-secrets: blocked, $1. If the user needs this, ask them to run it themselves." >&2
  exit 2
}

# .env and .env.<anything>, except the checked-in example files.
is_env_name() {
  case "$1" in
    .env.example|.env.sample|.env.template|.env.dist) return 1 ;;
    .env|.env.*) return 0 ;;
  esac
  return 1
}

case "$tool" in
  Read|Edit|Write|NotebookEdit|Grep)
    path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // .tool_input.path // empty')
    [ -n "$path" ] || exit 0
    case "$path" in
      */.secrets|*/.secrets/*|*/secrets/*) block "$path is in a secrets folder" ;;
    esac
    is_env_name "$(basename "$path")" && block "$path is an env file"
    ;;
  Bash)
    cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
    if printf '%s' "$cmd" | grep -Eq '(^|[^[:alnum:]_])\.secrets(/|[^[:alnum:]_.-]|$)'; then
      block "the command touches a .secrets folder"
    fi
    for name in $(printf '%s' "$cmd" | grep -Eo '(^|[[:space:]/"'"'"'=<(])\.env(\.[[:alnum:]_.-]+)?($|[[:space:]"'"'"';|&)>])' | grep -Eo '\.env(\.[[:alnum:]_.-]+)?'); do
      is_env_name "$name" && block "the command touches $name"
    done
    if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+push([[:space:]][^;&|]*)?[[:space:]](--force|-[[:alpha:]]*f[[:alpha:]]*)([[:space:]]|$)'; then
      block "plain force push. Use --force-with-lease on your own branch"
    fi
    ;;
esac
exit 0
