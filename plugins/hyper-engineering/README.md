<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-Plugin-purple?style=for-the-badge" alt="Claude Code Plugin" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="MIT License" />
  <img src="https://img.shields.io/badge/Version-2.7.0-blue?style=for-the-badge" alt="Version" />
</p>

# Hyper-Engineering Plugin

**Specs first. Code second. Verification always.**

Local-first, spec-driven development workflow. Specs matter more than code—specifications are the source of truth, code is disposable.

Works standalone or with [Hyper Control](https://github.com/juanbermudez/hyper-control) desktop app.

## Components

| Component | Count |
|-----------|-------|
| Agents | 7 |
| Commands | 9 |
| Skills | 3 |
| MCP Servers | 1 |

---

## Hyper-Engineering Workflow

**Specs matter more than code. Code is disposable; specifications are the source of truth.**

The hyper-engineering workflow uses local `.hyper/` directory as the source of truth, with mandatory human review gates and verification loops.

### Directory Structure

```
.hyper/
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
| Project | `_project.mdx` | `.hyper/projects/auth-system/_project.mdx` |
| Task | `task-NNN.mdx` | `.hyper/projects/auth-system/tasks/task-001.mdx` |
| Initiative | `{slug}.mdx` | `.hyper/initiatives/q1-goals.mdx` |
| Doc | `{slug}.mdx` | `.hyper/docs/architecture.mdx` |

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
| `/hyper-init` | Initialize `.hyper/` workspace structure |
| `/hyper-status` | View project and task status from CLI |
| `/hyper-plan` | Spawn research agents → create spec → wait for approval → create tasks |
| `/hyper-implement` | Implement task with verification loop |
| `/hyper-review` | Orchestrate parallel domain reviewers |
| `/hyper-verify` | Run comprehensive automated and manual verification |
| `/hyper-init-stack` | Initialize stack-specific templates |
| `/hyper-statusline:setup` | Install Dracula statusline |
| `/hyper-statusline:optout` | Opt out of statusline prompt |

### Agents

7 specialized agents for orchestration, research, and debugging:

| Agent | Category | Purpose |
|-------|----------|---------|
| `research-orchestrator` | Orchestrators | Coordinate research sub-agents in parallel |
| `implementation-orchestrator` | Orchestrators | Coordinate engineering sub-agents and verification |
| `repo-research-analyst` | Research | Research repository structure and conventions |
| `best-practices-researcher` | Research | Gather external best practices and examples |
| `framework-docs-researcher` | Research | Research framework documentation and best practices |
| `git-history-analyzer` | Research | Analyze git history and code evolution |
| `web-app-debugger` | Testing | Debug web apps using Chrome extension for browser inspection |

### Skills

The workflow leverages 3 core skills:

| Skill | Used By | Purpose |
|-------|---------|---------|
| `hyper-local` | All hyper-* commands | Guidance on `.hyper/` directory operations |
| `git-worktree` | hyper-implement | Isolated parallel development with Git worktrees |
| `compound-docs` | hyper-review, hyper-plan | Document recurring patterns and learnings |

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

Customize workflows, agents, and commands via `.hyper/settings/`:

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

### Agents (7)

Orchestrators (2), Research agents (4), and Testing agent (1):

| Agent | Category | Description |
|-------|----------|-------------|
| `research-orchestrator` | Orchestrators | Coordinate research sub-agents in parallel, synthesize findings |
| `implementation-orchestrator` | Orchestrators | Coordinate engineering sub-agents, enforce verification gates |
| `repo-research-analyst` | Research | Research repository structure and conventions |
| `best-practices-researcher` | Research | Gather external best practices and examples |
| `framework-docs-researcher` | Research | Research framework documentation and best practices |
| `git-history-analyzer` | Research | Analyze git history and code evolution |
| `web-app-debugger` | Testing | Debug and test web apps using Claude Code Chrome extension |

### Commands (9)

| Command | Description |
|---------|-------------|
| `/hyper-init` | Initialize `.hyper/` workspace structure with templates |
| `/hyper-status` | View project and task status from CLI |
| `/hyper-plan` | Spawn research agents → create spec → wait for approval → create tasks |
| `/hyper-implement` | Implement task with verification loop |
| `/hyper-review` | Orchestrate parallel domain reviewers |
| `/hyper-verify` | Run comprehensive automated and manual verification |
| `/hyper-init-stack` | Initialize stack-specific templates (node-typescript, python, go) |
| `/hyper-statusline:setup` | One-command installation of Dracula statusline |
| `/hyper-statusline:optout` | Opt out of statusline setup prompt |

### Skills (3)

Core skills for the hyper-engineering workflow:

| Skill | Description |
|-------|-------------|
| `hyper-local` | Expert guidance for `.hyper/` directory operations and local-first development |
| `git-worktree` | Manage Git worktrees for parallel development |
| `compound-docs` | Capture solved problems as categorized documentation |

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

The plugin includes a bundled CLI binary (`hyper`) for creating projects, tasks, and tracking activity.

### CLI Commands

```bash
# Create project with validated frontmatter
${CLAUDE_PLUGIN_ROOT}/binaries/hyper project create \
  --slug "auth-system" \
  --title "User Auth" \
  --priority "high"

# Create task
${CLAUDE_PLUGIN_ROOT}/binaries/hyper task create \
  --project "auth-system" \
  --id "as-001" \
  --title "Phase 1: OAuth Setup"

# Update status
${CLAUDE_PLUGIN_ROOT}/binaries/hyper task update \
  --id "as-001" \
  --project "auth-system" \
  --status "in-progress"
```

### Automatic Activity Tracking

Activity is tracked automatically via PostToolUse hook:

1. Agent writes to `.hyper/*.mdx` file
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

See `skills/hyper-local/references/frontmatter-schema.md` for full activity format.

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

- Hyper Control watches `.hyper/` via file watcher
- TanStack DB syncs from `.hyper/` files
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
