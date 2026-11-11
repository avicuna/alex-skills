# Bug Report Template

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
