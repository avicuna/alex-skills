# Recipe: CLI Testing (Bash)

Use this recipe when testing command-line tools, scripts, or any executable invoked from a shell.

#### Setup

```bash
# Create isolated temp directory for each test section
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"
```

#### Test Patterns

**Basic command execution:**
```bash
# Run the command and capture output + exit code
OUTPUT=$(command arg1 arg2 2>&1)
EXIT_CODE=$?
# Assert exit code
[ "$EXIT_CODE" -eq 0 ] && echo "PASS" || echo "FAIL: exit code $EXIT_CODE"
```

**Stdout vs stderr separation:**
```bash
STDOUT=$(command arg1 2>/dev/null)
STDERR=$(command arg1 2>&1 >/dev/null)
```

**Check output contains expected text:**
```bash
echo "$OUTPUT" | grep -q "expected text" && echo "PASS" || echo "FAIL: expected text not found"
```

**Check output matches exact value:**
```bash
[ "$OUTPUT" = "exact expected output" ] && echo "PASS" || echo "FAIL: got '$OUTPUT'"
```

**Performance measurement:**
```bash
START=$(date +%s%N)
command arg1 arg2 >/dev/null 2>&1
END=$(date +%s%N)
DURATION_MS=$(( (END - START) / 1000000 ))
[ "$DURATION_MS" -lt 500 ] && echo "PASS: ${DURATION_MS}ms" || echo "FAIL: too slow (${DURATION_MS}ms)"
```

#### What to Test

- **Help flag:** `command --help` exits 0 and prints usage info
- **Version flag:** `command --version` exits 0 and prints a version string
- **No arguments:** `command` (no args) — should it show help or error? Test both exit code and output
- **Invalid arguments:** `command --nonexistent` exits non-zero and prints an error to stderr
- **Invalid input file:** `command nonexistent.txt` exits non-zero with a clear error
- **Empty input:** `echo "" | command` or `command /dev/null` — graceful handling
- **Large input:** Generate large input to test memory/performance bounds
- **Piped input:** `echo "data" | command` should work equivalently to `command file.txt`
- **File output:** If the command creates files, verify they exist and contain expected content
- **Environment variables:** Test with and without relevant env vars set
- **Permission errors:** Test with read-only files or dirs when applicable

#### Cleanup

```bash
# After each test section
rm -rf "$TEST_DIR"
```

Always clean up temp directories. Never write test artifacts to the source repo directory.

#### Error Evidence Collection (CLI)

On any `FAIL`:
- Record the full command that was run
- Record stdout (first 50 lines if large)
- Record stderr (first 50 lines if large)
- Record exit code
- Record relevant environment variables
