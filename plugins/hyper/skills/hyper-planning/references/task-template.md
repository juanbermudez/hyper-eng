# Task Template

Create task files only AFTER explicit user approval of the specification.

## Update Project Status

```bash
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft project update \
  "${PROJECT_SLUG}" --status "todo"
```

## Generate Task IDs

Derive initials from project slug:

```bash
# Convert slug to initials
INITIALS=$(echo "$PROJECT_SLUG" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) printf substr($i,1,1)}')
echo "Project initials: $INITIALS"
# Examples: user-auth → ua, workspace-settings → ws
```

## Create Tasks Using CLI

For each implementation phase in the spec:

```bash
TASK_NUM=1
TASK_FILE_NUM=$(printf "%03d" $TASK_NUM)
TASK_ID="${INITIALS}-${TASK_FILE_NUM}"

# Create task with validated frontmatter
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft task create \
  --project "${PROJECT_SLUG}" \
  --id "${TASK_ID}" \
  --title "Phase ${TASK_NUM}: [Phase Name]" \
  --priority "[PRIORITY]" \
  --depends-on "[comma-separated task IDs if any]"
```

## Add Task Content

Use the Write tool to add body content to the task file:

```markdown
---
# Frontmatter created by CLI
---

# Phase [N]: [Phase Name]

[Detailed phase description from spec]

## Objectives

[Specific goals for this phase]

## Files to Create/Modify

### New Files
- [list of new files]

### Modified Files
- [list of files to modify with line numbers]

## Implementation Details

[Specific implementation guidance]

### Code Patterns

```typescript
// Example code or pattern to follow
```

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Verification

```bash
# Commands to verify this task
npm run lint
npm run typecheck
npm test
npm run build
```

### Manual Verification
- [ ] [Manual check 1]
- [ ] [Manual check 2]

## Dependencies

- [List any dependencies on other tasks]
- E.g., "Depends on ${INITIALS}-001 for type definitions"
```

## Dependency References

Use initials-based IDs for dependencies:

```yaml
# Example for user-auth project (initials: ua)
depends_on:
  - ua-001
  - ua-002
```

## Verification Tasks (Optional)

For complex projects, create verification sub-tasks:

```bash
VERIFY_NUM=$((TASK_NUM + 100))  # Verification tasks start at 101
VERIFY_FILE_NUM=$(printf "%03d" $VERIFY_NUM)
VERIFY_ID="${INITIALS}-${VERIFY_FILE_NUM}"

${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft task create \
  --project "${PROJECT_SLUG}" \
  --id "${VERIFY_ID}" \
  --title "Verify: Phase ${TASK_NUM} - [Phase Name]" \
  --priority "[PRIORITY]" \
  --depends-on "${TASK_ID}" \
  --tags "verification,phase-${TASK_NUM}"
```

## Final Verification Task

Create a final project verification task:

```bash
FINAL_ID="${INITIALS}-999"

${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft task create \
  --project "${PROJECT_SLUG}" \
  --id "${FINAL_ID}" \
  --title "Final: Project Completion Verification" \
  --priority "high" \
  --depends-on "[all verification task IDs]" \
  --tags "verification,final,project-qa"
```

## Summary Output

After creating all tasks, report to user:

```markdown
## Tasks Created

**Project**: `${PROJECT_SLUG}`
**Project Initials**: `${INITIALS}`
**Location**: `$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/tasks/`

### Implementation Tasks
| File | ID | Title |
|------|-----|-------|
| `task-001.mdx` | `${INITIALS}-001` | Phase 1 - [Description] |
| `task-002.mdx` | `${INITIALS}-002` | Phase 2 - [Description] |

### Verification Tasks (if created)
| File | ID | Title |
|------|-----|-------|
| `task-101.mdx` | `${INITIALS}-101` | Verify Phase 1 |

**Start implementation**: `/hyper:implement ${PROJECT_SLUG}/task-001`
```
