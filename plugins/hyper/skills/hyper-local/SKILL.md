---
name: hyper-local
description: This skill provides expert guidance for spec-driven development using local $HYPER_WORKSPACE_ROOT/ directory structure. Use when orchestrating research, planning, and implementation workflows with local files as the source of truth. Compatible with Hypercraft UI.
model: sonnet
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Task
  - WebFetch
---

<skill name="hyper-local">

<description>
Expert guidance for spec-driven development with local file-based project management. Uses the $HYPER_WORKSPACE_ROOT/ directory structure compatible with Hypercraft UI. Orchestrates research, planning, and implementation workflows using specialized sub-agents with local files as the single source of truth. Core workflow context lives in `hyper-craft`.
</description>

<intake>
What would you like to do?

1. **Plan a new feature** - Research codebase, create spec, get approval, then break down into tasks
2. **Implement a task** - Execute a task with verification loop
3. **Review code** - Run comprehensive review with domain sub-agents
4. **Verify implementation** - Run automated and manual verification checks
5. **View project status** - See current status of all projects and tasks
6. **Customize settings** - Modify workflows, agents, or commands
7. **Learn about the workflow** - Understand the hyper-engineering process

Please select an option or describe what you need.
</intake>

<routing>
| User Intent | Action |
|-------------|--------|
| Plan, new feature, spec, PRD | Invoke `/hyper:plan` command |
| Implement, work on, build, code | Invoke `/hyper:implement` command |
| Review, check, audit | Invoke `/hyper:review` command |
| Verify, test, check | Invoke `/hyper:verify` command |
| Status, progress, list | Invoke `/hyper:status` command |
| Initialize, setup, init | Invoke `/hyper:init` command |
| Customize, settings, workflows, agents, commands | Read [settings-guide.md](./references/settings-guide.md) or explain <settings_system> |
| Learn, understand, help | Read [workflow-guide.md](./references/workflow-guide.md) |
</routing>

<context>
<hyper_directory_reference>
The $HYPER_WORKSPACE_ROOT/ directory is the local file-based alternative to Linear CLI.

**Full documentation:**
- [directory-structure.md](./references/directory-structure.md) - Complete directory layout
- [frontmatter-schema.md](./references/frontmatter-schema.md) - MDX frontmatter reference
- [template-guide.md](./references/template-guide.md) - Template customization
- [settings-guide.md](./references/settings-guide.md) - Settings customization

## Directory Structure

```
$HYPER_WORKSPACE_ROOT/
├── workspace.json           # Workspace metadata
├── projects/                # Project containers
│   └── {project-slug}/
│       ├── _project.mdx     # Project definition + spec (inline)
│       ├── tasks/           # Task files
│       │   └── task-*.mdx
│       └── resources/       # Supporting documents
│           └── research/
│               └── *.md
├── docs/                    # Standalone documentation
│   └── *.mdx
└── settings/                # Customization (NEW)
    ├── workflows.yaml       # Project/task workflow stages
    ├── agents/              # Agent customization
    │   ├── README.md
    │   └── *.yaml           # Per-agent overrides
    └── commands/            # Command customization
        ├── README.md
        └── *.yaml           # Per-command overrides
```

## Core Principles

1. **Files are the API** - No external service needed
2. **MDX with frontmatter** - Structured metadata + markdown content
3. **Hypercraft compatible** - UI watches for file changes in real-time
4. **Template system** - Customizable per-workspace
5. **Version controllable** - Everything in git
6. **Activity tracking** - Session history recorded in frontmatter

## Quick Reference

**IMPORTANT**: Always use the Hypercraft CLI for workspace operations. The CLI handles validation, activity tracking, and maintains data integrity.

```bash
# Initialize workspace
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft init --name "My Project"

# Create project
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft project create \
  --slug "auth-system" \
  --title "User Authentication System" \
  --priority "high" \
  --summary "OAuth-based authentication with Google and GitHub providers" \
  --json

# Create task (ID is auto-generated)
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft task create \
  --project "auth-system" \
  --title "Phase 1: OAuth Provider Setup" \
  --priority "high" \
  --json

# Update task status (ID is positional arg)
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft task update as-001 --status "in-progress"

# Update project status
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft project update auth-system --status "in-progress"

# List projects
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft project list --json

# List tasks for a project
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft task list --project auth-system --json

# Search across all resources
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft search "OAuth" --json
```

## Activity Tracking

Activity is automatically tracked via PostToolUse hook when agents write to `$HYPER_WORKSPACE_ROOT/` files.
Session IDs are captured and logged in the `activity` array in frontmatter.

**Automatic (agent sessions)**:
- PostToolUse hook detects Write/Edit to `$HYPER_WORKSPACE_ROOT/*.mdx`
- Hook script calls CLI to append activity entry
- Session ID and parent session tracked

