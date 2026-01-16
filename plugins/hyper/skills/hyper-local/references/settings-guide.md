# Settings & Customization Guide

The `$HYPER_WORKSPACE_ROOT/settings/` directory allows customization of workflows, agents, and commands without modifying plugin files. All settings use YAML format for easy editing.

## Directory Structure

```
$HYPER_WORKSPACE_ROOT/settings/
├── workflows.yaml           # Project/task workflow stages & quality gates
├── agents/                  # Agent customization
│   ├── README.md            # Documentation
│   ├── research-orchestrator.yaml
│   ├── implementation-orchestrator.yaml
│   ├── repo-research-analyst.yaml
│   ├── best-practices-researcher.yaml
│   ├── framework-docs-researcher.yaml
│   ├── git-history-analyzer.yaml
│   └── web-app-debugger.yaml
└── commands/                # Command customization
    ├── README.md            # Documentation
    ├── hyper-plan.yaml
    ├── hyper-implement.yaml
    ├── hyper-review.yaml
    ├── hyper-verify.yaml
    └── hyper-init-stack.yaml
```

## Workflows Configuration

**File:** `$HYPER_WORKSPACE_ROOT/settings/workflows.yaml`

This file defines the workflow stages for projects and tasks.

### Project Workflow

Projects move through these stages:

| Stage | Description | Gate |
|-------|-------------|------|
| `planned` | Initial state, research in progress | - |
| `review` | Specification complete, awaiting approval | ✓ Human approval required |
| `todo` | Spec approved, ready for implementation | - |
| `in-progress` | Active implementation | - |
| `blocked` | Blocked by external dependency | - |
| `verification` | Running verification checks | - |
| `complete` | All tasks done, verification passed | Terminal |
| `cancelled` | Project cancelled | Terminal |

### Task Workflow

Tasks within a project follow this workflow:

| Stage | Description | Actions |
|-------|-------------|---------|
| `todo` | Not yet started | - |
| `in-progress` | Actively being implemented | Sets `started` date |
| `blocked` | Blocked by dependency | - |
| `review` | Awaiting verification | - |
| `complete` | Task finished | Sets `completed` date |
| `cancelled` | Task cancelled | Terminal |

### Quality Gates

Configure automated and manual verification checks:

```yaml
quality_gates:
  task_completion:
    automated:
      - id: lint
        name: "Lint Check"
        command: "npm run lint"
        required: true
      - id: typecheck
        name: "Type Check"
        command: "npm run typecheck"
        required: true
      - id: test
        name: "Unit Tests"
        command: "npm run test"
        required: true
      - id: build
        name: "Build"
        command: "npm run build"
        required: true
      - id: e2e
        name: "E2E Tests"
        command: "npm run e2e"
        required: false  # Optional

    manual:
      - id: browser
        name: "Browser Testing"
        required_if: "ui_changes"
      - id: security
        name: "Security Review"
        required_if: "security_sensitive"
```

### Tags Configuration

Define tags for categorizing projects and tasks:

```yaml
tags:
  priority:
    - id: urgent
      name: "Urgent"
      color: "#EF4444"
    - id: high
      name: "High"
      color: "#F97316"
    - id: medium
      name: "Medium"
      color: "#F59E0B"
    - id: low
      name: "Low"
      color: "#6B7280"

  type:
    - id: feature
      name: "Feature"
      color: "#3B82F6"
    - id: bugfix
      name: "Bug Fix"
      color: "#EF4444"
    - id: refactor
      name: "Refactor"
      color: "#8B5CF6"
```

---

## Agent Customization

**Directory:** `$HYPER_WORKSPACE_ROOT/settings/agents/`

Customize agent behavior without modifying plugin files.

### Available Agents

| Agent | Purpose |
|-------|---------|
| `research-orchestrator` | Coordinates research sub-agents in parallel |
| `implementation-orchestrator` | Coordinates engineering sub-agents and verification |
| `repo-research-analyst` | Analyzes repository structure and conventions |
| `best-practices-researcher` | Gathers external best practices |
| `framework-docs-researcher` | Researches framework documentation |
| `git-history-analyzer` | Analyzes git history and code evolution |
| `web-app-debugger` | Debugs web apps using Chrome extension |

### Customization Options

#### `context_additions`

Add project-specific context that the agent should know:

```yaml
context_additions: |
  - This is a monorepo with packages/ directory
  - We use Tailwind CSS for all styling
  - Legacy code in src/legacy/ should not be recommended
```

#### `instructions_prepend`

Instructions added BEFORE the default agent instructions:

```yaml
instructions_prepend: |
  IMPORTANT: Always check for existing implementations first.
  Security is a top priority for this project.
```

#### `instructions_append`

Instructions added AFTER the default agent instructions:

```yaml
instructions_append: |
  After completing analysis:
  1. Check for related TODOs in the codebase
  2. Note any technical debt discovered
```

#### `output_format`

