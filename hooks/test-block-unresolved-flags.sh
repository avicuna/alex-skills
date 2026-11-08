#!/usr/bin/env bash
# Tests for block-unresolved-flags.sh. Run: hooks/test-block-unresolved-flags.sh
set -euo pipefail

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/block-unresolved-flags.sh"
STDERR_FILE="$(mktemp)"
trap 'rm -f "$STDERR_FILE"' EXIT
fail=0

check() {
  local name="$1" want_exit="$2" input="$3" want_stderr="${4:-}"
  local out err ec
  out=$(printf '%s' "$input" | "$HOOK" 2>"$STDERR_FILE") && ec=0 || ec=$?
  err=$(cat "$STDERR_FILE")
  if [ "$ec" -ne "$want_exit" ]; then
    echo "FAIL ($name): exit=$ec want=$want_exit"; fail=1; return
  fi
  if [ -n "$want_stderr" ] && ! printf '%s' "$err" | grep -qF -- "$want_stderr"; then
    echo "FAIL ($name): stderr missing '$want_stderr', got: $err"; fail=1; return
  fi
  if [ -z "$want_stderr" ] && [ -n "$err" ]; then
    echo "FAIL ($name): expected silent stderr, got: $err"; fail=1; return
  fi
  if [ -n "$out" ]; then
    echo "FAIL ($name): stdout must stay empty, got: $out"; fail=1; return
  fi
  echo "PASS ($name)"
}

check "flag in message -> blocked" 2 \
  '{"tool_input":{"channel_id":"C0","message":"cap is [NEEDS NUMBER] lines"}}' \
  "cap is [NEEDS NUMBER] lines"

check "flag in another field -> blocked" 2 \
  '{"tool_input":{"to":"a@b.c","body":"line one\nwe saw [NEEDS NUMBER] errors"}}' \
  "we saw [NEEDS NUMBER] errors"

check "flag nested in a list -> blocked" 2 \
  '{"tool_input":{"blocks":[{"text":"[NEEDS NUMBER] users"}]}}' \
  "BLOCKED"

check "clean message -> allowed, silent" 0 \
  '{"tool_input":{"message":"all clear"}}'

check "no text fields -> allowed, silent" 0 \
  '{"tool_input":{"channel_id":"C0","count":3}}'

check "malformed JSON -> allowed, warns" 0 'not json' "did not run"

check "missing tool_input -> allowed, warns" 0 '{"tool_name":"x"}' "did not run"

exit "$fail"
