---
description: View status of all projects and tasks in $HYPER_WORKSPACE_ROOT/ directory
argument-hint: "[project-slug]"
workflow: workflows/hyper-status.prose
---

Use the **hypercraft** skill to execute the status workflow.

## Execute Workflow

Load the hypercraft skill (which includes prose VM) and execute the workflow at `workflows/hyper-status.prose` with:

```
input project_slug: "$ARGUMENTS"
input verbose: "false"
```

The workflow will:

1. **Initialize** - Resolve workspace path
2. **Gather Status** - Query projects and tasks via CLI
3. **Check Hypercraft State** - Report recent runs and agent memory
4. **Generate Report** - Formatted status output

## Output Format

```
## Workspace Status Report

### Project Overview
| Project | Status | Progress | Priority |
|---------|--------|----------|----------|
| auth    | in-progress | 4/8 | high |

### Hypercraft Execution State
Recent Runs: 3
Agent Memory: impl-captain, researcher

### Next Actions
- Start task: /hyper:implement auth/task-005
```

## CLI Integration

Uses `${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft` for queries:
- `hypercraft project list --json`
- `hypercraft task list --project {slug} --json`
- `hypercraft find "query" --json` (for content search)

## State Location

```
$HYPER_WORKSPACE_ROOT/.prose/runs/     # Recent executions
$HYPER_WORKSPACE_ROOT/.prose/agents/   # Agent memory
```
