# API Reference

Technical reference for the skill-based workflow system.

## Hypercraft VM Syntax

### Agent Definition with Skills

```prose
agent agent-name:
  model: opus|sonnet|haiku
  persist: true|false
  skills:
    - skill-name-1
    - skill-name-2
    - slot-name            # Resolved from settings
  prompt: """Agent system prompt"""
```

### Skill Field

The `skills:` field declares which skills an agent should load:

```yaml
skills:
  - hyper-craft           # Core skill (always load for hypercraft agents)
  - hyper-planning        # Task-specific skill
  - doc-lookup            # Configurable slot
```

### Model Selection

| Model | Use Case | Token Limit |
|-------|----------|-------------|
| `opus` | Complex reasoning, orchestration | High |
| `sonnet` | General tasks, specialists | Medium |
| `haiku` | Simple lookups, formatting | Low |

### Persistence

```yaml
persist: true   # Maintains state across sessions
persist: false  # Stateless (default)
```

Use `persist: true` for orchestrators that need conversation continuity.

## Output Contract Format

Specialists return structured JSON to orchestrators:

```json
{
  "status": "complete|partial|blocked|error",
  "findings": {
    "summary": "Brief human-readable summary",
    "details": "Detailed information",
    "key_points": ["Point 1", "Point 2"]
  },
  "artifacts": {
    "artifact-key": "path/to/artifact.md",
    "another-artifact": "path/to/file.ts"
  },
  "next_steps": [
    "Suggested follow-up action 1",
    "Suggested follow-up action 2"
  ],
  "metadata": {
    "duration_ms": 1234,
    "tools_used": ["Read", "Grep"],
    "files_modified": ["path/to/file.ts"]
  }
}
```

### Status Values

| Status | Description | When to Use |
|--------|-------------|-------------|
| `complete` | Task finished successfully | All objectives met |
| `partial` | Some progress made | Needs more work or clarification |
| `blocked` | Cannot proceed | Missing dependencies or permissions |
| `error` | Task failed | Unrecoverable error |

### Findings Object

```json
"findings": {
  "summary": "Found 3 similar patterns in the codebase",
  "details": "Detailed analysis...",
  "key_points": [
    "Pattern A used in auth module",
    "Pattern B used in API layer"
  ],
  "recommendations": [
    "Follow Pattern A for consistency"
  ]
}
```

### Artifacts Object

Maps artifact names to file paths:

```json
"artifacts": {
  "research-summary": "$HYPER_WORKSPACE_ROOT/projects/slug/resources/research-summary.md",
  "codebase-analysis": "$HYPER_WORKSPACE_ROOT/projects/slug/resources/research/codebase.md"
}
```

## Skill Template Format

YAML format for configurable skill slots:

```yaml
# {slot-name}.yaml
# Description comment explaining this skill slot

# Selected skill implementation
# Options: skill-1, skill-2, none
selected: skill-1

# Implementation-specific configuration
config:
  skill-1:
    setting1: value1
    setting2: value2
  skill-2:
    setting1: value1

# Instructions added when this skill loads
instructions_append: |
  Additional context or guidelines that apply
  regardless of which implementation is selected.

# Contexts where this skill should be skipped
skip_in_contexts: []
  # Example:
  # - quick-review
  # - docs-only
```

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `selected` | string | Currently selected implementation |

### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `config` | object | Per-implementation settings |
| `instructions_append` | string | Extra instructions for all implementations |
| `skip_in_contexts` | array | Contexts where slot should be skipped |

## SKILL.md Frontmatter

### Required Fields

```yaml
---
name: skill-name              # Must match directory name
description: This skill...    # Third person, starts with "This skill"
---
```

### Optional Fields

```yaml
---
name: skill-name
description: This skill provides...
model: sonnet                       # Preferred model
version: 1.0.0                      # Semantic version
allowed-tools:                      # Tool restrictions
  - Read
  - Write
  - Bash
includes:                           # Other skills to load
  - hyper-craft
---
```

