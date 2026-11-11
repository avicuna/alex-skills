# Edge Cases

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
