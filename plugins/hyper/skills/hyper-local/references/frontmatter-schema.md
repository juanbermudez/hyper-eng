# Frontmatter Schema Reference

All `.hyper/` documents use YAML frontmatter with specific fields. This schema is compatible with Hyper Control's TanStack DB collections.

## ID Naming Convention

**CRITICAL**: Follow these ID conventions exactly for reliable parsing and incrementing.

### Project IDs

Format: `proj-{kebab-case-slug}`

```yaml
id: proj-user-auth           # From "User Authentication"
id: proj-workspace-settings  # From "Workspace Settings"
id: proj-api-refactor        # From "API Refactor"
```

### Task IDs

Format: `{project-initials}-{3-digit-number}`

**Generating project initials:**
1. Take the first letter of each word in the project slug
2. Combine them (lowercase)
3. Append 3-digit zero-padded number

| Project Slug | Initials | Task IDs |
|--------------|----------|----------|
| `user-auth` | `ua` | `ua-001`, `ua-002`, `ua-003` |
| `workspace-settings` | `ws` | `ws-001`, `ws-002`, `ws-003` |
| `content-design-system` | `cds` | `cds-001`, `cds-002`, `cds-003` |
| `api-refactor` | `ar` | `ar-001`, `ar-002`, `ar-003` |
| `session-virtualization` | `sv` | `sv-001`, `sv-002`, `sv-003` |

**Finding the next task number:**
```bash
# Get highest task number for a project
PROJECT_DIR=".hyper/projects/${PROJECT_SLUG}"
INITIALS="[derived-initials]"

# Find existing task files and extract numbers
LAST_NUM=$(ls "${PROJECT_DIR}/tasks/task-"*.mdx 2>/dev/null | \
  sed 's/.*task-\([0-9]*\)\.mdx/\1/' | \
  sort -n | tail -1)

# Default to 0 if no tasks exist
LAST_NUM=${LAST_NUM:-0}
NEXT_NUM=$(printf "%03d" $((10#$LAST_NUM + 1)))

# New task ID
TASK_ID="${INITIALS}-${NEXT_NUM}"
```

### Task File Naming

Task files use the **number only** (not the full ID):
- File: `task-001.mdx`, `task-002.mdx`, etc.
- ID inside: `ua-001`, `ua-002`, etc.

This keeps filenames short while IDs remain unique across projects.

### Examples

```yaml
# Project: .hyper/projects/user-auth/_project.mdx
---
id: proj-user-auth
title: "User Authentication"
type: project
---

# Task: .hyper/projects/user-auth/tasks/task-001.mdx
---
id: ua-001
title: "Phase 1: OAuth Setup"
type: task
parent: proj-user-auth
---

# Task: .hyper/projects/user-auth/tasks/task-002.mdx
---
id: ua-002
title: "Phase 2: Session Management"
type: task
parent: proj-user-auth
depends_on:
  - ua-001
---
```

## Common Fields (All Documents)

```yaml
---
id: string           # Unique identifier (required)
title: string        # Human-readable title (required)
type: string         # Document type (required)
status: string       # Current status (optional, depends on type)
priority: string     # Priority level (optional)
created: string      # ISO date: YYYY-MM-DD (required)
updated: string      # ISO date: YYYY-MM-DD (required)
tags: string[]       # Searchable tags (optional)
---
```

## Document Types

Valid values for `type`:

| Type | Description | Status Values |
|------|-------------|---------------|
| `initiative` | Strategic grouping | planned, in-progress, qa, completed, canceled |
| `project` | Work container | planned, todo, in-progress, qa, completed, canceled |
| `task` | Implementation unit | draft, todo, in-progress, qa, complete, blocked |
| `resource` | Supporting documentation | (none) |
| `doc` | Standalone documentation | (none) |

## Status Values

### Task Statuses

| Status | Description | Next States |
|--------|-------------|-------------|
| `draft` | Work in progress, not ready | todo |
| `todo` | Ready to be worked on | in-progress, blocked |
| `in-progress` | Active work | qa, blocked |
| `qa` | Quality assurance & verification | complete, in-progress |
| `complete` | Done, all checks passed | (terminal) |
| `blocked` | Blocked by dependencies | todo, in-progress |

