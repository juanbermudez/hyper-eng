# Automated Checks

Run automated verification gates in order.

## Gate Order

1. **Lint** - Quick feedback on style issues
2. **Type Check** - Catch type errors
3. **Tests** - Verify behavior
4. **Build** - Confirm production build

Stop on first failure, fix, then restart from beginning.

## Node.js / TypeScript

### Lint

```bash
# npm
npm run lint

# pnpm
pnpm lint

# yarn
yarn lint

# direct
eslint . --ext .ts,.tsx
```

**Expected**: Exit code 0, no errors

### Type Check

```bash
# npm scripts
npm run typecheck

# direct
tsc --noEmit

# Next.js
npx next lint --strict
```

**Expected**: Exit code 0, no type errors

### Tests

```bash
# npm
npm test

# direct
jest
vitest
```

**Expected**: All tests pass

### Build

```bash
# npm
npm run build

# Next.js
npx next build

# Vite
npx vite build
```

**Expected**: Build completes without errors

## Rust

### Lint

```bash
cargo clippy -- -D warnings
```

### Type Check

```bash
cargo check
```

### Tests

```bash
cargo test
```

### Build

```bash
cargo build --release
```

## Python

### Lint

```bash
ruff check .
# or
flake8 .
```

### Type Check

```bash
mypy .
# or
pyright
```

### Tests

```bash
pytest
```

### Build

```bash
python -m build
```

## Gate Results Template

```markdown
## Automated Verification

| Gate | Command | Status | Duration |
|------|---------|--------|----------|
| Lint | `npm run lint` | ✓ Pass | 2.1s |
| Typecheck | `npm run typecheck` | ✓ Pass | 4.8s |
| Tests | `npm test` | ✓ Pass | 15.2s |
| Build | `npm run build` | ✓ Pass | 22.4s |
```

## Handling Failures

### Lint Failure

```markdown
### Lint Failure

**Command**: `npm run lint`
**Exit Code**: 1

**Errors**:
```
src/components/Button.tsx:15:3
  error  'unused' is assigned a value but never used  @typescript-eslint/no-unused-vars
```

**Fix**: Remove unused variable on line 15
```

### Type Error

```markdown
### Typecheck Failure

**Command**: `tsc --noEmit`
**Exit Code**: 1

**Errors**:
```
src/lib/api.ts:23:15 - error TS2345: Argument of type 'string' is not assignable to parameter of type 'number'.
```

**Fix**: Cast to number or change parameter type
```

### Test Failure

```markdown
### Test Failure

**Command**: `npm test`
**Failed Tests**: 2

**Failures**:
```
FAIL src/components/Button.test.tsx
  ● Button › renders correctly
    expect(received).toBe(expected)
    Expected: "Submit"
    Received: "Click me"
```

**Fix**: Update Button default text or test expectation
```

### Build Failure

```markdown
### Build Failure

**Command**: `npm run build`
**Exit Code**: 1

**Errors**:
```
Error: Cannot find module './missing'
```

**Fix**: Add missing module or fix import path
```

## Retry Policy

| Failure Type | Retry? | Action |
|--------------|--------|--------|
| Lint error | No | Fix immediately |
| Type error | No | Fix immediately |
| Test failure | Once | May be flaky |
| Build error | Once | May be transient |
| Timeout | Yes | Increase timeout |
