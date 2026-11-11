# Test Plan Template

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
