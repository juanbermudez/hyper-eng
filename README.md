<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-Plugin-purple?style=for-the-badge" alt="Claude Code Plugin" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="MIT License" />
  <img src="https://img.shields.io/badge/Version-3.16.2-blue?style=for-the-badge" alt="Version" />
</p>

# Hyper-Engineering

**Specs first. Code second. Verification always.**

A Claude Code plugin for local-first, spec-driven development. It turns workflows into reusable programs, keeps all artifacts local, and enforces human gates before code ships. Works standalone or with the Hypercraft desktop app.

## Why Hyper-Engineering?

Traditional AI-assisted development is chaotic. You prompt, get code, fix bugs, repeat. Context gets lost. Quality varies.

Hyper-Engineering inverts this:

- **Research before planning** - Parallel research agents explore the codebase and docs
- **Specs before code** - The spec is the source of truth
- **Approval before work** - Gates prevent wasted effort
- **Verification before done** - QA must pass before completion

## Quick Start

In Claude Code, run these slash commands:

```
# Add the marketplace
/plugin marketplace add juanbermudez/hyper-eng

# Install the plugin
/plugin install hyper

# Initialize workspace
/hyper:init

# Start planning
/hyper:plan "Add user authentication with OAuth"
```

## Workflow

```mermaid
flowchart LR
    R[Research] --> S[Spec + Direction Gate]
    S --> A[Approval Gate]
    A --> T[Task Files]
    T --> I[Implement]
    I --> RV[Review]
    RV --> V[Verify/QA]
    V --> C[Completed]

    subgraph Workspace["$HYPER_WORKSPACE_ROOT/"]
      P[_project.mdx]
      K[tasks/task-NNN.mdx]
      Q[resources/]
    end

    R --> Q
    S --> P
    T --> K
```

## Commands

| Command | Description |
|---------|-------------|
| `/hyper:init` | Initialize workspace structure and migrate legacy data |
| `/hyper:plan` | Research → spec → approval → tasks |
| `/hyper:implement` | Execute a task with verification loops |
| `/hyper:implement-worktree` | Implement in an isolated worktree |
| `/hyper:review` | Parallel code review (security, architecture, performance, quality) |
| `/hyper:verify` | Automated + manual verification gates |
| `/hyper:status` | View project and task status |
| `/hyper:research` | Research-only workflow |
| `/hyper:import-external` | Import from external systems (Linear, GitHub, TODO.md) |

## Agent Model

Captains are user-facing and select workflows. Orchestrators manage steps and pass a minimal skill list to workers.

```mermaid
graph TD
    U[User] --> C[Captain]
    C --> O[Orchestrator]
    O --> W1[Worker Agents]
    O --> W2[Reviewers]
    W1 --> CLI[Hypercraft CLI]
    W2 --> CLI
    CLI --> FS[$HYPER_WORKSPACE_ROOT/]
    CLI --> DRV[Drive (personal:/ws:)]
```

## Status Model

Project flow:

```
planned → todo → in-progress → qa → completed
```

Task flow:

```
draft → todo → in-progress → qa → complete
```

## Archiving Projects

Archive hides projects from default views without deleting files:

```
hypercraft project archive --slug auth-system
hypercraft project archive --slug auth-system --unarchive
```

## Artifacts and Drives

Workspace artifacts live under `$HYPER_WORKSPACE_ROOT/` and are git-trackable.
Drive items live in HyperHome and are accessed via the CLI:

```
hypercraft drive list --json
hypercraft drive get ws:notes/overview.md --json
hypercraft drive get personal:ideas/agent-notes.md --json
```

## Components

| Type | Count | Description |
|------|-------|-------------|
| Agents | 10 | Orchestrators, research, detection, testing, verification |
| Commands | 9 | Core workflow commands |
| Workflows | 5 | `.prose` programs executed by the Hypercraft VM |
| Skills | 14 | Reusable knowledge + VM |
| MCP Servers | 1 | Context7 for framework docs |

## Hypercraft VM Credit

Hypercraft VM, the workflow VM used by this plugin, is a full fork of [OpenProse](https://github.com/openprose/prose) adapted for Hypercraft workflows.

## Philosophy

**Specs matter more than code.**

Code is disposable. Specifications capture intent, decisions, and rationale. Hyper-Engineering treats specs as the source of truth, with the local `$HYPER_WORKSPACE_ROOT/` directory as the persistent system of record.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT — see [LICENSE](LICENSE) for details.

---

<p align="center">
  <sub>Built for developers who believe specs should outlive code.</sub>
</p>
