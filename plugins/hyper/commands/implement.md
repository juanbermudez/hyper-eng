---
description: Implement tasks from $HYPER_WORKSPACE_ROOT/ - pass project-slug for FULL project implementation, or project-slug/task-id for single task
argument-hint: "[project-slug] (full project) or [project-slug/task-id] (single task)"
---

Use the **hyper-implementation** skill to implement:

$ARGUMENTS

## Modes

**Single Task Mode** (`project-slug/task-id`):
- Implements one specific task
- Updates task status through workflow
- Runs verification gates
- Commits on completion

**Full Project Mode** (`project-slug`):
- Implements ALL incomplete tasks in dependency order
- Resolves task dependencies automatically
- Reports progress after each task
- Moves project to QA when all tasks complete

## Workflow Summary

1. **Read task/project** - Understand requirements from $HYPER_WORKSPACE_ROOT/ files
2. **Check dependencies** - Ensure blocking tasks are complete
3. **Update status** - Mark task `in-progress`
4. **Implement** - Make code changes following spec
5. **Verify** - Run lint, typecheck, test, build gates
6. **Complete** - Mark `complete` only when ALL gates pass
7. **Commit** - Git commit with conventional format

## Verification Gates

All must pass before marking complete:
- Lint: `npm run lint` / `cargo clippy` / `ruff check`
- Typecheck: `tsc --noEmit` / `cargo check` / `mypy`
- Tests: `npm test` / `cargo test` / `pytest`
- Build: `npm run build` / `cargo build`

## Status Flow

```
todo → in-progress → qa → complete
                      ↓
              (if fail) → in-progress (fix) → qa
```

## CLI Integration

```bash
hyper task update "task-id" --status "in-progress"
hyper task update "task-id" --status "complete"
```

## Git Workflow

- Branch: `feat/{project-slug}` or `feat/{project-slug}/{task-id}`
- Commit format: `{type}({scope}): {description}`
- Include `Task: {task-id}` in commit body

**Activity tracking**: Session ID automatically captured on all $HYPER_WORKSPACE_ROOT/ modifications.