**QA Status**: This is where automated checks (lint, typecheck, test, build) and manual verification occur. Tasks should only move to `complete` after ALL quality gates pass.

### Project Statuses

| Status | Description | Next States |
|--------|-------------|-------------|
| `planned` | In backlog, spec phase | todo, canceled |
| `todo` | Spec approved, ready for work | in-progress, canceled |
| `in-progress` | Active development | ready-for-review, qa, canceled |
| `ready-for-review` | Research complete, awaiting review | completed, in-progress |
| `qa` | All tasks done, project-level QA | completed, in-progress |
| `completed` | Successfully finished | (terminal) |
| `canceled` | Won't do | (terminal) |

**QA Status**: Projects enter QA when all tasks are complete. This is for project-level verification: integration testing, final review, documentation check.

**Ready for Review Status**: Used primarily for research projects. Indicates research is complete and awaiting human review before archiving or follow-up planning.

### Initiative Statuses

Same as project statuses.

## Priority Values

| Priority | Description | Typical Use |
|----------|-------------|-------------|
| `urgent` | Needs immediate attention | Blockers, critical bugs |
| `high` | Important, do soon | Core features |
| `medium` | Normal priority | Standard work |
| `low` | Nice to have | Improvements, minor fixes |

## Task-Specific Fields

```yaml
---
# ... common fields ...
parent: string       # Parent project ID (required for tasks)
depends_on: string[] # IDs this task depends on
blocks: string[]     # IDs this task blocks
assignee: string     # Optional assignee name/email
---
```

### Example Task

```yaml
---
id: task-auth-system-001
title: "Phase 1: OAuth Provider Setup"
type: task
status: todo
priority: high
parent: proj-auth-system
depends_on: []
blocks:
  - task-auth-system-002
created: 2025-12-28
updated: 2025-12-28
tags:
  - oauth
  - setup
---
```

## Project-Specific Fields

```yaml
---
# ... common fields ...
summary: string              # Brief description for project cards
project_type: string         # Optional: feature, research, or spike
archived: boolean            # Optional: hide from default views (default: false)
---
```

### Project Types

| Type | Description | Typical Status Flow |
|------|-------------|---------------------|
| `feature` | New functionality (default) | planned → todo → in-progress → qa → completed |
| `research` | Investigation, exploration | planned → in-progress → ready-for-review → completed |
| `spike` | Time-boxed investigation | planned → in-progress → completed |

### Archiving Projects

Set `archived: true` to hide a project from default views. Useful for completed research or old projects.

```yaml
---
id: proj-old-research
archived: true    # Hidden from project list
status: completed
---
```

To archive via CLI: `hyper project archive --slug old-research`
To unarchive: `hyper project archive --slug old-research --unarchive`

### Example Project

```yaml
---
id: proj-auth-system
title: "User Authentication System"
type: project
status: planned
priority: high
summary: "OAuth-based authentication with Google and GitHub providers"
created: 2025-12-28
updated: 2025-12-28
tags:
  - auth
  - oauth
  - security
---
```

## Resource-Specific Fields

Resources typically don't have status or priority:

```yaml
---
id: resource-auth-system-spec
title: "Specification"
type: resource
created: 2025-12-28
updated: 2025-12-28
tags:
  - spec
  - documentation
---
```

## Relationship Fields

### depends_on

Tasks this task depends on (blockers):

```yaml
depends_on:
  - task-auth-system-001
  - task-auth-system-002
```

### blocks

Tasks this task blocks (reverse dependencies):

```yaml
blocks:
  - task-auth-system-003
```

### related_to

Related documents (informational):

```yaml
related_to:
  - doc-architecture
  - resource-auth-system-spec
```

## Date Format

Always use ISO 8601 format:

```yaml
created: 2025-12-28
updated: 2025-12-28
```

## Tags Format

YAML array format:

```yaml
# Inline format
tags: [auth, oauth, security]

# Multi-line format
tags:
  - auth
  - oauth
  - security
```

## Custom Fields

Additional fields are allowed and will be displayed in Hyper Control:

