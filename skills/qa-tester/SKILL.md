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

Read the one file for the selected mode and follow it:

- **Full QA Mode** → `references/catalog-full.md`
- **MR QA Mode** → `references/catalog-mr.md`

Both end by presenting the catalog and waiting for the user to confirm it before Phase 2.

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

Use the canonical template in `references/test-plan-template.md`.

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

### Recipes

Read only the recipe for the app type under test:

- **Web app** (Playwright MCP) → `references/recipe-web.md`
- **CLI** (Bash) → `references/recipe-cli.md`
- **API** (Bash + curl) → `references/recipe-api.md`

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

Use the template in `references/bug-report-template.md`.

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

When the app isn't running, Playwright MCP is missing, auth fails mid-test, the plan runs past 200 tests, a test can't be automated, or the app crashes during testing, read `references/edge-cases.md` for the handling.

---

## Skill Interactions

- **qa-tester is terminal** — it does not auto-invoke other skills
- Can be invoked after brainstorming (user designs a feature, then QA tests it)
- Can be invoked on merge request branches to validate changes before merge
- After Phase 5 fixes, suggest: "Consider running `/code-review` on the bug fixes before committing."
