# Lifecycle and Status Transitions

This document defines the allowed status values and transitions for projects and tasks in the hyper-engineering workflow.

## Project Lifecycle

### Status Values

| Status | Description | Terminal |
|--------|-------------|----------|
| `planned` | Initial state, research/spec phase | No |
| `todo` | Spec approved, ready for work | No |
| `in-progress` | Active development | No |
| `blocked` | Blocked by external dependency | No |
| `qa` | Quality assurance phase | No |
| `completed` | Successfully finished | Yes |
| `canceled` | Project canceled | Yes |

### Allowed Transitions

```
planned ──────┬───────> todo ──────────> in-progress ──────┬───────> qa ──────────> completed
              │                                │           │
              │                                │           │
              └───────> canceled               └───────> blocked
                                                           │
                                                           └───> in-progress
```

| From | Allowed To |
|------|------------|
| `planned` | `todo`, `canceled` |
| `todo` | `in-progress`, `canceled` |
| `in-progress` | `qa`, `blocked`, `canceled` |
| `blocked` | `in-progress`, `canceled` |
| `qa` | `completed`, `in-progress` |
| `completed` | (terminal) |
| `canceled` | (terminal) |

### Gates

| Transition | Gate Type | Requirements |
|------------|-----------|--------------|
| `planned` -> `todo` | Human approval | Spec must be approved |
| `qa` -> `completed` | Quality gate | All automated checks pass |

## Task Lifecycle

### Status Values

| Status | Description | Terminal |
|--------|-------------|----------|
| `draft` | Work in progress, not ready | No |
| `todo` | Ready to be worked on | No |
| `in-progress` | Active work | No |
| `blocked` | Blocked by dependencies | No |
| `qa` | Quality assurance phase | No |
| `complete` | Done, all checks passed | Yes |

### Allowed Transitions

```
draft ────────> todo ──────────> in-progress ──────┬───────> qa ──────────> complete
                                       │           │
                                       │           │
                                       └───────> blocked
                                                   │
                                                   └───> in-progress
                                                         or todo
```

| From | Allowed To |
|------|------------|
| `draft` | `todo` |
| `todo` | `in-progress`, `blocked` |
| `in-progress` | `qa`, `blocked` |
| `blocked` | `todo`, `in-progress` |
| `qa` | `complete`, `in-progress` |
| `complete` | (terminal) |

### Gates

| Transition | Gate Type | Requirements |
|------------|-----------|--------------|
| `in-progress` -> `qa` | Readiness | Implementation complete |
| `qa` -> `complete` | Quality gate | All checks pass |

## Quality Assurance (QA) Phase

The `qa` status is where verification happens:

### For Tasks

1. **Automated checks** (must all pass):
   - `lint` - Code style and linting
   - `typecheck` - Type checking
   - `test` - Unit and integration tests
   - `build` - Build succeeds

2. **Manual verification** (if applicable):
   - Browser testing for UI changes
   - Code review for non-trivial changes
   - Security review for sensitive changes

3. **Transition rules**:
   - All checks pass -> Move to `complete`
   - Any check fails -> Back to `in-progress` to fix

### For Projects

1. **Prerequisites**:
   - All tasks must be `complete`

2. **Project-level verification**:
   - Integration testing
   - End-to-end testing
   - Documentation review
   - Final stakeholder review

3. **Transition rules**:
   - All verification passes -> Move to `completed`
   - Issues found -> Back to `in-progress`

## Dependency Handling

### Task Dependencies

Tasks can depend on other tasks via the `depends_on` field:

```yaml
---
id: as-002
depends_on:
  - as-001
---
```

Rules:
- Cannot start a task until dependencies are `complete`
- Set status to `blocked` if waiting on dependencies
- Move to `todo` or `in-progress` when dependencies complete

### Project Dependencies

Projects don't have explicit dependencies, but:
- Related projects should be documented in the spec
- Cross-project coordination happens at the initiative level

## Workflow Customization

Workflows can be customized in `$HYPER_WORKSPACE_ROOT/settings/workflows.yaml`:

```yaml
project_workflow:
  stages:
    - id: planned
      name: "Planned"
      allowed_transitions: [todo, canceled]
    - id: todo
      name: "Ready"
      allowed_transitions: [in-progress, canceled]
    - id: in-progress
      name: "In Progress"
      allowed_transitions: [qa, blocked]
    - id: qa
      name: "QA"
      gate: true
      allowed_transitions: [completed, in-progress]
    - id: completed
      name: "Complete"
      terminal: true
    - id: canceled
      name: "Canceled"
      terminal: true

task_workflow:
  stages:
    - id: draft
      name: "Draft"
      allowed_transitions: [todo]
    - id: todo
      name: "To Do"
      allowed_transitions: [in-progress, blocked]
    - id: in-progress
      name: "In Progress"
      on_enter:
        - action: update_frontmatter
          field: started
          value: "{{DATE}}"
      allowed_transitions: [qa, blocked]
    - id: qa
      name: "QA"
      gate: true
      allowed_transitions: [complete, in-progress]
    - id: complete
      name: "Complete"
      terminal: true
      on_enter:
        - action: update_frontmatter
          field: completed
          value: "{{DATE}}"
    - id: blocked
      name: "Blocked"
      allowed_transitions: [todo, in-progress]

quality_gates:
  task_completion:
    automated:
      - id: lint
        command: "npm run lint"
        required: true
      - id: typecheck
        command: "npm run typecheck"
        required: true
      - id: test
        command: "npm run test"
        required: true
      - id: build
        command: "npm run build"
        required: true
    manual:
      - id: browser
        name: "Browser Testing"
        required_if: "ui_changes"
```

## Status Update via CLI

```bash
# Update task status
hyper task update as-001 --status in-progress

# Update project status
hyper project update auth-system --status qa

# Activity is automatically tracked
```

## Troubleshooting

### Task stuck in blocked

1. Check `depends_on` in frontmatter
2. Verify dependent tasks are `complete`
3. Update status to `in-progress` or `todo` manually if dependencies resolved

### Verification fails repeatedly

After 3 attempts:
1. Document what failed
2. Research alternatives
3. Question fundamentals - is the approach wrong?
4. Create fix sub-tasks if needed

### Project won't move to completed

1. Verify all tasks are `complete`
2. Run project-level verification
3. Check for any `blocked` tasks that were missed
