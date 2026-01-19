# Status Transitions

Allowed status transition paths for projects and tasks.

## Project Status Flow

```
planned ─────► todo ─────► in-progress ─────► qa ─────► completed
   │                            │              │
   │                            │              └──► in-progress (fix issues)
   │                            │
   └──► canceled               └──► canceled
```

### Project Status Values

| Status | Meaning | Transitions To |
|--------|---------|---------------|
| `planned` | Spec phase, research ongoing | `todo`, `canceled` |
| `todo` | Spec approved, tasks created | `in-progress`, `canceled` |
| `in-progress` | Work underway | `qa`, `canceled` |
| `qa` | All tasks done, project-level QA | `completed`, `in-progress` |
| `completed` | All quality gates passed | (terminal) |
| `canceled` | Abandoned | (terminal) |

### Project Transition Rules

1. **planned → todo**: Requires spec approval and task creation
2. **todo → in-progress**: **MANDATORY** when first task starts (see enforcement below)
3. **in-progress → qa**: When ALL tasks are `complete`
4. **qa → completed**: When project-level verification passes
5. **qa → in-progress**: When issues found in project QA

### CRITICAL: Project Status Enforcement

> **MANDATORY REQUIREMENT**: When starting implementation of ANY task, you MUST check and update
> the project status. This is NOT optional and NOT automatic - it must be done explicitly.

**Why this matters**:
- Project status controls visibility in Hyper Control UI
- A project in "planned" or "todo" appears dormant even with active tasks
- Users cannot see progress without proper project status

**Enforcement pattern** (MUST be done in /hyper-implement):

```bash
# Before starting ANY task, check project status
PROJECT_STATUS=$(grep "^status:" "$PROJECT_DIR/_project.mdx" | awk '{print $2}')

# Update to in-progress if not already there
if [ "$PROJECT_STATUS" = "planned" ] || [ "$PROJECT_STATUS" = "todo" ]; then
  hyper project update "$PROJECT_SLUG" --status "in-progress"
fi
```

**Failure to update project status is a workflow violation.**

## Task Status Flow

```
draft ─────► todo ─────► in-progress ─────► qa ─────► complete
  │            │              │              │
  │            │              │              └──► in-progress (fix)
  │            │              │
  │            └──► blocked   └──► blocked
  │
  └──► (deleted)
```

### Task Status Values

| Status | Meaning | Transitions To |
|--------|---------|---------------|
| `draft` | Work in progress, not ready | `todo`, deleted |
| `todo` | Ready to be worked on | `in-progress`, `blocked` |
| `in-progress` | Active work | `qa`, `blocked` |
| `qa` | Quality assurance phase | `complete`, `in-progress` |
| `complete` | Done (all checks passed) | (terminal) |
| `blocked` | Blocked by dependencies | `todo`, `in-progress` |

### Task Transition Rules

1. **draft → todo**: When task definition is complete
2. **todo → in-progress**: When work begins
3. **in-progress → qa**: When implementation done, running checks
4. **qa → complete**: When ALL verification gates pass
5. **qa → in-progress**: When checks fail, fix required
6. **Any → blocked**: When dependency not satisfied
7. **blocked → todo/in-progress**: When blocker resolved

## Validation Logic

```bash
# Validate project transition
validate_project_transition() {
  local from="$1"
  local to="$2"

  case "$from:$to" in
    "planned:todo") return 0 ;;
    "todo:in-progress") return 0 ;;
    "in-progress:qa") return 0 ;;
    "in-progress:canceled") return 0 ;;
    "qa:completed") return 0 ;;
    "qa:in-progress") return 0 ;;
    "planned:canceled") return 0 ;;
    "todo:canceled") return 0 ;;
    *) return 1 ;;
  esac
}

# Validate task transition
validate_task_transition() {
  local from="$1"
  local to="$2"

  case "$from:$to" in
    "draft:todo") return 0 ;;
    "todo:in-progress") return 0 ;;
    "todo:blocked") return 0 ;;
    "in-progress:qa") return 0 ;;
    "in-progress:blocked") return 0 ;;
    "qa:complete") return 0 ;;
    "qa:in-progress") return 0 ;;
    "blocked:todo") return 0 ;;
    "blocked:in-progress") return 0 ;;
    *) return 1 ;;
  esac
}
```

## Common Invalid Transitions

| Invalid | Reason | Correct Path |
|---------|--------|--------------|
| `todo → complete` | Must pass through in-progress + qa | `todo → in-progress → qa → complete` |
| `in-progress → complete` | Must run QA checks | `in-progress → qa → complete` |
| `qa → todo` | Cannot regress that far | `qa → in-progress` to fix, then back to qa |
| `completed → *` | Terminal state | Create new task/project |
