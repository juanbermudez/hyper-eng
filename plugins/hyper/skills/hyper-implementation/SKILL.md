---
name: hyper-implementation
description: This skill should be used when the user asks to "implement a task", "start coding", "work on a feature", or references a task ID to implement. Guides task execution with verification gates.
version: 1.0.0
model: sonnet
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
includes:
  - hyper-craft
  - hyper-workflow-enforcement
  - hyper-cli
  - hyper-verification
---

# Hyper Implementation Skill

Guided task implementation following the task specification with verification gates. Requires `hyper-craft` as the core skill.

## Overview

This skill guides implementation through:

1. **Read Task** - Load task requirements and context
2. **Update Status** - Mark task as in-progress
3. **Read Codebase** - Understand existing patterns
4. **Implement** - Write code following spec and patterns
5. **Verify** - Run all verification gates
6. **Complete** - Update status based on results

## Reference Documents

- [Implementation Checklist](./references/implementation-checklist.md) - Step-by-step implementation guide
- [Verification Gates](./references/verification-gates.md) - All verification requirements
- [Task Loading](./references/task-loading.md) - Loading task context

## Workflow

### Step 1: Load Task Context

<hyper-embed file="references/task-loading.md" />

### Step 2: Update Status to In-Progress (CRITICAL)

> **MANDATORY**: You MUST update BOTH project AND task status before beginning implementation.
> Failing to update project status causes visibility issues in Hypercraft.

#### Step 2a: Update PROJECT Status First

Check if project needs status update:

```bash
# Get project info
PROJECT_STATUS=$(grep "^status:" "$PROJECT_DIR/_project.mdx" | awk '{print $2}')

# MUST update project to in-progress if currently planned or todo
if [ "$PROJECT_STATUS" = "planned" ] || [ "$PROJECT_STATUS" = "todo" ]; then
  ${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft project update \
    "${PROJECT_SLUG}" --status "in-progress"
fi
```

#### Step 2b: Update TASK Status

```bash
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft task update \
  "${TASK_ID}" --status "in-progress"
```

> **Why project status matters**: The project status determines visibility in Hypercraft.
> A project in "planned" or "todo" status appears dormant even if tasks are being worked on.
> Always ensure the project is "in-progress" when any task is being implemented.

### Step 3: Understand Codebase

Before making changes:

1. **Use unified `find` command to locate relevant files:**
   ```bash
   # Search across all resources
   hypercraft find "authentication" --json

   # Search specific resource types
   hypercraft find "handler" --type projects --json
   hypercraft find "component" --type tasks --json

   # Hybrid search for complex queries
   hypercraft find "API error handling" --mode hybrid --json
   ```

   | Scenario | Tool | Reason |
   |----------|------|--------|
   | Find implementations | `hypercraft find` | Ranked results, highlighted snippets |
   | Quick grep | Grep | Simple regex, no index needed |
   | File discovery | Glob | Pattern matching on paths |

2. **Read all files mentioned in task description**
   - Never use limit/offset - read files completely
   - Understand current implementation
   - Note patterns and conventions

3. **Read related files for context**
   - Import/export chains
   - Test files
   - Similar features

### Step 4: Implement

<hyper-embed file="references/implementation-checklist.md" />

### Step 5: Run Verification

<hyper-embed file="references/verification-gates.md" />

### Step 6: Update Status

Based on verification results:

**All checks pass**:
```bash
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft task update \
  "${TASK_ID}" --status "complete"
```

**Any check fails**:
- Keep status as `in-progress`
- Fix issues
- Re-run verification
- Repeat until all pass

## Status Reference

**Task Status Values**:
- `draft` - Work in progress, not ready
- `todo` - Ready to be worked on
- `in-progress` - Active work
- `qa` - Quality assurance & verification
- `complete` - Done, all checks passed
- `blocked` - Blocked by dependencies

**Status Transitions**:
- `todo` → `in-progress` (start work)
- `in-progress` → `qa` (implementation done)
- `qa` → `complete` (all checks pass)
- `qa` → `in-progress` (checks fail, fix needed)

## Implementation Log

Add progress log to task file:

```markdown
## Progress Log

### [DATE] - Started Implementation
- Reading spec and codebase
- Branch: [branch-name]
- Status: in-progress

### [DATE] - Implementation Complete
- Files modified: [list]
- Files created: [list]
- Tests added: [list]
- Verification: [results]
- Status: complete
```

## Git Workflow

```bash
# Create feature branch
git checkout main && git pull origin main
git checkout -b feat/${PROJECT_SLUG}/${TASK_ID}

# After implementation
git add -A
git commit -m "feat(${PROJECT_SLUG}): ${TASK_TITLE}

Task: ${TASK_ID}

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## Best Practices

- Read files completely - never use limit/offset
- Follow existing patterns in codebase
- Run verification frequently during implementation
- Don't mark complete until ALL checks pass
- Update task with implementation log
- Commit with conventional commit format

## Error Handling

| Condition | Action |
|-----------|--------|
| Task not found | Check project slug and task ID |
| Dependencies incomplete | Warn and ask whether to proceed |
| Verification fails 3+ times | Stop and ask for manual review |
| Unclear requirements | Reference spec or ask user |

## Includes

This skill depends on:

- **hyper-workflow-enforcement** - Status transition validation
- **hyper-cli** - CLI command patterns
- **hyper-verification** - Verification gate execution