**Manual (user actions via UI/CLI)**:
```bash
# Add a comment
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft activity comment \
  --file "$HYPER_WORKSPACE_ROOT/projects/auth-system/tasks/task-001.mdx" \
  --actor-type user \
  --actor-id "user-uuid" \
  --actor-name "Juan Bermudez" \
  "This looks ready for review"
```

See [frontmatter-schema.md](./references/frontmatter-schema.md) for full activity format.

## Status Values

**Task Statuses:**
- `draft` - Work in progress, not ready
- `todo` - Ready to be worked on
- `in-progress` - Active work
- `qa` - Quality assurance & verification phase
- `complete` - Done, all checks passed
- `blocked` - Blocked by dependencies

**Project Statuses:**
- `planned` - In backlog, not yet started
- `todo` - Scheduled for work
- `in-progress` - Active development
- `qa` - All tasks done, project-level QA
- `completed` - Successfully finished
- `canceled` - Won't do

**QA Status Explained:**
The `qa` status is where quality checks and verification happen:
- **Tasks**: Run automated checks (lint, typecheck, test, build) + manual verification
- **Projects**: Integration testing, final review, documentation check
- If checks fail → back to `in-progress` to fix
- Only move to `complete`/`completed` when ALL checks pass
</hyper_directory_reference>

<workflow_stages>
## Hyper-Engineering Workflow (Local Mode)

### 1. Research Phase
- Agent asks clarifying questions (5-7 questions)
- Parallel sub-agents explore codebase
- Creates $HYPER_WORKSPACE_ROOT project directory with research documents
- Project status: **planned**

### 2. Planning Phase
- Agent reads research, asks scope questions
- Creates detailed spec inline in _project.mdx
- Includes mermaid diagrams and ASCII layouts
- Includes verification requirements
- Project status: **planned** (awaits human approval)

### 3. Task Breakdown (After Approval)
- Agent creates task files in tasks/ directory
- Sets up dependencies via frontmatter
- Each task includes verification requirements
- Project status: **todo**

### 4. Implementation Phase
- Agent reads task spec from task file
- Implements following codebase patterns
- Task status: **in-progress**

### 5. QA Phase (Quality Assurance)
- Run automated checks: lint, typecheck, test, build
- Run manual verification: browser testing, code review
- Task status: **qa**
- If checks fail → back to **in-progress** to fix
- If all pass → **complete**

### 6. Project QA (After All Tasks Complete)
- All tasks must be **complete**
- Project-level integration testing
- Final review, documentation check
- Project status: **qa** → **completed**

### 7. Review Phase (Optional)
- Review orchestrator spawns domain sub-agents
- Security, architecture, performance, code quality
- Creates fix tasks as new task files if issues found
</workflow_stages>

<file_operations>
## Common File Operations

**CLI-First Approach**: Always prefer CLI commands over direct Write/Edit tools for workspace operations. The CLI provides validation, consistent formatting, and automatic activity tracking.

### Creating a Project (CLI)

```bash
# Create project with validated frontmatter (returns JSON with created file info)
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft project create \
  --slug "auth-system" \
  --title "User Authentication System" \
  --priority "high" \
  --summary "Implement OAuth-based authentication with Google and GitHub" \
  --json

# For spec content, use file API to add body while preserving frontmatter
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft file write \
  projects/auth-system/_project.mdx \
  --body "# User Authentication System\n\n## Overview\n..." \
  --json
```

### Creating a Task (CLI)

```bash
# Create task with auto-generated ID
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft task create \
  --project "auth-system" \
  --title "Phase 1: OAuth Provider Setup" \
  --priority "high" \
  --json

# Add task content via file API
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft file write \
  projects/auth-system/tasks/task-001.mdx \
  --body "# Phase 1: OAuth Provider Setup\n\n## Objectives\n..." \
  --json
```

### Updating Status (CLI)

```bash
# Update task status (ID is positional argument)
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft task update as-001 --status "in-progress"

# Update project status (slug is positional argument)
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft project update auth-system --status "in-progress"
```

### Reading Data (CLI)

```bash
# Get project details
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft project get auth-system --json

# Get task details
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft task get as-001 --json

# List all tasks for a project
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft task list --project auth-system --json

# Read file with frontmatter parsed
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft file read projects/auth-system/_project.mdx --json

# Read only frontmatter
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft file read projects/auth-system/_project.mdx --frontmatter-only --json
```

### Searching (CLI)

```bash
# Search across all resources
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft search "OAuth" --json

# Search with filters
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft search "authentication" --resource-type project --status in-progress --json

# File-level search
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft file search "OAuth" --json
```

### Activity Tracking