Override the default output format:

```yaml
output_format: |
  Return findings as a bullet list with severity ratings.
  Include file:line references for all code mentions.
```

#### `skip_sub_agents` (Orchestrators only)

Skip specific sub-agents:

```yaml
skip_sub_agents:
  - git-history-analyzer  # Git history is messy
```

#### `disabled`

Temporarily disable an agent:

```yaml
disabled: true
reason: "Using custom research process during migration"
```

### Example: Customizing Research Orchestrator

```yaml
# $HYPER_WORKSPACE_ROOT/settings/agents/research-orchestrator.yaml

context_additions: |
  - Ruby on Rails monolith with RSpec tests
  - Legacy code in app/legacy/ - analyze but don't recommend

instructions_append: |
  After research:
  1. Check for related TODOs in codebase
  2. Check for related GitHub issues

skip_sub_agents:
  - git-history-analyzer  # Messy history from migration
```

---

## Command Customization

**Directory:** `$HYPER_WORKSPACE_ROOT/settings/commands/`

Customize command workflow and phases.

### Available Commands

| Command | Purpose |
|---------|---------|
| `hyper-plan` | Planning workflow (research → spec → tasks) |
| `hyper-implement` | Implementation workflow with verification |
| `hyper-review` | Code review with domain reviewers |
| `hyper-verify` | Verification workflow (automated + manual) |
| `hyper-init-stack` | Stack-specific initialization |

### Customization Options

#### `context_additions`

Project-specific context for the command:

```yaml
context_additions: |
  - All changes require at least one reviewer
  - We deploy to production every Thursday
```

#### `phase_overrides`

Override specific phases of the workflow:

```yaml
phase_overrides:
  initial_interview:
    instructions_append: |
      Always ask about bounded context ownership.

  spec_creation:
    instructions_prepend: |
      REQUIRED: Include rollback plan in every spec.
```

#### `skip_phases`

Skip phases that aren't relevant:

```yaml
skip_phases:
  - browser_verification  # Backend-only project
  - structure_checkpoint  # Streamlined process
```

#### `quality_gates`

Override verification checks for this command:

```yaml
quality_gates:
  lint:
    command: "pnpm lint"
    required: true
  custom_check:
    name: "Security Scan"
    command: "npm run security:scan"
    required: true
```

### Example: Customizing hyper-plan

```yaml
# $HYPER_WORKSPACE_ROOT/settings/commands/hyper-plan.yaml

context_additions: |
  - This project follows Domain-Driven Design
  - All features require product manager approval

phase_overrides:
  initial_interview:
    instructions_append: |
      Always ask about:
      1. Which bounded context does this belong to?
      2. What events will this feature emit?

  spec_creation:
    instructions_prepend: |
      REQUIRED in every spec:
      - Bounded context classification
      - Event definitions (name, payload)
      - Feature flag configuration

interview:
  max_initial_questions: 10
  required_topics:
    - "user impact"
    - "success criteria"
```

### Example: Customizing hyper-implement

```yaml
# $HYPER_WORKSPACE_ROOT/settings/commands/hyper-implement.yaml

context_additions: |
  - Use conventional commit messages
  - Create draft PR early for visibility

quality_gates:
  test:
    command: "npm run test:coverage"
    required: true
    threshold:
      coverage: 80

  bundle_size:
    name: "Bundle Size Check"
    command: "npm run analyze"
    required: false

git:
  branch_pattern: "feat/{{PROJECT_SLUG}}/{{TASK_ID}}"
  commit_format: "conventional"
  auto_create_pr: false
```

---

## Loading Priority

Settings are merged with plugin defaults:

1. **Workspace settings** (`$HYPER_WORKSPACE_ROOT/settings/*.yaml`) - Highest priority
2. **Plugin defaults** - Fallback for unspecified options

Only specified options are overridden; everything else uses defaults.

---

## Best Practices

### Getting Started

1. **Start minimal** - Only add customizations you actually need
2. **Test changes** - Run a command after customizing to verify behavior
3. **Iterate** - Add customizations as you discover needs

### Team Collaboration

1. **Version control** - Commit `$HYPER_WORKSPACE_ROOT/settings/` to share with team
2. **Document reasons** - Use comments to explain why customizations exist
3. **Review together** - Discuss settings changes in code review

### Maintenance

1. **Reset to defaults** - Delete a file to reset that component
2. **Regular review** - Periodically review if customizations are still needed
3. **Keep up to date** - Update settings when plugin adds new options

---

## Troubleshooting

### Settings Not Applied

1. Check YAML syntax is valid
2. Ensure file is in correct location
3. Restart Claude Code session after changes

### Agent/Command Disabled

Check for `disabled: true` in the YAML file.

### Phases Not Running

Check `skip_phases` array for the phase name.

### Quality Gates Failing

Verify command paths are correct for your project:

```bash
# Test commands manually
npm run lint
npm run typecheck
```
