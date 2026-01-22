---
name: hyper-cli
description: This skill provides guidance on using the Hypercraft CLI for programmatic file operations. This skill should be used when agents need to create, read, update, delete, or search files in the $HYPER_WORKSPACE_ROOT/ directory structure, manage Drive notes, track activity, handle validation errors, or self-correct from structured error responses.
model: sonnet
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
---

<skill name="hyper-cli">

<description>
This skill teaches AI agents how to work with the Hypercraft CLI for programmatic manipulation of `$HYPER_WORKSPACE_ROOT/` planning documents and HyperHome Drive notes. It covers both the Resource API (high-level operations) and File API (low-level plumbing), error handling patterns, and self-correction workflows.
</description>

<note>
Core workflow context lives in `hyper-craft`. This skill is a CLI reference only.
</note>

<context>

## CLI Overview

The Hypercraft CLI provides commands for managing workspace projects, tasks, Drive notes, and configuration.

```
hypercraft <COMMAND>

Commands:
  init        Initialize a new workspace
  add-skill   Install skills across multiple agents
  add-plugin  Install plugins (Claude + emulated Codex)
  worktree    Manage git worktrees for isolated development
  project     Manage workspace projects (list, get, create, update)
  task        Manage workspace tasks (list, get, create, update)
  drive       Manage HyperHome drive items/notes (list, create, show, delete, mkdir)
  agents      Manage Claude/Codex primitives (config, skill, agent)
  config      Get/set configuration (get, set, list)
  activity    Track activity on projects and tasks (add, comment)
  file        Low-level file operations (list, read, write, search, delete)
  settings    Manage workspace settings (workflow, stage, gate, tag)
  search      Search across all resources (projects, tasks)
  vfs         Virtual filesystem operations (list, resolve, search)
```

## Quick Reference

### Essential Commands

| Operation | Resource API (Porcelain) | File API (Plumbing) |
|-----------|-------------------------|---------------------|
| Initialize workspace | `hypercraft init --name "My Project"` | N/A |
| List projects | `hypercraft project list --json` | `hypercraft file list projects --json` |
| Create project | `hypercraft project create --slug x --title "X"` | `hypercraft file write projects/x/_project.mdx --frontmatter "..."` |
| Update status | `hypercraft project update x --status in-progress` | `hypercraft file write projects/x/_project.mdx --frontmatter "status=in-progress"` |
| Read project | `hypercraft project get x --json` | `hypercraft file read projects/x/_project.mdx --json` |
| Delete file | N/A (use file API) | `hypercraft file delete projects/x/_project.mdx --force --json` |
| Search | `hypercraft search "query" --json` | `hypercraft file search "query" --json` |
| Task operations | `hypercraft task list/get/create/update` | `hypercraft file ...` on task files |
| Drive notes | `hypercraft drive list/create/show/delete` | N/A |
| Activity tracking | `hypercraft activity add/comment` | N/A |

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

## Skills and Plugins

Use these commands to install skills/plugins across multiple agent environments or duplicate existing primitives.

```
# Install all skills to detected agents in every workspace
hypercraft add-skill owner/repo --all --all-skills

# Install a specific skill to all workspaces
hypercraft add-skill owner/repo --skill hyper-local --all

# Install a specific skill to Claude Code and Codex
hypercraft add-skill owner/repo --skill hyper-local --agent claude-code --agent codex

# Install a Claude/Codex plugin (manifest in .claude-plugin/)
hypercraft add-plugin owner/repo --all

# Duplicate a skill within Claude or Codex
hypercraft agents skill duplicate claude my-skill my-skill-custom --force

# Duplicate a Claude subagent
hypercraft agents agent duplicate claude research-orchestrator research-orchestrator-custom --force
```

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
status: planned           # Required, enum: planned|todo|in-progress|qa|completed|canceled
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
status: todo              # Required, enum: draft|todo|in-progress|qa|complete|blocked
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
| `WORKSPACE_NOT_FOUND` | 1 | No $HYPER_WORKSPACE_ROOT/ directory | Run `hypercraft init` |
| `PROJECT_NOT_FOUND` | 66 | Project doesn't exist | Check slug, create if needed |
| `TASK_NOT_FOUND` | 66 | Task doesn't exist | Check ID |
| `FILE_NOT_FOUND` | 66 | File doesn't exist | Check path |
| `PROTECTED_PATH` | 65 | Cannot modify location | Use allowed path |
| `PATH_OUTSIDE_WORKSPACE` | 65 | Path not in workspace | Use workspace-relative path |
| `INVALID_FIELD_VALUE` | 65 | Value not in enum | Check `allowed` array in error |
| `INVALID_ENUM_VALUE` | 65 | Enum field has invalid value | Check `allowed` array in error |
| `MISSING_FIELD` | 65 | Required field missing | Add required field |
| `MISSING_REQUIRED_FIELD` | 65 | Required field missing | Add required field |
| `YAML_PARSE_ERROR` | 65 | YAML frontmatter syntax error | Check suggestion for fix |
| `INVALID_PARENT_REFERENCE` | 65 | Task's parent project doesn't exist | Check project ID |
| `INVALID_DEPENDENCY_REFERENCE` | 65 | depends_on references non-existent task | Check task ID |
| `SELF_DEPENDENCY` | 65 | Task depends on itself | Remove self-reference |
| `CIRCULAR_DEPENDENCY` | 65 | Dependency cycle detected | Break the cycle |
| `MALFORMED_ID` | 65 | ID format incorrect | Check ID pattern |
| `INVALID_DATE_FORMAT` | 65 | Date not in YYYY-MM-DD format | Use ISO format |
| `IO_ERROR` | 74 | Filesystem error | Retry or check permissions |