Activity is automatically tracked via PostToolUse hook when agents write to `$HYPER_WORKSPACE_ROOT/*.mdx` files.

```bash
# Manual activity entry (for programmatic updates)
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft activity add \
  --file "projects/auth-system/tasks/task-001.mdx" \
  --actor-type session \
  --actor-id "$SESSION_ID" \
  --action modified \
  --json

# Add a comment (convenience wrapper)
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft activity comment \
  --file "projects/auth-system/tasks/task-001.mdx" \
  --actor-type user \
  --actor-id "user-uuid" \
  --actor-name "Juan Bermudez" \
  "This is ready for review"
```
</file_operations>

<template_system>
## Template Loading Priority

Templates are loaded in this order:
1. Workspace templates: `$HYPER_WORKSPACE_ROOT/templates/*.template`
2. Plugin templates: `templates/hyper/*.template`

## Available Templates

- `project.mdx.template` - Project definition
- `task.mdx.template` - Implementation task
- `resource.mdx.template` - Supporting documentation
- `doc.mdx.template` - Standalone documentation
- `workspace.json.template` - Workspace metadata

## Template Variables

Use `{{VARIABLE_NAME}}` for substitution:

| Variable | Description |
|----------|-------------|
| `{{SLUG}}` | URL-safe identifier |
| `{{TITLE}}` | Human-readable title |
| `{{DATE}}` | Current date (YYYY-MM-DD) |
| `{{PRIORITY}}` | Priority level |
| `{{STATUS}}` | Initial status |
| `{{PROJECT_SLUG}}` | Parent project identifier |
| `{{NUM}}` | Task number (zero-padded) |
</template_system>

<settings_system>
## Settings & Customization

The `$HYPER_WORKSPACE_ROOT/settings/` directory allows customization of workflows, agents, and commands without modifying plugin files.

### Workflows Configuration

**File:** `$HYPER_WORKSPACE_ROOT/settings/workflows.yaml`

Defines project and task workflow stages:

```yaml
project_workflow:
  stages:
    - id: planned
      name: "Planned"
      allowed_transitions: [review, cancelled]
    - id: review
      name: "Spec Review"
      gate: true  # Requires approval
      allowed_transitions: [todo, planned, cancelled]
    - id: todo
      name: "Ready"
      allowed_transitions: [in-progress, cancelled]
    - id: in-progress
      name: "In Progress"
      allowed_transitions: [verification, blocked, todo]
    - id: verification
      name: "Verification"
      allowed_transitions: [complete, in-progress]
    - id: complete
      name: "Complete"
      terminal: true

task_workflow:
  stages:
    - id: todo
      name: "To Do"
      allowed_transitions: [in-progress, blocked]
    - id: in-progress
      name: "In Progress"
      on_enter:
        - action: update_frontmatter
          field: started
          value: "{{DATE}}"
      allowed_transitions: [review, blocked, todo]
    - id: review
      name: "In Review"
      allowed_transitions: [complete, in-progress]
    - id: complete
      name: "Complete"
      terminal: true
      on_enter:
        - action: update_frontmatter
          field: completed
          value: "{{DATE}}"

quality_gates:
  task_completion:
    automated:
      - id: lint
        command: "{{LINT_COMMAND}}"
        required: true
      - id: typecheck
        command: "{{TYPECHECK_COMMAND}}"
        required: true
      - id: test
        command: "{{TEST_COMMAND}}"
        required: true
      - id: build
        command: "{{BUILD_COMMAND}}"
        required: true
```

### Agent Customization

**Directory:** `$HYPER_WORKSPACE_ROOT/settings/agents/`

Each agent can be customized via YAML file:

```yaml
# $HYPER_WORKSPACE_ROOT/settings/agents/research-orchestrator.yaml

context_additions: |
  - This is a monorepo with packages/ directory
  - Legacy code in src/legacy/ should not be recommended

instructions_prepend: |
  IMPORTANT: Always prioritize security considerations.

instructions_append: |
  After research, also check for related TODOs in codebase.

skip_sub_agents:
  - git-history-analyzer  # Skip if git history is messy
```

**Available agents:**
- `research-orchestrator.yaml`
- `implementation-orchestrator.yaml`
- `repo-research-analyst.yaml`
- `best-practices-researcher.yaml`
- `framework-docs-researcher.yaml`
- `git-history-analyzer.yaml`
- `web-app-debugger.yaml`

**Customization options:**
| Option | Description |
|--------|-------------|
| `context_additions` | Project-specific context for the agent |
| `instructions_prepend` | Instructions added BEFORE default |
| `instructions_append` | Instructions added AFTER default |
| `output_format` | Override default output format |
| `skip_sub_agents` | Skip specific sub-agents (orchestrators only) |
| `disabled` | Temporarily disable an agent |

