#!/bin/sh
# Pipe-tests protect-laws.sh: sh claude-hooks/protect-laws.test.sh claude-hooks/protect-laws.sh
H=$1
err=$(mktemp)
fail=0
t() {
  printf '%s' "$2" | "$H" >/dev/null 2>"$err"
  got=$?
  ok=PASS; [ "$got" = "$1" ] || { ok=FAIL; fail=1; }
  printf '%s want=%s got=%s %s | %s\n' "$ok" "$1" "$got" "$3" "$(head -c 60 "$err")"
}
p() { jq -n --arg c "$1" '{tool_name:"apply_patch",tool_input:{command:$c}}'; }
nl='
'
t 2 "$(p "*** Begin Patch${nl}*** Update File: tests/laws/move.test.ts${nl}@@${nl}-a${nl}+b${nl}*** End Patch")" "patch: update relative law"
t 2 "$(p "*** Begin Patch${nl}*** Update File: /Users/x/repo/tests/laws/move.test.ts${nl}@@${nl}-a${nl}+b${nl}*** End Patch")" "patch: update absolute law"
t 2 "$(p "*** Begin Patch${nl}*** Delete File: tests/laws/move.test.ts${nl}*** End Patch")" "patch: delete law"
t 2 "$(p "*** Begin Patch${nl}*** Add File: tests/laws/new.test.ts${nl}+x${nl}*** End Patch")" "patch: add law"
t 2 "$(p "*** Begin Patch${nl}*** Update File: src/a.ts${nl}*** Move to: tests/laws/a.test.ts${nl}*** End Patch")" "patch: move into laws"
t 0 "$(p "*** Begin Patch${nl}*** Update File: src/shared/move.ts${nl}@@${nl}-// see tests/laws/move.test.ts${nl}+x${nl}*** End Patch")" "patch: src file mentioning laws"
t 0 "$(p "*** Begin Patch${nl}*** Add File: tests/shared/laws.test.ts${nl}+x${nl}*** End Patch")" "patch: other tests"
t 2 '{"tool_name":"Edit","tool_input":{"file_path":"/r/tests/laws/x.ts"}}' "claude: edit law"
t 0 '{"tool_name":"Edit","tool_input":{"file_path":"/r/tests/shared/x.ts"}}' "claude: edit other"
t 2 '{"tool_name":"Bash","tool_input":{"command":"rm tests/laws/move.test.ts"}}' "bash: rm law"
t 2 '{"tool_name":"Bash","tool_input":{"command":"echo x > tests/laws/a.ts"}}' "bash: redirect into laws"
t 0 '{"tool_name":"Bash","tool_input":{"command":"npx vitest run tests/laws > /tmp/log 2>&1"}}' "bash: run laws"
t 0 '{"tool_name":"Bash","tool_input":{"command":"npm test"}}' "bash: unrelated"
printf '%s' '{"tool_name":"Edit","tool_input":{"file_path":"tests/laws/a.ts"}}' | ALLOW_LAW_EDITS=1 "$H"
[ $? = 0 ] && echo "PASS override" || { echo "FAIL override"; fail=1; }
rm -f "$err"
exit $fail
