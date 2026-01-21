---
description: Run comprehensive automated and manual verification, creating fix tasks in $HYPER_WORKSPACE_ROOT/ for failures and looping until all checks pass
argument-hint: "[project-slug/task-id]"
---

Use the **hyper** skill to execute the verification workflow.

## Execute Workflow

Load the VM specification from `skills/hyper/prose.md` and execute the workflow at `commands/hyper:verify.prose` with:

```
input target_id: "$ARGUMENTS"
```

The workflow will guide you through:

1. **Initialize** - Detect target type (task or project), set up run ID
2. **Load Target** - Read task/project file, check current status
3. **Update Status** - Move to QA phase
4. **Run Verification** - Execute verification block with retry logic
5. **Handle Results** - Mark complete or revert to in-progress

## Verification Layers

| Layer | Description |
|-------|-------------|
| **Automated Checks** | Lint, typecheck, test, build |
| **Hypercraft State** | Validate framework state files |
| **UI Verification** | Tauri MCP tools (connect, screenshot, verify) |
| **Sentry Logging** | Track all results for observability |

## Verification Block

Uses reusable block from `blocks/verification.prose`:
- `verify-implementation` - Single verification pass
- `verify-with-retry` - Up to 3 attempts with fixes

## State Management

```
$HYPER_WORKSPACE_ROOT/.prose/runs/{run-id}/
├── state.md
└── bindings/
    └── verification_result.md
```

## Status Flow

```
in-progress → qa → complete (if pass)
              qa → in-progress (if fail, to fix)
```
