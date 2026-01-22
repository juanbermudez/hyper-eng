# Hyper-Engineering Methodology

## Philosophy

**Specs matter more than code. Code is disposable; specifications are the source of truth.**

## Workflow Phases

### 1. Plan → /hyper:plan

Research → Interview → Spec → Review → Tasks

**Steps:**
1. Initial interview to understand requirements
2. Research phase with parallel sub-agents
3. Post-research clarification
4. Direction validation (Gate 1)
5. Detailed specification creation
6. Specification review (Gate 2)
7. Task breakdown after approval

**Output:**
- `$HYPER_WORKSPACE_ROOT/projects/{slug}/_project.mdx` (spec inline)
- `$HYPER_WORKSPACE_ROOT/projects/{slug}/tasks/task-*.mdx`
- `$HYPER_WORKSPACE_ROOT/projects/{slug}/resources/`

### 2. Implement → /hyper:implement

Execute tasks with verification gates

**Steps:**
1. Update task status to in-progress
2. Read spec and codebase patterns
3. Implement changes
4. Run automated verification gates
5. Update task with implementation log
6. Mark complete when all gates pass

**Output:**
- Code changes
- Test additions
- Task completion

### 3. Verify → /hyper:verify

Comprehensive verification loop

**Steps:**
1. Run automated checks (lint, typecheck, test, build)
2. Run manual verification scenarios
3. Run browser testing (if UI changes)
4. Create fix tasks for failures
5. Loop until all checks pass

**Output:**
- Verification results in task file
- Fix tasks if needed

### 4. Review → /hyper:review

Code review for quality

**Steps:**
1. Review code changes
2. Check against spec requirements
3. Verify test coverage
4. Provide feedback

## Status Flow

### Projects
```
planned → todo → in-progress → qa → completed
```

### Tasks
```
draft → todo → in-progress → qa → complete
```

## Key Principles

1. **Never skip phases** - Even for "simple" tasks
2. **Get approval at gates** - Direction check, spec review
3. **Verify before completion** - All automated gates must pass
4. **Document everything** - Specs, tasks, verification results
5. **Use CLI for status** - Validates automatically

## Directory Structure

```
$HYPER_WORKSPACE_ROOT/
├── workspace.json
├── projects/
│   └── {slug}/
│       ├── _project.mdx      # Spec inline
│       ├── tasks/            # Task breakdown
│       └── resources/        # Research docs
└── settings/
    ├── workflows.yaml
    └── agents/
```

## Activity Tracking

All modifications to `$HYPER_WORKSPACE_ROOT/` files are automatically tracked:
- Session ID captured
- Parent chain for sub-agents
- Operation type (create/modify/delete)
- Timestamp

## CLI Integration

Use the `hyper` CLI for all operations:
- `hyper project create` - Create project
- `hyper task create` - Create task
- `hyper task update --status` - Update status
- `hyper file validate` - Validate frontmatter
