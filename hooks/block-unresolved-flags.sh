#!/usr/bin/env bash
# PreToolUse hook: block a send whose text still contains an unresolved
# [NEEDS NUMBER] flag from voice-rewrite.
#
# Register it in ~/.claude/settings.json for the tools that send messages
# (Slack, email, PR comments...). It checks every string in tool_input, so it
# doesn't depend on which field a tool uses for the text.
#
# Exit 2 blocks the call and shows stderr to the agent. Anything it can't
# parse is allowed through with a warning, because blocking a send for a
# reason nobody can see is worse than missing one flag.
set -euo pipefail

set +e
hits=$(python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(3)
if not isinstance(data, dict) or not isinstance(data.get("tool_input"), dict):
    sys.exit(3)

def strings(value):
    if isinstance(value, str):
        yield value
    elif isinstance(value, dict):
        for v in value.values():
            yield from strings(v)
    elif isinstance(value, list):
        for v in value:
            yield from strings(v)

lines = [line for s in strings(data["tool_input"]) for line in s.splitlines() if "[NEEDS NUMBER]" in line]
print("\n".join(lines[:3]))
')
status=$?
set -e

if [ "$status" -ne 0 ]; then
  echo "WARNING: block-unresolved-flags.sh could not read tool_input; the [NEEDS NUMBER] check did not run." >&2
  exit 0
fi

if [ -n "$hits" ]; then
  cat >&2 <<EOF
BLOCKED: this message contains an unresolved [NEEDS NUMBER] flag.

$hits

Fill in the real number or remove the claim, then send again.
EOF
  exit 2
fi

exit 0
