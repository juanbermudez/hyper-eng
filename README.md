<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-Plugin-purple?style=for-the-badge" alt="Claude Code Plugin" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="MIT License" />
  <img src="https://img.shields.io/badge/Linear-Integrated-blue?style=for-the-badge" alt="Linear Integrated" />
</p>

# Hyper-Engineering

**Specs first. Code second. Verification always.**

A Claude Code plugin for spec-driven development with Linear integration. Transform vague ideas into comprehensive specifications, implement them systematically, and verify everything before it ships.

## Why Hyper-Engineering?

Traditional AI-assisted development is chaotic. You prompt, get code, fix bugs, repeat. Context gets lost. Quality varies wildly.

Hyper-Engineering inverts this:

- **Research before planning** — 4 agents explore your codebase in parallel
- **Specs before code** — Comprehensive specifications with diagrams and success criteria
- **Approval before work** — Two gates prevent wasted effort
- **Verification before done** — Nothing ships without passing all checks

## Quick Start

In Claude Code, run these slash commands:

```
# Add the marketplace
/plugin marketplace add juanbermudez/hyper-eng

# Install the plugin
/plugin install hyper-engineering

# Start planning
/hyper-plan "Add user authentication with OAuth"
```

You'll also need the [Agent Linear CLI](https://github.com/juanbermudez/agent-linear-cli) for Linear integration.

## The Workflow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   RESEARCH  │───▶│    SPEC     │───▶│  IMPLEMENT  │───▶│   VERIFY    │
│             │    │             │    │             │    │             │
│ 4 parallel  │    │ Gate 1: Dir │    │ Incremental │    │ Slop check  │
│ agents      │    │ Gate 2: Full│    │ + worktrees │    │ Auto checks │
│             │    │             │    │             │    │ Manual test │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                          │                   │                  │
                          ▼                   ▼                  ▼
                    ┌─────────────────────────────────────────────────┐
                    │                    LINEAR                        │
                    │    Projects • Specs • Tasks • Status Updates     │
                    └─────────────────────────────────────────────────┘
```

## Commands

| Command | Description |
|---------|-------------|
| `/hyper-plan` | Research → Spec → Approval → Tasks. |
| `/hyper-implement` | Execute a Linear task with verification loops. |
| `/hyper-verify` | Run slop detection + automated checks + manual verification. |
| `/hyper-review` | Parallel code review (security, architecture, performance, quality). |

## What Makes It Different

### Context-Aware Agents

Agents return **pointers, not dumps**. You get `file:line` references and JSON summaries instead of walls of code. Large tasks checkpoint to `PROGRESS.md` so you can continue in a fresh context.

### Slop Detection

AI-specific checks that run before standard verification:
- **Import validation** — Catches hallucinated packages
- **Hardcoded secrets** — Finds API keys that should be env vars
- **Debug statements** — Removes console.log before production

### Two-Gate Approval

1. **Direction checkpoint** — Validate approach before writing detailed spec
2. **Full spec approval** — Review complete spec before creating tasks

### Environment Awareness

Before implementing, agents check if your linters, tests, and docs are ready for the work ahead. Good environments make AI succeed.

## Requirements

- [Claude Code](https://claude.ai/download)
- [Agent Linear CLI](https://github.com/juanbermudez/agent-linear-cli) with API key
- Git (for worktree support)

## Components

| Type | Count | Description |
|------|-------|-------------|
| Agents | 4 | Parallel research specialists |
| Commands | 7 | Core workflow commands |
| Skills | 3 | Reusable capabilities |
| MCP Servers | 2 | Playwright + Context7 |

## Philosophy

**Specs matter more than code.**

Code is disposable. It can be regenerated, refactored, rewritten. Specifications capture intent, decisions, and rationale. They're the permanent artifact.

Hyper-Engineering treats specs as the source of truth. Linear holds everything—projects, documents, tasks, status. Code is just an implementation detail.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT — see [LICENSE](LICENSE) for details.

---

<p align="center">
  <sub>Built for developers who believe specs should outlive code.</sub>
</p>
