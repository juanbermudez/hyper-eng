# Hypercraft CLI Reference

The Hypercraft CLI is the **primary interface for agents** to interact with ALL artifacts (projects, tasks, workflows, skills, agents, drive notes).

**CRITICAL**: Agents should NEVER use `find`, `grep`, `ls`, `cat` for discovery or file operations. Always use the Hypercraft CLI.

## CLI Overview

```
hypercraft <COMMAND>

Commands:
  find      🔍 Unified discovery across all resources (projects, tasks, workflows, skills, agents, notes)
  project   Manage workspace projects (list, get, create, update)
  task      Manage workspace tasks (list, get, create, update)
  drive     Manage HyperHome drive items/notes (list, create, show, delete, mkdir)
  file      Low-level file operations (list, read, write, delete)
  activity  Track activity on projects and tasks (add, comment)
  settings  Manage workspace settings (workflow, stage, gate, tag)
  config    Get/set configuration (get, set, list)
  index     Manage QFS search index (add, build, status)
  vfs       Virtual filesystem path resolution (resolve)
  init      Initialize a new workspace
  worktree  Manage git worktrees for isolated development
```

## The Two Commands Agents Need

### 1. Discovery: `hypercraft find`
```bash
hypercraft find <query> --type <type> [--status X] [--json]
```

### 2. Operations: `hypercraft <resource> <action>`
```bash
hypercraft project create --slug X --title Y --json
hypercraft task update <id> --status done --json
hypercraft file read <path> --json
hypercraft drive create "Title" --json
```

---

## Find Command (Unified Discovery)

**Use `find` for ALL discovery operations.** It searches across the QFS index for fast, semantic search.

```bash
hypercraft find <query> [OPTIONS]

OPTIONS:
  -t, --type <TYPE>       Resource type [projects, tasks, workflows, skills, agents, notes, all]
  -s, --status <STATUS>   Filter by status field
  -p, --priority <PRIORITY> Filter by priority field
  -m, --mode <MODE>       Search mode [bm25, vector, hybrid] (default: bm25)
  -n, --limit <N>         Max results (default: 20)
  --all                   Return all matches (for listing/aggregation)
  --json                  Output as JSON
```

### Examples

```bash
# Find projects matching "auth"
hypercraft find "auth" --type projects --json

# Find in-progress tasks
hypercraft find "" --type tasks --status in-progress --json

# Find workflows for planning
hypercraft find "plan" --type workflows --json

# Find skills for testing
hypercraft find "testing" --type skills --json

# Find captain agents
hypercraft find "captain" --type agents --json

# Semantic search across everything
hypercraft find "authentication flow" --mode hybrid --json

# List ALL tasks from all projects
hypercraft find --type tasks --all --json

# List ALL workflows
hypercraft find --type workflows --all --json
```

### Resource Type Mapping

| `--type` | What Gets Searched |
|----------|-------------------|
| `projects` | Project MDX files (`_project.mdx`) |
| `tasks` | Task MDX files (`tasks/*.mdx`) - aggregated from all projects |
| `workflows` | Workflow programs (`*.prose`) |
| `skills` | Skill definitions (`SKILL.md`) |
| `agents` | Agent definitions (`agents/**/*.md`) |
| `notes` | Drive notes |
| `all` | Everything (default) |

---

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

# Read file content
hypercraft file read projects/auth/_project.mdx --json
hypercraft file read projects/auth/_project.mdx --frontmatter-only --json
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

### VFS (Path Resolution)

Convert virtual paths to physical paths:

```bash
hypercraft vfs resolve /projects/my-feature --json
```

| Virtual Path | Resolves To |
|--------------|-------------|
| `/projects` | `$HYPER_WORKSPACE_ROOT/projects/` |
| `/projects/{slug}` | `$HYPER_WORKSPACE_ROOT/projects/{slug}/` |
| `/notes` | Personal Drive directory |
| `/settings` | Workspace settings directory |

### Index Management

```bash
# Add a collection to the index
hypercraft index add workflows plugins/hyper/commands/workflows --patterns "**/*.prose" --json

# Build/rebuild the index
hypercraft index build --json

# Check index status
hypercraft index status --json

# List indexed collections
hypercraft index list --json
```

## API Selection Guide

| Use Case | Command | Reason |
|----------|---------|--------|
| **Discovery** | `hypercraft find` | Unified search across all resources |
| Create project/task | `hypercraft project/task create` | Handles validation, defaults |
| Update status | `hypercraft project/task update` | Simple and validated |
| Read file content | `hypercraft file read` | Parsed frontmatter |
| Write file content | `hypercraft file write` | Validates and preserves structure |
| Get physical path | `hypercraft vfs resolve` | Path resolution |
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
