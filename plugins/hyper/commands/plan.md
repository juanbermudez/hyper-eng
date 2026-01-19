---
description: Create a comprehensive specification with two approval gates - first validating direction after research, then approving the full spec before task creation. Uses local $HYPER_WORKSPACE_ROOT/ directory for all artifacts.
argument-hint: "[feature or requirement description]"
---

Use the **hyper-prose** skill to execute the planning workflow.

## Execute Workflow

Load the VM specification from `skills/hyper-prose/prose.md` and execute the workflow at `commands/hyper-plan.prose` with:

```
input feature: "$ARGUMENTS"
```

The workflow will guide you through:

1. **Initialize** - Set up workspace and run ID
2. **Research Phase** - Spawn 4 parallel research sub-agents
3. **Direction Gate** - Get early approval before detailed spec
4. **Specification** - Create detailed technical PRD
5. **Approval Gate** - Wait for human approval
6. **Task Breakdown** - Create task files after approval

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

The workflow uses `${CLAUDE_PLUGIN_ROOT}/binaries/hyper` for all file operations.

## Status Flow

```
planned → todo → in-progress → qa → completed
```