### Self-Correction Pattern

When receiving a validation error, extract correct values from the error response:

```bash
# Step 1: Attempt with invalid status
hypercraft file write $HYPER_WORKSPACE_ROOT/projects/foo/_project.mdx \
  --frontmatter "id=proj-foo" \
  --frontmatter "title=Foo" \
  --frontmatter "type=project" \
  --frontmatter "status=wip" \
  --frontmatter "priority=high" \
  --json

# Error response includes allowed values:
# { "error": { "context": { "allowed": ["planned", "todo", ...] } } }

# Step 2: Self-correct using the allowed value
hypercraft file write $HYPER_WORKSPACE_ROOT/projects/foo/_project.mdx \
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
- `$HYPER_WORKSPACE_ROOT/settings` (directory itself)

**CAN create/edit/delete:**
- `$HYPER_WORKSPACE_ROOT/projects/{slug}/` (project directories)
- `$HYPER_WORKSPACE_ROOT/projects/{slug}/_project.mdx` (project files)
- `$HYPER_WORKSPACE_ROOT/projects/{slug}/tasks/*.mdx` (task files)
- `$HYPER_WORKSPACE_ROOT/projects/{slug}/resources/**` (resource files)
- `$HYPER_WORKSPACE_ROOT/notes/*.mdx` (personal drive notes)
- `$HYPER_WORKSPACE_ROOT/notes/**/*.mdx` (nested notes in subfolders)
- `$HYPER_WORKSPACE_ROOT/docs/**/*.md` (documentation)
- `$HYPER_WORKSPACE_ROOT/settings/workflows.yaml` (workflow config)
- `$HYPER_WORKSPACE_ROOT/settings/agents/*.yaml` (agent configs)
- `$HYPER_WORKSPACE_ROOT/settings/commands/*.md` (command customizations)

## Common Workflows

### Creating a New Project

```bash
# Option 1: Resource API (recommended for creation)
hypercraft project create \
  --slug my-feature \
  --title "My Feature" \
  --priority high \
  --summary "Implementing a new feature" \
  --json

# Option 2: File API (for full control)
hypercraft file write $HYPER_WORKSPACE_ROOT/projects/my-feature/_project.mdx \
  --frontmatter "id=proj-my-feature" \
  --frontmatter "title=My Feature" \
  --frontmatter "type=project" \
  --frontmatter "status=planned" \
  --frontmatter "priority=high" \
  --frontmatter "summary=Implementing a new feature" \
  --body "# My Feature\n\n## Description\n..." \
  --json
```

### Updating Project Status

```bash
# Resource API (simple)
hypercraft project update my-feature --status in-progress

# File API (preserves existing body content)
hypercraft file write $HYPER_WORKSPACE_ROOT/projects/my-feature/_project.mdx \
  --frontmatter "status=in-progress" \
  --json
```

### Creating a Task

```bash
# Resource API
hypercraft task create \
  --project my-feature \
  --title "Phase 1: Foundation" \
  --priority high \
  --json

# File API (full control)
hypercraft file write $HYPER_WORKSPACE_ROOT/projects/my-feature/tasks/task-001.mdx \
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
hypercraft task update mf-001 --status in-progress

# File API
hypercraft file write $HYPER_WORKSPACE_ROOT/projects/my-feature/tasks/task-001.mdx \
  --frontmatter "status=in-progress" \
  --json
```

### Deleting Files

```bash
# Delete a task file
hypercraft file delete projects/my-feature/tasks/task-001.mdx --force --json

# Delete a project directory (removes all tasks too)
hypercraft file delete projects/my-feature --force --json

# Note: Resource API (project/task) does not have delete - use file API
```

### Searching for Content

```bash
# Search by content (full text)
hypercraft file search "authentication" --json

# Search by field value
hypercraft file search "in-progress" --field status --file-type project --json

# High-level search with filters
hypercraft search "OAuth" --status in-progress --json
```

### Reading Workflow Configuration

```bash
# List all settings
hypercraft settings workflow list --json

# Get project stages
hypercraft settings workflow get project.stages --json

# Get task statuses
hypercraft settings workflow get task.statuses --json

# Set a value
hypercraft settings workflow set project.stages '["planned", "todo", "in-progress", "qa", "completed"]' --json
```

### Reading and Writing Files

```bash
# List files in a directory
hypercraft file list --path $HYPER_WORKSPACE_ROOT/projects --file-type project --recursive --json

# Read a file
hypercraft file read $HYPER_WORKSPACE_ROOT/projects/my-feature/_project.mdx --json

# Read only frontmatter
hypercraft file read $HYPER_WORKSPACE_ROOT/projects/my-feature/_project.mdx --frontmatter-only --json

# Read only body
hypercraft file read $HYPER_WORKSPACE_ROOT/projects/my-feature/_project.mdx --body-only --json
```

## Settings API

The settings API allows reading and modifying workflow configuration:

```bash
# Full workflow config
hypercraft settings workflow list --json

# Get specific setting
hypercraft settings workflow get project.stages --json

# Set a value
hypercraft settings workflow set project.stages '["planned", "todo", "in-progress", "qa", "completed"]' --json

# Manage workflow stages
hypercraft settings stage list --json
hypercraft settings gate list --json
hypercraft settings tag list --json
```

## Drive API

Manage HyperHome Drive items (wiki-style notes):

```bash
# List all drive items
hypercraft drive list --json

# Create a new note
hypercraft drive create "My Note Title" --folder "research" --icon "book" --json

# Show note content
hypercraft drive show <id> --json

# Delete a note
hypercraft drive delete <id> --force --json

# Create a folder
hypercraft drive mkdir "research/experiments" --json

# Move a note to a different folder or scope
hypercraft drive move <id> --to-folder "archive" --json
hypercraft drive move <id> --to-scope "ws:my-workspace" --json
hypercraft drive move <id> --to-scope "personal" --to-folder "notes" --keep-redirect --json
```

### Moving Drive Items

The `hypercraft drive move` command moves notes between folders and/or scopes:

```bash
# Move to a different folder (same scope)
hypercraft drive move "personal:my-note" --to-folder "archive" --json

# Move to a different scope (note gets new ID)
hypercraft drive move "personal:my-note" --to-scope "ws:workspace-id" --json

# Move with redirect (leaves pointer at old location)
hypercraft drive move "personal:my-note" --to-scope "ws:workspace-id" --keep-redirect --json
```

**Cross-scope moves**:
- Generate a new ID with the target scope prefix
- Optionally create a redirect file at the old location (with `--keep-redirect`)
- Update all file references automatically

**Same-scope moves**:
- Update the `folder` field in frontmatter
- Preserve the same ID

Drive notes support scopes:
- `--scope personal` (default) - User's personal notes in global `/drive`
- `--scope org:<id>` - Organization-scoped notes
- `--scope ws:<id>` - Workspace-scoped notes (shown in workspace Drive view)
- `--scope proj:<id>` - Project-scoped notes in project resources

### Choosing the Right Scope

| Artifact Type | Recommended Scope | Rationale |
|---------------|-------------------|-----------|
| Personal notes | `personal:` | Private learning, research, drafts |
| Workspace artifacts | `ws:{workspaceId}:` | Shared context for workspace projects |
| Project diagrams | `proj:{projectId}:` | Project-specific design docs |
| Team templates | `org:{orgId}:` | Cross-workspace org standards |

**Rule of thumb**:
- Personal notes → Personal Drive (`hypercraft drive create "..." --scope personal`)
- Project artifacts → Workspace Drive (`hypercraft drive create "..." --scope ws:{id}`)
- Planning docs → `$HYPER_WORKSPACE_ROOT/projects/{slug}/` (git-tracked)

### Workspace-Scoped Drive Examples

```bash
# Create in personal drive (default)
hypercraft drive create "My Personal Note" --icon "FileText"

# Create in workspace drive (visible in workspace Drive view)
hypercraft drive create "Design Doc" --scope ws:my-workspace --icon "Layout"

# Create in project scope
hypercraft drive create "Architecture" --scope proj:my-project --icon "Box"

# List workspace drive items
hypercraft drive list --scope ws:my-workspace --json
```

### Drive File Frontmatter Format

**CRITICAL**: When creating drive files directly (without CLI), you MUST follow this exact format or files will not appear in the Hypercraft UI.

```yaml
---
id: "personal:my-note-slug"        # REQUIRED: Scope-prefixed ID (see below)
title: "My Note Title"             # REQUIRED: Human-readable title
icon: FileText                     # OPTIONAL: Lucide icon name (default: "box")
created: 2026-01-18                # REQUIRED: ISO date (YYYY-MM-DD)
updated: 2026-01-18                # OPTIONAL: ISO date
sortPosition: a0                   # OPTIONAL: Fractional index for ordering
tags:                              # OPTIONAL: Searchable tags
  - tag1
  - tag2
---
```

### ID Format (CRITICAL)

The `id` field MUST include a scope prefix followed by a colon:

| Scope | ID Format | Example |
|-------|-----------|---------|
| Personal | `personal:{slug}` | `id: "personal:my-research-notes"` |
| Organization | `org-{orgId}:{slug}` | `id: "org-abc123:team-docs"` |
| Workspace | `ws-{wsId}:{slug}` | `id: "ws-proj-123:feature-notes"` |
| Project | `proj-{projId}:{slug}` | `id: "proj-auth:design-doc"` |

**Common Mistakes to Avoid:**

| Mistake | Correct |
|---------|---------|
| `id: my-note` | `id: "personal:my-note"` (missing scope prefix) |
| `id: personal/my-note` | `id: "personal:my-note"` (use colon, not slash) |
| `id: PERSONAL:my-note` | `id: "personal:my-note"` (lowercase scope) |
| Missing quotes | `id: "personal:my-note"` (quote if contains colons) |

### Recommended: Use CLI Instead

**Always prefer the CLI** for creating drive files:

```bash
# CLI handles ID generation, validation, and formatting automatically
hypercraft drive create "My Note Title" --icon "FileText" --json
```

The CLI:
- Generates correct scope-prefixed IDs
- Sets required fields with defaults
- Validates frontmatter format
- Tracks activity automatically

Only write files directly when the CLI is not available.

## Activity Tracking API

Track activity on projects and tasks:

```bash
# Add activity entry (automatic via hooks, but can be manual)
hypercraft activity add \
  --file "projects/my-feature/_project.mdx" \
  --actor-id "$SESSION_ID" \
  --actor-type session \
  --action modified \
  --json

# Add a comment (convenience wrapper)
hypercraft activity comment \
  --file "projects/my-feature/tasks/task-001.mdx" \
  --actor-id "user-uuid" \
  --actor-type user \
  --actor-name "Juan Bermudez" \
  "This is ready for review"
```

Activity actions:
- `created` - Initial creation
- `modified` - Content changed
- `commented` - Comment added
- `status_changed` - Status transition
- `assigned` - Assignment changed

## Worktree API

Manage git worktrees for isolated development:

```bash
# Create worktree for a project
hypercraft worktree create --project my-feature --json

# List all worktrees
hypercraft worktree list --json

# Show current worktree status
hypercraft worktree status --json

# Remove a worktree
hypercraft worktree remove my-feature --json
```

## Search API

Search across all workspace resources:

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

## VFS (Virtual Filesystem) API

Unified access across workspace and Drive:

```bash
# List files at virtual path
hypercraft vfs list /projects --json

# Resolve virtual path to physical
hypercraft vfs resolve /projects/my-feature --json

# Search across all sources
hypercraft vfs search "authentication" --json
```

## Configuration API

Manage workspace and global configuration:

```bash
# Get a config value
hypercraft config get globalPath --json
hypercraft config get worktree.enabled --json

# Set a config value
hypercraft config set worktree.enabled true --json
hypercraft config set globalPath ~/.hypercraft --global --json

# List all config
hypercraft config list --json
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
9. **Use activity tracking** to maintain audit trail on modifications
10. **Prefer Drive API** for notes over direct file manipulation

</context>

</skill>
