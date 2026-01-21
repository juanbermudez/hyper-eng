# $HYPER_WORKSPACE_ROOT/ Directory Structure

The `$HYPER_WORKSPACE_ROOT/` directory is a local file-based project management system compatible with Hypercraft UI.

## Complete Structure

```
$HYPER_WORKSPACE_ROOT/
├── workspace.json           # Workspace metadata
├── templates/               # Custom templates (optional)
│   └── *.template
├── initiatives/             # High-level strategic groupings
│   └── {initiative-slug}.mdx
├── projects/                # Project containers
│   └── {project-slug}/
│       ├── _project.mdx     # Project definition (required)
│       ├── tasks/           # Task files
│       │   ├── task-001.mdx
│       │   ├── task-002.mdx
│       │   ├── verify-task-001.mdx
│       │   └── verify-task-002.mdx
│       └── resources/       # Supporting documents
│           ├── specification.md
│           └── research/
│               ├── codebase-analysis.md
│               ├── best-practices.md
│               └── framework-docs.md
└── docs/                    # Standalone documentation
    └── {doc-slug}.mdx
```

## File Descriptions

### workspace.json

Workspace metadata - created by `/hyper:init`:

```json
{
  "workspacePath": "/path/to/project",
  "name": "My Project",
  "created": "2025-12-28"
}
```

### initiatives/*.mdx

Strategic groupings that contain multiple projects:

```yaml
---
id: init-q1-2025
title: "Q1 2025 Product Launch"
type: initiative
status: in-progress
priority: high
created: 2025-12-28
updated: 2025-12-28
tags:
  - quarterly
  - product
---
```

### projects/{slug}/_project.mdx

Project definition - the main project file:

```yaml
---
id: proj-auth-system
title: "User Authentication System"
type: project
status: planned
priority: high
summary: "OAuth-based authentication with Google and GitHub"
created: 2025-12-28
updated: 2025-12-28
tags:
  - auth
  - security
---
```

### projects/{slug}/tasks/task-NNN.mdx

Implementation tasks with zero-padded numbering:

```yaml
---
id: task-auth-system-001
title: "Phase 1: OAuth Provider Setup"
type: task
status: todo
priority: high
parent: proj-auth-system
depends_on: []
created: 2025-12-28
updated: 2025-12-28
tags:
  - setup
---
```

### projects/{slug}/tasks/verify-task-NNN.mdx

Verification tasks linked to implementation tasks:

```yaml
---
id: verify-auth-system-001
title: "Verify: Phase 1 - OAuth Provider Setup"
type: task
status: todo
priority: high
parent: proj-auth-system
depends_on:
  - task-auth-system-001
created: 2025-12-28
updated: 2025-12-28
tags:
  - verification
---
```

### projects/{slug}/resources/specification.md

Detailed specification document:

```markdown
# Specification: User Authentication System

## Problem Statement
...

## Proposed Solution
...

## Architecture
...
```

### projects/{slug}/resources/research/*.md

Research findings from sub-agents:

- `codebase-analysis.md` - From repo-research-analyst
- `best-practices.md` - From best-practices-researcher
- `framework-docs.md` - From framework-docs-researcher
- `git-history.md` - From git-history-analyzer

### docs/*.mdx

Standalone documentation not tied to projects:

```yaml
---
id: doc-architecture
title: "Architecture Overview"
type: doc
created: 2025-12-28
updated: 2025-12-28
tags:
  - architecture
  - overview
---
```

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Project slug | kebab-case | `auth-system` |
| Task file | `task-NNN.mdx` | `task-001.mdx` |
| Verify task | `verify-task-NNN.mdx` | `verify-task-001.mdx` |
| Project file | `_project.mdx` | Always `_project.mdx` |
| Initiative | `{slug}.mdx` | `q1-2025.mdx` |
| Doc | `{slug}.mdx` | `architecture.mdx` |

## ID Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Project | `proj-{slug}` | `proj-auth-system` |
| Task | `task-{project-slug}-{NNN}` | `task-auth-system-001` |
| Verify | `verify-{project-slug}-{NNN}` | `verify-auth-system-001` |
| Initiative | `init-{slug}` | `init-q1-2025` |
| Doc | `doc-{slug}` | `doc-architecture` |
| Resource | `resource-{project-slug}-{slug}` | `resource-auth-system-spec` |

## File System Operations

### Initialize Workspace

```bash
mkdir -p $HYPER_WORKSPACE_ROOT/{initiatives,projects,docs}
echo '{"workspacePath": "'$(pwd)'", "name": "Project", "created": "'$(date +%Y-%m-%d)'"}' > $HYPER_WORKSPACE_ROOT/workspace.json
```

### Create Project

```bash
PROJECT_SLUG="auth-system"
mkdir -p "$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/{tasks,resources,resources/research}"
```

### List Projects

```bash
ls -d $HYPER_WORKSPACE_ROOT/projects/*/
```

### List Tasks

```bash
ls $HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/tasks/task-*.mdx
```

### Get Next Task Number

```bash
TASK_COUNT=$(ls $HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/tasks/task-*.mdx 2>/dev/null | wc -l)
NEXT_NUM=$(printf "%03d" $((TASK_COUNT + 1)))
```
