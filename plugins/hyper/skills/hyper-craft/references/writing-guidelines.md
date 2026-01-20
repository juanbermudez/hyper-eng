# Writing Guidelines

This document defines the file naming conventions, ID formats, and frontmatter schemas for all `$HYPER_WORKSPACE_ROOT/` documents.

## ID Naming Conventions

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

**Finding next task number:**
```bash
# Get highest task number for a project
PROJECT_DIR="$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}"
LAST_NUM=$(ls "${PROJECT_DIR}/tasks/task-"*.mdx 2>/dev/null | \
  sed 's/.*task-\([0-9]*\)\.mdx/\1/' | sort -n | tail -1)
LAST_NUM=${LAST_NUM:-0}
NEXT_NUM=$(printf "%03d" $((10#$LAST_NUM + 1)))
```

### Other IDs

| Type | Pattern | Example |
|------|---------|---------|
| Initiative | `init-{slug}` | `init-q1-2025` |
| Doc | `doc-{slug}` | `doc-architecture` |
| Resource | `resource-{project-slug}-{slug}` | `resource-auth-system-spec` |

## File Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Project file | `_project.mdx` | Always `_project.mdx` |
| Task file | `task-NNN.mdx` | `task-001.mdx` |
| Initiative | `{slug}.mdx` | `q1-2025.mdx` |
| Doc | `{slug}.mdx` | `architecture.mdx` |
| Research | `{topic}.md` | `codebase-analysis.md` |

**Important:** Task file names use **only the number** (`task-001.mdx`), while task IDs include project initials (`ua-001`).

## Frontmatter Schemas

### Project (`_project.mdx`)

```yaml
---
id: proj-{slug}               # REQUIRED: Pattern ^proj-[a-z0-9-]+$
title: "Project Title"        # REQUIRED: minLength 1
type: project                 # REQUIRED: literal "project"
status: planning              # REQUIRED: See status values
priority: medium              # REQUIRED: urgent|high|medium|low
summary: "Brief description"  # REQUIRED: One-line summary
project_type: feature         # OPTIONAL: feature|research|spike
created: YYYY-MM-DD           # REQUIRED: ISO date
updated: YYYY-MM-DD           # REQUIRED: ISO date (auto-updated)
tags:                         # OPTIONAL: string[]
  - tag1
  - tag2
archived: false               # OPTIONAL: Hide from views
---
```

**Project status values:** `planned`, `todo`, `in-progress`, `blocked`, `qa`, `completed`, `canceled`

**Project types:**
- `feature` (default) - New functionality
- `research` - Investigation, exploration
- `spike` - Time-boxed investigation

### Task (`tasks/task-NNN.mdx`)

```yaml
---
id: {initials}-{NNN}          # REQUIRED: Pattern ^[a-z]+-\d{3}$
title: "Task Title"           # REQUIRED
type: task                    # REQUIRED: literal "task"
status: todo                  # REQUIRED: See status values
priority: medium              # OPTIONAL: urgent|high|medium|low
parent: proj-{slug}           # REQUIRED: Project ID
depends_on:                   # OPTIONAL: Task IDs
  - ua-001
blocks:                       # OPTIONAL: Tasks this blocks
  - ua-003
assignee: "name"              # OPTIONAL: Assignee name/email
created: YYYY-MM-DD           # REQUIRED: ISO date
updated: YYYY-MM-DD           # OPTIONAL: ISO date
started: YYYY-MM-DD           # OPTIONAL: Auto-set on in-progress
completed: YYYY-MM-DD         # OPTIONAL: Auto-set on complete
tags:                         # OPTIONAL: string[]
  - phase-1
---
```

**Task status values:** `draft`, `todo`, `in-progress`, `blocked`, `qa`, `complete`

### Initiative (`initiatives/{slug}.mdx`)

