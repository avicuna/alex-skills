---
name: qa-tester
version: 0.1.0
description: Systematically test an app, feature, or MR like a QA engineer. Generates test plans, executes tests via Playwright/curl/CLI, and produces structured reports. Use when asked to QA test, test an app, test this MR, find bugs, or run a test pass.
---

# QA Tester

Systematically test applications and features like a senior QA engineer. Two modes:
- **Full QA** (`/qa-tester` or `/qa-tester full`): Comprehensive test pass across the entire app
- **MR QA** (`/qa-tester mr <branch-or-URL>`): Scoped testing of changed features + targeted regression

**Announce at start:** "Using the qa-tester skill to systematically test this app/feature."

## When to Skip

Skip this skill if:
- User just wants a single manual check, not a systematic test plan
- User wants to write automated test *files* (unit/integration tests), not run QA — point them to TDD workflows instead
- User wants a test strategy document without execution
- User is asking about testing concepts, not requesting a test run

## Mode Selection

Parse the arguments passed to this skill:

1. **No arguments or `full`** → Execute **Full QA Mode**
2. **Argument starts with `mr` followed by a branch name or URL** → Execute **MR QA Mode**
   - URL patterns: `github.com/.*/pull/\d+`, `gitlab.com/.*/merge_requests/\d+`
   - Plain branch name: any non-URL string after `mr`
3. **Argument is a bare PR/MR URL** (no `mr` prefix) → Treat as **MR QA Mode**
   - Detect by matching `github.com/.*/pull/\d+` or `gitlab.com/.*/merge_requests/\d+`

Store the selected mode and any branch/URL reference for use in later phases.

## Phase 0: Prerequisites

Collect context before generating a test plan. Use a combination of auto-detection and user questions.

### Step 1: Ask User for Context

Ask the user (batch these into a single message):

1. **App entry point** — URL, CLI command, or path to run the app
2. **Auth method** — none, token, login flow, env vars, or "not sure"
3. **Areas of concern** — specific features or flows to focus on (optional)

If the user doesn't know the auth method, default to `none` and flag any auth-dependent tests with `[AUTH-RISK]` throughout the session.

### Step 2: Auto-Detect Tech Stack

Scan the project directory for signals:

| Signal | App Type | Primary Execution |
|--------|----------|-------------------|
| `package.json` with `svelte`, `react`, `vue`, `next`, `nuxt` | Web frontend | Playwright |
| `package.json` with `express`, `fastify`, `hono` | Web API | curl + Playwright for any UI |
| `go.mod`, `Cargo.toml`, `*.csproj` with no UI framework | CLI / Backend | Bash |
| `tauri.conf.json`, `electron-builder` | Desktop app | Playwright (web view) |
| `Dockerfile` + API routes | Containerized service | curl after docker compose up |
| `openapi.yaml` / `swagger.json` | API service | curl, schema-driven tests |

Detection logic:
- Read `package.json` dependencies and devDependencies for framework keywords
- Check for `go.mod`, `Cargo.toml`, `*.csproj` in the project root
- Look for `tauri.conf.json` or `electron-builder` config
- Check for `Dockerfile`, `docker-compose.yml`
- Look for `openapi.yaml`, `openapi.json`, `swagger.json`, `swagger.yaml`

### Step 3: Classify App Type

Based on Step 2 detection:
- **Web frontend** → Primary tool: Playwright
- **Web API** → Primary tool: curl (+ Playwright if a UI exists)
- **CLI / Backend** → Primary tool: Bash
- **Desktop app** → Primary tool: Playwright (web view)
- **Containerized service** → Primary tool: curl after docker compose up
- **API service** → Primary tool: curl, schema-driven

If multiple app types are detected (e.g., web frontend + API backend in a monorepo):
- Ask the user which to test first, or whether to run sequential sessions per type
- Default to the frontend if user doesn't respond

### Step 4: Verify App is Running

Perform a quick health check (5-second timeout):
- **Web app/API**: HTTP HEAD request to the provided URL
- **CLI**: Run `<command> --version` or `<command> --help`
- **Containerized**: Check `docker compose ps` for running containers

On failure:
- Warn the user: "Could not reach the app at `<entry_point>`. Proceeding anyway — all tests will be flagged `[APP-DOWN]` until connectivity is confirmed."
- Do NOT block execution — continue with plan generation
- Flag all subsequent test results with `[APP-DOWN]` risk marker

