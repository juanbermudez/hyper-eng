# Directory Structure

## Overview

Hyper Engineering uses a **centralized HyperHome** structure that separates workspace data from project repositories. This document explains the full directory hierarchy and how `$HYPER_WORKSPACE_ROOT` resolves.

> **CRITICAL**: `$HYPER_WORKSPACE_ROOT` is a **variable** resolved at runtime. It points to an account-scoped workspace directory in HyperHome, NOT a local `.hyper/` folder.
>
> **See [path-resolution.md](./path-resolution.md) for cross-platform details (macOS, Linux, Windows).**

## Full HyperHome Hierarchy

```
~/.hyper/                                      # Base HyperHome (OS-specific)
├── active-account.json                        # Current account pointer
├── config.json                                # Global workspace registry
└── accounts/
    └── {accountId}/                           # e.g., "local", "work-machine"
        └── hyper/
            ├── config.json                    # Account settings
            ├── notes/                         # Personal Drive (ACCOUNT-LEVEL)
            │   ├── personal-note-1.mdx        # id: "personal:note-1"
            │   └── personal-note-2.mdx        # id: "personal:note-2"
            └── workspaces/
                └── {workspaceId}/             # e.g., "my-project-a1b2c3"
                    ├── workspace.json         # ← $HYPER_WORKSPACE_ROOT starts here
                    ├── templates/             # Custom templates (optional)
                    ├── projects/              # Project containers
                    │   └── {slug}/
                    │       ├── _project.mdx   # Project definition
                    │       ├── tasks/         # Task files
                    │       │   ├── task-001.mdx
                    │       │   └── task-NNN.mdx
                    │       └── resources/     # Research, specs
                    ├── docs/                  # Standalone documentation
                    ├── settings/              # Workspace customization
                    │   ├── workflows.yaml     # Project/task stages
                    │   ├── agents/            # Agent configs
                    │   ├── commands/          # Command configs
                    │   └── skills/            # Skill configs
                    └── .prose/                # Hypercraft VM state
                        ├── runs/{run-id}/
                        └── agents/{name}/
```

## Key Concepts

### HyperHome Location (Platform-Specific)

| Platform | Location | Alternative |
|----------|----------|-------------|
| **macOS** | `~/.hyper/` | - |
| **Linux** | `~/.hyper/` | `$XDG_DATA_HOME/hyper/` |
| **Windows** | `%USERPROFILE%\.hyper\` | `%LOCALAPPDATA%\Hyper\` |

**See [path-resolution.md](./path-resolution.md) for cross-platform setup.**

### Account Scoping

Each account (e.g., different machines or contexts) has its own:
- **Personal Drive**: `~/.hyper/accounts/{accountId}/hyper/notes/`
- **Workspaces**: `~/.hyper/accounts/{accountId}/hyper/workspaces/`
- **Config**: `~/.hyper/accounts/{accountId}/hyper/config.json`

**Default account**: `local`

### Workspace Resolution

`$HYPER_WORKSPACE_ROOT` resolves via:

1. **Check workspace registry**: `~/.hyper/config.json`
2. **Find entry** where `localPath` matches current directory
3. **Resolve to**: `~/.hyper/accounts/{accountId}/hyper/workspaces/{workspaceId}/`
4. **Fallback**: Legacy local `.hyper/` (if exists)

**Example**:
```bash
# Working in: /Users/juan/projects/my-app
# Registry lookup: my-app-a1b2c3
# Resolves to: /Users/juan/.hyper/accounts/local/hyper/workspaces/my-app-a1b2c3/
```

## Workspace Directory Structure

Once resolved, `$HYPER_WORKSPACE_ROOT` contains:

```
$HYPER_WORKSPACE_ROOT/
├── workspace.json           # Workspace metadata (PROTECTED - read-only)
├── templates/               # Custom templates (optional)
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
│   ├── commands/            # Command customization
│   │   └── *.yaml
│   └── skills/              # Skill customization
│       └── *.yaml
└── .prose/                  # Hypercraft VM run state (auto-managed)
    ├── runs/{run-id}/       # Run artifacts
    └── agents/{name}/       # Agent memory
```

## Personal Drive vs Workspace Resources

**CRITICAL**: Personal Drive notes are **ACCOUNT-LEVEL**, not workspace-level.

| Content Type | Location | Scope | Git-Tracked | When to Use |
|--------------|----------|-------|-------------|-------------|
| **Personal notes** | `$HYPER_ACCOUNT_ROOT/notes/` | Account | ❌ No | Private research, learning notes |
| **Project specs** | `$HYPER_WORKSPACE_ROOT/projects/{slug}/` | Workspace | ✅ Yes | Project definitions, tasks |
| **Project resources** | `$HYPER_WORKSPACE_ROOT/projects/{slug}/resources/` | Workspace | ✅ Yes | Research findings, specs |
| **Workspace docs** | `$HYPER_WORKSPACE_ROOT/docs/` | Workspace | ✅ Yes | Standalone documentation |

**Drive ID Format**:
```yaml
---
id: "personal:my-note"      # Personal Drive (account-level)
title: "My Personal Note"
icon: FileText
---
```

**Never write to**:
- ❌ `$HYPER_WORKSPACE_ROOT/notes/` (doesn't exist)
- ❌ `$HYPER_PERSONAL_DRIVE/` directly without Drive ID

**Always use**:
- ✅ `hypercraft drive create "Note Title"` for Personal Drive
- ✅ `$HYPER_WORKSPACE_ROOT/projects/{slug}/resources/` for project artifacts

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

### projects/{slug}/resources/*.md

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
| Doc | `{slug}.mdx` | `architecture.mdx` |

## ID Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Project | `proj-{slug}` | `proj-auth-system` |
| Task | `{initials}-{NNN}` | `as-001` |
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
- `resource.mdx.template`
- `doc.mdx.template`
- `workspace.json.template`
