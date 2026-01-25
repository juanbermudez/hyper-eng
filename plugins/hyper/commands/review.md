---
description: Run comprehensive code review with domain sub-agents, producing a review artifact in project resources and optional fix tasks.
argument-hint: "[project-slug] or [project-slug/task-id] or [task-id]"
workflow: workflows/hyper-review.prose
---

Use the **hypercraft** skill to execute the review workflow.

## Execute Workflow

Load the hypercraft skill (which includes prose VM) and execute the workflow at `workflows/hyper-review.prose` with:

```
input target_id: "$ARGUMENTS"
```

The workflow will guide you through:

1. **Initialize** - Set up workspace and run ID
2. **Resolve Target** - Determine project/task scope
3. **Scope Analysis** - Identify files to review (uses QFS for discovery)
4. **Parallel Reviews** - Spawn domain reviewers
5. **Synthesis** - Write review report artifact
6. **Fix Tasks (optional)** - Auto-create fix tasks based on settings

## File Discovery

The scope analysis phase uses **QFS** for fast file discovery:

```bash
# Find files related to feature
hypercraft find "authentication" --json

# Search for patterns to review
hypercraft find "error handling" --limit 50 --json
```

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
