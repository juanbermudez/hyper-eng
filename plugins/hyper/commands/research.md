---
description: Conduct comprehensive or deep research on a topic and produce structured findings. Creates research projects with project_type research.
argument-hint: "[topic or question] [--depth comprehensive|deep]"
---

Use the **hyper-research** skill to conduct research on:

$ARGUMENTS

## Depth Modes

**Comprehensive** (default):
- 4 parallel research agents
- Single synthesis round
- 5 output documents

**Deep** (`--depth deep`):
- 7 agents (4 standard + 3 specialists)
- Multiple rounds with PROGRESS.md checkpoints
- 8 output documents including architecture, security, performance

## Research Agents

| Agent | Focus |
|-------|-------|
| repo-research-analyst | Codebase patterns and conventions |
| best-practices-researcher | External best practices, web search |
| framework-docs-researcher | Framework documentation via Context7 |
| git-history-analyzer | Git history and code evolution |
| architecture-analyst | System design patterns (deep mode) |
| security-reviewer | Security implications (deep mode) |
| performance-analyst | Performance considerations (deep mode) |

## Workflow Summary

1. **Clarification** - Use AskUserQuestion to understand research goals
2. **Project Creation** - Create research project with `project_type: research`
3. **Research Orchestration** - Spawn research-orchestrator with selected depth
4. **Review Gate** - Update status to `ready-for-review` when complete

## Output Location

```
$HYPER_WORKSPACE_ROOT/projects/{slug}/
├── _project.mdx              # Research project (project_type: research)
└── resources/research/
    ├── codebase-analysis.md
    ├── best-practices.md
    ├── framework-docs.md
    ├── git-history.md
    ├── research-summary.md
    └── (deep mode: architecture.md, security.md, performance.md)
```

## Status Flow

```
planned → ready-for-review → completed
```

## Key Differences from /hyper:plan

| Aspect | /hyper:research | /hyper:plan |
|--------|-----------------|-------------|
| Goal | Knowledge gathering | Implementation planning |
| Output | Research documents | Spec + task breakdown |
| Tasks | None (documents only) | Full task breakdown |
| Next step | Human review → archive | Approved → implement |

**Activity tracking**: Session ID automatically captured on all $HYPER_WORKSPACE_ROOT/ modifications.
