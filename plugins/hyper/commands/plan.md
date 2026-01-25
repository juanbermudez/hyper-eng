---
description: Create a comprehensive specification with two approval gates - first validating direction after research, then approving the full spec before task creation.
argument-hint: "[feature or requirement description]"
workflow: workflows/hyper-plan.prose
---

Use the **hypercraft** skill to execute the planning workflow.

## Execute Workflow

Load the hypercraft skill (includes prose VM) and execute `commands/workflows/hyper-plan.prose` with:

```
input feature: "$ARGUMENTS"
```

The workflow will guide you through:

1. **Initialize** - Set up workspace and run ID
2. **Research Phase** - Spawn 4 parallel research sub-agents (uses QFS for codebase search)
3. **Direction Gate** - Get early approval before detailed spec
4. **Specification** - Create detailed technical PRD
5. **Approval Gate** - Wait for human approval
6. **Task Breakdown** - Create task files after approval

## Search Strategy

Research agents leverage **QFS** for fast, ranked codebase searches:

```bash
hypercraft find "pattern" --json
```

See `/hyper:research` for detailed search options.

## State Management

Execution state persists in:
```
$HYPER_WORKSPACE_ROOT/.prose/runs/{run-id}/
├── state.md           # Execution position
├── bindings/          # Variable values
└── agents/            # Agent memory
```

This enables resumption if interrupted.

## CLI Integration

The workflow uses `${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft` for all file operations.

## Status Flow

```
planned → todo → in-progress → qa → completed
```
