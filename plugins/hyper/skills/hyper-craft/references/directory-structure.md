# $HYPER_WORKSPACE_ROOT/ Directory Structure

The `$HYPER_WORKSPACE_ROOT/` directory is a local file-based project management system. Files are the API - no external service required.

## Complete Structure

```
$HYPER_WORKSPACE_ROOT/
├── workspace.json           # Workspace metadata (PROTECTED - read-only)
├── templates/               # Custom templates (optional)
│   └── *.template
├── initiatives/             # High-level strategic groupings
│   └── {initiative-slug}.mdx
├── projects/                # Project containers (PROTECTED - directory itself)
│   └── {project-slug}/
│       ├── _project.mdx     # Project definition (required)
│       ├── tasks/           # Task files
│       │   ├── task-001.mdx
│       │   ├── task-002.mdx
│       │   └── task-NNN.mdx
│       └── resources/       # Supporting documents
│           ├── specification.md
│           └── research/
│               ├── codebase-analysis.md
│               ├── best-practices.md
│               └── framework-docs.md
├── docs/                    # Standalone documentation (WRITABLE)
│   └── {doc-slug}.mdx
├── settings/                # Customization (PROTECTED - directory itself)
│   ├── workflows.yaml       # Project/task workflow stages
│   ├── agents/              # Agent customization
│   │   └── *.yaml
│   └── commands/            # Command customization
│       └── *.yaml
└── .prose/                  # Hyper-Prose run state (auto-managed)
    ├── runs/{run-id}/       # Run artifacts
    └── agents/{name}/       # Agent memory
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

**PROTECTED**: Do not modify directly.

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

# Project Specification

[Inline spec content here]
```

### projects/{slug}/tasks/task-NNN.mdx

Implementation tasks with zero-padded numbering:

```yaml
---
id: as-001
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

# Task Implementation Details
```

### projects/{slug}/resources/research/*.md

Research findings from sub-agents:

| File | Source Agent |
|------|-------------|
| `codebase-analysis.md` | repo-research-analyst |
| `best-practices.md` | best-practices-researcher |
| `framework-docs.md` | framework-docs-researcher |
| `git-history.md` | git-history-analyzer |

### settings/workflows.yaml

Workflow configuration:

```yaml
project_workflow:
  stages:
    - id: planned
      allowed_transitions: [todo, canceled]
    - id: todo
      allowed_transitions: [in-progress, canceled]
    - id: in-progress
      allowed_transitions: [qa, blocked]
    - id: qa
      gate: true
      allowed_transitions: [completed, in-progress]
    - id: completed
      terminal: true

task_workflow:
  stages:
    - id: draft
      allowed_transitions: [todo]
    - id: todo
      allowed_transitions: [in-progress, blocked]
    - id: in-progress
      allowed_transitions: [qa, blocked]
    - id: qa
      gate: true
      allowed_transitions: [complete, in-progress]
    - id: complete
      terminal: true

quality_gates:
  task_completion:
    automated:
      - id: lint
        required: true
      - id: typecheck
        required: true
      - id: test
        required: true
      - id: build
        required: true
```

## Protected Paths

**CANNOT modify:**
- `workspace.json` - Core workspace structure
- `projects/` directory itself - Use CLI to create projects
- `initiatives/` directory itself
- `settings/` directory itself

**CAN create/edit/delete:**
- `projects/{slug}/` - Project directories
- `projects/{slug}/_project.mdx` - Project files
- `projects/{slug}/tasks/*.mdx` - Task files
- `projects/{slug}/resources/**` - Resource files
- `docs/**/*.mdx` - Documentation
- `settings/workflows.yaml` - Workflow config
- `settings/agents/*.yaml` - Agent configs
- `settings/commands/*.yaml` - Command configs

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Project slug | kebab-case | `auth-system` |
| Project file | `_project.mdx` | Always `_project.mdx` |
| Task file | `task-NNN.mdx` | `task-001.mdx` |
| Initiative | `{slug}.mdx` | `q1-2025.mdx` |
| Doc | `{slug}.mdx` | `architecture.mdx` |

## ID Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Project | `proj-{slug}` | `proj-auth-system` |
| Task | `{initials}-{NNN}` | `as-001` |
| Initiative | `init-{slug}` | `init-q1-2025` |
| Doc | `doc-{slug}` | `doc-architecture` |

## Core Principles

1. **Files are the API** - No external service needed
2. **MDX with frontmatter** - Structured metadata + markdown content
3. **Version controllable** - Everything in git
4. **Template system** - Customizable per-workspace
5. **Activity tracking** - Session history in frontmatter

## Template Loading Priority

1. **Workspace templates**: `$HYPER_WORKSPACE_ROOT/templates/*.template` (highest)
2. **Plugin templates**: `templates/hyper/*.template` (fallback)

Available templates:
- `project.mdx.template`
- `task.mdx.template`
- `initiative.mdx.template`
- `resource.mdx.template`
- `doc.mdx.template`
- `workspace.json.template`
