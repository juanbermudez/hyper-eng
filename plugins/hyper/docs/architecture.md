# Skill-Based Workflow Architecture

Technical overview of the HyperCraft skill-based agent system.

## Overview

The skill-based architecture organizes AI agents into a three-tier hierarchy with composable skills that provide domain-specific knowledge and capabilities.

```
┌─────────────────────────────────────────────────────────────────┐
│                      COMMAND LAYER                              │
│  /hyper:plan    /hyper:implement    /hyper:review    /hyper:verify│
│  Entry points that orchestrate entire workflows                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    ORCHESTRATOR LAYER                           │
│  hyper-captain       impl-captain       review-captain          │
│                      verify-captain                           │
│  Persistent agents that coordinate specialist agents            │
│  Skills: hyper-craft + task-specific (hyper-planning, etc.)     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     SPECIALIST LAYER                            │
│  repo-analyst    best-practices    executor    reviewer         │
│  Single-purpose agents that perform specific tasks              │
│  Skills: hyper-craft + domain-specific (code-search, etc.)      │
└─────────────────────────────────────────────────────────────────┘
```

## Agent Hierarchy

### Command Layer

Commands are the entry points invoked by users:

| Command | Purpose | Orchestrator |
|---------|---------|--------------|
| `/hyper:plan` | Research → Spec → Tasks | hyper-captain |
| `/hyper:implement` | Task execution with verification | impl-captain |
| `/hyper:review` | Domain reviews and fix tasks | review-captain |
| `/hyper:verify` | Comprehensive verification loop | verify-captain |

Commands define the overall workflow structure and HITL gates.

### Orchestrator Layer

Orchestrators are persistent agents that:

- Coordinate specialist agents
- Maintain workflow state
- Present HITL gates for human approval
- Synthesize outputs from specialists

**Key characteristics:**
- Use `persist: true` for conversation continuity
- Load core skill (`hyper-craft`) plus task-specific skill
- Model: typically `opus` for complex reasoning

```prose
agent hyper-captain:
  model: opus
  persist: true
  skills:
    - hyper-craft              # Core knowledge (always)
    - hyper-planning           # Task-specific guidance
```

### Specialist Layer

Specialists are single-purpose agents that:

- Perform specific, focused tasks
- Return structured output using output contracts
- Are spawned by orchestrators as needed

**Key characteristics:**
- Non-persistent (stateless)
- Load core skill plus domain-specific skills
- Model: typically `sonnet` for efficiency

```prose
agent repo-analyst:
  model: sonnet
  skills:
    - hyper-craft              # Core knowledge
    - code-search              # Domain-specific capability
```

## Skill Types

### Core Skills

Always loaded by all hypercraft agents. Provides foundational knowledge.

**Example:** `hyper-craft`

- Directory structure conventions
- CLI usage patterns
- Output contract format
- Project/task lifecycle

### Task Skills

Loaded for specific workflow phases. Provides phase-specific guidance.

| Skill | Used By | Purpose |
|-------|---------|---------|
| `hyper-planning` | hyper-captain | HITL gates, research coordination, spec writing |
| `hyper-implementation` | impl-captain | Verification gates, code review, testing |
| `hyper-verification` | verify-captain | Automated checks, browser testing, QA |

### User Skills (Configurable)

Selected by users via Settings UI. Allows customization of agent capabilities.

| Slot | Default | Options |
|------|---------|---------|
| `doc-lookup` | context7 | context7, web-search, none |
| `code-search` | grep-enhanced | grep-enhanced, ast-parser, none |
| `browser-testing` | tauri-testing | tauri-testing, playwright, none |
| `error-tracking` | none | sentry-cli, datadog, none |

## Skill Resolution

When an agent declares skills, they are resolved in priority order:

```
1. Workspace settings    $HYPER_WORKSPACE_ROOT/settings/skills/{slot}.yaml
2. Template defaults     templates/hyper/settings/skills/{slot}.yaml
3. Built-in defaults     Core skills from plugin
```

### Resolution Flow

