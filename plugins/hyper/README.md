<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-Plugin-purple?style=for-the-badge" alt="Claude Code Plugin" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="MIT License" />
  <img src="https://img.shields.io/badge/Version-3.13.0-blue?style=for-the-badge" alt="Version" />
</p>

# Hyper-Engineering Plugin

**Specs first. Code second. Verification always.**

Local-first, spec-driven development workflow. Specs matter more than code—specifications are the source of truth, code is disposable.

Works standalone or with [Hyper Control](https://github.com/juanbermudez/hyper-control) desktop app.

**Now with Hyper-Prose** (our fork of [OpenProse](https://github.com/openprose/prose)) for executable, resumable workflows. Slash commands automatically use the Hyper-Prose VM.

## Components

| Component | Count |
|-----------|-------|
| Agents | 10 |
| Commands | 8 |
| Prose Workflows | 4 |
| Skills | 11 |
| MCP Servers | 1 |

---

## Hyper-Engineering Workflow

**Specs matter more than code. Code is disposable; specifications are the source of truth.**

The hyper-engineering workflow uses local `$HYPER_WORKSPACE_ROOT/` directory as the source of truth, with mandatory human review gates and verification loops.

### Directory Structure

```
$HYPER_WORKSPACE_ROOT/
├── workspace.json           # Workspace configuration
├── initiatives/             # Strategic groupings
│   └── {slug}.mdx
├── projects/                # Active projects
│   └── {slug}/
│       ├── _project.mdx     # Project definition + spec (inline)
│       ├── tasks/           # Task files
│       │   └── task-NNN.mdx # Tasks with 3-digit numbering
│       └── resources/       # Supporting docs
│           └── research/    # Research findings
├── docs/                    # Standalone documentation
│   └── {slug}.mdx
└── settings/                # Customization
    ├── workflows.yaml       # Workflow stages & quality gates
    ├── agents/              # Agent customization
    │   └── {agent}.yaml
    └── commands/            # Command customization
        └── {command}.yaml
```

### MDX File Naming

**IMPORTANT**: Follow these naming conventions exactly:

| File Type | Filename | Example |
|-----------|----------|---------|
| Project | `_project.mdx` | `$HYPER_WORKSPACE_ROOT/projects/auth-system/_project.mdx` |
| Task | `task-NNN.mdx` | `$HYPER_WORKSPACE_ROOT/projects/auth-system/tasks/task-001.mdx` |
| Initiative | `{slug}.mdx` | `$HYPER_WORKSPACE_ROOT/initiatives/q1-goals.mdx` |
| Doc | `{slug}.mdx` | `$HYPER_WORKSPACE_ROOT/docs/architecture.mdx` |

### Workflow Stages

```
Draft → Spec Review → Ready → In Progress → Verification → Done
```

| Stage | Description |
|-------|-------------|
| **Draft** | Research phase - agent explores codebase with parallel sub-agents |
| **Spec Review** | Human review gate - spec must be approved before tasks are created |
| **Ready** | Tasks created from approved spec |
| **In Progress** | Implementation following codebase patterns |
| **Verification** | Automated (lint, test, typecheck, build) + manual checks |
| **Done** | All verification passed |

### Hyper Commands

| Command | Description |
|---------|-------------|
| `/hyper:init` | Guided setup wizard - detects existing configs, migrates CLAUDE.md, offers imports |
| `/hyper:import-external` | Import from external systems (TODO.md, GitHub Issues, Linear) |
| `/hyper:status` | View project and task status from CLI |
| `/hyper:plan` | Spawn research agents → create spec → wait for approval → create tasks |
| `/hyper:implement` | Implement task with verification loop |
| `/hyper:implement-worktree` | Implement task in isolated worktree (mandatory isolation) |
| `/hyper:verify` | Run comprehensive automated and manual verification |
| `/hyper:research` | Standalone research workflow with comprehensive or deep modes |

### Agents

10 specialized agents for orchestration, research, testing, detection, and verification:

| Agent | Category | Purpose |
|-------|----------|---------|
| `research-orchestrator` | Orchestrators | Coordinate research sub-agents in parallel |
| `implementation-orchestrator` | Orchestrators | Coordinate engineering sub-agents and verification |
| `repo-research-analyst` | Research | Research repository structure and conventions |
| `best-practices-researcher` | Research | Gather external best practices and examples |
| `framework-docs-researcher` | Research | Research framework documentation and best practices |
| `git-history-analyzer` | Research | Analyze git history and code evolution |
| `web-app-debugger` | Testing | Debug web apps using Chrome extension for browser inspection |
| `tauri-ui-verifier` | Verification | Verify Hyper Control UI state via Tauri MCP tools |
| `workflow-observer` | Verification | Log workflow events to Sentry for observability |

### Prose Workflows

Executable workflows using [OpenProse](https://github.com/openprose/prose) for structured, resumable execution:

| Workflow | Description |
|----------|-------------|
| `hyper-plan.prose` | Full planning: research → direction gate → spec → approval → tasks |
| `hyper-implement.prose` | Implementation: load task → analyze → implement → review → verify → complete |
| `hyper-verify.prose` | Verification: automated checks → prose state → UI verification via Tauri |
| `hyper-status.prose` | Status reporting: project/task overview with progress metrics |

**Running Workflows:**
```bash
# In Claude Code, load the OpenProse skill then run:
prose run hyper-plan.prose feature="Add user authentication"
prose run hyper-implement.prose task="ua-001"
prose run hyper-verify.prose project="user-auth"
```

**State Management:**
- Execution state: `$HYPER_WORKSPACE_ROOT/.prose/runs/{run-id}/`
- Agent memory: `$HYPER_WORKSPACE_ROOT/.prose/agents/{name}/memory.md`

### Skills

The workflow leverages 11 skills including the bundled OpenProse VM:

| Skill | Used By | Purpose |
|-------|---------|---------|
| `hyper-cli` | All commands | CLI command reference for workspace operations |
| `hyper-local` | All hyper-* commands | Guidance on `$HYPER_WORKSPACE_ROOT/` directory operations |
| `hyper-planning` | hyper-plan | Spec-driven planning with research and approval gates |
| `hyper-research` | hyper-plan | Orchestrate comprehensive codebase research |
| `hyper-implementation` | hyper-implement | Task execution with verification gates |
| `hyper-verification` | hyper-verify | Automated and manual verification workflows |
| `hyper-workflow-enforcement` | All commands | Status transitions and gate requirements |
| `hyper-activity-tracking` | All commands | Activity tracking for file modifications |
| `git-worktree` | hyper-implement | Isolated parallel development with Git worktrees |
| `compound-docs` | hyper-review, hyper-plan | Document recurring patterns and learnings |
| `hyper-prose` | All .prose workflows | Hyper-Prose VM for executing workflow files (fork of OpenProse) |

### Quick Start

```bash
# Initialize workspace
/hyper-init

# Check status
/hyper-status

# Plan a new feature
/hyper-plan "Add user authentication"

# Implement a task
/hyper-implement auth-login

# Verify implementation
/hyper-verify auth-login
```

### Settings & Customization

Customize workflows, agents, and commands via `$HYPER_WORKSPACE_ROOT/settings/`:

**Workflows** (`workflows.yaml`):
```yaml
project_workflow:
  stages:
    - id: review
      gate: true  # Human approval required
quality_gates:
  task_completion:
    automated:
      - id: lint
        command: "npm run lint"
        required: true
```

**Agents** (`agents/{agent}.yaml`):
```yaml
context_additions: |
  - This is a monorepo with packages/ directory
instructions_append: |
  After research, also check for related TODOs.
skip_sub_agents:
  - git-history-analyzer
```

**Commands** (`commands/{command}.yaml`):
```yaml
phase_overrides:
  initial_interview:
    instructions_append: |
      Always ask about bounded context ownership.
skip_phases:
  - browser_verification
```

---

## Reference

### Agents (9)

Orchestrators (2), Research agents (4), Testing agent (1), and Verification agents (2):

| Agent | Category | Description |
|-------|----------|-------------|
| `research-orchestrator` | Orchestrators | Coordinate research sub-agents in parallel, synthesize findings |
| `implementation-orchestrator` | Orchestrators | Coordinate engineering sub-agents, enforce verification gates |
| `repo-research-analyst` | Research | Research repository structure and conventions |
| `best-practices-researcher` | Research | Gather external best practices and examples |
| `framework-docs-researcher` | Research | Research framework documentation and best practices |
| `git-history-analyzer` | Research | Analyze git history and code evolution |
| `web-app-debugger` | Testing | Debug and test web apps using Claude Code Chrome extension |
| `tauri-ui-verifier` | Verification | Verify Hyper Control UI state using Tauri MCP tools |
| `workflow-observer` | Verification | Log workflow events to Sentry for observability tracking |

### Commands (7)

| Command | Description |
|---------|-------------|
| `/hyper:init` | Initialize or repair workspace structure in HyperHome |
| `/hyper:status` | View project and task status from CLI |
| `/hyper:plan` | Spawn research agents → create spec → wait for approval → create tasks |
| `/hyper:implement` | Implement task with verification loop |
| `/hyper:implement-worktree` | Implement task in isolated worktree (mandatory isolation) |
| `/hyper:verify` | Run comprehensive automated and manual verification |
| `/hyper:research` | Standalone research workflow with comprehensive or deep modes |

### Prose Workflows (4)

Executable workflows using [OpenProse](https://github.com/openprose/prose):

| Workflow | Description |
|----------|-------------|
| `hyper-plan.prose` | Full planning: research → direction gate → spec → approval → tasks |
| `hyper-implement.prose` | Implementation: load task → analyze → implement → review → verify |
| `hyper-verify.prose` | Verification: automated checks → prose state → UI verification |
| `hyper-status.prose` | Status reporting: project/task overview with progress metrics |

### Skills (11)

Core skills including bundled OpenProse VM:

| Skill | Description |
|-------|-------------|
| `hyper-cli` | Complete CLI command reference for programmatic file operations |
| `hyper-local` | Expert guidance for `$HYPER_WORKSPACE_ROOT/` directory operations and local-first development |
| `hyper-planning` | Spec-driven planning with research and approval gates |
| `hyper-research` | Orchestrate comprehensive codebase research |
| `hyper-implementation` | Task execution with verification gates |
| `hyper-verification` | Automated and manual verification workflows |
| `hyper-workflow-enforcement` | Status transitions and gate requirements |
| `hyper-activity-tracking` | Activity tracking for file modifications |
| `git-worktree` | Manage Git worktrees for parallel development |
| `compound-docs` | Capture solved problems as categorized documentation |
| `hyper-prose` | Hyper-Prose VM for executing .prose workflow files (fork of OpenProse) |

## MCP Servers

| Server | Description |
|--------|-------------|
| `context7` | Framework documentation lookup via Context7 |

### Context7

**Tools provided:**
- `resolve-library-id` - Find library ID for a framework/package
- `get-library-docs` - Get documentation for a specific library

Supports 100+ frameworks including Rails, React, Next.js, Vue, Django, Laravel, and more.

> **Tauri Testing:** For Tauri v2 app testing, install the separate [tauri-testing plugin](https://github.com/Hyper-Builders/tauri-testing-plugin).

## CLI & Activity Tracking

The plugin includes a bundled CLI binary (`hyper`) for managing workspace files, Drive notes, and activity tracking.

### CLI Overview

```
hyper <COMMAND>

Commands:
  init      Initialize a new workspace
  worktree  Manage git worktrees for isolated development
  project   Manage workspace projects (list, get, create, update)
  task      Manage workspace tasks (list, get, create, update)
  drive     Manage HyperHome drive items/notes (list, create, show, delete)
  config    Get/set configuration (get, set, list)
  activity  Track activity on projects and tasks (add, comment)
  file      Low-level file operations (list, read, write, search, delete)
  settings  Manage workspace settings (workflow, stage, gate, tag)
  search    Search across all resources (projects, tasks, initiatives)
  vfs       Virtual filesystem operations (list, resolve, search)
```

### Essential CLI Commands

```bash
# Initialize workspace
${CLAUDE_PLUGIN_ROOT}/binaries/hyper init --name "My Project"

# Create project with validated frontmatter
${CLAUDE_PLUGIN_ROOT}/binaries/hyper project create \
  --slug "auth-system" \
  --title "User Auth" \
  --priority "high" \
  --json

# Create task (ID auto-generated)
${CLAUDE_PLUGIN_ROOT}/binaries/hyper task create \
  --project "auth-system" \
  --title "Phase 1: OAuth Setup" \
  --priority "high" \
  --json

# Update task status (ID is positional argument)
${CLAUDE_PLUGIN_ROOT}/binaries/hyper task update as-001 --status "in-progress"

# Update project status (slug is positional argument)
${CLAUDE_PLUGIN_ROOT}/binaries/hyper project update auth-system --status "in-progress"

# List projects
${CLAUDE_PLUGIN_ROOT}/binaries/hyper project list --json

# Search across all resources
${CLAUDE_PLUGIN_ROOT}/binaries/hyper search "OAuth" --json

# Create Drive note
${CLAUDE_PLUGIN_ROOT}/binaries/hyper drive create "Research Notes" --folder "research" --json

# Low-level file operations
${CLAUDE_PLUGIN_ROOT}/binaries/hyper file read projects/auth-system/_project.mdx --json
${CLAUDE_PLUGIN_ROOT}/binaries/hyper file write projects/auth-system/_project.mdx --body "New content" --json
```

### Automatic Activity Tracking

Activity is tracked automatically via PostToolUse hook:

1. Agent writes to `$HYPER_WORKSPACE_ROOT/*.mdx` file
2. PostToolUse hook captures session ID
3. CLI appends activity entry to frontmatter

```yaml
activity:
  - timestamp: "2026-01-02T10:30:00Z"
    actor:
      type: session
      id: "abc-123-def"
    action: modified
```

### Skills Documentation

For comprehensive CLI documentation, see:
- `hyper-cli` skill — Complete CLI command reference with all APIs
- `hyper-local` skill — Workspace directory operations and workflows
- `skills/hyper-local/references/frontmatter-schema.md` — Full frontmatter and activity format

## Installation

```bash
claude /plugin install hyper-engineering
```

Then initialize a workspace:

```bash
/hyper-init
```

## Hyper Control Integration

This plugin works standalone, but optionally integrates with [Hyper Control](https://github.com/juanbermudez/hyper-control) desktop app:

- Hyper Control watches `$HYPER_WORKSPACE_ROOT/` via file watcher
- TanStack DB syncs from `$HYPER_WORKSPACE_ROOT/` files
- Visual project management UI
- Real-time status updates

## Known Issues

### MCP Server Not Auto-Loading

**Issue:** The bundled Context7 MCP server may not load automatically when the plugin is installed.

**Workaround:** Manually add it to your project's `.claude/settings.json`:

```json
{
  "mcpServers": {
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp"
    }
  }
}
```

Or add it globally in `~/.claude/settings.json` for all projects.

## Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## Claude Code Documentation

This plugin uses Claude Code's extensibility features:

- [Sub-Agents](https://code.claude.com/docs/en/sub-agents) — Specialized AI assistants with separate context
- [Plugins](https://code.claude.com/docs/en/plugins) — Packaging commands, agents, and skills
- [Skills](https://code.claude.com/docs/en/skills) — Model-invoked specialized knowledge
- [Hooks](https://code.claude.com/docs/en/hooks-guide) — Event-driven automation

## License

MIT

---

<p align="center">
  <sub>Built for developers who believe specs should outlive code.</sub>
</p>
