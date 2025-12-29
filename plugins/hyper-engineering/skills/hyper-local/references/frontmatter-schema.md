# Frontmatter Schema Reference

All `.hyper/` documents use YAML frontmatter with specific fields. This schema is compatible with Hyper Control's TanStack DB collections.

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
| `initiative` | Strategic grouping | planned, in-progress, completed, canceled |
| `project` | Work container | planned, todo, in-progress, completed, canceled |
| `task` | Implementation unit | draft, todo, in-progress, review, complete, blocked |
| `resource` | Supporting documentation | (none) |
| `doc` | Standalone documentation | (none) |

## Status Values

### Task Statuses

| Status | Description | Next States |
|--------|-------------|-------------|
| `draft` | Work in progress, not ready | todo |
| `todo` | Ready to be worked on | in-progress, blocked |
| `in-progress` | Active work | review, blocked |
| `review` | Awaiting verification | complete, in-progress |
| `complete` | Done | (terminal) |
| `blocked` | Blocked by dependencies | todo, in-progress |

### Project Statuses

| Status | Description | Next States |
|--------|-------------|-------------|
| `planned` | In backlog | todo, canceled |
| `todo` | Scheduled for work | in-progress, canceled |
| `in-progress` | Active development | completed, canceled |
| `completed` | Successfully finished | (terminal) |
| `canceled` | Won't do | (terminal) |

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
summary: string      # Brief description for project cards
---
```

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

## TypeScript Schema (Hyper Control)

```typescript
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
  // Additional fields allowed
  [key: string]: unknown;
}
```
