---
name: hyper-planning
description: This skill provides planning-specific knowledge for the planning orchestrator including HITL gate patterns, research coordination, and specification writing guidelines.
model: sonnet
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Task
  - AskUserQuestion
---

# Hyper Planning Skill

Planning-specific knowledge for the hyper-captain during `/hyper:plan` workflows.

## Planning Workflow Overview

The planning workflow has 3 HITL (Human-In-The-Loop) gates:

1. **Gate 1: Pre-Research Clarification** - Confirm understanding before research
2. **Gate 2: Post-Research Direction** - Approve approach after research
3. **Gate 3: Spec Approval** - Approve specification before task creation

## HITL Gate Pattern

At each gate, follow this pattern:

```
1. READ the relevant artifact (research summary, spec, etc.)
2. DISPLAY the FULL content to the user (never summarize)
3. ASK for explicit approval using AskUserQuestion
4. WAIT for user response before proceeding
5. RECORD the decision in the binding
```

## Research Coordination

### Spawning Research Agents

Use the Task tool to spawn these research agents in parallel:

| Agent | Skills | Focus |
|-------|--------|-------|
| `repo-analyst` | hyper-craft, code-search | Codebase patterns, existing implementations |
| `best-practices` | hyper-craft, doc-lookup | External best practices, industry standards |
| `framework-docs` | hyper-craft, doc-lookup | Framework/library documentation |
| `git-analyzer` | hyper-craft, code-search | Code evolution, historical context |

### Research Output Location

All research artifacts go to:
```
$HYPER_WORKSPACE_ROOT/projects/{slug}/resources/research/
├── codebase-analysis.md     # From repo-analyst
├── best-practices.md        # From best-practices
├── framework-docs.md        # From framework-docs
├── git-history.md           # From git-analyzer
└── research-summary.md      # Synthesized by captain
```

## Specification Writing

### Required Sections

Every project specification MUST include:

- **Overview**: Problem statement and proposed solution
- **Goals**: Numbered list of objectives
- **Technical Approach**: Architecture, key components, integration points
- **Implementation Phases**: Numbered phases for task breakdown
- **Acceptance Criteria**: Testable success conditions
- **Out of Scope**: Explicit exclusions
- **Dependencies**: External and internal dependencies
- **Risks**: Risk assessment with mitigations

### Spec Quality Checklist

Before presenting spec for approval:

- [ ] All required sections present
- [ ] Goals are specific and measurable
- [ ] Implementation phases map to tasks
- [ ] Acceptance criteria are testable
- [ ] Out of scope is explicitly defined
- [ ] Technical approach references research findings

## Task Creation Guidelines

### Task Sizing

- Each task should represent ~1-4 hours of work
- Tasks should be independently completable
- Include a final "documentation and testing" task
- Include quality gate verification task

### Task Dependencies

Set `depends_on` to establish order:
- Phase 2 depends on Phase 1
- Documentation task depends on all implementation tasks
- QA task depends on all tasks

## Project Creation Flow

**CRITICAL**: Create project skeleton BEFORE research:

```bash
# Create project via CLI (visible in Hypercraft immediately)
hypercraft project create \
  --slug "$PROJECT_SLUG" \
  --title "{feature}" \
  --priority "high" \
  --status "planned" \
  --json
```

This ensures the project appears in Hypercraft immediately, even before research completes.