### Step 5: Derive Target Slug

Determine a `<target>` slug for naming artifacts (reports, screenshots, logs):

1. If `package.json` exists → use the `name` field
2. Else if entry point is a URL → extract the hostname (strip `www.`)
3. Else → use the current directory name

Sanitize: lowercase, replace spaces/special chars with hyphens, max 30 chars.

### Step 6: Create Output Directory

```bash
mkdir -p notes/qa/
grep -qxF '/notes/' .git/info/exclude 2>/dev/null || echo '/notes/' >> .git/info/exclude
```

All QA artifacts (test plans, reports, screenshots) will be written to `notes/qa/` throughout the session. `notes/` stays out of git. If the repo already keeps QA artifacts somewhere else, use that instead.

### Step 7: Summarize Prerequisites

Print a summary for user confirmation:

```
## QA Session Configuration

- **Mode:** Full QA / MR QA (<branch>)
- **App type:** <detected type>
- **Entry point:** <url/command>
- **Auth:** <method> | none (auth-dependent tests marked [AUTH-RISK])
- **Primary tool:** <Playwright/curl/Bash>
- **Target slug:** <target>
- **App status:** reachable / [APP-DOWN]
- **Output dir:** notes/qa/
```

Wait for user acknowledgment before proceeding to Phase 1 (Feature Catalog).

## Phase 1: Feature Catalog

Build a catalog of testable features before generating a test plan. The approach differs by mode.

---

### Full QA Mode: Feature Catalog

Systematically explore the codebase to identify all testable surfaces. Use Glob and Grep directly for focused searches.

#### Step 1: Discover Routes and Pages

Search for route definitions based on the detected framework:

| Framework | Search Locations |
|-----------|-----------------|
| SvelteKit | `src/routes/**/+page.svelte`, `src/routes/**/+server.ts` |
| Next.js (App Router) | `app/**/page.tsx`, `app/**/route.ts` |
| Next.js (Pages Router) | `pages/**/*.tsx` (exclude `_app`, `_document`) |
| React Router | Grep for `createBrowserRouter`, `<Route`, `<Routes` |
| Vue/Nuxt | `pages/**/*.vue`, `components/**/*.vue` |
| Go CLI | `cmd/*/main.go`, subcommands in `internal/` or `pkg/` |
| Express/Fastify | Grep for `app.get`, `app.post`, `app.put`, `app.delete`, `router.` |

#### Step 2: Discover Interactive Components

Search for components with user interaction:

- **Forms**: Grep for `<form`, `onSubmit`, `handleSubmit`, `useForm`, `v-model`
- **Modals/Dialogs**: Grep for `dialog`, `modal`, `Dialog`, `Modal`, `Sheet`, `Drawer`
- **Dropdowns/Selects**: Grep for `<select`, `Combobox`, `Dropdown`, `Popover`
- **Buttons with handlers**: Grep for `onClick`, `on:click`, `@click`, `hx-post`
- **File uploads**: Grep for `type="file"`, `dropzone`, `upload`

#### Step 3: Discover State Management

- **Svelte**: Look in `src/lib/stores/` for `.ts` files, grep for `writable`, `readable`, `derived`
- **React**: Grep for `createContext`, `useReducer`, `zustand`, `createSlice` (Redux Toolkit), `atom` (Jotai/Recoil)
- **Vue**: Look in `composables/`, `stores/`, grep for `defineStore` (Pinia), `ref(`, `reactive(`
- **Go**: Check for config files, environment variable parsing, flag definitions

#### Step 4: Discover External Integrations

- Grep for `fetch(`, `axios`, `$fetch`, HTTP client usage
- Look for WebSocket connections: `WebSocket`, `socket.io`, `ws`
- Look for database access: `prisma`, `drizzle`, `sql`, `query`, `db.`
- Look for third-party SDK usage: payment processors, auth providers, storage services

#### Step 5: Discover Settings and Configuration Surfaces

- Look for settings/preferences pages or components
- Look for admin panels or dashboards
- Check for feature flags, environment-driven behavior, config files users interact with

#### Step 6: Compile and Present Catalog

Organize findings into a numbered feature catalog. Estimate test count per area based on:
- Number of routes/pages in the area: ~2-3 tests per page
- Number of interactive components: ~1-2 tests per component
- Number of state flows: ~2-4 tests per distinct flow
- Number of integrations: ~2-3 tests per external dependency