### Description Format

**Must** start with "This skill..." (third person):

```yaml
# Correct
description: This skill provides guidance for API integration patterns.

# Incorrect
description: Use this skill to integrate APIs.
description: Guidance for API integration.
```

## Trigger Detection Keywords

### User Correction Keywords

```yaml
user_correction_keywords:
  - "actually"
  - "you're right"
  - "you are right"
  - "no, I meant"
  - "that's not what I asked"
  - "let me clarify"
  - "that's wrong"
  - "not quite"
```

### Self-Correction Keywords

```yaml
self_correction_keywords:
  - "my bad"
  - "I apologize"
  - "let me correct"
  - "I was wrong"
  - "I should have"
  - "mistake on my part"
  - "let me fix that"
```

### Unexpected Behavior Keywords

```yaml
unexpected_behavior_keywords:
  - "that's weird"
  - "shouldn't happen"
  - "unexpected"
  - "strange"
  - "interesting, that"
```

### Trigger Priority

| Trigger Type | Priority | Threshold |
|--------------|----------|-----------|
| Tool error + user correction | Critical | Any |
| User correction | High | 1+ |
| Tool error | High | 3+ |
| Self-correction | Medium | 1+ |
| Multiple retries | Medium | 3+ |
| Single tool error | Low | 1 |

## Learnings Schema

### File Location

```
$HYPER_WORKSPACE_ROOT/projects/{project-slug}/resources/learnings.md
```

### Entry Format

```markdown
## [Category]: [Title]

**Date**: YYYY-MM-DD
**Session ID**: {workflow}-{timestamp}-{uuid}
**Trigger Type**: tool_error|user_correction|self_correction|multiple_retries|manual
**Severity**: critical|high|medium|low

### Context
What was being accomplished when this happened.

### What Happened
The specific issue, error, or insight.

### Root Cause
Why this happened - technical explanation.

### Solution
How it was resolved.

### Future Prevention
Actionable guidance to avoid in future.

### Tags
#category #technology #pattern
```

### Category Taxonomy

| Category | Description |
|----------|-------------|
| Testing | Test setup, assertions, mocking |
| Configuration | Config files, environment |
| Types | TypeScript, type errors |
| Performance | Speed, memory, optimization |
| Integration | External services, APIs |
| Build | Compilation, bundling |
| Runtime | Execution errors |
| Workflow | Process, tooling |

## CLI Commands

### Hypercraft CLI

```bash
# Get workspace data path
hypercraft config get globalPath

# Project operations
hypercraft project create --slug "my-project" --title "My Project" --priority high
hypercraft project update "my-project" --status in-progress
hypercraft project get "my-project" --json

# Task operations
hypercraft task create --project "my-project" --title "Task 1" --priority high
hypercraft task update "task-001" --status complete
hypercraft task list --project "my-project" --json

# File operations
hypercraft file write "path/to/file.md" --body "content"
hypercraft file read "path/to/file.md" --json
```

### Status Values

**Project statuses:**
```
planned → todo → in-progress → qa → completed
                                  → canceled
```

**Task statuses:**
```
draft → todo → in-progress → qa → complete
                               → blocked
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `$HYPER_WORKSPACE_ROOT` | Workspace root directory |
| `$CLAUDE_PLUGIN_ROOT` | Plugin installation directory |

## File Paths

### Plugin Paths

```
hyper-engineer-plugin/plugins/hyper/
├── skills/           # Plugin skills
├── commands/         # Hypercraft command files
├── blocks/           # Reusable workflow blocks
├── templates/        # Default templates
└── docs/             # Documentation
```

### Workspace Paths

```
$HYPER_WORKSPACE_ROOT/
├── projects/         # Project directories
├── settings/         # User settings
│   ├── skills/       # Skill configurations
│   ├── commands/     # Command configurations
│   └── agents/       # Agent configurations
└── .prose/           # Hypercraft runtime state
    ├── runs/         # Execution state
    └── agents/       # Persistent agent state
```
