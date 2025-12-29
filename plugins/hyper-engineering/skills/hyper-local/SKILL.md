---
name: hyper-local
description: This skill provides expert guidance for spec-driven development using local .hyper/ directory structure. Use when orchestrating research, planning, and implementation workflows with local files as the source of truth. Compatible with Hyper Control UI.
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
Expert guidance for spec-driven development with local file-based project management. Uses the .hyper/ directory structure compatible with Hyper Control UI. Orchestrates research, planning, and implementation workflows using specialized sub-agents with local files as the single source of truth.
</description>

<intake>
What would you like to do?

1. **Plan a new feature** - Research codebase, create spec, get approval, then break down into tasks
2. **Implement a task** - Execute a task with verification loop
3. **Review code** - Run comprehensive review with domain sub-agents
4. **Verify implementation** - Run automated and manual verification checks
5. **View project status** - See current status of all projects and tasks
6. **Learn about the workflow** - Understand the hyper-engineering process

Please select an option or describe what you need.
</intake>

<routing>
| User Intent | Action |
|-------------|--------|
| Plan, new feature, spec, PRD | Invoke `/hyper-plan` command |
| Implement, work on, build, code | Invoke `/hyper-implement` command |
| Review, check, audit | Invoke `/hyper-review` command |
| Verify, test, check | Invoke `/hyper-verify` command |
| Status, progress, list | Invoke `/hyper-status` command |
| Initialize, setup, init | Invoke `/hyper-init` command |
| Learn, understand, help | Read [workflow-guide.md](./references/workflow-guide.md) |
</routing>

<context>
<hyper_directory_reference>
The .hyper/ directory is the local file-based alternative to Linear CLI.

**Full documentation:**
- [directory-structure.md](./references/directory-structure.md) - Complete directory layout
- [frontmatter-schema.md](./references/frontmatter-schema.md) - MDX frontmatter reference
- [template-guide.md](./references/template-guide.md) - Template customization

## Directory Structure

```
.hyper/
├── workspace.json           # Workspace metadata
├── initiatives/             # High-level strategic groupings
│   └── *.mdx
├── projects/                # Project containers
│   └── {project-slug}/
│       ├── _project.mdx     # Project definition
│       ├── tasks/           # Task files
│       │   └── task-*.mdx
│       └── resources/       # Supporting documents
│           ├── specification.md
│           └── research/
│               └── *.md
└── docs/                    # Standalone documentation
    └── *.mdx
```

## Core Principles

1. **Files are the API** - No external service needed
2. **MDX with frontmatter** - Structured metadata + markdown content
3. **Hyper Control compatible** - UI watches for file changes in real-time
4. **Template system** - Customizable per-workspace
5. **Version controllable** - Everything in git

## Quick Reference

```bash
# Initialize workspace
mkdir -p .hyper/{initiatives,projects,docs}
echo '{"workspacePath": "'$(pwd)'", "name": "My Project", "created": "'$(date +%Y-%m-%d)'"}' > .hyper/workspace.json

# Create project
PROJECT_SLUG="auth-system"
mkdir -p ".hyper/projects/${PROJECT_SLUG}/{tasks,resources,resources/research}"
# Write _project.mdx using template

# Create task
TASK_NUM="001"
# Write task file: .hyper/projects/${PROJECT_SLUG}/tasks/task-${TASK_NUM}.mdx

# Update status (edit frontmatter)
# Change: status: todo → status: in-progress
# Update: updated: YYYY-MM-DD
```

## Status Values

**Task Statuses:**
- `draft` - Work in progress, not ready
- `todo` - Ready to be worked on
- `in-progress` - Active work
- `review` - Awaiting review/verification
- `complete` - Done
- `blocked` - Blocked by dependencies

**Project Statuses:**
- `planned` - In backlog, not yet started
- `todo` - Scheduled for work
- `in-progress` - Active development
- `completed` - Successfully finished
- `canceled` - Won't do
</hyper_directory_reference>

<workflow_stages>
## Hyper-Engineering Workflow (Local Mode)

### 1. Research Phase
- Agent asks clarifying questions (5-7 questions)
- Parallel sub-agents explore codebase
- Creates .hyper project directory with research documents
- Project status: **planned**

### 2. Planning Phase
- Agent reads research, asks scope questions
- Creates detailed spec in resources/specification.md
- Includes mermaid diagrams and ASCII layouts
- Includes verification requirements
- Project status: **review** (awaits human approval)

