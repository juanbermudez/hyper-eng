---
description: Run comprehensive code review with domain sub-agents, producing a review artifact in project resources and optional fix tasks.
argument-hint: "[project-slug] or [project-slug/task-id] or [task-id]"
---

Use the **hyper** skill to execute the review workflow.

## Execute Workflow

Load the VM specification from `skills/hyper/prose.md` and execute the workflow at `commands/hyper-review.prose` with:

```
input target_id: "$ARGUMENTS"
```

The workflow will guide you through:

1. **Initialize** - Set up workspace and run ID
2. **Resolve Target** - Determine project/task scope
3. **Scope Analysis** - Identify files to review
4. **Parallel Reviews** - Spawn domain reviewers
5. **Synthesis** - Write review report artifact
6. **Fix Tasks (optional)** - Auto-create fix tasks based on settings

## State Management

Execution state persists in:
```
$HYPER_WORKSPACE_ROOT/.prose/runs/{run-id}/
├── state.md           # Execution position
├── bindings/          # Variable values
└── agents/            # Agent memory
```

## Review Artifacts

Review reports are written to:
```
$HYPER_WORKSPACE_ROOT/projects/{project-slug}/resources/review-{run-id}.md
```

## Auto-Create Fix Tasks

Configure auto-create behavior in:
```
$HYPER_WORKSPACE_ROOT/settings/commands/hyper-review.yaml
```
