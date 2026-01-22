# Hypercraft CLI Reference

The Hypercraft CLI provides commands for managing workspace projects, tasks, Drive notes, and configuration. **Always use the CLI for workspace operations** to ensure validation, activity tracking, and data integrity.

## CLI Overview

```
hypercraft <COMMAND>

Commands:
  init      Initialize a new workspace
  worktree  Manage git worktrees for isolated development
  project   Manage workspace projects (list, get, create, update)
  task      Manage workspace tasks (list, get, create, update)
  drive     Manage HyperHome drive items/notes (list, create, show, delete, mkdir)
  activity  Track activity on projects and tasks (add, comment)
  file      Low-level file operations (list, read, write, search, delete)
  settings  Manage workspace settings (workflow, stage, gate, tag)
  search    Search across all resources (projects, tasks)
  config    Get/set configuration (get, set, list)
  vfs       Virtual filesystem operations (list, resolve, search)
```

## Command Reference

### Initialization

```bash
# Initialize workspace
hypercraft init --name "My Project"
```

### Projects

```bash
# Create project
hypercraft project create \
  --slug "auth-system" \
  --title "User Authentication" \
  --priority "high" \
  --summary "OAuth-based authentication" \
  --json

# List projects
hypercraft project list --json

# Get project details
hypercraft project get auth-system --json

# Update project status
hypercraft project update auth-system --status "in-progress"

# Archive project
hypercraft project archive --slug auth-system

# Unarchive project
hypercraft project archive --slug auth-system --unarchive
```

### Tasks

```bash
# Create task (ID auto-generated)
hypercraft task create \
  --project "auth-system" \
  --title "Phase 1: OAuth Setup" \
  --priority "high" \
  --json

# List tasks for project
hypercraft task list --project auth-system --json

# Get task details
hypercraft task get as-001 --json

# Update task status (ID is positional)
hypercraft task update as-001 --status "in-progress"
```

### File API (Low-Level)

```bash
# List files in directory
hypercraft file list --path $HYPER_WORKSPACE_ROOT/projects --file-type project --recursive --json

# Read file with parsed frontmatter
hypercraft file read $HYPER_WORKSPACE_ROOT/projects/auth-system/_project.mdx --json

# Read only frontmatter
hypercraft file read projects/auth-system/_project.mdx --frontmatter-only --json

# Read only body
hypercraft file read projects/auth-system/_project.mdx --body-only --json

# Write file (preserves frontmatter when writing body)
hypercraft file write projects/auth-system/_project.mdx \
  --body "# User Authentication\n\n## Overview\n..." \
  --json

# Write with frontmatter
hypercraft file write projects/foo/_project.mdx \
  --frontmatter "id=proj-foo" \
  --frontmatter "title=Foo" \
  --frontmatter "type=project" \
  --frontmatter "status=planned" \
  --frontmatter "priority=high" \
  --json

# Delete file
hypercraft file delete projects/my-feature/tasks/task-001.mdx --force --json

# Search file content
hypercraft file search "OAuth" --json
hypercraft file search "in-progress" --field status --file-type project --json
```

### Search

```bash
# Full-text search
hypercraft search "authentication" --json

# Filter by resource type
hypercraft search "auth" --resource-type project --json
hypercraft search "login" --resource-type task --json

# Filter by status
hypercraft search "OAuth" --status in-progress --json

# Filter by priority
hypercraft search "security" --priority high --json
```

### Drive (Notes)

```bash
# List all drive items
hypercraft drive list --json

# Create note (personal scope default)
hypercraft drive create "My Note Title" --icon "FileText" --json

# Create in folder
hypercraft drive create "Research Notes" --folder "research" --json

# Create in specific scope
hypercraft drive create "Design Doc" --scope ws:my-workspace --icon "Layout" --json

# Show note content
hypercraft drive show <id> --json

# Delete note
hypercraft drive delete <id> --force --json

# Create folder
hypercraft drive mkdir "research/experiments" --json

# Move note
hypercraft drive move "personal:my-note" --to-folder "archive" --json

# Move between scopes
hypercraft drive move "personal:my-note" --to-scope "ws:my-workspace" --json
```

Drive scopes:
- `--scope personal` (default) - User's personal notes
- `--scope org:<id>` - Organization-scoped notes
- `--scope ws:<id>` - Workspace-scoped notes
- `--scope proj:<id>` - Project-scoped notes

### Activity Tracking

```bash
# Add activity entry
hypercraft activity add \
  --file "projects/my-feature/_project.mdx" \
  --actor-id "$SESSION_ID" \
  --actor-type session \
  --action modified \
  --json

# Add comment
hypercraft activity comment \
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
hypercraft settings workflow list --json

# Get specific setting
hypercraft settings workflow get project.stages --json
hypercraft settings workflow get task.statuses --json

# Set value
hypercraft settings workflow set project.stages '["planned", "todo", "in-progress", "qa", "completed"]' --json

# Manage stages/gates/tags
hypercraft settings stage list --json
hypercraft settings gate list --json
hypercraft settings tag list --json
```

### Worktrees

```bash
# Create worktree for project
hypercraft worktree create --project my-feature --json

# List worktrees
hypercraft worktree list --json

# Show status
hypercraft worktree status --json

# Remove worktree
hypercraft worktree remove my-feature --json
```

### Configuration

```bash
# Get config value
hypercraft config get globalPath --json
hypercraft config get worktree.enabled --json

# Set config value
hypercraft config set worktree.enabled true --json
hypercraft config set globalPath ~/.hypercraft --global --json

# List all config
hypercraft config list --json
```

### VFS (Virtual Filesystem)

```bash
# List at virtual path
hypercraft vfs list /projects --json

# Resolve virtual path
hypercraft vfs resolve /projects/my-feature --json

# Search across sources
hypercraft vfs search "authentication" --json
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
      "allowed": ["planned", "todo", "in-progress", "qa", "completed", "canceled"]
    },
    "suggestion": "Valid values: planned, todo, in-progress, qa, completed, canceled"
  }
}
```

### Error Codes

| Code | Exit | Meaning | Action |
|------|------|---------|--------|
| `SUCCESS` | 0 | Operation completed | Continue |
| `WORKSPACE_NOT_FOUND` | 1 | No workspace | Run `hypercraft init` |
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
hypercraft file write projects/foo/_project.mdx \
  --frontmatter "status=wip" \
  --json
# Error: { "error": { "context": { "allowed": ["planned", "todo", ...] } } }

# Step 2: Self-correct using allowed value
hypercraft file write projects/foo/_project.mdx \
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
