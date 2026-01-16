---
name: hyper-planning
description: This skill should be used when the user asks to "plan a feature", "create a specification", "break down a project", or mentions planning, specs, PRDs, or project setup. Guides multi-phase planning with research, interviews, and approval gates.
version: 1.0.0
model: sonnet
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
  - WebFetch
  - WebSearch
  - AskUserQuestion
  - Skill
includes:
  - hyper-workflow-enforcement
  - hyper-cli
  - hyper-local
---

# Hyper Planning Skill

Expert guidance for creating comprehensive project specifications with research-backed decisions and approval gates.

## Overview

This skill guides you through a rigorous planning workflow:

1. **Initial Interview** - Use AskUserQuestion to deeply understand requirements
2. **Research Phase** - Spawn parallel research sub-agents
3. **Post-Research Interview** - Clarify decisions surfaced by research
4. **Direction Validation (Gate 1)** - Get early approval before detailed spec
5. **Specification Creation** - Write comprehensive technical PRD
6. **Specification Review (Gate 2)** - Wait for human approval
7. **Task Breakdown** - Create task files only after approval

**Philosophy**: Don't assume - ASK. Use AskUserQuestion liberally. Each answer informs the next question. Complex features may require 10+ questions.

## Reference Documents

- [Interview Guide](./references/interview-guide.md) - Interview methodology and question patterns
- [Spec Template](./references/spec-template.md) - Comprehensive specification template
- [Task Template](./references/task-template.md) - Task file structure and patterns
- [Initialization Steps](./references/initialization-steps.md) - Workspace setup procedures
- [Post-Research Interview](./references/post-research-interview.md) - Post-research clarification patterns

## Workflow Phases

### Phase 1: Initialization

<hyper-embed file="references/initialization-steps.md" />

### Phase 2: Initial Interview

<hyper-embed file="references/interview-guide.md" />

### Phase 3: Research

Spawn the research orchestrator to coordinate comprehensive research:

```
Task tool with subagent_type: "hyper:research-orchestrator"

Prompt: "Coordinate comprehensive research for:
Feature: [feature description]
Project Slug: ${PROJECT_SLUG}
Frameworks: [list from clarification]
Focus Areas: [from user priorities]

Spawn 4 research sub-agents in parallel:
- repo-research-analyst: Codebase patterns
- best-practices-researcher: External best practices
- framework-docs-researcher: Framework docs via Context7
- git-history-analyzer: Code evolution

Write findings to: $HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/resources/research/
Return JSON summary with key findings."
```

### Phase 4: Post-Research Interview

<hyper-embed file="references/post-research-interview.md" />

### Phase 5: Direction Check (Gate 1)

Present a brief summary for early validation:

```markdown
## Direction Check

**Problem**: [2-3 sentence summary]

**Proposed Approach**:
- [Key approach point 1]
- [Key approach point 2]

**Key Technical Decisions**:
- [Decision]: [Rationale]

**Estimated Phases**: [Phase 1] → [Phase 2] → [Phase 3]

**Research Summary**:
- Codebase: [Key finding]
- Best Practices: [Key finding]

Does this direction look right before I write the detailed spec?
```

**Wait for approval before proceeding to detailed spec.**

### Phase 6: Specification Creation

<hyper-embed file="references/spec-template.md" />

### Phase 7: Review Gate (Gate 2)

**STOP - Do NOT create tasks yet**

Update project frontmatter:
- Change: `status: planned` (unchanged, awaiting approval)
- Update: `updated: [today's date]`

Inform user:
```
## Specification Ready for Review

**Project**: `$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/`
**Spec**: `$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/_project.mdx`

Please review and provide feedback. Reply "approved" to create task breakdown.

**I will NOT create tasks until you approve this specification.**
```

### Phase 8: Task Breakdown (After Approval Only)

<hyper-embed file="references/task-template.md" />

## Status Reference

**Project Status Values**:
- `planned` - Initial state, research/spec phase
- `todo` - Spec approved, tasks created, ready for work
- `in-progress` - Implementation underway
- `qa` - All tasks done, project-level QA
- `completed` - All quality gates passed
- `canceled` - Project abandoned

**Status Transitions**:
1. Create project → `planned`
2. Spec ready for review → `planned` (awaiting Gate 2)
3. Spec approved → `todo` + create tasks

## ID Conventions

**Project ID**: `proj-{kebab-case-slug}`
- Example: `proj-user-auth`, `proj-workspace-settings`

**Task ID**: `{project-initials}-{3-digit-number}`
- Derive initials from project slug (first letter of each word)
- Example: `user-auth` → `ua`, tasks are `ua-001`, `ua-002`

## CLI Integration

Use the Hyper CLI for file operations:

```bash
# Create project with validated frontmatter
${CLAUDE_PLUGIN_ROOT}/binaries/hyper project create \
  --slug "${PROJECT_SLUG}" \
  --title "[TITLE]" \
  --priority "[PRIORITY]" \
  --summary "[BRIEF_SUMMARY]"

# Create task with validated frontmatter
${CLAUDE_PLUGIN_ROOT}/binaries/hyper task create \
  --project "${PROJECT_SLUG}" \
  --id "${TASK_ID}" \
  --title "[TITLE]" \
  --priority "[PRIORITY]"

# Update status
${CLAUDE_PLUGIN_ROOT}/binaries/hyper project update \
  "${PROJECT_SLUG}" --status "todo"
```

## Activity Tracking

Activity is automatically tracked via PostToolUse hook when writing to `$HYPER_WORKSPACE_ROOT/` files. Session IDs are captured in the `activity` array in frontmatter.

## Best Practices

- Use AskUserQuestion for EVERY clarifying question - don't batch
- Conduct initial interview BEFORE research
- Read ALL research documents in full after orchestrator returns
- Get direction approval at Gate 1 BEFORE writing detailed spec
- Resolve ALL open questions before approval - none can remain pending
- NEVER create tasks before human approval of full specification
- Include file:line references to actual codebase locations
- All diagrams must be grounded in real component hierarchy

## Error Handling

| Condition | Action |
|-----------|--------|
| Unclear requirements | Ask additional targeted questions |
| Research insufficient | Launch focused research tasks |
| User provides feedback | Update spec and return to review gate |
| Project already exists | Ask: continue existing or create new? |

## Includes

This skill depends on:

- **hyper-workflow-enforcement** - Status transition validation
- **hyper-cli** - CLI command patterns
- **hyper-local** - Directory structure guidance
