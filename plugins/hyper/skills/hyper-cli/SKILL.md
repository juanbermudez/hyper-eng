---
name: hyper-cli
description: This skill provides guidance on using the Hyper CLI for programmatic file operations. This skill should be used when agents need to create, read, update, delete, or search files in the $HYPER_WORKSPACE_ROOT/ directory structure, handle validation errors, or self-correct from structured error responses.
model: sonnet
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
---

<skill name="hyper-cli">

<description>
This skill teaches AI agents how to work with the Hyper CLI for programmatic manipulation of `$HYPER_WORKSPACE_ROOT/` planning documents. It covers both the Resource API (high-level operations) and File API (low-level plumbing), error handling patterns, and self-correction workflows.
</description>

<context>

## Quick Reference

### Essential Commands

| Operation | Resource API (Porcelain) | File API (Plumbing) |
|-----------|-------------------------|---------------------|
| List projects | `hyper project list --json` | `hyper file list --path $HYPER_WORKSPACE_ROOT/projects --file-type project --json` |
| Create project | `hyper project create --slug x --title "X"` | `hyper file write $HYPER_WORKSPACE_ROOT/projects/x/_project.mdx --frontmatter "..."` |
| Update status | `hyper project update x --status in-progress` | `hyper file write $HYPER_WORKSPACE_ROOT/projects/x/_project.mdx --frontmatter "status=in-progress"` |
| Read project | `hyper project get x --json` | `hyper file read $HYPER_WORKSPACE_ROOT/projects/x/_project.mdx --json` |
| Delete project | `hyper project delete x --force --json` | `hyper file delete $HYPER_WORKSPACE_ROOT/projects/x --force --json` |
| Search | `hyper search "query" --json` | `hyper file search "query" --json` |
| Task operations | `hyper task list/get/create/update/delete` | `hyper file ...` on task files |

### When to Use Each API

**Use Resource API (Porcelain) when:**
- Creating new projects/tasks (handles validation and defaults)
- Quick status updates
- Human-readable output needed

**Use File API (Plumbing) when:**
- Bulk operations across multiple files
- Direct file manipulation with full control
- Integration with file-based workflows
- Need to read/write arbitrary fields

## Directory Structure

```
$HYPER_WORKSPACE_ROOT/
├── workspace.json         # Workspace metadata (PROTECTED - read-only)
├── projects/              # Feature projects (PROTECTED - directory itself)
│   └── {slug}/
│       ├── _project.mdx   # Project spec (WRITABLE)
│       ├── tasks/         # Task breakdown (WRITABLE)
│       │   └── task-NNN.mdx
│       └── resources/     # Research, docs, artifacts (WRITABLE)
│           └── research/
├── initiatives/           # High-level initiatives (PROTECTED - directory)
├── docs/                  # Workspace documentation (WRITABLE)
└── settings/              # Configuration
    ├── workflows.yaml     # Project/task stages (WRITABLE)
    ├── agents/            # Agent definitions (WRITABLE)
    └── commands/          # Custom commands (WRITABLE)
```

## Frontmatter Schemas

### Project (`_project.mdx`)

```yaml
---
id: proj-{slug}           # Required, pattern: ^proj-[a-z0-9-]+$
title: "Project Title"    # Required, minLength: 1
type: project             # Required, literal
status: planning          # Required, enum: planning|todo|blocked|in-progress|verifying|completed|canceled
priority: medium          # Required, enum: urgent|high|medium|low
summary: "Brief desc"     # Optional
created: 2026-01-13       # Optional, auto-set on creation
updated: 2026-01-13       # Optional, auto-updated on write
tags: [tag1, tag2]        # Optional, string[]
---
```

### Task (`tasks/task-NNN.mdx`)

```yaml
---
id: {initials}-{NNN}      # Required, pattern: ^[a-z]+-\d{3}$
title: "Task Title"       # Required
type: task                # Required, literal
status: todo              # Required, enum: draft|todo|in-progress|verifying|complete|blocked
priority: medium          # Optional, enum: urgent|high|medium|low
parent: proj-{slug}       # Required, project ID
depends_on: [id-001]      # Optional, task IDs
created: 2026-01-13       # Optional
updated: 2026-01-13       # Optional
---
```