### 3. Task Breakdown (After Approval)
- Agent creates task files in tasks/ directory
- Sets up dependencies via frontmatter
- Each task includes verification requirements
- Project status: **todo**

### 4. Implementation Phase
- Agent reads task spec from task file
- Implements following codebase patterns
- Runs verification loop
- Task status: **in-progress** → **review** → **complete**

### 5. Review Phase (Optional)
- Review orchestrator spawns domain sub-agents
- Security, architecture, performance, code quality
- Creates fix tasks as new task files
</workflow_stages>

<file_operations>
## Common File Operations

### Creating a Project

```bash
PROJECT_SLUG="auth-system"
mkdir -p ".hyper/projects/${PROJECT_SLUG}/{tasks,resources,resources/research}"

cat > ".hyper/projects/${PROJECT_SLUG}/_project.mdx" << 'EOF'
---
id: proj-auth-system
title: User Authentication System
type: project
status: planned
priority: high
summary: Implement OAuth-based authentication with Google and GitHub providers
created: 2025-12-28
updated: 2025-12-28
tags:
  - auth
  - oauth
  - security
---

# User Authentication System

[Project description here]
EOF
```

### Creating a Task

```bash
PROJECT_SLUG="auth-system"
TASK_NUM="001"

cat > ".hyper/projects/${PROJECT_SLUG}/tasks/task-${TASK_NUM}.mdx" << 'EOF'
---
id: task-auth-system-001
title: "Phase 1: OAuth Provider Setup"
type: task
status: todo
priority: high
parent: proj-auth-system
created: 2025-12-28
updated: 2025-12-28
tags:
  - oauth
  - setup
---

# Phase 1: OAuth Provider Setup

[Task description here]
EOF
```

### Updating Status

```bash
# Using Edit tool to update frontmatter
# Change: status: todo → status: in-progress
# Update: updated: [today's date]
```

### Reading Task Details

```bash
# Get full task content
cat ".hyper/projects/${PROJECT_SLUG}/tasks/task-001.mdx"

# List all tasks with status
for f in .hyper/projects/${PROJECT_SLUG}/tasks/task-*.mdx; do
  echo "$(basename $f)"
  grep "^status:" "$f"
done
```
</file_operations>

<template_system>
## Template Loading Priority

Templates are loaded in this order:
1. Workspace templates: `.hyper/templates/*.template`
2. Plugin templates: `templates/hyper/*.template`

## Available Templates

- `project.mdx.template` - Project definition
- `task.mdx.template` - Implementation task
- `initiative.mdx.template` - Strategic grouping
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
1. Runs `/hyper-plan "Add user authentication with OAuth"`
2. Checks if .hyper/ exists, creates if not
3. Asks clarifying questions:
   - Which OAuth providers? (Google, GitHub, etc.)
   - Session storage approach? (JWT, cookies)
   - Protected routes scope?
4. Launches research sub-agents
5. Creates project directory with:
   - `_project.mdx` (status: planned)
   - `resources/specification.md` (detailed spec)
   - `resources/research/*.md` (research findings)
6. Updates project status to "review"
7. Waits for human approval
8. Creates task files after approval (status: todo)
</example>

<example name="implementing_task">
User: Implement auth-system/task-001

Agent:
1. Runs `/hyper-implement auth-system/task-001`
2. Reads task file from `.hyper/projects/auth-system/tasks/task-001.mdx`
3. Reads project spec from resources/specification.md
4. Updates task status: `todo` → `in-progress`
5. Implements code following patterns
6. Runs verification:
   - `pnpm lint` ✓
   - `pnpm typecheck` ✓
   - `pnpm test` ✓
   - `pnpm build` ✓
7. Manual verification (Playwright if available)
8. Updates task status: `in-progress` → `complete`
</example>
</examples>

<integration_with_hyper_control>
## Hyper Control Integration

When Hyper Control (Tauri desktop app) is running:

1. **Automatic sync** - File watcher monitors `.hyper/` for changes
2. **Real-time updates** - All file operations immediately reflected in UI
3. **No API needed** - Filesystem IS the API
4. **Search & filter** - Browse projects, tasks, and docs visually
5. **Session browser** - View Claude Code session history

## Works Standalone

The .hyper/ workflow works completely without Hyper Control:

- All planning artifacts are local files
- Git tracks all changes
- Works offline
- Any text editor can view/edit files
</integration_with_hyper_control>

</skill>
