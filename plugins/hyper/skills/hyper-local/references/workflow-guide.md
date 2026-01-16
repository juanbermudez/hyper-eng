# Hyper-Engineering Workflow Guide (Local Mode)

The hyper-engineering workflow uses local `$HYPER_WORKSPACE_ROOT/` files as the source of truth, with optional Hyper Control UI for visual project management.

## Philosophy

**Specs matter more than code. Code is disposable; specifications are the source of truth.**

All planning artifacts are stored locally in `$HYPER_WORKSPACE_ROOT/`:
- Version controllable via git
- Works offline without external services
- Real-time sync with Hyper Control UI (when running)
- Human-readable markdown format

## Workflow Stages

```
planned → todo → in-progress → qa → complete/completed
```

| Stage | Project Status | Task Status | Description |
|-------|---------------|-------------|-------------|
| Research | `planned` | - | Agent explores codebase with sub-agents |
| Ready | `todo` | `todo` | Tasks created from approved spec |
| Implementation | `in-progress` | `in-progress` | Active development |
| QA | `qa` | `qa` | Automated + manual verification |
| Complete | `completed` | `complete` | All checks passed |

## Commands

| Command | Purpose |
|---------|---------|
| `/hyper-init` | Initialize $HYPER_WORKSPACE_ROOT/ directory structure |
| `/hyper-plan` | Research → create spec → approval → create tasks |
| `/hyper-implement` | Implement task with verification loop |
| `/hyper-verify` | Run comprehensive verification |
| `/hyper-review` | Run code review with sub-agents |
| `/hyper-status` | View project and task status |

## Detailed Workflow

### 1. Initialize Workspace

```bash
/hyper-init my-project
```

Creates:
```
$HYPER_WORKSPACE_ROOT/
├── workspace.json
├── initiatives/
├── projects/
└── docs/
```

### 2. Plan a Feature

```bash
/hyper-plan "Add user authentication with OAuth"
```

**Phase 1: Clarification**
- Agent asks 5-7 clarifying questions
- Scope, success criteria, constraints, etc.

**Phase 2: Research**
- Spawns 4 research agents in parallel:
  - repo-research-analyst
  - best-practices-researcher
  - framework-docs-researcher
  - git-history-analyzer
- Writes findings to `$HYPER_WORKSPACE_ROOT/projects/{slug}/resources/research/`

**Phase 3: Direction Check (Gate 1)**
- Presents brief summary for early validation
- Saves rework if direction is wrong

**Phase 4: Spec Creation**
- Creates detailed specification in `resources/specification.md`
- Includes mermaid diagrams, ASCII layouts
- Explicit "Out of Scope" section
- Verification requirements

**Phase 5: Spec Review (Gate 2)**
- Updates project status to `review`
- Waits for human approval
- **No tasks created until approved**

**Phase 6: Task Breakdown**
- Creates task files in `tasks/` directory
- Sets up dependencies via frontmatter
- Each task includes verification checklist

### 3. Implement a Task

```bash
/hyper-implement auth-system/task-001
```

**Initialization**
- Reads task from `$HYPER_WORKSPACE_ROOT/projects/{project}/tasks/task-001.mdx`
- Reads project spec for context
- Checks dependencies are complete

**Status Update**
- Updates task: `status: todo` → `status: in-progress`
- Appends to progress log in task file

**Implementation**
- Follows codebase patterns
- Makes incremental changes
- Tracks progress in task file

**Verification**
- Runs automated checks (lint, test, typecheck, build)
- Creates fix tasks for failures
- Loops until all pass

**QA Phase (Quality Assurance)**
- Updates task: `status: in-progress` → `status: qa`
- Run automated checks + manual verification
- web-app-debugger agent for browser testing (uses Chrome extension)

**Completion**
- Updates task: `status: qa` → `status: complete`
- Moves to next task

### 4. Verify Implementation

```bash
/hyper-verify auth-system/task-001
```

**Slop Detection**
- Checks for hallucinated imports
- Checks for hardcoded secrets
- Checks for debug statements

**Automated Checks**
- Linting
- Type checking
- Tests
- Build

**Manual Verification**
- Uses web-app-debugger agent with Chrome extension
- Screenshots at each step
- Asserts expected behavior

**Fix Loop**
- Creates fix tasks for failures
- Loops until all pass

### 5. Review Code

```bash
/hyper-review auth-system
```

**Parallel Sub-Agents**
- security-reviewer
- architecture-reviewer
- performance-reviewer
- code-quality-reviewer

**Synthesizes Findings**
- Creates fix tasks for P1 issues
- Documents patterns in compound-docs

## File Operations Reference

### Create Project

```bash
PROJECT_SLUG="auth-system"
mkdir -p "$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/{tasks,resources,resources/research}"
# Write _project.mdx with project template
```

### Create Task

```bash
TASK_NUM=$(printf "%03d" $(($(ls tasks/task-*.mdx 2>/dev/null | wc -l) + 1)))
# Write task-${TASK_NUM}.mdx with task template
```

### Update Status

```bash
# Edit frontmatter in task file
# status: todo → status: in-progress
# updated: YYYY-MM-DD
```

### Check Dependencies

```bash
# Parse depends_on from frontmatter
# Verify each dependency has status: complete
```

## Integration with Hyper Control

When Hyper Control is running:

1. **Automatic sync** - File watcher monitors `$HYPER_WORKSPACE_ROOT/`
2. **Real-time UI** - Changes appear immediately
3. **Visual management** - Browse projects, tasks, docs
4. **Search & filter** - Find documents quickly
5. **Session browser** - View Claude Code history

## Standalone Mode

Works without Hyper Control:

1. **Local files** - All artifacts in `$HYPER_WORKSPACE_ROOT/`
2. **Git tracked** - Version control everything
3. **Offline** - No network required
4. **Any editor** - View/edit with any tool

## Best Practices

1. **Always approve specs** - Gate 2 prevents premature task creation
2. **Complete dependencies** - Don't skip blocked tasks
3. **Run verification** - Never mark complete without checks
4. **Track progress** - Update status in real-time
5. **Document decisions** - Keep specs updated

## Troubleshooting

### No $HYPER_WORKSPACE_ROOT/ directory

```bash
/hyper-init
```

### Tasks not appearing

Check:
- Files are in correct directory
- Frontmatter is valid YAML
- Status is valid value

### Verification fails repeatedly

After 3 attempts:
1. Document what failed
2. Research alternatives
3. Question fundamentals
4. Try different approach

### Hyper Control not syncing

- Check file watcher is running
- Verify `$HYPER_WORKSPACE_ROOT/` path is correct
- Restart Hyper Control
