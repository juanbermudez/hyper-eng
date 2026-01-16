# Verification Gates

All verification gates must pass before marking a task complete.

## Automated Gates

### 1. Lint

```bash
# Run project linter
npm run lint        # Node.js
pnpm lint           # pnpm
yarn lint           # Yarn
cargo clippy        # Rust
```

**Must pass**: No errors (warnings acceptable)

### 2. Type Check

```bash
# Run type checker
npm run typecheck   # Node.js with tsc
tsc --noEmit        # Direct TypeScript
cargo check         # Rust
mypy .              # Python
```

**Must pass**: No type errors

### 3. Tests

```bash
# Run test suite
npm test            # Node.js
pnpm test           # pnpm
pytest              # Python
cargo test          # Rust
```

**Must pass**: All tests pass (including new tests)

### 4. Build

```bash
# Verify build succeeds
npm run build       # Node.js
pnpm build          # pnpm
cargo build         # Rust
```

**Must pass**: Build completes without errors

## Gate Execution Order

Run gates in this order (stop on first failure):

1. Lint - Quick feedback on style issues
2. Type Check - Catch type errors
3. Tests - Verify behavior
4. Build - Confirm production build works

## Manual Verification

For UI changes, also verify:

### Browser Testing

Use web-app-debugger agent for:
- [ ] Visual inspection matches spec
- [ ] No console errors
- [ ] Interactive elements work
- [ ] Responsive design (mobile, tablet, desktop)

### Accessibility

- [ ] Keyboard navigation works
- [ ] Screen reader compatible
- [ ] Color contrast adequate
- [ ] Focus indicators visible

### Edge Cases

From task acceptance criteria:
- [ ] [Edge case 1 from spec]
- [ ] [Edge case 2 from spec]

## Gate Results

Document results in task file:

```markdown
## Verification Results

### Automated Gates
| Gate | Status | Notes |
|------|--------|-------|
| Lint | ✓ Pass | |
| Typecheck | ✓ Pass | |
| Tests | ✓ Pass | 15 tests added |
| Build | ✓ Pass | |

### Manual Verification
| Check | Status | Notes |
|-------|--------|-------|
| Visual Match | ✓ Pass | Matches spec |
| Console | ✓ Pass | No errors |
| Responsive | ✓ Pass | Mobile tested |

### Summary
All gates passed. Ready for status: complete
```

## On Failure

If any gate fails:

### Step 1: Document Failure

```markdown
### Gate Failure: [Gate Name]

**Error**:
```
[exact error message]
```

**Analysis**: [what went wrong]
**Fix Plan**: [how to fix]
```

### Step 2: Fix Issue

Apply fix based on error.

### Step 3: Re-run Gate

Re-run the failed gate.

### Step 4: Re-run All Gates

After fix, re-run ALL gates to ensure no regressions.

## Retry Limits

If a gate fails 3 times:
1. Stop attempting fixes
2. Document all attempts
3. Ask user for guidance
4. Consider if approach is wrong

## Status Flow

```
in-progress
    │
    ▼
  [Run Gates]
    │
    ├── All Pass ────► complete
    │
    └── Any Fail ────► in-progress (fix and retry)
```

## Skip Conditions

Gates may be skipped only if:
- Task explicitly excludes them in acceptance criteria
- Project has custom gate configuration
- User explicitly approves skip

Never skip gates without explicit approval.