## Error Handling

All CLI commands with `--json` flag return structured responses:

### Success Response
```json
{
  "success": true,
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "INVALID_FIELD_VALUE",
    "message": "Invalid value 'foo' for field 'status'",
    "context": {
      "field": "status",
      "value": "foo",
      "allowed": ["planning", "todo", "blocked", "in-progress", "verifying", "completed", "canceled"]
    },
    "suggestion": "Valid values: planning, todo, blocked, in-progress, verifying, completed, canceled"
  }
}
```

### Error Codes

| Code | Exit | Meaning | Action |
|------|------|---------|--------|
| `SUCCESS` | 0 | Operation completed | Continue |
| `WORKSPACE_NOT_FOUND` | 1 | No $HYPER_WORKSPACE_ROOT/ directory | Run `hyper init` |
| `PROJECT_NOT_FOUND` | 66 | Project doesn't exist | Check slug, create if needed |
| `TASK_NOT_FOUND` | 66 | Task doesn't exist | Check ID |
| `FILE_NOT_FOUND` | 66 | File doesn't exist | Check path |
| `PROTECTED_PATH` | 65 | Cannot modify location | Use allowed path |
| `PATH_OUTSIDE_WORKSPACE` | 65 | Path not in workspace | Use workspace-relative path |
| `INVALID_FIELD_VALUE` | 65 | Value not in enum | Check `allowed` array in error |
| `MISSING_FIELD` | 65 | Required field missing | Add required field |
| `IO_ERROR` | 74 | Filesystem error | Retry or check permissions |

### Self-Correction Pattern

When receiving a validation error, extract correct values from the error response:

```bash
# Step 1: Attempt with invalid status
hyper file write $HYPER_WORKSPACE_ROOT/projects/foo/_project.mdx \
  --frontmatter "id=proj-foo" \
  --frontmatter "title=Foo" \
  --frontmatter "type=project" \
  --frontmatter "status=wip" \
  --frontmatter "priority=high" \
  --json

# Error response includes allowed values:
# { "error": { "context": { "allowed": ["planning", "todo", ...] } } }

# Step 2: Self-correct using the allowed value
hyper file write $HYPER_WORKSPACE_ROOT/projects/foo/_project.mdx \
  --frontmatter "id=proj-foo" \
  --frontmatter "title=Foo" \
  --frontmatter "type=project" \
  --frontmatter "status=in-progress" \
  --frontmatter "priority=high" \
  --json
```

## Protected Paths

**CANNOT modify:**
- `$HYPER_WORKSPACE_ROOT/workspace.json` (core structure)
- `$HYPER_WORKSPACE_ROOT/projects` (directory itself)
- `$HYPER_WORKSPACE_ROOT/initiatives` (directory itself)
- `$HYPER_WORKSPACE_ROOT/settings` (directory itself)

**CAN create/edit/delete:**
- `$HYPER_WORKSPACE_ROOT/projects/{slug}/` (project directories)
- `$HYPER_WORKSPACE_ROOT/projects/{slug}/_project.mdx` (project files)
- `$HYPER_WORKSPACE_ROOT/projects/{slug}/tasks/*.mdx` (task files)
- `$HYPER_WORKSPACE_ROOT/projects/{slug}/resources/**` (resource files)
- `$HYPER_WORKSPACE_ROOT/docs/**/*.md` (documentation)
- `$HYPER_WORKSPACE_ROOT/settings/workflows.yaml` (workflow config)
- `$HYPER_WORKSPACE_ROOT/settings/agents/*.yaml` (agent configs)
- `$HYPER_WORKSPACE_ROOT/settings/commands/*.md` (command customizations)

## Common Workflows

### Creating a New Project

```bash
# Option 1: Resource API (recommended for creation)
hyper project create \
  --slug my-feature \
  --title "My Feature" \
  --priority high \
  --summary "Implementing a new feature" \
  --json

# Option 2: File API (for full control)
hyper file write $HYPER_WORKSPACE_ROOT/projects/my-feature/_project.mdx \
  --frontmatter "id=proj-my-feature" \
  --frontmatter "title=My Feature" \
  --frontmatter "type=project" \
  --frontmatter "status=planning" \
  --frontmatter "priority=high" \
  --frontmatter "summary=Implementing a new feature" \
  --body "# My Feature\n\n## Description\n..." \
  --json
```

