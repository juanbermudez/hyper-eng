---
description: Implement tasks from $HYPER_WORKSPACE_ROOT/ - pass project-slug for FULL project implementation, or project-slug/task-id for single task
argument-hint: "[project-slug] (full project) or [project-slug/task-id] (single task)"
---

Use the **hyper** skill to execute the implementation workflow.

## Execute Workflow

Load the VM specification from `skills/hyper/prose.md` and execute the workflow at `commands/hyper-implement.prose` with:

```
input task_id: "$ARGUMENTS"
```

The workflow will guide you through:

1. **Initialize** - Set up workspace, run ID, and git branch
2. **Load Task** - Read task spec and project context
3. **Analysis** - Understand codebase patterns before implementing
4. **Implementation Loop** - Write code with review cycles (max 3 attempts)
5. **QA Phase** - Run automated and manual verification
6. **Completion** - Mark complete and commit changes

## Modes

**Single Task Mode** (`project-slug/task-id`):
- Implements one specific task
- Updates task status through workflow

**Full Project Mode** (`project-slug`):
- Implements ALL incomplete tasks in dependency order
- Reports progress after each task

## State Management

Execution state persists in:
```
$HYPER_WORKSPACE_ROOT/.prose/runs/{run-id}/
├── state.md           # Execution position
├── bindings/          # Variable values (task_spec, analysis, etc.)
└── agents/            # Agent memory (impl-captain, executor, reviewer)
```

## Verification Gates

All must pass before marking complete:
- Lint, Typecheck, Tests, Build
- UI verification via Tauri MCP (if applicable)

## Status Flow

```
todo → in-progress → qa → complete
                      ↓
              (if fail) → in-progress (fix) → qa
```
