---
name: hyper-craft
description: This skill provides core knowledge for ALL hypercraft agents including directory structure, CLI reference, output contracts, lifecycle management, and writing guidelines. Load this skill when working on any hyper-engineering workflow.
model: sonnet
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Task
---

# Hyper Craft - Core Agent Knowledge

## Overview

Hyper Craft is the foundational skill that ALL hypercraft agents load. It provides the shared knowledge base for working with the `$HYPER_WORKSPACE_ROOT/` directory structure, the Hypercraft CLI, output contracts, and lifecycle management.

## Agent Roles and Skill Composition

Use a three-tier model to keep context tight and skills composable:

- **Captain**: Primary user-facing agent. Loads `hyper-craft` and selects the workflow (plan/implement/review/verify).
- **Orchestrator**: Coordinates sub-agents for a phase. Passes a targeted skill list to each worker.
- **Worker**: Executes a focused task with only the skills it needs (plus `hyper-craft`).

**Skill pass-through rule**: Captains define the minimal skill list for each sub-agent. Workers never auto-load unrelated skills.

## Quick Reference

### Directory Structure

```
$HYPER_WORKSPACE_ROOT/
├── workspace.json           # Workspace metadata (read-only)
├── projects/                # Project containers
│   └── {slug}/
│       ├── _project.mdx     # Project spec (inline)
│       ├── tasks/           # Task files (task-NNN.mdx)
│       └── resources/       # Research, docs, artifacts
├── docs/                    # Standalone documentation
└── settings/                # Workflow customization
```

See [directory-structure.md](./references/directory-structure.md) for full details.

### CLI Commands (Most Common)

```bash
# Initialize workspace
hypercraft init --name "My Project"

# Projects
hypercraft project create --slug "auth" --title "Authentication" --priority high --json
hypercraft project update auth --status in-progress
hypercraft project get auth --json

# Tasks
hypercraft task create --project auth --title "Phase 1" --priority high --json
hypercraft task update au-001 --status in-progress
hypercraft task list --project auth --json

# Search
hypercraft search "OAuth" --json
```

See [cli-reference.md](./references/cli-reference.md) for complete CLI documentation.

### CLI Capability Discovery

When you need to discover available actions or configuration, prefer the CLI:

```bash
hypercraft help
hypercraft <command> --help
hypercraft config list --json
hypercraft settings workflow list --json
hypercraft vfs list / --json
hypercraft drive list --json
```

### Status Transitions

**Projects:** `planned` -> `todo` -> `in-progress` -> `qa` -> `completed`

**Tasks:** `draft` -> `todo` -> `in-progress` -> `qa` -> `complete`

See [lifecycle.md](./references/lifecycle.md) for allowed transitions and gate requirements.

### Sub-Agent Output Contract

All sub-agents MUST return structured responses:

```json
{
  "meta": {
    "agent_name": "repo-research-analyst",
    "status": "complete",
    "execution_time_ms": 12500
  },
  "artifacts": [
    {
      "type": "document",
      "path": "projects/{slug}/resources/codebase-analysis.md",
      "summary": "Analysis of existing authentication patterns",
      "key_points": ["JWT used for sessions", "No OAuth currently"]
    }
  ],
  "next_steps": ["Research OAuth providers", "Check security requirements"]
}
```

See [output-contracts.md](./references/output-contracts.md) for full specification.

### Writing Guidelines

- **Project IDs:** `proj-{slug}` (e.g., `proj-auth-system`)
- **Task IDs:** `{initials}-{NNN}` (e.g., `as-001` from `auth-system`)
- **File names:** `task-NNN.mdx` (zero-padded, e.g., `task-001.mdx`)
- **Dates:** ISO 8601 format (`YYYY-MM-DD`)

See [writing-guidelines.md](./references/writing-guidelines.md) for frontmatter schemas and naming conventions.

## Workflow Routing

| Intent | Action |
|--------|--------|
| Plan a feature | Run `/hyper:plan` |
| Implement a task | Run `/hyper:implement` or `/hyper:implement-worktree` |
| Review code | Run `/hyper:review` |
| Verify work | Run `/hyper:verify` |
| Get status | Run `/hyper:status` |
| Research only | Run `/hyper:research` |
| Initialize workspace | Run `/hyper:init` |

## Artifact Placement Rules

| Artifact Type | Location | Scope |
|---------------|----------|-------|
| Project specs | `$HYPER_WORKSPACE_ROOT/projects/{slug}/_project.mdx` | Git-tracked |
| Tasks | `$HYPER_WORKSPACE_ROOT/projects/{slug}/tasks/task-NNN.mdx` | Git-tracked |
| Research | `$HYPER_WORKSPACE_ROOT/projects/{slug}/resources/` | Git-tracked |
| Personal notes | Drive (`personal:`) | Not git-tracked |
| Shared docs | Drive (`ws:` or `org:`) | Not git-tracked |

See [drive.md](./references/drive.md) for Drive scopes, IDs, and commands.

## CLI-First Operations

**Always prefer CLI commands** for workspace operations:

1. CLI handles validation and defaults
2. CLI tracks activity automatically
3. CLI maintains data integrity
4. Direct file writes bypass validation

## Quality Gates

Before marking tasks/projects complete:

1. **Automated checks**: `lint`, `typecheck`, `test`, `build`
2. **Manual verification**: Browser testing if UI changes
3. **Code review**: For non-trivial changes

## Skill System

### Skill Resolution Order

Skills are resolved in priority order:

1. **Workspace settings** - `$HYPER_WORKSPACE_ROOT/settings/skills/{slot}.yaml`
2. **Template defaults** - Plugin templates at `templates/hyper/settings/skills/`
3. **Built-in defaults** - Core skills always loaded from plugin

### Skill Slots

| Slot | Purpose | Default |
|------|---------|---------|
| `core` | Foundational knowledge | `hyper-craft` (always) |
| `doc-lookup` | Documentation retrieval | `context7` |
| `code-search` | Codebase analysis | `codebase-search` |
| `browser-testing` | Browser automation | `playwright` |
| `error-tracking` | Error monitoring | `sentry` |

### Customizing Skills

Edit templates in `$HYPER_WORKSPACE_ROOT/settings/skills/` to:
- Select different skill implementations
- Add skill-specific configuration
- Skip skills in certain contexts

See [skill-templates.md](./references/skill-templates.md) for detailed configuration.

## References

- [directory-structure.md](./references/directory-structure.md) - Complete `$HYPER_WORKSPACE_ROOT/` layout
- [cli-reference.md](./references/cli-reference.md) - All Hypercraft CLI commands
- [drive.md](./references/drive.md) - Drive scopes, IDs, and commands
- [output-contracts.md](./references/output-contracts.md) - Sub-agent response format
- [lifecycle.md](./references/lifecycle.md) - Status transitions and gates
- [writing-guidelines.md](./references/writing-guidelines.md) - File naming and frontmatter specs
- [skill-templates.md](./references/skill-templates.md) - Skill configuration and templates
