# Hyper-Engineering Plugin

Local-first, spec-driven development workflow. Specs matter more than code—specifications are the source of truth, code is disposable.

Works standalone or with [Hyper Control](https://github.com/juanbermudez/hyper-control) desktop app.

## Components

| Component | Count |
|-----------|-------|
| Agents | 4 |
| Commands | 9 |
| Skills | 3 |
| MCP Servers | 2 |

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
│       ├── project.mdx      # Project definition
│       ├── specification.md # Full specification
│       ├── tasks/           # Task files
│       │   └── {id}.mdx
│       └── resources/       # Supporting docs
│           └── research/    # Research findings
└── docs/                    # Standalone documentation
    └── {slug}.mdx
```

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

### Research Agents

All 4 agents are research specialists used by `/hyper-plan`:

| Agent | Purpose |
|-------|---------|
| `repo-research-analyst` | Research repository structure and conventions |
| `best-practices-researcher` | Gather external best practices and examples |
| `framework-docs-researcher` | Research framework documentation and best practices |
| `git-history-analyzer` | Analyze git history and code evolution |

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

---

## Reference

### Agents (4)

All agents are research specialists used by `/hyper-plan`:

| Agent | Description |
|-------|-------------|
| `repo-research-analyst` | Research repository structure and conventions |
| `best-practices-researcher` | Gather external best practices and examples |
| `framework-docs-researcher` | Research framework documentation and best practices |
| `git-history-analyzer` | Analyze git history and code evolution |

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
| `playwright` | Browser automation via `@playwright/mcp` |
| `context7` | Framework documentation lookup via Context7 |

### Playwright

**Tools provided:**
- `browser_navigate` - Navigate to URLs
- `browser_take_screenshot` - Take screenshots
- `browser_click` - Click elements
- `browser_fill_form` - Fill form fields
- `browser_snapshot` - Get accessibility snapshot
- `browser_evaluate` - Execute JavaScript

### Context7

**Tools provided:**
- `resolve-library-id` - Find library ID for a framework/package
- `get-library-docs` - Get documentation for a specific library

Supports 100+ frameworks including Rails, React, Next.js, Vue, Django, Laravel, and more.

MCP servers start automatically when the plugin is enabled.

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

### MCP Servers Not Auto-Loading

**Issue:** The bundled MCP servers (Playwright and Context7) may not load automatically when the plugin is installed.

**Workaround:** Manually add them to your project's `.claude/settings.json`:

```json
{
  "mcpServers": {
    "playwright": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"],
      "env": {}
    },
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp"
    }
  }
}
```

Or add them globally in `~/.claude/settings.json` for all projects.

## Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## License

MIT
