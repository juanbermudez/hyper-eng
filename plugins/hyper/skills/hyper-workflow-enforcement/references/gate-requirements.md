# Gate Requirements

Verification gates that must pass before completion.

## Gate Types

### Automated Gates

| Gate | Command Pattern | Required |
|------|-----------------|----------|
| Lint | `npm run lint`, `pnpm lint`, `cargo clippy` | Yes |
| Typecheck | `tsc --noEmit`, `cargo check`, `mypy` | Yes |
| Test | `npm test`, `pnpm test`, `cargo test`, `pytest` | Yes |
| Build | `npm run build`, `pnpm build`, `cargo build` | Yes |

### Manual Gates

| Gate | Method | When Required |
|------|--------|---------------|
| Browser | web-app-debugger agent | UI changes |
| Visual | Screenshot comparison | Design changes |
| Performance | Lighthouse, profiling | Performance work |
| Security | Manual review | Auth/security changes |

## Gate Execution Order

Run gates in this order (stop on first failure):

1. **Lint** - Quick feedback on code style
2. **Typecheck** - Catch type errors
3. **Test** - Verify behavior
4. **Build** - Confirm production build
5. **Browser** - Visual/interactive verification (if UI)

## Gate Results Format

Record in task file:

```markdown
## Verification Results

### Run: 2026-01-15 10:30 UTC

| Gate | Status | Duration | Notes |
|------|--------|----------|-------|
| Lint | ✓ Pass | 2.1s | |
| Typecheck | ✓ Pass | 4.8s | |
| Tests | ✓ Pass | 12.4s | 47 tests |
| Build | ✓ Pass | 18.2s | |
| Browser | ✓ Pass | manual | Console clean |

**Result**: PASS - Ready for complete status
```

## Gate Failure Handling

### On Lint Failure

```markdown
### Lint Failure

**Command**: `npm run lint`
**Exit Code**: 1

**Errors**:
```
src/components/Button.tsx:15:3
  error  'unused' is assigned a value but never used
```

**Action**: Fix immediately, re-run all gates
```

### On Test Failure

```markdown
### Test Failure

**Command**: `npm test`
**Failed**: 2 of 47

**Failures**:
```
FAIL src/utils/format.test.ts
  ● formatDate › handles null input
    Expected: "N/A"
    Received: null
```

**Action**: Fix test or implementation, re-run from lint
```

### On Build Failure

```markdown
### Build Failure

**Command**: `npm run build`
**Exit Code**: 1

**Error**:
```
Module not found: Can't resolve './missing-module'
```

**Action**: Fix import, re-run from lint
```

## Retry Policy

| Gate | Retry? | When |
|------|--------|------|
| Lint | No | Fix immediately |
| Typecheck | No | Fix immediately |
| Test | Once | May be flaky |
| Build | Once | May be transient |
| Browser | Yes | Network issues |

## QA Status Rules

### Moving TO QA

- All implementation work complete
- Ready to run verification gates
- Update status: `in-progress → qa`

### Moving FROM QA

**To complete** (success):
- ALL automated gates pass
- Manual gates pass (if required)
- Update status: `qa → complete`

**To in-progress** (failure):
- ANY gate fails
- Fix the issue
- Update status: `qa → in-progress`
- After fix: `in-progress → qa` (re-run ALL gates)

## Project-Level Gates

When all tasks are complete, project enters QA with additional checks:

| Gate | Description |
|------|-------------|
| Integration | Cross-feature testing |
| Regression | Existing features still work |
| Documentation | README/CHANGELOG updated |
| Final Build | Full production build |

Project only moves to `completed` when project-level gates pass.