```yaml
---
id: task-custom-001
title: "Custom Task"
type: task
status: todo
# Custom fields
estimated_hours: 4
complexity: medium
reviewer: "@johndoe"
---
```

## Validation Rules

1. **id** must be unique across the workspace
2. **type** must be a valid document type
3. **status** must be valid for the document type
4. **priority** must be a valid priority value
5. **created** and **updated** must be valid ISO dates
6. **parent** is required for tasks, must reference existing project
7. **depends_on** references must exist
8. **tags** must be an array of strings

## Activity Tracking

The `activity` field tracks who modified a document and when. Activity entries are
automatically added by the PostToolUse hook (for agent sessions) or manually (for
users via UI or CLI).

### Activity Field Structure

```yaml
activity:
  # Agent session example
  - timestamp: "2026-01-02T10:30:00Z"   # ISO 8601 with timezone
    actor:
      type: session                      # Claude Code session
      id: "abc-123-def"                  # Session UUID
      parent_id: "parent-456"            # Optional - for sub-agent sessions
    action: modified                     # See action types below
    content: "Updated implementation"    # Optional description

  # User comment example
  - timestamp: "2026-01-02T11:00:00Z"
    actor:
      type: user                         # Human user
      id: "user-uuid-789"                # User UUID (from Supabase)
      name: "Juan Bermudez"              # Display name (required for users)
    action: commented
    content: "Looks good, ready for review!"  # Required for comments

  # User status change example
  - timestamp: "2026-01-02T11:30:00Z"
    actor:
      type: user
      id: "user-uuid-789"
      name: "Juan Bermudez"
    action: status_changed
    content: "Moving to QA after final review"
```

### Actor Types

| Type | Fields | Use Case |
|------|--------|----------|
| `session` | id, name?, parent_id? | Claude Code agent sessions |
| `user` | id, name | Human users via UI |

### Action Types

| Action | Description | Content |
|--------|-------------|---------|
| `created` | Initial creation | Optional |
| `modified` | File content changed | Optional |
| `commented` | Added a comment | Required |
| `status_changed` | Status transition | Optional |
| `assigned` | Task assigned (future) | Optional |

### Automatic Activity Tracking

For Claude Code sessions, activity is tracked automatically:

1. **PostToolUse hook** triggers on Write/Edit operations to `.hyper/` files
2. **Hook script** (`track-activity.sh`) extracts session_id from hook payload
3. **Hyper CLI** appends activity entry to frontmatter

Agents do NOT need to manually log activity - just use Write/Edit tools normally.

### Manual Activity (CLI)

For user-initiated activities (comments, status changes from UI):

```bash
# Add a comment
${CLAUDE_PLUGIN_ROOT}/binaries/hyper activity comment \
  --file ".hyper/projects/my-project/tasks/task-001.mdx" \
  --actor-type user \
  --actor-id "user-uuid" \
  --actor-name "Juan Bermudez" \
  "This looks ready for review"

# Add an activity entry
${CLAUDE_PLUGIN_ROOT}/binaries/hyper activity add \
  --file ".hyper/projects/my-project/tasks/task-001.mdx" \
  --actor-type user \
  --actor-id "user-uuid" \
  --actor-name "Juan Bermudez" \
  --action status_changed \
  --content "Moving to QA"
```

## TypeScript Schema (Hyper Control)

```typescript
interface Actor {
  type: 'session' | 'user';
  id: string;
  name?: string;
  parent_id?: string;
}

interface ActivityEntry {
  timestamp: string;
  actor: Actor;
  action: 'created' | 'modified' | 'commented' | 'status_changed' | 'assigned';
  content?: string;
}

interface Frontmatter {
  id: string;
  title: string;
  type: 'initiative' | 'project' | 'task' | 'resource' | 'doc';
  status?: string;
  priority?: 'urgent' | 'high' | 'medium' | 'low';
  parent?: string;
  blocks?: string[];
  depends_on?: string[];
  related_to?: string[];
  assignee?: string;
  tags?: string[];
  created: string;
  updated: string;
  summary?: string;
  activity?: ActivityEntry[];
  // Additional fields allowed
  [key: string]: unknown;
}
```
