<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-Plugin-purple?style=for-the-badge" alt="Claude Code Plugin" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="MIT License" />
  <img src="https://img.shields.io/badge/Version-3.16.2-blue?style=for-the-badge" alt="Version" />
</p>

# Hyper-Engineering Plugin

**Specs first. Code second. Verification always.**

Local-first, spec-driven development workflow. Specs matter more than code—specifications are the source of truth, code is disposable.

Works standalone or with the Hypercraft desktop app ([repo](https://github.com/juanbermudez/hyper-control)).

**Now with Hypercraft VM** (a full fork of [OpenProse](https://github.com/openprose/prose)) for executable, resumable workflows. Slash commands automatically use the Hypercraft VM.

## Components

| Component | Count |
|-----------|-------|
| Agents | 10 |
| Commands | 9 |
| Hypercraft Workflows | 5 |
| Skills | 14 |
| MCP Servers | 1 |

---

## Hyper-Engineering Workflow

**Specs matter more than code. Code is disposable; specifications are the source of truth.**

The hyper-engineering workflow uses local `$HYPER_WORKSPACE_ROOT/` directory as the source of truth, with mandatory human review gates and verification loops.

### Directory Structure

```
$HYPER_WORKSPACE_ROOT/
├── workspace.json           # Workspace configuration
│   └── {slug}.mdx
├── projects/                # Active projects
│   └── {slug}/
│       ├── _project.mdx     # Project definition + spec (inline)
│       ├── tasks/           # Task files
│       │   └── task-NNN.mdx # Tasks with 3-digit numbering
│       └── resources/       # Research + artifacts (no nested research/)
├── docs/                    # Standalone documentation
│   └── {slug}.mdx
└── settings/                # Customization
    ├── workflows.yaml       # Workflow stages & quality gates
    ├── agents/              # Agent customization
    │   └── {agent}.yaml
    └── commands/            # Command customization
        └── {command}.yaml
```

Drive items live outside the workspace and are accessed via the Hypercraft CLI:

- Personal Drive: `personal:` scope (private notes)
- Workspace Drive: `ws:` scope (shared notes)

### MDX File Naming

**IMPORTANT**: Follow these naming conventions exactly:

| File Type | Filename | Example |
|-----------|----------|---------|
| Project | `_project.mdx` | `$HYPER_WORKSPACE_ROOT/projects/auth-system/_project.mdx` |
| Task | `task-NNN.mdx` | `$HYPER_WORKSPACE_ROOT/projects/auth-system/tasks/task-001.mdx` |
| Doc | `{slug}.mdx` | `$HYPER_WORKSPACE_ROOT/docs/architecture.mdx` |

### Workflow Stages

```
planned → todo → in-progress → qa → completed
```

| Stage | Description |
|-------|-------------|
| **planned** | Research + direction (spec drafting) |
| **todo** | Spec approved, tasks created |
| **in-progress** | Implementation following codebase patterns |
| **qa** | Automated (lint, test, typecheck, build) + manual checks |
| **completed** | All verification passed |

### Hyper Commands

| Command | Description |
|---------|-------------|
| `/hyper:init` | Guided setup wizard - detects existing configs, migrates CLAUDE.md, offers imports |
| `/hyper:import-external` | Import from external systems (TODO.md, GitHub Issues, Linear) |
| `/hyper:status` | View project and task status from CLI |
| `/hyper:plan` | Spawn research agents → create spec → wait for approval → create tasks |
| `/hyper:implement` | Implement task with verification loop |
| `/hyper:implement-worktree` | Implement task in isolated worktree (mandatory isolation) |
| `/hyper:review` | Orchestrate code review with domain sub-agents |
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
| `prior-system-detector` | Detection | Identify prior systems, migrations, or legacy integrations |
| `web-app-debugger` | Testing | Debug web apps using Chrome extension for browser inspection |
| `tauri-ui-verifier` | Verification | Internal-only UI verification (not enabled by default) |
| `workflow-observer` | Verification | Internal-only observability hooks (not enabled by default) |

### Hypercraft Workflows

Executable workflows using Hypercraft VM (a fork of [OpenProse](https://github.com/openprose/prose)) for structured, resumable execution:

| Workflow | Description |
|----------|-------------|
| `hyper-plan.prose` | Full planning: research → direction gate → spec → approval → tasks |
| `hyper-implement.prose` | Implementation: load task → analyze → implement → review → verify → complete |
| `hyper-review.prose` | Review: scope → domain review → findings → fix tasks |
| `hyper-verify.prose` | Verification: automated checks → Hypercraft state → UI verification via Tauri |
| `hyper-status.prose` | Status reporting: project/task overview with progress metrics |

**Running Workflows:**
```bash
# In Claude Code, load the Hypercraft VM skill then run:
hypercraft run hyper-plan.prose feature="Add user authentication"
hypercraft run hyper-implement.prose task="ua-001"
hypercraft run hyper-review.prose target_id="user-auth/ua-001"
hypercraft run hyper-verify.prose project="user-auth"
```

**State Management:**
- Execution state: `$HYPER_WORKSPACE_ROOT/.prose/runs/{run-id}/`
- Agent memory: `$HYPER_WORKSPACE_ROOT/.prose/agents/{name}/memory.md`

### Skill-Based Agent Architecture

Agents are organized in a three-tier hierarchy with composable skills:

```
COMMAND LAYER          /hyper:plan, /hyper:implement, /hyper:review, /hyper:verify
       │
       ▼
CAPTAIN/ORCHESTRATOR   hyper-captain, impl-captain, review-captain, verify-captain
       │               Skills: hyper-craft + task-specific
       ▼
WORKER LAYER           repo-analyst, executor, reviewer
                       Skills: hyper-craft + domain-specific
```

**Skill Types:**
- **Core skills** - Always loaded (e.g., `hyper-craft`)
- **Task skills** - Phase-specific (e.g., `hyper-planning`)
- **User skills** - Configurable via Settings UI

**Configurable Skill Slots:**

| Slot | Default | Options |
|------|---------|---------|
| `doc-lookup` | context7 | context7, web-search, none |
| `code-search` | codebase-search | codebase-search, sourcegraph, none |
| `browser-testing` | playwright | playwright, puppeteer, none |
| `error-tracking` | none | none or custom integration |

Customize via workspace settings: `$HYPER_WORKSPACE_ROOT/settings/skills/`

### Skills

The workflow leverages 14 skills including the bundled Hypercraft VM:

| Skill | Used By | Purpose |
|-------|---------|---------|
| `hyper-cli` | All commands | CLI command reference for workspace operations |
| `hyper-local` | All hyper-* commands | Guidance on `$HYPER_WORKSPACE_ROOT/` directory operations |
| `hyper-craft` | All commands | Workflow routing, artifact placement, templates, and CLI conventions |
| `hyper-planning` | hyper-plan | Spec-driven planning with research and approval gates |
| `hyper-research` | hyper-plan | Orchestrate comprehensive codebase research |
| `hyper-implementation` | hyper-implement | Task execution with verification gates |
| `hyper-verification` | hyper-verify | Automated and manual verification workflows |
| `hyper-workflow-enforcement` | All commands | Status transitions and gate requirements |
| `hyper-activity-tracking` | All commands | Activity tracking for file modifications |
| `git-worktree` | hyper-implement | Isolated parallel development with Git worktrees |
| `compound-docs` | hyper-review, hyper-plan | Document recurring patterns and learnings |
| `compound-engineering` | All commands | Capture learnings from workflow triggers |
| `skill-template-creator` | All commands | Create reusable skill templates |
| `hyper` | All .prose workflows | Hypercraft VM for executing workflow files (fork of OpenProse) |

### Quick Start

```bash
# Initialize workspace
/hyper:init

# Check status
/hyper:status

# Plan a new feature
/hyper:plan "Add user authentication"

# Implement a task
/hyper:implement auth-login

# Verify implementation
/hyper:verify auth-login
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

### Agents (10)

Orchestrators (2), Research agents (4), Detection agent (1), Testing agent (1), and Verification agents (2):

| Agent | Category | Description |
|-------|----------|-------------|
| `research-orchestrator` | Orchestrators | Coordinate research sub-agents in parallel, synthesize findings |
| `implementation-orchestrator` | Orchestrators | Coordinate engineering sub-agents, enforce verification gates |
| `repo-research-analyst` | Research | Research repository structure and conventions |
| `best-practices-researcher` | Research | Gather external best practices and examples |
| `framework-docs-researcher` | Research | Research framework documentation and best practices |
| `git-history-analyzer` | Research | Analyze git history and code evolution |
| `prior-system-detector` | Detection | Identify prior systems, migrations, or legacy integrations |
| `web-app-debugger` | Testing | Debug and test web apps using Claude Code Chrome extension |
| `tauri-ui-verifier` | Verification | Internal-only UI verification (not enabled by default) |
| `workflow-observer` | Verification | Internal-only observability hooks (not enabled by default) |

### Commands (9)

| Command | Description |
|---------|-------------|
| `/hyper:init` | Initialize or repair workspace structure in HyperHome |
| `/hyper:import-external` | Import from external systems (TODO.md, GitHub Issues, Linear) |
| `/hyper:status` | View project and task status from CLI |
| `/hyper:plan` | Spawn research agents → create spec → wait for approval → create tasks |
| `/hyper:implement` | Implement task with verification loop |
| `/hyper:implement-worktree` | Implement task in isolated worktree (mandatory isolation) |
| `/hyper:review` | Orchestrate code review with domain sub-agents |
| `/hyper:verify` | Run comprehensive automated and manual verification |
| `/hyper:research` | Standalone research workflow with comprehensive or deep modes |

### Hypercraft Workflows (5)

Executable workflows using Hypercraft VM (a fork of [OpenProse](https://github.com/openprose/prose)):

| Workflow | Description |
|----------|-------------|
| `hyper-plan.prose` | Full planning: research → direction gate → spec → approval → tasks |
| `hyper-implement.prose` | Implementation: load task → analyze → implement → review → verify |
| `hyper-review.prose` | Review: scoped code review with domain reviewers |
| `hyper-verify.prose` | Verification: automated checks → Hypercraft state → UI verification |
| `hyper-status.prose` | Status reporting: project/task overview with progress metrics |

### Skills (14)

Core skills including bundled Hypercraft VM:

| Skill | Description |
|-------|-------------|
| `hyper-cli` | Complete CLI command reference for programmatic file operations |
| `hyper-local` | Expert guidance for `$HYPER_WORKSPACE_ROOT/` directory operations and local-first development |
| `hyper-craft` | Routing and conventions for workflows, artifacts, templates, and CLI usage |
| `hyper-planning` | Spec-driven planning with research and approval gates |
| `hyper-research` | Orchestrate comprehensive codebase research |
| `hyper-implementation` | Task execution with verification gates |
| `hyper-verification` | Automated and manual verification workflows |
| `hyper-workflow-enforcement` | Status transitions and gate requirements |
| `hyper-activity-tracking` | Activity tracking for file modifications |
| `git-worktree` | Manage Git worktrees for parallel development |
| `compound-docs` | Capture solved problems as categorized documentation |
| `compound-engineering` | Detect triggers and capture learnings from workflow execution |
| `skill-template-creator` | Create new skills as templates for HyperCraft workflows |
| `hyper` | Hypercraft VM for executing .prose workflow files (fork of OpenProse) |

### Documentation

| Document | Description |
|----------|-------------|
| [Skill Authoring Guide](./docs/skill-authoring-guide.md) | How to create custom skills |
| [Architecture](./docs/architecture.md) | Technical overview of skill-based architecture |
| [API Reference](./docs/api-reference.md) | Hypercraft VM syntax, output contracts, schemas |

## MCP Servers

| Server | Description |
|--------|-------------|
| `context7` | Framework documentation lookup via Context7 |

### Context7

**Tools provided:**
- `resolve-library-id` - Find library ID for a framework/package
- `get-library-docs` - Get documentation for a specific library

Supports 100+ frameworks including Rails, React, Next.js, Vue, Django, Laravel, and more.


## CLI & Activity Tracking

The plugin includes a bundled Hypercraft CLI binary (`hypercraft`, alias `hyper`) for managing workspace files, Drive notes, and activity tracking.

### CLI Overview

```
hypercraft <COMMAND>

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
  search    Search across all resources (projects, tasks)
  vfs       Virtual filesystem operations (list, resolve, search)
```

### Essential CLI Commands

```bash
# Initialize workspace
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft init --name "My Project"

# Create project with validated frontmatter
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft project create \
  --slug "auth-system" \
  --title "User Auth" \
  --priority "high" \
  --json

# Create task (ID auto-generated)
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft task create \
  --project "auth-system" \
  --title "Phase 1: OAuth Setup" \
  --priority "high" \
  --json

# Update task status (ID is positional argument)
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft task update as-001 --status "in-progress"

# Update project status (slug is positional argument)
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft project update auth-system --status "in-progress"

# List projects
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft project list --json

# Archive project (hide from default views)
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft project archive --slug auth-system
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft project archive --slug auth-system --unarchive

# Search across all resources
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft search "OAuth" --json

# Create Drive note
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft drive create "Research Notes" --folder "research" --json

# Low-level file operations
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft file read projects/auth-system/_project.mdx --json
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft file write projects/auth-system/_project.mdx --body "New content" --json
```

### Automatic Activity Tracking

Write, edit, and session events are wired via Claude Code hooks:
- PreToolUse validates writes before they happen
- SessionStart runs workspace checks
- PostToolUse tracks activity and validates frontmatter

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
claude /plugin install hyper
```

Then initialize a workspace:

```bash
/hyper:init
```

## Hypercraft Integration

This plugin works standalone, but optionally integrates with [Hypercraft](https://github.com/juanbermudez/hyper-control) desktop app:

- Hypercraft watches `$HYPER_WORKSPACE_ROOT/` via file watcher
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
