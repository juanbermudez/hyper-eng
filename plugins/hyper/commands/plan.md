---
description: Create a comprehensive specification with two approval gates - first validating direction after research, then approving the full spec before task creation. Uses local $HYPER_WORKSPACE_ROOT/ directory for all artifacts.
argument-hint: "[feature or requirement description]"
---

Use the **hyper-planning** skill to create a comprehensive specification for:

$ARGUMENTS

## Workflow Summary

The skill guides you through the complete hyper-engineering workflow:

1. **Initial Interview** - Use AskUserQuestion to deeply understand requirements
2. **Research Phase** - Spawn research-orchestrator with 4 parallel sub-agents
3. **Post-Research Interview** - Clarify decisions surfaced by research
4. **Direction Validation (Gate 1)** - Get early approval before detailed spec
5. **Specification Creation** - Detailed technical PRD with file:line references
6. **Specification Review (Gate 2)** - Wait for human approval
7. **Task Breakdown** - Create task files only after approval

## Key Principles

- **Don't assume - ASK**: Use AskUserQuestion liberally for every clarification
- **Research first**: Always run research before writing spec
- **Two gates**: Direction check + full spec approval saves rework
- **Specs are detailed**: Include file:line references, before/after examples, diagrams

## CLI Integration

Use `hyper` CLI for all $HYPER_WORKSPACE_ROOT/ file operations:
- `hyper project create` - Create project with validated frontmatter
- `hyper task create` - Create tasks with proper schema
- `hyper task update --status` - Update status (validates transitions)

## Activity Tracking

Session ID automatically tracked on all file modifications via PostToolUse hook.

## Output Location

```
$HYPER_WORKSPACE_ROOT/projects/{slug}/
├── _project.mdx           # Spec inline in project file
├── tasks/task-*.mdx       # Task breakdown
└── resources/research/    # Research findings
```

## Status Flow

```
planned → todo → in-progress → qa → completed
```

**Strict Methodology**: Follow every phase. Do not skip phases regardless of perceived task simplicity.