```
Agent declares: skills: [hyper-craft, doc-lookup]
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ Step 1: Load hyper-craft (core skill, always available)         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ Step 2: Resolve doc-lookup slot                                 │
│         → Check workspace settings/skills/doc-lookup.yaml       │
│         → If found, use selected value (e.g., "web-search")     │
│         → If not, use template default (e.g., "context7")       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ Step 3: Load resolved skills                                    │
│         → hyper-craft skill loaded                              │
│         → context7 (or web-search) skill loaded                 │
└─────────────────────────────────────────────────────────────────┘
```

## Output Contracts

Specialists communicate with orchestrators using structured output:

```json
{
  "status": "complete",
  "findings": {
    "summary": "Brief summary of results",
    "details": "..."
  },
  "artifacts": {
    "file1.md": "$HYPER_WORKSPACE_ROOT/projects/slug/resources/file1.md"
  },
  "next_steps": [
    "Suggested action 1",
    "Suggested action 2"
  ]
}
```

### Status Values

| Status | Meaning |
|--------|---------|
| `complete` | Task finished successfully |
| `partial` | Task partially complete, needs more work |
| `blocked` | Cannot proceed without intervention |
| `error` | Task failed with error |

## Compound Engineering

The architecture includes automatic learning capture through compound engineering.

### Trigger Detection

Triggers are detected during workflow execution:

| Trigger Type | Detection |
|--------------|-----------|
| Tool errors | Non-zero exit code, error in result |
| User corrections | Keywords: "actually", "you're right", "no, I meant" |
| Self-corrections | Keywords: "my bad", "I apologize", "let me correct" |
| Multiple retries | Same operation 3+ times |

### Learnings Capture

At workflow end, detected triggers are analyzed and documented:

```
projects/{slug}/resources/learnings.md
```

### Integration Points

1. **During Planning**: Query existing learnings before research
2. **During Implementation**: Surface relevant learnings when similar errors occur
3. **After Completion**: Capture new learnings if triggers detected

## Data Flow

### Planning Workflow

```
User → /hyper:plan "feature"
         │
         ▼
    hyper-captain
         │
    ┌────┴────┬────────┬────────┐
    │         │        │        │
    ▼         ▼        ▼        ▼
repo-     best-    framework-  git-
analyst   practices  docs     analyzer
    │         │        │        │
    └────┬────┴────────┴────────┘
         │
         ▼
    Research Summary (artifact)
         │
         ▼
    HITL Gate 2: Direction
         │
         ▼
    Specification (artifact)
         │
         ▼
    HITL Gate 3: Approval
         │
         ▼
    Task Creation (artifacts)
```

### Implementation Workflow

```
User → /hyper:implement task-id
         │
         ▼
    impl-captain
         │
         ├──→ Query prior learnings
         │
         ├──→ Analyze codebase
         │
         ▼
      executor
         │
         ▼
      reviewer
         │
         ▼
    Verification Gates
         │
         ▼
    Task Complete / Learnings Capture
```

## Configuration

### Workspace Settings

Settings are stored in `$HYPER_WORKSPACE_ROOT/settings/`:

```
settings/
├── skills/
│   ├── doc-lookup.yaml
│   ├── code-search.yaml
│   └── browser-testing.yaml
├── commands/
│   ├── hyper-plan.yaml
│   └── hyper-implement.yaml
└── agents/
    ├── research-orchestrator.yaml
    └── implementation-orchestrator.yaml
```

### Template System

Templates provide defaults that can be customized:

```
templates/hyper/settings/
├── skills/
│   ├── doc-lookup.yaml      # Default: context7
│   ├── code-search.yaml     # Default: grep-enhanced
│   └── browser-testing.yaml # Default: tauri-testing
└── ...
```

Users customize by copying templates to workspace settings and modifying.

## Extending the Architecture

### Adding a New Skill Slot

1. Create template: `templates/hyper/settings/skills/{slot}.yaml`
2. Create skill implementations: `skills/{implementation}/SKILL.md`
3. Update agent definitions to use the slot
4. Add to Settings UI (useSkillSettings hook)

### Adding a New Agent

1. Define agent in prose file with skills
2. Choose appropriate model (opus/sonnet/haiku)
3. Ensure output contract compliance
4. Add to orchestrator workflow

### Adding a New Workflow

1. Create command file: `commands/{workflow}.prose`
2. Define orchestrator agent
3. Define specialist agents
4. Implement HITL gates
5. Add compound engineering phase
