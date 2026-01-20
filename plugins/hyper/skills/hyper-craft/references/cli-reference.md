# Hyper CLI Reference

The Hyper CLI provides commands for managing workspace projects, tasks, Drive notes, and configuration. **Always use the CLI for workspace operations** to ensure validation, activity tracking, and data integrity.

## CLI Overview

```
hyper <COMMAND>

Commands:
  init      Initialize a new workspace
  worktree  Manage git worktrees for isolated development
  project   Manage workspace projects (list, get, create, update)
  task      Manage workspace tasks (list, get, create, update)
  drive     Manage HyperHome drive items/notes (list, create, show, delete, mkdir)
  activity  Track activity on projects and tasks (add, comment)
  file      Low-level file operations (list, read, write, search, delete)
  settings  Manage workspace settings (workflow, stage, gate, tag)
  search    Search across all resources (projects, tasks, initiatives)
  config    Get/set configuration (get, set, list)
  vfs       Virtual filesystem operations (list, resolve, search)
```

## Command Reference

### Initialization

```bash
# Initialize workspace
hyper init --name "My Project"
```

### Projects

```bash
# Create project
hyper project create \
  --slug "auth-system" \
  --title "User Authentication" \
  --priority "high" \
  --summary "OAuth-based authentication" \
  --json

# List projects
hyper project list --json

# Get project details
hyper project get auth-system --json

# Update project status
hyper project update auth-system --status "in-progress"

# Archive project
hyper project archive --slug auth-system

# Unarchive project
hyper project archive --slug auth-system --unarchive
```

### Tasks

```bash
# Create task (ID auto-generated)
hyper task create \
  --project "auth-system" \
  --title "Phase 1: OAuth Setup" \
  --priority "high" \
  --json

# List tasks for project
hyper task list --project auth-system --json

# Get task details
hyper task get as-001 --json

# Update task status (ID is positional)
hyper task update as-001 --status "in-progress"
```

### File API (Low-Level)

```bash
# List files in directory
hyper file list --path $HYPER_WORKSPACE_ROOT/projects --file-type project --recursive --json

# Read file with parsed frontmatter
hyper file read $HYPER_WORKSPACE_ROOT/projects/auth-system/_project.mdx --json

# Read only frontmatter
hyper file read projects/auth-system/_project.mdx --frontmatter-only --json

# Read only body
hyper file read projects/auth-system/_project.mdx --body-only --json

# Write file (preserves frontmatter when writing body)
hyper file write projects/auth-system/_project.mdx \
  --body "# User Authentication\n\n## Overview\n..." \
  --json

# Write with frontmatter
hyper file write projects/foo/_project.mdx \
  --frontmatter "id=proj-foo" \
  --frontmatter "title=Foo" \
  --frontmatter "type=project" \
  --frontmatter "status=planning" \
  --frontmatter "priority=high" \
  --json

# Delete file
hyper file delete projects/my-feature/tasks/task-001.mdx --force --json

# Search file content
hyper file search "OAuth" --json
hyper file search "in-progress" --field status --file-type project --json
```

### Search

```bash
# Full-text search
hyper search "authentication" --json

# Filter by resource type
hyper search "auth" --resource-type project --json
hyper search "login" --resource-type task --json

# Filter by status
hyper search "OAuth" --status in-progress --json

# Filter by priority
hyper search "security" --priority high --json
```

### Drive (Notes)

```bash
# List all drive items
hyper drive list --json

# Create note (personal scope default)
hyper drive create "My Note Title" --icon "FileText" --json

# Create in folder
hyper drive create "Research Notes" --folder "research" --json

# Create in specific scope
hyper drive create "Design Doc" --scope ws:my-workspace --icon "Layout" --json

# Show note content
hyper drive show <id> --json

# Delete note
hyper drive delete <id> --force --json

# Create folder
hyper drive mkdir "research/experiments" --json

# Move note
hyper drive move "personal:my-note" --to-folder "archive" --json

# Move between scopes
hyper drive move "personal:my-note" --to-scope "ws:my-workspace" --json
```

Drive scopes:
- `--scope personal` (default) - User's personal notes
- `--scope org:<id>` - Organization-scoped notes
- `--scope ws:<id>` - Workspace-scoped notes
- `--scope proj:<id>` - Project-scoped notes