### Updating Project Status

```bash
# Resource API (simple)
hyper project update my-feature --status in-progress

# File API (preserves existing body content)
hyper file write $HYPER_WORKSPACE_ROOT/projects/my-feature/_project.mdx \
  --frontmatter "status=in-progress" \
  --json
```

### Creating a Task

```bash
# Resource API
hyper task create \
  --project my-feature \
  --title "Phase 1: Foundation" \
  --priority high \
  --json

# File API (full control)
hyper file write $HYPER_WORKSPACE_ROOT/projects/my-feature/tasks/task-001.mdx \
  --frontmatter "id=mf-001" \
  --frontmatter "title=Phase 1: Foundation" \
  --frontmatter "type=task" \
  --frontmatter "status=todo" \
  --frontmatter "parent=proj-my-feature" \
  --frontmatter "priority=high" \
  --body "# Phase 1: Foundation\n\n## Objectives\n..." \
  --json
```

### Updating Task Status

```bash
# Resource API
hyper task update mf-001 --status in-progress

# File API
hyper file write $HYPER_WORKSPACE_ROOT/projects/my-feature/tasks/task-001.mdx \
  --frontmatter "status=in-progress" \
  --json
```

### Deleting a Project

```bash
# Resource API (deletes project and all tasks)
hyper project delete my-feature --force --json

# File API (deletes specific path)
hyper file delete $HYPER_WORKSPACE_ROOT/projects/my-feature --force --json
```

### Deleting a Task

```bash
# Resource API
hyper task delete mf-001 --force --json

# File API
hyper file delete $HYPER_WORKSPACE_ROOT/projects/my-feature/tasks/task-001.mdx --force --json
```

### Searching for Content

```bash
# Search by content (full text)
hyper file search "authentication" --json

# Search by field value
hyper file search "in-progress" --field status --file-type project --json

# High-level search with filters
hyper search "OAuth" --status in-progress --json
```

### Reading Workflow Configuration

```bash
# List all settings
hyper settings workflow list --json

# Get project stages
hyper settings workflow get project.stages --json

# Get task statuses
hyper settings workflow get task.statuses --json

# Set a value
hyper settings workflow set project.stages '["planning", "todo", "in-progress", "completed"]' --json
```

### Reading and Writing Files

```bash
# List files in a directory
hyper file list --path $HYPER_WORKSPACE_ROOT/projects --file-type project --recursive --json

# Read a file
hyper file read $HYPER_WORKSPACE_ROOT/projects/my-feature/_project.mdx --json

# Read only frontmatter
hyper file read $HYPER_WORKSPACE_ROOT/projects/my-feature/_project.mdx --frontmatter-only --json

# Read only body
hyper file read $HYPER_WORKSPACE_ROOT/projects/my-feature/_project.mdx --body-only --json
```

## Best Practices

1. **Always use `--json`** for programmatic operations
2. **Check exit codes** for error handling (0 = success)
3. **Parse error responses** to extract `allowed` values for self-correction
4. **Use Resource API** for creation (handles defaults and validation)
5. **Use File API** for bulk operations or when full control needed
6. **Never hardcode** enum values - read from errors or settings
7. **Always include `--force`** flag when automating delete operations
8. **Check project exists** before creating tasks

## Settings API

The settings API allows reading and modifying workflow configuration:

```bash
# Full workflow config
hyper settings workflow list --json

# Returns:
{
  "success": true,
  "data": {
    "settings": {
      "project": {
        "stages": ["planning", "todo", "in-progress", "verifying", "completed"],
        "priorities": ["urgent", "high", "medium", "low"]
      },
      "task": {
        "statuses": ["draft", "todo", "in-progress", "verifying", "complete", "blocked"],
        "priorities": ["urgent", "high", "medium", "low"]
      }
    }
  }
}
```

</context>

</skill>
