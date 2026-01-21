---
name: hyper-workflow-enforcement
description: This skill enforces workflow status transitions and gate requirements for projects and tasks. It validates that status changes follow allowed paths and ensures quality gates are met before completion.
version: 1.0.0
system: true
allowed-tools:
  - Read
  - Bash
includes:
  - hyper-cli
---

# Hyper Workflow Enforcement

System skill that enforces status transitions and verification gates.

## Overview

This skill is automatically included by other skills to ensure:
1. Status transitions follow allowed paths
2. Quality gates are passed before completion
3. Activity is tracked on all modifications

## Reference Documents

- [Status Transitions](./references/status-transitions.md) - Allowed status changes
- [Gate Requirements](./references/gate-requirements.md) - Verification gate rules

## Status Transition Rules

<hyper-embed file="references/status-transitions.md" />

## Gate Requirements

<hyper-embed file="references/gate-requirements.md" />

## Enforcement Behavior

When included by another skill, this enforces:

### Before Status Change

```bash
# Validate transition is allowed
hypercraft status validate --from "${CURRENT}" --to "${NEW}" --type "${TYPE}"
```

### Before Completion

```bash
# Verify all gates passed
hypercraft gate check --task "${TASK_ID}" --gates "lint,typecheck,test,build"
```

### On Failure

- Block invalid transitions with clear error message
- Block completion if gates haven't passed
- Suggest corrective action

## CLI Commands Used

| Command | Purpose |
|---------|---------|
| `hypercraft task update --status` | Update task status |
| `hypercraft project update --status` | Update project status |

## Best Practices

- Always use CLI for status updates (validates automatically)
- Run verification gates before marking QA
- Only mark complete when ALL gates pass
- Document gate results in task file