### Activity Tracking

```bash
# Add activity entry
hyper activity add \
  --file "projects/my-feature/_project.mdx" \
  --actor-id "$SESSION_ID" \
  --actor-type session \
  --action modified \
  --json

# Add comment
hyper activity comment \
  --file "projects/my-feature/tasks/task-001.mdx" \
  --actor-id "user-uuid" \
  --actor-type user \
  --actor-name "Juan Bermudez" \
  "This is ready for review"
```

Activity actions: `created`, `modified`, `commented`, `status_changed`, `assigned`

### Settings

```bash
# List all settings
hyper settings workflow list --json

# Get specific setting
hyper settings workflow get project.stages --json
hyper settings workflow get task.statuses --json

# Set value
hyper settings workflow set project.stages '["planning", "todo", "in-progress", "completed"]' --json

# Manage stages/gates/tags
hyper settings stage list --json
hyper settings gate list --json
hyper settings tag list --json
```

### Worktrees

```bash
# Create worktree for project
hyper worktree create --project my-feature --json

# List worktrees
hyper worktree list --json

# Show status
hyper worktree status --json

# Remove worktree
hyper worktree remove my-feature --json
```

### Configuration

```bash
# Get config value
hyper config get globalPath --json
hyper config get worktree.enabled --json

# Set config value
hyper config set worktree.enabled true --json
hyper config set globalPath ~/.hyper --global --json

# List all config
hyper config list --json
```

### VFS (Virtual Filesystem)

```bash
# List at virtual path
hyper vfs list /projects --json

# Resolve virtual path
hyper vfs resolve /projects/my-feature --json

# Search across sources
hyper vfs search "authentication" --json
```

## API Selection Guide

| Use Case | API | Reason |
|----------|-----|--------|
| Create new project/task | Resource API | Handles validation, defaults |
| Quick status updates | Resource API | Simple and validated |
| Bulk file operations | File API | Full control |
| Body content edits | File API | Preserves frontmatter |
| Arbitrary field read/write | File API | Direct access |

## Error Handling

All commands with `--json` return structured responses:

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
      "allowed": ["planning", "todo", "in-progress", "qa", "completed", "canceled"]
    },
    "suggestion": "Valid values: planning, todo, in-progress, qa, completed, canceled"
  }
}
```

### Error Codes

| Code | Exit | Meaning | Action |
|------|------|---------|--------|
| `SUCCESS` | 0 | Operation completed | Continue |
| `WORKSPACE_NOT_FOUND` | 1 | No workspace | Run `hyper init` |
| `PROJECT_NOT_FOUND` | 66 | Project missing | Check slug |
| `TASK_NOT_FOUND` | 66 | Task missing | Check ID |
| `FILE_NOT_FOUND` | 66 | File missing | Check path |
| `PROTECTED_PATH` | 65 | Cannot modify | Use allowed path |
| `PATH_OUTSIDE_WORKSPACE` | 65 | Invalid path | Use workspace-relative |
| `INVALID_FIELD_VALUE` | 65 | Invalid enum | Check `allowed` array |
| `MISSING_FIELD` | 65 | Required missing | Add required field |
| `IO_ERROR` | 74 | Filesystem error | Check permissions |

### Self-Correction Pattern

When receiving validation errors, extract correct values from error response:

```bash
# Step 1: Attempt with invalid status
hyper file write projects/foo/_project.mdx \
  --frontmatter "status=wip" \
  --json
# Error: { "error": { "context": { "allowed": ["planning", "todo", ...] } } }

# Step 2: Self-correct using allowed value
hyper file write projects/foo/_project.mdx \
  --frontmatter "status=in-progress" \
  --json
```

## Best Practices

1. **Always use `--json`** for programmatic operations
2. **Check exit codes** (0 = success)
3. **Parse error responses** for self-correction
4. **Use Resource API** for creation (handles defaults)
5. **Use File API** for bulk operations
6. **Never hardcode** enum values - read from errors or settings
7. **Include `--force`** for automated deletes
8. **Check project exists** before creating tasks
9. **Track activity** via CLI or PostToolUse hook
10. **Prefer Drive API** over direct file writes for notes
