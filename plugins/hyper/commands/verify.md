---
description: Run comprehensive automated and manual verification, creating fix tasks in $HYPER_WORKSPACE_ROOT/ for failures and looping until all checks pass
argument-hint: "[project-slug/task-id]"
---

Use the **hyper-verification** skill to run verification for:

$ARGUMENTS

## Verification Process

1. **Slop Detection** - AI-specific quality checks (hallucinated imports, secrets, debug statements)
2. **Automated Checks** - Lint, typecheck, test, build
3. **Manual Verification** - Browser testing via web-app-debugger agent
4. **Compound Phase** - Capture learnings in docs/solutions/

## Verification Loop

```
slop detection
    ↓ (if fail → create fix task → STOP)
automated checks (lint, typecheck, test, build)
    ↓ (if fail → create fix task → STOP)
manual verification (browser testing)
    ↓ (if fail → create fix task → STOP)
completion → compound phase
```

## Automated Checks

| Check | Command | Required |
|-------|---------|----------|
| Lint | `npm run lint` / `cargo clippy` / `ruff check` | Yes |
| Typecheck | `tsc --noEmit` / `cargo check` / `mypy` | Yes |
| Test | `npm test` / `cargo test` / `pytest` | Yes |
| Build | `npm run build` / `cargo build` | Yes |

## Browser Testing

Uses web-app-debugger agent with Claude Code Chrome extension for:
- Screenshots at each step
- DOM inspection
- Console log verification
- UI interaction testing

## Fix Task Creation

When checks fail, creates fix tasks automatically:
- Includes error output and root cause analysis
- Sets priority to urgent
- Links to parent task
- Includes re-verification instructions

## Completion Criteria

**Only mark complete when ALL checks pass:**
- ✓ Slop detection passed
- ✓ All automated checks passed
- ✓ All manual verification steps passed

## CLI Integration

```bash
# Update task status
hyper task update "task-id" --status "qa"
hyper task update "task-id" --status "complete"
```

## Compound Phase

After successful verification, extracts learnings:
- Bug fixes → `docs/solutions/bugs/`
- Patterns → `docs/solutions/patterns/`
- Gotchas → `docs/solutions/gotchas/`

**Activity tracking**: Session ID automatically captured on all $HYPER_WORKSPACE_ROOT/ modifications.
