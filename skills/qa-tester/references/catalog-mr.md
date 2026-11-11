# MR QA Mode: Feature Catalog

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