```yaml
---
id: init-{slug}               # REQUIRED
title: "Initiative Title"     # REQUIRED
type: initiative              # REQUIRED: literal "initiative"
status: in-progress           # REQUIRED: Same as project statuses
priority: high                # REQUIRED
created: YYYY-MM-DD           # REQUIRED
updated: YYYY-MM-DD           # OPTIONAL
tags:                         # OPTIONAL
  - quarterly
---
```

### Resource (`resources/*.md`)

```yaml
---
id: resource-{project}-{slug} # OPTIONAL (resources may not have frontmatter)
title: "Resource Title"       # OPTIONAL
type: resource                # OPTIONAL
created: YYYY-MM-DD           # OPTIONAL
updated: YYYY-MM-DD           # OPTIONAL
---
```

### Doc (`docs/{slug}.mdx`)

```yaml
---
id: doc-{slug}                # REQUIRED
title: "Document Title"       # REQUIRED
type: doc                     # REQUIRED: literal "doc"
created: YYYY-MM-DD           # REQUIRED
updated: YYYY-MM-DD           # OPTIONAL
tags:                         # OPTIONAL
  - architecture
---
```

## Activity Tracking

The `activity` field tracks modifications:

```yaml
activity:
  - timestamp: "2026-01-02T10:30:00Z"
    actor:
      type: session           # session|user
      id: "session-uuid"
      parent_id: "parent-session"  # For sub-agents
      name: "Agent Name"      # Optional
    action: modified          # created|modified|commented|status_changed
    content: "Description"    # Optional (required for comments)
```

**Activity is tracked automatically** via PostToolUse hook for agent sessions.

## Date Format

Always use ISO 8601:

```yaml
created: 2025-12-28
updated: 2025-12-28
```

Timestamps include timezone:
```yaml
timestamp: "2026-01-02T10:30:00Z"
```

## Tags Format

Use YAML array format:

```yaml
# Inline (short lists)
tags: [auth, oauth, security]

# Multi-line (longer lists)
tags:
  - auth
  - oauth
  - security
```

## Common Mistakes to Avoid

| Mistake | Correct |
|---------|---------|
| `id: auth-system` | `id: proj-auth-system` (projects need `proj-` prefix) |
| `id: 001` | `id: ua-001` (tasks need initials) |
| `status: in_progress` | `status: in-progress` (use hyphens) |
| `status: done` | `status: complete` (exact values only) |
| `parent: auth-system` | `parent: proj-auth-system` (include prefix) |
| Missing `type: task` | Always include `type` field |
| `task-ua-001.mdx` | `task-001.mdx` (file name uses number only) |

## Drive Note IDs

Drive notes use scope-prefixed IDs:

```yaml
id: "personal:my-note"        # Personal scope
id: "ws-abc123:design-doc"    # Workspace scope
id: "org-xyz:team-standards"  # Organization scope
id: "proj-auth:architecture"  # Project scope
```

**Always use CLI** to create drive notes - it generates correct IDs automatically.

## Validation Rules

1. **id** must be unique across the workspace
2. **type** must be a valid document type
3. **status** must be valid for the document type
4. **priority** must be a valid priority value
5. **created** and **updated** must be valid ISO dates
6. **parent** is required for tasks, must reference existing project
7. **depends_on** references must exist
8. **tags** must be an array of strings

## Template Variables

When using templates, these variables are substituted:

| Variable | Description | Example |
|----------|-------------|---------|
| `{{SLUG}}` | URL-safe identifier | `auth-system` |
| `{{TITLE}}` | Human-readable title | `User Authentication` |
| `{{DATE}}` | Current date | `2025-12-28` |
| `{{PRIORITY}}` | Priority level | `high` |
| `{{STATUS}}` | Initial status | `todo` |
| `{{PROJECT_SLUG}}` | Parent project slug | `auth-system` |
| `{{PROJECT_INITIALS}}` | Project initials | `as` |
| `{{NUM}}` | Task number (zero-padded) | `001` |
| `{{SUMMARY}}` | Brief description | One-line text |
| `{{TAGS}}` | YAML array | `[tag1, tag2]` |
