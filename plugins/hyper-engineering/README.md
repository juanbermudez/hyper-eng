# Hyper-Engineering Plugin

Linear-integrated, spec-driven development workflow. Specs matter more than code—specifications are the source of truth, code is disposable.

## Components

| Component | Count |
|-----------|-------|
| Agents | 4 |
| Commands | 5 |
| Skills | 3 |
| MCP Servers | 2 |

---

## Hyper-Engineering Workflow

**Specs matter more than code. Code is disposable; specifications are the source of truth.**

The hyper-engineering workflow uses Linear as the single source of truth, with mandatory human review gates and verification loops.

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
| `/hyper-plan` | Spawn 4 specialized research agents → create spec with diagrams → wait for approval → create tasks |
| `/hyper-implement` | Implement Linear task with verification loop |
| `/hyper-review` | Orchestrate parallel domain reviewers (security, architecture, performance, code quality) |
| `/hyper-verify` | Run comprehensive automated and manual verification |
| `/hyper-init-stack` | Initialize stack-specific templates (node-typescript, python, go) |

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
| `linear-cli-expert` | All hyper-* commands | Guidance on Linear CLI commands and workflows |
| `git-worktree` | hyper-implement | Isolated parallel development with Git worktrees |
| `compound-docs` | hyper-review, hyper-plan | Document recurring patterns and learnings |

### Setup

Run the setup script to configure Linear workflow states:

```bash
./scripts/setup-linear-statuses.sh
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

### Commands (5)

All commands use the `hyper-*` prefix:

| Command | Description |
|---------|-------------|
| `/hyper-plan` | Spawn 4 specialized research agents → create spec with diagrams → wait for approval → create tasks |
| `/hyper-implement` | Implement Linear task with verification loop |
| `/hyper-review` | Orchestrate parallel domain reviewers (security, architecture, performance, code quality) |
| `/hyper-verify` | Run comprehensive automated and manual verification |
| `/hyper-init-stack` | Initialize stack-specific templates (node-typescript, python, go) |

### Skills (3)

Core skills for the hyper-engineering workflow:

| Skill | Description |
|-------|-------------|
| `linear-cli-expert` | Expert guidance for spec-driven development with Linear CLI and AI agents |
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
