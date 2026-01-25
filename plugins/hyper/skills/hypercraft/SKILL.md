---
name: hypercraft
description: |
  Hypercraft framework for orchestrating AI workflows.

  Load this skill when the user wants to:
  - Plan, design, or spec something
  - Implement, build, or code something
  - Review, debug, or verify something
  - Any multi-step task requiring orchestration

  Activates on INTENT, not just /commands.
includes:
  - prose
---

# Hypercraft Framework

Hypercraft is a workflow orchestration framework built on OpenProse. It provides structured, resumable workflows with human-in-the-loop gates.

## Architecture

```
prose (VM)  +  hypercraft context  =  hypercraft (framework)
```

- **prose**: Universal OpenProse VM that runs any `.prose` program
- **hypercraft context**: Project artifacts, CLI, directory structure, agent hierarchy
- **hypercraft**: The complete framework for hyper-engineering workflows

## Agent Hierarchy

```
Captain → Squad Leader → Worker
(routes)   (orchestrates)  (executes)
```

| Tier | Role | Model | Spawns |
|------|------|-------|--------|
| Captain | Routes requests | opus | Squad Leaders |
| Squad Leader | Orchestrates domain | opus (persist) | Workers |
| Worker | Executes tasks | sonnet/haiku | Nothing |

See `hierarchy/` for detailed role definitions.

## CLI Commands

### Discovery

```bash
hypercraft find "query" --type <type> --json
```

Types: `projects`, `tasks`, `workflows`, `skills`, `agents`, `notes`, `all`

Options:
- `--status <STATUS>` - Filter by status
- `--priority <PRIORITY>` - Filter by priority
- `--mode <MODE>` - Search mode: bm25, vector, hybrid
- `--all` - Return all matches

### Operations

```bash
# Projects
hypercraft project create --slug X --title Y --json
hypercraft project update <slug> --status in-progress

# Tasks
hypercraft task create --project <slug> --title Y --json
hypercraft task update <id> --status done

# Files
hypercraft file read <path> --json
hypercraft file write <path> --body "..." --json

# Drive
hypercraft drive create "Title" --json

# Path resolution
hypercraft vfs resolve /projects/slug --json
```

## Workflow Discovery

Workflows are dynamically discovered:

```bash
# Find workflows by intent
hypercraft find "plan" --type workflows --json
hypercraft find --type workflows --all --json
```

To add a workflow:
1. Create `commands/workflows/hyper-{name}.prose`
2. Run `hypercraft index build`
3. Discoverable via `hypercraft find`

## Directory Structure

```
$HYPER_WORKSPACE_ROOT/
├── projects/
│   └── {slug}/
│       ├── _project.mdx
│       ├── tasks/
│       └── resources/
├── docs/
└── settings/
```

## Session Tracking

Workflows set environment variables for session tracking:

| Variable | Purpose |
|----------|---------|
| `HYPER_AGENT_ROLE` | captain, squad-leader, worker |
| `HYPER_AGENT_NAME` | Display name |
| `HYPER_RUN_ID` | Workflow run ID |
| `HYPER_WORKFLOW` | Workflow name |
| `HYPER_PHASE` | Current phase |

## Context Files

- `context/cli-reference.md` - Complete CLI documentation
- `context/directory-structure.md` - Workspace layout
- `context/output-contracts.md` - Agent response format
- `context/lifecycle.md` - Status transitions
- `context/writing-guidelines.md` - Naming conventions
- `hierarchy/captain.md` - Captain role
- `hierarchy/squad-leader.md` - Squad Leader role
- `hierarchy/worker.md` - Worker role
