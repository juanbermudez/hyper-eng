# Task Loading

## Parse Input

Determine project and task from input:

**Format: `project-slug/task-NNN`**
```bash
PROJECT_SLUG="[extracted-project]"
TASK_ID="[extracted-task]"
TASK_FILE="$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/tasks/${TASK_ID}.mdx"
```

**If only project provided**, list available tasks:
```bash
PROJECT_SLUG="[provided-slug]"
echo "Available tasks in ${PROJECT_SLUG}:"
for f in $HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/tasks/task-*.mdx; do
  if [ -f "$f" ]; then
    task_name=$(basename "$f" .mdx)
    echo "- ${task_name}"
  fi
done
```

## Verify Task Exists

```bash
if [ ! -f "$TASK_FILE" ]; then
  echo "Task file not found: $TASK_FILE"
  exit 1
fi
```

## Read Task Content

```bash
cat "${TASK_FILE}"
```

Parse frontmatter for:
- `id` - Task identifier
- `title` - Task title
- `status` - Current status (should be `todo`)
- `priority` - Task priority
- `depends_on` - Blocking dependencies
- `parent` - Parent project ID

## Read Project Spec

Specification is inline in `_project.mdx`:

```bash
cat "$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/_project.mdx"
```

## Check Dependencies

For each ID in `depends_on`:

```bash
for dep in "${DEPENDS_ON[@]}"; do
  DEP_STATUS=$(grep "^status:" "$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/tasks/${dep}.mdx" | head -1 | awk '{print $2}')
  if [ "$DEP_STATUS" != "complete" ]; then
    echo "Dependency ${dep} not complete (status: ${DEP_STATUS})"
  fi
done
```

If dependencies incomplete, warn user:
```
This task depends on tasks that are not complete:
- [dep-id]: [status]

Would you like to:
1. Implement this task anyway (may cause issues)
2. Implement the dependency first
3. Cancel
```

## Load Research Context (Optional)

If research exists:
```bash
if [ -d "$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/resources" ]; then
  cat "$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/resources/research-summary.md"
fi
```

## Context Summary

After loading, summarize context:

```markdown
## Task Context

**Project**: ${PROJECT_SLUG}
**Task**: ${TASK_ID} - [Title]
**Status**: [current status]
**Priority**: [priority]

**Objectives**:
[From task file]

**Files to Modify**:
[From task file]

**Dependencies**: [list or "None"]

**Ready to implement**: [Yes/No with reason]
```
