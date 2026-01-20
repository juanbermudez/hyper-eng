# Learnings Schema Reference

Complete schema for learnings documentation.

## File Location

```
$HYPER_WORKSPACE_ROOT/projects/{project-slug}/resources/learnings.md
```

## Document Structure

```markdown
# Learnings: {Project Title}

[Learning entries in reverse chronological order]
```

## Learning Entry Schema

### Required Fields

```yaml
title:
  type: string
  format: "[Category]: [Title]"
  example: "Testing: MSW Setup Race Condition"

date:
  type: date
  format: YYYY-MM-DD

session_id:
  type: string
  format: "{workflow}-{timestamp}-{uuid}"
  example: "impl-20260120-143052-a1b2c3d4"

trigger_type:
  type: enum
  values:
    - tool_error
    - user_correction
    - self_correction
    - multiple_retries
    - manual

severity:
  type: enum
  values:
    - critical
    - high
    - medium
    - low

context:
  type: markdown
  description: What you were trying to accomplish

what_happened:
  type: markdown
  description: The specific issue or insight

root_cause:
  type: markdown
  description: Why this happened

solution:
  type: markdown
  description: How it was resolved

future_prevention:
  type: markdown
  description: Actionable guidance for future sessions

tags:
  type: array[string]
  format: "#tag"
  example: ["#testing", "#async", "#ci"]
```

### Optional Fields

```yaml
related:
  type: array[link]
  description: Links to related learnings

code_before:
  type: codeblock
  description: Code that caused the issue

code_after:
  type: codeblock
  description: Fixed code

files_affected:
  type: array[string]
  description: File paths involved

error_message:
  type: string
  description: Exact error message

environment:
  type: object
  properties:
    os: string
    node_version: string
    framework_version: string
```

## Category Taxonomy

### Primary Categories

| Category | Description | Example |
|----------|-------------|---------|
| Testing | Test setup, assertions, mocking | MSW setup issues |
| Configuration | Config files, environment | ENV variable missing |
| Types | TypeScript, type errors | Generic inference |
| Performance | Speed, memory, optimization | N+1 queries |
| Integration | External services, APIs | Auth token refresh |
| Build | Compilation, bundling | Import resolution |
| Runtime | Execution errors | Undefined reference |
| Workflow | Process, tooling | Git branch issues |

### Subcategories

```yaml
Testing:
  - Unit
  - Integration
  - E2E
  - Mocking
  - Setup

Configuration:
  - Environment
  - Build
  - Runtime
  - Deployment

Types:
  - Inference
  - Generics
  - Declarations
  - Compatibility

Performance:
  - Database
  - Rendering
  - Network
  - Memory
```

## Tag Conventions

### Technology Tags

```yaml
languages:
  - "#typescript"
  - "#javascript"
  - "#rust"
  - "#python"

frameworks:
  - "#react"
  - "#nextjs"
  - "#tauri"
  - "#tailwind"

tools:
  - "#vitest"
  - "#msw"
  - "#git"
  - "#pnpm"
```

### Pattern Tags

```yaml
patterns:
  - "#async"
  - "#race-condition"
  - "#caching"
  - "#error-handling"
  - "#state-management"
```

### Severity Tags

```yaml
severity:
  - "#critical"
  - "#important"
  - "#gotcha"
  - "#tip"
```

## Example Complete Entry

```markdown
## Testing: MSW Handler Registration Race

**Date**: 2026-01-20
**Session ID**: impl-20260120-143052-a1b2c3d4
**Trigger Type**: multiple_retries
**Severity**: medium

### Context
Implementing integration tests for the API client module. Tests needed to mock HTTP calls using Mock Service Worker.

### What Happened
Tests passed locally but failed intermittently in CI. The error showed:
```
Error: No request handler found for GET /api/users
```

Investigation showed handlers were sometimes not registered when the first test ran.

### Root Cause
MSW's `server.listen()` is asynchronous, but the test setup used synchronous `beforeAll`:

```typescript
// Problem: synchronous setup
beforeAll(() => {
  server.listen();  // Doesn't wait for listen to complete
});
```

The first test would sometimes execute before the server was ready.

### Solution
Made the setup async and added explicit server ready check:

```typescript
// Solution: async setup with verification
beforeAll(async () => {
  await server.listen();
});

afterAll(() => {
  server.close();
});
```

### Future Prevention
1. Always use `async/await` with MSW server setup
2. Run CI tests multiple times locally before pushing
3. Add explicit handler verification in test setup if issues persist

### Related
- [compound-docs: MSW Best Practices](../../docs/solutions/testing/msw-setup.md)

### Tags
#testing #msw #async #race-condition #ci
```

## Validation Rules

### Entry Completeness

A learning entry is valid if:

- [ ] Title follows `[Category]: [Title]` format
- [ ] Date is valid ISO date
- [ ] Session ID matches pattern
- [ ] Trigger type is valid enum
- [ ] Severity is valid enum
- [ ] Context is non-empty (min 20 characters)
- [ ] What Happened is non-empty (min 50 characters)
- [ ] Root Cause is non-empty (min 30 characters)
- [ ] Solution is non-empty (min 30 characters)
- [ ] Future Prevention is non-empty (min 20 characters)
- [ ] At least 2 tags provided

### Quality Guidelines

Good learnings have:

- ✅ Exact error messages (copy-paste)
- ✅ Code examples (before/after)
- ✅ Specific file references
- ✅ Technical explanation of "why"
- ✅ Actionable prevention steps
- ✅ Relevant tags for searchability

Avoid:

- ❌ Vague descriptions ("something was wrong")
- ❌ Missing code examples
- ❌ Generic prevention ("be more careful")
- ❌ Too few tags (hard to find later)