### Command Customization

**Directory:** `$HYPER_WORKSPACE_ROOT/settings/commands/`

Each command can be customized via YAML file:

```yaml
# $HYPER_WORKSPACE_ROOT/settings/commands/hyper-plan.yaml

context_additions: |
  - This project follows Domain-Driven Design
  - All features require product manager approval

phase_overrides:
  initial_interview:
    instructions_append: |
      Always ask about bounded context ownership.

  spec_creation:
    instructions_prepend: |
      REQUIRED: Include event definitions for event sourcing.

skip_phases:
  - structure_checkpoint  # Skip if process is streamlined

interview:
  max_initial_questions: 10
  required_topics:
    - "user impact"
    - "success criteria"
```

**Available commands:**
- `hyper-plan.yaml`
- `hyper-implement.yaml`
- `hyper-review.yaml`
- `hyper-verify.yaml`
- `hyper-init-stack.yaml`

**Customization options:**
| Option | Description |
|--------|-------------|
| `context_additions` | Project-specific context |
| `phase_overrides` | Override specific phases |
| `skip_phases` | Skip certain phases |
| `quality_gates` | Override verification checks |
| `git` | Git workflow settings |

### Loading Priority

1. **Workspace settings**: `$HYPER_WORKSPACE_ROOT/settings/*.yaml` (highest priority)
2. **Plugin defaults**: Built-in defaults (fallback)

Only specified options are overridden; defaults are preserved for everything else.

### Best Practices

1. **Start minimal** - Only add customizations you need
2. **Test changes** - Run a command after customizing
3. **Version control** - Commit `$HYPER_WORKSPACE_ROOT/settings/` to share with team
4. **Reset to defaults** - Delete a file to reset that component
</settings_system>
</context>

<verification_requirements>
## Verification Checklist Template

### Automated Checks
- [ ] `pnpm lint` or equivalent passes
- [ ] `pnpm typecheck` or equivalent passes
- [ ] `pnpm test` or equivalent passes
- [ ] `pnpm build` or equivalent succeeds

### Manual Verification
- [ ] Feature works on localhost
- [ ] Edge cases handled correctly
- [ ] No console errors in browser
- [ ] Responsive on mobile viewport

### Visual Verification (UI changes)
- [ ] Matches spec/mockup
- [ ] Consistent with design system
- [ ] Accessibility checked

## On Verification Failure
1. Document the failure in task progress section
2. Create fix sub-task as new task file
3. Implement fix
4. Re-run verification
5. Repeat until all checks pass
</verification_requirements>

<examples>
<example name="planning_new_feature">
User: I want to add user authentication with OAuth

Agent:
1. Runs `/hyper:plan "Add user authentication with OAuth"`
2. Checks if $HYPER_WORKSPACE_ROOT/ exists, creates if not
3. Asks clarifying questions:
   - Which OAuth providers? (Google, GitHub, etc.)
   - Session storage approach? (JWT, cookies)
   - Protected routes scope?
4. Launches research sub-agents
5. Creates project using CLI and writes:
   - `_project.mdx` (status: planned, with inline spec)
   - `resources/*.md` (research findings)
6. Updates project status to "review"
7. Waits for human approval
8. Creates task files via CLI after approval (status: todo)
</example>

<example name="implementing_task">
User: Implement auth-system/task-001

Agent:
1. Runs `/hyper:implement auth-system/task-001`
2. Reads task file from `$HYPER_WORKSPACE_ROOT/projects/auth-system/tasks/task-001.mdx`
3. Reads project spec from `_project.mdx` (inline)
4. Updates task status via CLI: `todo` → `in-progress`
5. Implements code following patterns
6. Runs verification:
   - `pnpm lint` ✓
   - `pnpm typecheck` ✓
   - `pnpm test` ✓
   - `pnpm build` ✓
7. Manual verification (web-app-debugger agent if UI changes)
8. Updates task status via CLI: `in-progress` → `complete`
9. Activity automatically logged by PostToolUse hook
</example>
</examples>

<integration_with_hyper_control>
## Hypercraft Integration

When Hypercraft (Tauri desktop app) is running:

1. **Automatic sync** - File watcher monitors `$HYPER_WORKSPACE_ROOT/` for changes
2. **Real-time updates** - All file operations immediately reflected in UI
3. **No API needed** - Filesystem IS the API
4. **Search & filter** - Browse projects, tasks, and docs visually
5. **Session browser** - View Claude Code session history

## Works Standalone

The $HYPER_WORKSPACE_ROOT/ workflow works completely without Hypercraft:

- All planning artifacts are local files
- Git tracks all changes
- Works offline
- Any text editor can view/edit files
</integration_with_hyper_control>

</skill>