Present to the user in this format:

```
## Feature Catalog

1. **<Feature Area>** (~N tests) — brief description of surfaces
2. **<Feature Area>** (~N tests) — brief description of surfaces
3. ...

Reply with the numbers of any areas to skip, or describe what to add.
```

Wait for user response. Apply their edits (removals, additions, reprioritization) and confirm the final catalog before proceeding to Phase 2.

---

### MR QA Mode: Feature Catalog

Scope testing to changed code plus targeted regression areas.

#### Step 1: Determine Base Branch

Resolve the comparison base:

1. If user provided a PR/MR URL → extract the base branch from the PR metadata (use `gh pr view <number> --json baseRefName` for GitHub, or parse from the URL context for GitLab)
2. If user provided a branch name → use `origin/main` as base (or `origin/master` if `main` doesn't exist)
3. If neither → ask the user, defaulting to `origin/main`

#### Step 2: Get Changed Files

Run:
```bash
git diff <base>..HEAD --name-only
```

Filter out non-testable files:
- Exclude: `*.spec.*`, `*.test.*`, `__tests__/`, `.github/`, `ci/`, `.gitlab-ci*`, test fixtures, `*.md`, `*.lock`
- Keep: source files, components, routes, config that affects runtime behavior

#### Step 3: Map Changed Files to Feature Areas

Group changed files into feature areas using these heuristics:

- **Same directory** = same feature area (high confidence)
  - e.g., `src/routes/auth/login/+page.svelte` and `src/routes/auth/login/+page.server.ts` → "Authentication"
- **Shared parent directory** = likely same feature area
  - e.g., `src/lib/components/chat/MessageInput.svelte` and `src/lib/components/chat/MessageList.svelte` → "Chat UI"

For each feature area, assign a test estimate:
- Modified page/route: ~3-4 tests (render, key interactions, edge cases)
- Modified component: ~2-3 tests (render, interaction, state)
- Modified utility/service: ~2 tests (happy path, error path)

#### Step 4: Identify Regression Scope

Check if any changed files are shared utilities or libraries:
- Files in `src/lib/`, `src/utils/`, `pkg/`, `internal/`, `shared/`, `common/`
- Files imported by multiple feature areas (check for common patterns — do NOT attempt full import-graph tracing as it is unreliable across frameworks and dynamic imports)

For each shared file changed, identify likely consumers by:
- Checking the parent directory name for semantic clues
- Grepping for the filename (without extension) in import statements across the codebase
- Limiting to the first 5-10 consumer matches — flag these as suggested regression scope

#### Step 5: Present Scoped Catalog

Present the catalog with regression suggestions clearly separated:

```
## Feature Catalog (MR scope)

Changed features:
1. **<Feature Area>** (~N tests) — <files changed>
2. **<Feature Area>** (~N tests) — <files changed>

Suggested regression scope (shared utilities changed):
3. **<Feature Area>** (~N tests) — may be affected by changes to <shared file>
4. **<Feature Area>** (~N tests) — may be affected by changes to <shared file>

Reply with the numbers of any areas to skip, or describe what to add.
Confirm which regression areas (if any) to include.
```

Wait for user response. The user must explicitly confirm which regression areas to include — do not assume all suggested areas are in scope. Apply their edits and confirm the final catalog before proceeding to Phase 2.

## Phase 2: Test Plan Generation

Generate a structured, hierarchical test plan from the confirmed feature catalog. Save the plan to disk as a persistent artifact before any execution begins.

### Tier Structure and Generation Rules

**Tier 1 — Happy Path (~60-70% of tests):**

- Create one section per feature area from the confirmed catalog.
- Section ID format: `T1.N` where N = the catalog item number.
- Tests cover the primary user flow for each feature — the path a real user takes to accomplish the feature's core purpose.
- Each test has: hierarchical number, descriptive name, steps (imperative voice), and expected outcome (concrete observable).
- Aim for 3-8 tests per feature area depending on complexity.

**Tier 2 — Adversarial (~30-40% of tests):**

Cross-cutting categories, not tied to individual features. Always include all six:

- **T2.1 Security** — XSS via user inputs, injection (SQL/NoSQL/command), auth bypass, CSRF, insecure direct object references, token handling.
- **T2.2 Race Conditions and Timing** — Double-submit, rapid sequential actions, stale state after background updates, optimistic UI rollback.
- **T2.3 Error Handling and Edge Cases** — Network failures mid-operation, malformed data, boundary values, empty states, max-length inputs, Unicode/emoji in text fields.
- **T2.4 Accessibility** — Keyboard navigation for all interactive elements, focus management after dynamic content changes, ARIA labels on custom widgets, screen reader announcement of state changes.
- **T2.5 Responsive / Layout Stress** — Viewport breakpoints (320px, 768px, 1024px, 1440px), text overflow with long content, dynamic content resize, zoom to 200%.
- **T2.6 Cross-Feature Interactions and State Leaks** — Shared state corruption between features, navigation mid-operation, feature A's output as feature B's input, logout/login state persistence.

Generate Tier 2 tests based on the detected tech stack and feature catalog. Not every sub-category will apply to every target — skip categories that have no meaningful attack surface (e.g., skip T2.5 for a CLI tool).

**Tier 3 — Council Suggested:**

Placeholder section. Tests are added here only after the optional council review in Phase 2.5. Generate the section header but leave it empty initially.

### Test Format Specification

Use this EXACT markdown table format per section:

```markdown
### T1.2 Chat UI

| # | Test | Steps | Expected |
|---|------|-------|----------|
| T1.2.1 | Send message | 1. Type "hello" in input 2. Press Enter | Message appears in chat, input clears |
| T1.2.2 | Empty submit | 1. Click send with empty input | No message sent, input stays focused |
```

**Hierarchical numbering: `T{tier}.{section}.{test}`** — e.g., `T1.2.3` = Tier 1, Section 2, Test 3.

This numbering is stable under additions/deletions and enables unambiguous back-references from bug reports.

Rules for test content:
- **Steps** — imperative voice, numbered within the cell. Each step is a single user action.
- **Expected** — a concrete observable outcome. Never "works correctly" or "behaves as expected." State what the user sees, what the DOM contains, or what the API returns.
- **Test names** — short noun phrases or verb phrases describing the scenario, not the expected result.

### Execution Priority

At the end of the test plan, include an ordered list of section IDs for execution order.

Priority rules (apply in order):
1. Critical user flows first — authentication, onboarding, core value proposition.
2. Shared state features before isolated features — test the foundation before the edges.
3. Features with more integrations before standalone features.
4. Adversarial tests (Tier 2) after all happy path tests (Tier 1).
5. Within Tier 2, security first, then race conditions, then the rest.

Format:
```markdown
## Execution Priority
1. T1.1 — Auth is a gate for all other features
2. T1.3 — Core feature, shared state with T1.4
3. T1.2 — Standalone UI
4. T2.1 — Security (always first in adversarial)
5. T2.2 — Race conditions
6. T2.3 — Error handling
7. T2.4 — Accessibility
8. T2.5 — Responsive
9. T2.6 — Cross-feature interactions
```

### Test Plan Template

Write the test plan to `notes/qa/YYYY-MM-DD-<target>-test-plan.md` where `<target>` is the app or feature name (kebab-case, no spaces). Create the `notes/qa/` directory if it does not exist.

Use this canonical template:

```markdown
# QA Test Plan: <target>

**Date:** YYYY-MM-DD
**Target:** <app/feature name>
**Mode:** Full | MR (<branch>)
**App URL:** <url or command>
**Tech Stack:** <detected>

## Prerequisites
- [ ] App running at <url>
- [ ] Auth configured: <method>
- [ ] Test data seeded (if applicable)

## Tier 1: Happy Path

### T1.1 <Feature Area>

| # | Test | Steps | Expected |
|---|------|-------|----------|
| T1.1.1 | ... | ... | ... |

### T1.2 <Feature Area>

| # | Test | Steps | Expected |
|---|------|-------|----------|
| T1.2.1 | ... | ... | ... |

## Tier 2: Adversarial

### T2.1 Security

| # | Test | Steps | Expected |
|---|------|-------|----------|
| T2.1.1 | ... | ... | ... |

### T2.2 Race Conditions and Timing

| # | Test | Steps | Expected |
|---|------|-------|----------|
| T2.2.1 | ... | ... | ... |

### T2.3 Error Handling and Edge Cases

| # | Test | Steps | Expected |
|---|------|-------|----------|
| T2.3.1 | ... | ... | ... |

### T2.4 Accessibility

| # | Test | Steps | Expected |
|---|------|-------|----------|
| T2.4.1 | ... | ... | ... |

### T2.5 Responsive / Layout Stress

| # | Test | Steps | Expected |
|---|------|-------|----------|
| T2.5.1 | ... | ... | ... |

### T2.6 Cross-Feature Interactions and State Leaks

| # | Test | Steps | Expected |
|---|------|-------|----------|
| T2.6.1 | ... | ... | ... |

## Tier 3: Council Suggested

_Populated after council review, if accepted._

## Execution Priority
1. T1.1 — <reason>
2. T1.2 — <reason>
3. ...
4. T2.1 — Security (always first in adversarial)
5. T2.2 — Race conditions
6. ...
```

### Phase 2 Output

After generating the test plan, write it to disk. Then prompt:

> "Test plan saved to `notes/qa/<filename>`. Want a council review of test coverage to suggest edge cases? (Adds ~20 tests targeting seams and gaps)"

Wait for user response before proceeding.

## Phase 2.5: Council Review (Optional)

Execute this phase only if the user accepts the council review offer.

### Council Review Process

1. Read the saved test plan file content.
2. Run the `council` skill on the test plan, keeping the delegates read-only, with this focus directive:

   > "Review this QA test plan for coverage gaps. Focus on: (1) missed edge cases specific to the tech stack, (2) cross-feature state interactions that could leak or corrupt, (3) boundary conditions not covered by existing tests, (4) tech-stack-specific failure modes (e.g., hydration mismatches for SSR, stale closures in React, race conditions in async state). Suggest concrete tests in the same table format."

3. Parse the council's response for suggested tests.
4. Format suggested tests into the `T3.{N}.{test}` numbering scheme, grouping by theme.
5. Insert the formatted tests into the "Tier 3: Council Suggested" section of the saved file.
6. Rewrite the file with the new Tier 3 content.
7. Report what was added:

   > "Added N council-suggested tests to Tier 3 covering: <brief list of themes>. Updated `notes/qa/<filename>`."

### Post-Plan Prompt

After the plan is finalized (with or without council review), prompt:

> "Ready to execute the test plan, or want to review/edit it first?"

Wait for user response. If they want to review/edit, open the file path for them and wait for confirmation to proceed. Do not begin execution until explicitly told to proceed.

## Phase 3: Test Execution

Execute the test plan produced in Phase 2. Dispatch execution using the recipe matching the app type. If the app spans multiple types (e.g., web frontend + API backend), execute each recipe independently and merge results.

### Execution Protocol

These rules apply to ALL execution recipes regardless of app type.

1. **Priority order.** Run tests in the priority order specified by the Execution Priority section of the test plan (Tier 1 first, then Tier 2, then Tier 3).

2. **Per-test cycle.** For each test:
   - Execute the steps exactly as written in the test plan
   - Compare actual result against expected result
   - Log the result as one of: `PASS` | `FAIL` | `SKIP` | `BLOCKED`
   - On `FAIL`: collect evidence (screenshot, console output, error message, response body)

3. **Cascade detection.** If 3 or more consecutive tests fail with the same error signature (e.g., `401 Unauthorized`, `connection refused`, `ECONNREFUSED`, same exception class), mark all remaining tests in that dependent group as `BLOCKED` rather than running them individually. Resume execution with the next independent test group. Report blocked tests separately with the shared failure reason.

4. **Running tally.** Maintain pass/fail/skip/blocked counts throughout execution.

5. **Progress reporting.** Report progress every ~20 tests:
   > "Progress: 40/155 tests (35 pass, 3 fail, 1 skip, 1 blocked)"

6. **Teardown between test sections.** After completing each test section (each `### Section` in the plan):
   - **Web:** Clear cookies and localStorage via `browser_evaluate`, navigate to a blank page
   - **CLI:** Remove temp directories, reset environment variables
   - **API:** Note any resources created (for cleanup summary); reset auth tokens if rotated

7. **SKIP conditions.** Mark a test as `SKIP` (not `FAIL`) when:
   - A prerequisite feature is not deployed or not accessible
   - The test requires infrastructure not available in this environment (e.g., third-party service)
   - The user explicitly excluded it

---

### Recipe: Web App Testing (Playwright MCP)

Use this recipe when testing web applications, SPAs, SSR apps, or any browser-accessible interface.

#### Available Tools

| Tool | Purpose |
|------|---------|
| `browser_navigate` | Go to app URL |
| `browser_snapshot` | Get accessibility tree — **PRIMARY assertion method** (preferred over screenshots) |
| `browser_click` | Interact with buttons, links, tabs, checkboxes |
| `browser_type` | Fill a single text input |
| `browser_fill_form` | Fill multiple form fields at once |
| `browser_evaluate` | Run JS assertions (check console errors, DOM state, store values, localStorage) |
| `browser_console_messages` | Check for runtime errors after each interaction |
| `browser_take_screenshot` | Capture visual evidence of bugs — NOT for assertions |
| `browser_press_key` | Keyboard shortcuts, Tab navigation, Enter to submit, Escape to close |
| `browser_select_option` | Select dropdown options |
| `browser_wait_for` | Wait for async operations to complete (text appearing, text disappearing, or fixed delay) |
| `browser_hover` | Trigger hover states (tooltips, dropdown menus, previews) |
| `browser_drag` | Drag-and-drop interactions |

#### Assertion Patterns

- **Verify text appears:** Use `browser_snapshot` and check the accessibility tree for the expected text or element role.
- **Verify an element is gone:** Use `browser_snapshot` and confirm the element/text is absent from the tree.
- **Check for JS errors:** Use `browser_console_messages` with level `error` after each major interaction. Any unexpected error is a test failure.
- **Check DOM state:** Use `browser_evaluate` with a JS function that returns the value to assert (e.g., `() => document.querySelector('.counter').textContent`).
- **Check localStorage/sessionStorage:** Use `browser_evaluate` with `() => JSON.parse(localStorage.getItem('key'))`.
- **Test keyboard navigation:** Use `browser_press_key` with Tab, Enter, Escape, ArrowDown, ArrowUp. Then `browser_snapshot` to confirm focus moved correctly.
- **Verify visual state (color, visibility, size):** Use `browser_evaluate` with `getComputedStyle()` — do NOT rely on screenshots for assertions.
- **Verify navigation occurred:** After a click, use `browser_evaluate` with `() => window.location.pathname` or check the snapshot for new page content.

#### Example: Single Test Execution

Test: `T1.2.3 — Submit form with valid data shows success message`

```
1. browser_navigate → app URL + "/contact"
2. browser_snapshot → confirm form is present (look for form role, input fields)
3. browser_fill_form → fill Name, Email, Message fields
4. browser_click → click Submit button (ref from snapshot)
5. browser_wait_for → wait for "Message sent" text to appear
6. browser_snapshot → confirm success message is visible, form is cleared or hidden
7. browser_console_messages (level: error) → confirm no JS errors fired
```

Result: If success message found in snapshot and no console errors → `PASS`. If success message missing or JS error present → `FAIL` + capture screenshot as evidence.

#### Web Testing Flow

1. Start by navigating to the app base URL. Confirm it loads (snapshot shows expected content).
2. For each test section, navigate to the relevant page/route.
3. Execute tests sequentially within a section (they may share state like a logged-in session).
4. Between sections: `browser_evaluate` with `() => { localStorage.clear(); sessionStorage.clear(); document.cookie.split(';').forEach(c => document.cookie = c.trim().split('=')[0] + '=;expires=Thu, 01 Jan 1970'); }` then navigate to base URL.
5. If a test requires login, perform login as a setup step (not counted as a test) before the section.

#### Error Evidence Collection (Web)

On any `FAIL`:
1. `browser_take_screenshot` — capture the current visual state
2. `browser_console_messages` (level: error) — capture any JS errors
3. `browser_evaluate` with `() => window.location.href` — record current URL
4. Note the expected vs actual in the result log

---

### Recipe: CLI Testing (Bash)

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

---

### Recipe: API Testing (Bash + curl)

Use this recipe when testing REST APIs, GraphQL endpoints, or any HTTP service.

#### Setup

```bash
BASE_URL="http://localhost:PORT"  # or the actual deployed URL
AUTH_TOKEN="..."                   # if applicable
```

#### Request Patterns

**GET request with assertions:**
```bash
RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/endpoint")
HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')
[ "$HTTP_CODE" = "200" ] && echo "PASS" || echo "FAIL: HTTP $HTTP_CODE"
```

**POST with JSON body:**
```bash
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -d '{"key": "value"}' \
  "$BASE_URL/endpoint")
HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')
```

**JSON field assertion with jq:**
```bash
ACTUAL=$(echo "$BODY" | jq -r '.fieldName')
[ "$ACTUAL" = "expected" ] && echo "PASS" || echo "FAIL: expected 'expected', got '$ACTUAL'"
```

**Check response contains key:**
```bash
echo "$BODY" | jq -e '.requiredField' >/dev/null 2>&1 && echo "PASS" || echo "FAIL: missing .requiredField"
```

**Response time measurement:**
```bash
TIME=$(curl -s -o /dev/null -w "%{time_total}" "$BASE_URL/endpoint")
# TIME is in seconds (e.g., 0.045)
```

#### What to Test

- **Happy path:** Valid request → 200/201 + correct response body
- **Validation errors:** Missing required fields → 400 + descriptive error message
- **Not found:** Invalid resource ID → 404 + appropriate message
- **Auth - missing token:** No Authorization header → 401
- **Auth - invalid token:** Malformed or expired token → 401 or 403
- **Auth - insufficient permissions:** Valid token, wrong role → 403
- **Method not allowed:** Wrong HTTP method → 405
- **Content type:** Send wrong content type → 415 or 400
- **Rate limiting:** If applicable, hit the endpoint rapidly → 429; then wait and retry once to confirm recovery
- **Empty body:** POST with empty body → appropriate error
- **Oversized payload:** Very large request body → 413 or appropriate handling
- **CORS headers:** If browser-facing API, check `Access-Control-Allow-Origin` in response headers
- **Pagination:** If list endpoint, test `?page=1&limit=10`, boundary values, page beyond results
- **Idempotency:** Repeat the same PUT/PATCH → same result, no side effects

#### Rate Limit Handling

```bash
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/endpoint")
if [ "$HTTP_CODE" = "429" ]; then
  sleep 2
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/endpoint")
  [ "$HTTP_CODE" = "200" ] && echo "PASS: recovered after rate limit" || echo "FAIL: still rate limited"
fi
```

#### Cleanup Note

Track any resources created during testing (POST responses with IDs). At the end of the API test section, list them:

> "Created resources during testing: POST /users → id:abc123, POST /items → id:def456. These should be cleaned up or will expire via TTL."

If the API provides DELETE endpoints, clean up created resources after each section.

#### Error Evidence Collection (API)

On any `FAIL`:
- Record the full curl command (sanitize auth tokens in the report)
- Record HTTP status code
- Record response body (first 100 lines if large)
- Record response headers if relevant (e.g., rate limit headers, CORS headers)
- Record request body that was sent

---

## Phase 4: Bug Documentation

For every failed test, document a bug using this exact 8-field format:

### Bug Format

```markdown
### Bug N: <title>

- **Severity:** Critical | Major | Minor | Cosmetic
- **Test:** T{tier}.{section}.{test}
- **Steps to reproduce:**
  1. ...
- **Expected:** ...
- **Actual:** ...
- **Impact:** <user-facing consequence>
- **Root cause:** <technical diagnosis — cite specific file, function, and line>
- **Fix suggestion:** <specific code change or approach>
- **Evidence:** <screenshot path or console output>
```

### Severity Scale

| Level | Definition |
|-------|-----------|
| **Critical** | Feature broken, data loss, security vulnerability |
| **Major** | Feature degraded, workaround exists but poor UX |
| **Minor** | Cosmetic issue affecting usability, edge case failure |
| **Cosmetic** | Visual polish, typo, alignment |

### Root Cause Analysis

This is the skill's key differentiator. For each failed test:

1. **Read the relevant source code** to identify WHY the behavior is wrong — do not guess from symptoms alone
2. **Trace the data flow** from user action to the unexpected result
3. **Name the specific file, function, and line** where the bug originates
4. If the root cause is unclear, write: `Root cause: Unknown — requires deeper investigation` rather than fabricating an explanation
5. DO NOT invent root causes. If you cannot find the source code or trace the issue, say so explicitly

A bug report with an accurate root cause saves 10x the time versus one that just describes symptoms.

### Bug Report Template

Save to `notes/qa/YYYY-MM-DD-<target>-bug-report.md`:

```markdown
# QA Bug Report: <target>

**Date:** YYYY-MM-DD
**Tested on:** <environment>
**Tester:** Claude (qa-tester skill)

## Summary

| Severity | Count |
|----------|-------|
| Critical | 0 |
| Major | 0 |
| Minor | 0 |
| Cosmetic | 0 |
| **Total** | **0** |

## Bugs

### Bug 1: <title>

- **Severity:** ...
- **Test:** T{tier}.{section}.{test}
- **Steps to reproduce:**
  1. ...
- **Expected:** ...
- **Actual:** ...
- **Impact:** ...
- **Root cause:** ...
- **Fix suggestion:** ...
- **Evidence:** ...

## Tests Passed (Highlights)

| Area | Tests | Result |
|------|-------|--------|
| ... | T1.1.1-T1.1.5 | All pass |

## Tests Not Run

| # | Test | Reason |
|---|------|--------|
| T2.5.1 | Viewport 320px | Playwright viewport resize not supported |

## Recommendations

1. **[Critical]** Fix <bug> because <impact>
2. **[Major]** Fix <bug> because <impact>
3. ...
```

Every bug report MUST include these three closing sections:
1. **Tests Passed (Highlights)** — areas that worked well, builds confidence in stable areas
2. **Tests Not Run** — with reasons (tooling limitation, auth-gated, requires physical device, etc.)
3. **Recommendations** — prioritized fix list referencing bug numbers, ordered Critical → Cosmetic

---

## Phase 5: Fix & Verify (Optional)

After completing the bug report, prompt the user:

> "Want me to fix the bugs found? I'll address them by severity (Critical → Cosmetic)."

**Important:** The skill does NOT modify the codebase during Phases 0-4. All phases prior to Phase 5 are strictly read-only. Code changes only happen here, and only with user consent.

If the user accepts:

1. **Fix each bug**, starting with Critical severity and working down
2. **Re-run the specific failed test** to verify the fix works
3. **Run regression tests** on related features (all tests in the same section as the fixed bug)
4. **Update the bug report** — add `**Status:** Fixed in commit \`<sha>\`` to each fixed bug entry
5. **Ask user preference** for commit strategy:
   - One commit per bug (cleaner git blame, easier reverts)
   - Grouped by feature area (fewer commits, logical grouping)

If the user declines, the QA session is complete. Output the bug report path and summary.

---

## Edge Cases

### App Not Running

If the target URL does not respond or returns connection refused:

> "The app doesn't appear to be running at `{url}`. Please start it and try again, or proceed with plan generation only."

Generate the test plan anyway (Phases 0-1) so it's ready when the app is running. Skip Phases 2-4.

### Playwright MCP Not Available

If Playwright MCP tools are not available in the current environment:

> "Playwright MCP tools are not available. Falling back to manual testing guidance — I'll generate the test plan with manual execution steps."

Generate the full test plan with detailed manual steps. For each test, include the exact user actions to perform rather than Playwright commands.

### Auth Fails Mid-Test

If authentication expires during test execution:

1. Pause execution immediately
2. Flag the current test as `SKIP` with reason `[AUTH] Session expired`
3. Prompt the user: "Authentication expired. Please re-authenticate and tell me when ready to continue."
4. Resume from the skipped test once the user confirms

### Very Large Test Plans (>200 tests)

If the generated plan exceeds 200 tests:

> "This plan has N tests. Want to run Tier 1 first, then Tier 2 in a follow-up session?"

Suggest breaking into multiple sessions by tier. Each session produces its own bug report, then merge findings at the end if requested.

### Tests That Cannot Be Automated

Some tests cannot be verified programmatically (e.g., "verify email is received", "check push notification", "confirm SMS arrives"):

- Mark as `MANUAL` in the test plan
- Provide clear step-by-step instructions for the user to verify themselves
- Include what to look for (expected content, timing, format)
- After manual tests, ask the user for pass/fail results to include in the report

### App Crashes During Testing

If the application crashes or becomes unresponsive during test execution:

1. **Capture evidence** — take a screenshot, collect console output/errors
2. **Note the exact test** that caused or preceded the crash
3. **Wait 10 seconds**, then attempt to reload the application
4. If the app recovers, continue with the next test section (skip remaining tests in the crashed section)
5. If the app does not recover, pause and prompt the user
6. Document the crash as a Critical severity bug in the report

---

## Skill Interactions

- **qa-tester is terminal** — it does not auto-invoke other skills
- Can be invoked after brainstorming (user designs a feature, then QA tests it)
- Can be invoked on merge request branches to validate changes before merge
- After Phase 5 fixes, suggest: "Consider running `/code-review` on the bug fixes before committing."
