---
name: hyper-verification
description: This skill should be used when the user asks to "verify implementation", "run tests", "check quality", or mentions QA, testing, or verification. Runs comprehensive verification including automated checks and browser testing.
version: 1.0.0
model: sonnet
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
  - Task
includes:
  - hyper-craft
  - hyper-cli
---

# Hyper Verification Skill

Comprehensive verification and quality assurance with automated checks and browser testing. Requires `hyper-craft` as the core skill.

## Overview

This skill guides verification through:

1. **Automated Checks** - Lint, typecheck, test, build
2. **Manual Verification** - Scenario-based testing
3. **Browser Testing** - UI verification with web-app-debugger
4. **Status Update** - Based on results

## Reference Documents

- [Automated Checks](./references/automated-checks.md) - Command-line verification
- [Test Patterns](./references/test-patterns.md) - Writing and organizing tests
- [Browser Testing](./references/browser-testing.md) - Visual and interactive testing
- [Manual Verification](./references/manual-verification.md) - Scenario-based checks

## Workflow

### Step 1: Determine Verification Scope

From task file, identify:
- Required automated checks
- Manual verification scenarios
- Whether UI testing is needed

### Step 2: Run Automated Checks

<hyper-embed file="references/automated-checks.md" fallback="
Run standard checks:
- `npm run lint`
- `npm run typecheck`
- `npm test`
- `npm run build`
" />

### Step 3: Manual Verification

<hyper-embed file="references/manual-verification.md" />

### Step 4: Browser Testing (if UI changes)

<hyper-embed file="references/browser-testing.md" />

### Step 5: Update Status

Based on results:

**All pass**:
```bash
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft task update \
  "${TASK_ID}" --status "complete"
```

**Any fail**:
- Document failures
- Create fix tasks if needed
- Keep status as `in-progress` or `qa`
- Re-run verification after fixes

## Verification Commands by Project Type

### Node.js / TypeScript

```bash
npm run lint        # or pnpm lint / yarn lint
npm run typecheck   # or tsc --noEmit
npm test            # or jest / vitest
npm run build       # or next build / vite build
```

### Rust

```bash
cargo clippy        # Lint
cargo check         # Type check
cargo test          # Tests
cargo build         # Build
```

### Python

```bash
ruff check .        # Lint
mypy .              # Type check
pytest              # Tests
python -m build     # Build
```

## Status Flow

```
qa (verification phase)
    │
    ├── All Pass ────► complete
    │
    └── Any Fail ────► in-progress (fix first)
                           │
                           ▼
                       [Apply Fix]
                           │
                           ▼
                          qa (re-verify)
```

## Verification Results Format

Document in task file:

```markdown
## Verification Results

### Run: [DATE] [TIME]

#### Automated Gates
| Gate | Status | Duration | Notes |
|------|--------|----------|-------|
| Lint | ✓ Pass | 2.3s | |
| Typecheck | ✓ Pass | 5.1s | |
| Tests | ✓ Pass | 12.4s | 47 tests |
| Build | ✓ Pass | 18.2s | |

#### Manual Verification
| Scenario | Status | Notes |
|----------|--------|-------|
| Happy path | ✓ Pass | |
| Error case | ✓ Pass | |

#### Browser Testing
| Check | Status | Notes |
|-------|--------|-------|
| Visual | ✓ Pass | |
| Console | ✓ Pass | |

### Summary
**Result**: PASS
**Ready for**: complete status
```

## On Failure

### Step 1: Document Failure

```markdown
### Failure: [Gate/Scenario Name]

**Error**:
```
[exact output]
```

**Root Cause**: [analysis]
**Fix Required**: [description]
```

### Step 2: Determine Fix Approach

| Severity | Action |
|----------|--------|
| Minor (typo, lint) | Fix inline |
| Medium (logic bug) | Fix and re-test |
| Major (design flaw) | Create fix task |

### Step 3: After Fix

Re-run ALL verification to ensure no regressions.

## Best Practices

- Run verification frequently during implementation
- Don't mark complete until ALL checks pass
- Document all verification results
- Create fix tasks for complex issues
- Re-run full verification after any fix

## Error Handling

| Condition | Action |
|-----------|--------|
| Gate timeout | Retry once, then investigate |
| Flaky test | Document and investigate root cause |
| Environment issue | Fix environment first |
| 3+ failures | Stop and ask for guidance |

## Includes

This skill depends on:

- **hyper-cli** - CLI command patterns
