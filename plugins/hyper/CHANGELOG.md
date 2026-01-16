# Changelog

All notable changes to the hyper-engineering plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.5.0] - 2026-01-05

### Changed

**Full Project Implementation Mode**
- `/hyper:implement [project-slug]` now implements ALL tasks in dependency order
- `/hyper:implement-worktree [project-slug]` same behavior with worktree isolation
- Single task mode: `/hyper:implement [project-slug]/[task-id]`
- Full project mode: `/hyper:implement [project-slug]` (no task specified)
- Orchestrator handles dependency resolution and sequential task execution
- Reports progress after each task: completed, remaining, blocked

### Summary

| Component | Count |
|-----------|-------|
| Agents | 7 |
| Commands | 6 |
| Skills | 3 |
| MCP Servers | 1 |

---

## [3.4.0] - 2026-01-05

### Removed

**Statusline Commands**
- `/hyper:statusline-setup` - Removed (utility bloat)
- `/hyper:statusline-optout` - Removed (utility bloat)

### Summary

| Component | Count |
|-----------|-------|
| Agents | 7 |
| Commands | 6 |
| Skills | 3 |
| MCP Servers | 1 |

**Final command set**: `plan`, `implement`, `implement-worktree`, `verify`, `status`, `research`

---

## [3.3.0] - 2026-01-05

### Added

**Worktree-Enforced Implementation Command**
- New `/hyper:implement-worktree` command for mandatory worktree isolation
- Always creates isolated worktree before implementation (no option to skip)
- Safe for parallel development and experimentation
- Main checkout stays untouched on main branch
- Use when you want guaranteed isolation; use `/hyper:implement` for optional worktree

### Summary

| Component | Count |
|-----------|-------|
| Agents | 7 |
| Commands | 8 |
| Skills | 3 |
| MCP Servers | 1 |

---

## [3.2.0] - 2026-01-05

### Added

**Auto-Compounding in Verification**
- `/hyper:verify` now includes a **compound phase** after successful verification
- Automatically captures learnings from completed work:
  - Bug fixes with root cause analysis
  - Patterns and reusable approaches
  - Gotchas that blocked progress
- Creates solution docs in `$HYPER_WORKSPACE_ROOT/docs/solutions/{category}/`
- Detects recurring patterns and creates `$HYPER_WORKSPACE_ROOT/docs/patterns/` docs
- Philosophy: "Each unit of work should make subsequent units easier"

**Solution Documentation Schema**
- New YAML frontmatter for solution docs: `problem_type`, `component`, `root_cause`, `severity`, `tags`, `task_ref`
- Pattern docs with ❌ WRONG vs ✅ CORRECT examples
- Links back to originating task for context

### Removed

**Command Cleanup (3 commands removed)**
- `/hyper:init` - Removed. `/hyper:plan` now auto-creates `$HYPER_WORKSPACE_ROOT/` directory when needed.
- `/hyper:init-stack` - Removed. Project scaffolding is out of scope; use standard generators.
- `/hyper:review` - Removed. Code review concepts merged into verification workflow.

### Changed

- Verification loop now includes compounding principle in documentation
- Command count reduced from 10 to 7 for simpler workflow
- Core workflow is now: `plan` → `implement` → `verify` (with auto-compound)

### Summary

| Component | Count |
|-----------|-------|
| Agents | 7 |
| Commands | 7 |
| Skills | 3 |
| MCP Servers | 1 |

### Philosophy

This release embraces the **Compound Engineering** philosophy:
> "Each unit of work should make subsequent units easier."

By auto-capturing learnings at the verification step, knowledge compounds over time.
The simplified command set keeps the workflow focused: plan → implement → verify.

---

## [3.1.0] - 2026-01-05

### Added

**Final Project Verification Task**
- `/hyper:plan` now creates a final verification task (`task-999.mdx`) for every project
- Final task depends on ALL phase verification tasks (101, 102, 103, etc.)
- Ensures project-level QA before marking project as `completed`
- Includes comprehensive checklist: integration testing, documentation review, code quality, browser testing

**Project Completion Workflow**
- Final verification task must complete before project can move to `completed` status
- Checklist includes: cross-phase integration, no regressions, full e2e testing
- Documentation review: README, API docs, CHANGELOG, breaking changes
- Code quality: no unresolved TODOs, no debug code, convention compliance

### Changed

- Task breakdown phase now includes step 6 for creating final verification task
- Summary output includes "Final Project Verification" section with `task-999.mdx`

### Fixed

**Plugin Installation**
- Added missing `.claude-plugin/plugin.json` manifest to enable marketplace installation
- Plugin now passes `claude plugin validate` checks
- Fixes "plugin not found" errors when installing via `/plugin install hyper@hyper-eng-marketplace`

### Summary

| Component | Count |
|-----------|-------|
| Agents | 7 |
| Commands | 10 |
| Skills | 3 |
| MCP Servers | 1 |

---

## [3.0.0] - 2026-01-05

### Breaking Changes

**Plugin Renamed**
- Plugin renamed from `hyper-engineering` to `hyper`
- Namespace changed from `/hyper-engineering:hyper-*` to `/hyper:*`
- Command files renamed: `hyper-plan.md` → `plan.md`, etc.
- Shorter, cleaner command names: `/hyper:init`, `/hyper:plan`, `/hyper:implement`

### Changed

- All 10 command files renamed (removed `hyper-` prefix)
- Marketplace source path updated to `./plugins/hyper`
- Plugin directory renamed from `hyper-engineering` to `hyper`

### Summary

| Component | Count |
|-----------|-------|
| Agents | 7 |
| Commands | 10 |
| Skills | 3 |
| MCP Servers | 1 |

---

## [2.8.0] - 2026-01-04

### Added

**Standalone Research Command**
- New `/hyper-research` command for standalone research workflows
- Two depth modes: Comprehensive (default) and Deep
- Creates research projects with `project_type: research`
- Research projects use `ready-for-review` status for completion

**New Status and Fields**
- Added `ready-for-review` project status with pulsing badge
- Added `project_type` field (feature, research, spike)
- Added `archived` field for hiding completed projects

**CLI Archive Command**
- `hyper project archive --slug <slug>` to archive a project
- `hyper project archive --slug <slug> --unarchive` to restore

**UI Enhancements**
- Archive filter toggle in project list
- Pulsing lime/green badge for ready-for-review status
- Deep mode research with PROGRESS.md checkpoints

### Changed

- Enhanced research-orchestrator for standalone operation
- Updated frontmatter-schema.md with new fields and statuses
- Updated ProjectList UI with archive filtering

### Summary

| Component | Count |
|-----------|-------|
| Agents | 7 |
| Commands | 10 |
| Skills | 3 |
| MCP Servers | 1 |

---

## [2.7.0] - 2026-01-03

### Added

**CLI Integration**
- Bundled Hyper CLI binary (`binaries/hyper`) for project and task management
- CLI commands: `project create`, `task create`, `task update`, `project update`
- CLI validates frontmatter schema and handles file creation consistently
- CLI handles activity tracking with `activity add` and `activity comment` commands

**Automatic Activity Tracking**
- New `track-activity.sh` PostToolUse hook script
- Automatically logs session ID when agents modify `$HYPER_WORKSPACE_ROOT/*.mdx` files
- Activity entries support session (agent) and user (human) actors
- Action types: created, modified, commented, status_changed, assigned

**Updated Schema**
- Added `activity` field to frontmatter schema in `frontmatter-schema.md`
- Added Actor types: session (with parent_id for sub-agents) and user (with name)
- Added TypeScript interfaces for ActivityEntry and Actor

### Changed

- `/hyper-plan` now uses CLI for project and task creation (replaces bash heredocs)
- `/hyper-plan` writes spec inline in `_project.mdx` (removed separate `resources/specification.md`)
- `/hyper-implement` now uses CLI for status updates
- Implementation orchestrator uses CLI for status transitions
- Research orchestrator documents automatic activity tracking
- Updated all documentation to reference CLI commands

### Summary

| Component | Count |
|-----------|-------|
| Agents | 7 |
| Commands | 9 |
| Skills | 3 |
| MCP Servers | 1 |

---

## [2.6.0] - 2026-01-02

### Removed

**tauri-testing Skill**
- Moved to separate plugin: [Hyper-Builders/tauri-testing-plugin](https://github.com/Hyper-Builders/tauri-testing-plugin)
- Tauri-specific testing is now an optional plugin for better separation of concerns
- hyper-engineering remains technology-agnostic (general-purpose spec-driven framework)

**tauri-testing MCP Server**
- Moved to separate plugin alongside the skill
- Install the tauri-testing plugin separately if you need Tauri app testing

### Changed

- Bumped version to 2.6.0
- Updated skill count from 4 to 3
- Updated MCP server count from 2 to 1
- Removed `tauri` and `desktop-apps` keywords (now in tauri-testing plugin)

### Summary

| Component | Count |
|-----------|-------|
| Agents | 7 |
| Commands | 9 |
| Skills | 3 |
| MCP Servers | 1 |

---

## [2.5.0] - 2026-01-02

### Added

**tauri-testing Skill**
- New skill for verification workflow guidance for Tauri v2 applications
- Includes detection script to identify Tauri projects
- References for verification workflow and troubleshooting
- Works with tauri-plugin-mcp-bridge for WebSocket communication

**tauri-testing MCP Server**
- Added `tauri-mcp-server` npm package for Tauri app automation
- Tools: `tauri_launch_app`, `tauri_screenshot`, `tauri_click`, `tauri_get_text`, `tauri_type`
- Screenshot-to-file support via `filePath` parameter
- Configurable screenshot directory via `TAURI_MCP_SCREENSHOT_DIR` env var

### Changed

- Bumped version to 2.5.0
- Updated skill count from 3 to 4
- Updated MCP server count from 1 to 2
- Added `tauri` and `desktop-apps` keywords

## [2.4.0] - 2025-12-29

### Added

**QA Status for Tasks and Projects**
- New `qa` status for quality assurance and verification phase
- Tasks: `todo` → `in-progress` → `qa` → `complete`
- Projects: `todo` → `in-progress` → `qa` → `completed`
- QA is where all automated checks (lint, typecheck, test, build) and manual verification occur
- Tasks/projects only move to complete/completed after ALL checks pass

**Task ID Naming Convention**
- New initials-based task ID format: `{project-initials}-{3-digit-number}`
- Example: `user-auth` project → tasks `ua-001`, `ua-002`, `ua-003`
- Bash script for generating initials from project slug
- Reliable incrementing with zero-padded numbers

**Claude Code Documentation References**
- Added links to official Claude Code documentation
- Sub-Agents: https://code.claude.com/docs/en/sub-agents
- Plugins: https://code.claude.com/docs/en/plugins
- Skills: https://code.claude.com/docs/en/skills
- Hooks: https://code.claude.com/docs/en/hooks-guide

### Changed

**Status Reference in Commands**
- `hyper-plan.md` now includes explicit `<status_reference>` and `<id_convention>` sections
- `hyper-implement.md` now includes explicit status transitions with QA phase
- `hyper-status.md` updated with 🔍 icon for `qa` status

**Templates Updated**
- `task.mdx.template` includes status transitions comment with QA phase
- `project.mdx.template` includes status transitions comment with QA phase

**Skill Updates**
- `hyper-local/SKILL.md` updated with QA status and workflow stages
- `frontmatter-schema.md` updated with full ID naming convention and QA status

**Plugin Documentation**
- `CLAUDE.md` updated with QA status section and Claude Code doc links
- `README.md` updated with badges and file naming conventions

### Removed

**Playwright MCP References**
- Removed all remaining Playwright MCP references from documentation
- `hyper-verify.md` now uses `web-app-debugger` agent for browser testing
- `workflow-guide.md` updated to reference `web-app-debugger` agent
- `SKILL.md` updated to reference `web-app-debugger` agent
- Browser testing now uses Claude Code's Chrome extension instead of Playwright MCP

### Summary

| Component | Count |
|-----------|-------|
| Agents | 7 |
| Commands | 9 |
| Skills | 3 |
| MCP Servers | 1 |
| Hooks | 2 |

---

## [2.3.0] - 2025-12-29

### Added

**Settings & Customization System**
- New `$HYPER_WORKSPACE_ROOT/settings/` directory for workflow and agent/command customization
- `workflows.yaml` - Configure project/task workflow stages, quality gates, and tags
- Agent customization templates (7 YAML files) for all agents
- Command customization templates (5 YAML files) for major commands
- Settings guide reference documentation

**Workflow Configuration**
- Customizable project workflow stages (planned → review → todo → in-progress → verification → complete)
- Customizable task workflow stages with `on_enter` actions
- Quality gates configuration (automated and manual checks)
- Tags configuration (priority and type categories)

**Agent Customization Options**
- `context_additions` - Add project-specific context
- `instructions_prepend` / `instructions_append` - Modify agent instructions
- `output_format` - Override default output format
- `skip_sub_agents` - Skip specific sub-agents (orchestrators)
- `disabled` - Temporarily disable agents

**Command Customization Options**
- `context_additions` - Add project-specific context
- `phase_overrides` - Override specific workflow phases
- `skip_phases` - Skip phases not relevant to project
- `quality_gates` - Override verification checks
- `git` - Git workflow settings (branch patterns, commit format)

### Changed

**hyper-init**
- Now creates `$HYPER_WORKSPACE_ROOT/settings/` directory structure
- Creates `workflows.yaml` with default configuration
- Creates `agents/` and `commands/` subdirectories with README files
- Optional phase to copy full customization templates
- Updated structure check to validate settings directory

**hyper-local skill**
- Added settings customization documentation
- New routing for settings/customization requests
- Added `<settings_system>` section with comprehensive examples
- New `settings-guide.md` reference documentation

### Summary

| Component | Count |
|-----------|-------|
| Agents | 7 |
| Commands | 9 |
| Skills | 3 |
| MCP Servers | 1 |
| Hooks | 2 |

---

## [2.2.0] - 2025-12-29

### Added

**New Orchestrator Agents (2)**
- `research-orchestrator` - Coordinates research sub-agents in parallel, synthesizes findings, writes to `$HYPER_WORKSPACE_ROOT/projects/{slug}/resources/research/`
- `implementation-orchestrator` - Coordinates engineering sub-agents (backend, frontend, test), enforces verification gates, updates task status and implementation logs

**Verification Requirements in Tasks**
- Tasks now include detailed verification requirements section
- Automated quality gates: lint, typecheck, test, build, e2e
- Browser testing requirements for UI changes
- Implementation log section for progress tracking

**Project-Level Quality Gates**
- Project template now includes verification configuration
- Stack commands table for tech stack detection
- Automated gates checklist
- Manual gates checklist (code review, browser testing, security review)
- Browser verification section using web-app-debugger agent

**Task Implementation Workflow**
- Tasks updated with implementation logs when started
- Progress updates tracked in task files
- Completion details with changes, verification results, and git info
- Git workflow configuration in project template

### Changed

**hyper-plan: Orchestrator Pattern**
- Now spawns `research-orchestrator` instead of 4 agents directly
- Orchestrator coordinates parallel research and synthesizes findings
- Research output explicitly written to `$HYPER_WORKSPACE_ROOT/projects/{slug}/resources/research/`

**hyper-implement: Orchestrator Pattern**
- Now spawns `implementation-orchestrator` for task implementation
- Orchestrator coordinates backend, frontend, test sub-agents
- Parent agent verifies task was properly updated after completion
- Browser verification phase using web-app-debugger for UI changes

**Research Agents**
- All 4 research agents now have explicit output location sections
- Updated HYPER INTEGRATION section with orchestrator coordination
- Return structured JSON when called by orchestrator
- Write directly to research folder when called standalone

### Summary

| Component | Count |
|-----------|-------|
| Agents | 7 |
| Commands | 9 |
| Skills | 3 |
| MCP Servers | 1 |
| Hooks | 2 |

---

## [2.1.0] - 2025-12-29

### Added

**New Agent: web-app-debugger**
- Debug and test web applications using Claude Code Chrome extension
- Guides users through browser DevTools inspection (Console, Network, Elements)
- Supports React, Next.js, Vue debugging patterns
- Systematic debugging workflow with hypothesis testing

**Framework Documentation Sources**
- Added official documentation URLs for 40+ frameworks/technologies
- Research agents now have direct links to official docs (React, Next.js, Vue, Django, etc.)
- Improved search strategy: Context7 → Direct WebFetch → WebSearch fallback

**AskUserQuestion Protocol**
- All agents now include clarification protocol
- Agents use AskUserQuestion tool to gather context before research
- Prevents assumptions - agents ask for clarification when uncertain

**Authoritative Sources for Best Practices**
- Added authoritative source table for different topics (Security, Testing, Architecture, etc.)
- Research agents prioritize official docs and recognized experts

### Removed

**Playwright MCP Server**
- Removed Playwright MCP in favor of web-app-debugger agent with Chrome extension
- Simpler setup - no separate MCP server needed for browser testing

### Summary

| Component | Count |
|-----------|-------|
| Agents | 5 |
| Commands | 9 |
| Skills | 3 |
| MCP Servers | 1 |
| Hooks | 2 |

---

## [2.0.0] - 2025-12-28

### Breaking Changes

**Local-First Architecture**
- Default backend changed from Linear CLI to local `$HYPER_WORKSPACE_ROOT/` directory
- All planning, implementation, and verification now writes to local files
- Linear integration is no longer the default (plugin works standalone)

### Added

**New Skill: hyper-local**
- Complete guidance for `$HYPER_WORKSPACE_ROOT/` directory operations
- Intake routing for different request types
- File operations reference with examples
- Template system documentation
- Directory structure: `initiatives/`, `projects/{slug}/`, `docs/`, `workspace.json`

**New Commands (2)**
- `/hyper-init` - Initialize `$HYPER_WORKSPACE_ROOT/` workspace structure with templates
- `/hyper-status` - View project and task status from CLI

**Template System (6 templates)**
- `workspace.json.template` - Workspace configuration
- `project.mdx.template` - Project definition with frontmatter
- `task.mdx.template` - Task with dependencies and verification
- `initiative.mdx.template` - Strategic grouping of projects
- `resource.mdx.template` - Supporting documentation
- `doc.mdx.template` - Standalone documentation

**Validation Hooks**
- PostToolUse hook validates `$HYPER_WORKSPACE_ROOT/` file frontmatter on Write/Edit
- SessionStart hook checks for `$HYPER_WORKSPACE_ROOT/` existence and structure
- `validate-hyper-file.py` - Python validation script for frontmatter schema

**Skill References (4)**
- `directory-structure.md` - Complete `$HYPER_WORKSPACE_ROOT/` layout documentation
- `frontmatter-schema.md` - Full YAML frontmatter schema reference
- `template-guide.md` - Template customization guide
- `workflow-guide.md` - Local mode workflow documentation

### Changed

**hyper-plan: Local File Operations**
- Creates project directory in `$HYPER_WORKSPACE_ROOT/projects/{slug}/`
- Writes research findings to `resources/research/`
- Creates `specification.md` with full spec
- Creates task files in `tasks/` after approval
- Updates frontmatter status at each workflow transition

**hyper-implement: Local File Operations**
- Reads tasks from `$HYPER_WORKSPACE_ROOT/projects/{project}/tasks/`
- Updates task status by editing frontmatter
- Tracks implementation progress in task content
- Creates fix tasks as new files when verification fails

**hyper-verify: Local File Operations**
- Creates verification tasks in `$HYPER_WORKSPACE_ROOT/projects/{project}/tasks/`
- Tracks verification results in task content
- Creates fix tasks for failed verifications

**Research Agents (4)**
- All research agents now include HYPER INTEGRATION section
- Agents return structured JSON for parent agent synthesis
- Output written to `$HYPER_WORKSPACE_ROOT/projects/{slug}/resources/research/`
- Updated: repo-research-analyst, best-practices-researcher, framework-docs-researcher, git-history-analyzer

### Compatibility

**Hyper Control UI**
- Compatible with Hyper Control desktop app (optional)
- Hyper Control watches `$HYPER_WORKSPACE_ROOT/` via file watcher
- TanStack DB syncs from `$HYPER_WORKSPACE_ROOT/` files
- Plugin works standalone without Hyper Control

### Summary

| Component | Count |
|-----------|-------|
| Agents | 4 |
| Commands | 9 |
| Skills | 3 |
| MCP Servers | 2 |
| Hooks | 2 |

### Removed

**linear-cli-expert Skill**
- Removed Linear CLI integration skill - plugin is now fully local-first
- All workflow operations use `$HYPER_WORKSPACE_ROOT/` directory instead of Linear

---

## [1.1.0] - 2025-12-23

### Added

**Hyper-Statusline (Dracula Theme)**
- Modern statusline with visual context bar included as plugin asset
- Context bar changes color based on usage: green (0-49%), yellow (50-79%), red (80-100%)
- Model badge with color-coded icons: pink diamond (Opus), purple diamond (Sonnet), cyan circle (Haiku)
- Git branch indicator with uncommitted changes marker
- Session stats: lines added/removed, cost in USD

**New Commands (2)**
- `/hyper-statusline:setup` - One-command installation of the Dracula statusline
- `/hyper-statusline:optout` - Opt out of the setup prompt on session start

**New Hook: SessionStart**
- Checks if statusline is configured on new sessions
- Shows setup prompt with preview if not configured
- Respects opt-out preference

### Changed

**hyper-plan: Two-Gate Approval Process**
- Added Structure Checkpoint (Gate 1) after research phase for early direction validation
- Added explicit "Out of Scope" section to prevent scope creep
- Open questions now MUST be resolved before spec approval (Gate 2)
- Saves significant rework by validating direction before detailed spec writing

### Summary

| Component | Count |
|-----------|-------|
| Agents | 4 |
| Commands | 7 |
| Skills | 3 |
| MCP Servers | 2 |
| Hooks | 1 |

---

## [1.0.0] - 2025-12-22

### Initial Release

**Hyper-Engineering Plugin** - Linear-integrated, spec-driven development workflow with mandatory review gates and verification loops.

### Added - Hyper-Engineering Workflow

Major addition: Linear-integrated, spec-driven development workflow with mandatory review gates and verification loops.

**New Workflow Agents (3)**
- `research-agent` - Spawns 4 specialized research agents in parallel (repo-research-analyst, best-practices-researcher, framework-docs-researcher, git-history-analyzer) for comprehensive research including codebase patterns, external best practices, framework documentation, and code evolution
- `planning-agent` - Transforms research into specs with mermaid diagrams, enforces human review gates, creates Linear tasks only after approval
- `engineering-agent` - Implements Linear tasks following codebase patterns, runs verification loops (automated → manual), creates fix tasks when verification fails

**New Review Agents (5)**
- `review-orchestrator` - Orchestrates domain reviewers in parallel, synthesizes findings, creates P1 fix tasks
- `security-reviewer` - OWASP Top 10, authentication, input validation, secrets management
- `architecture-reviewer` - SOLID principles, component boundaries, dependency direction
- `performance-reviewer` - N+1 queries, algorithmic complexity, caching, resource management
- `code-quality-reviewer` - Naming, clarity, test coverage, error handling, code organization

**New Commands (5)**
- `/hyper-plan` - Spawn 4 specialized research agents → create spec with diagrams → wait for approval → create tasks. Uses `linear-cli-expert` skill for Linear guidance.
- `/hyper-implement` - Implement Linear task with verification loop. Uses `git-worktree` skill for isolated parallel development.
- `/hyper-review` - Orchestrate parallel domain reviewers. Uses `compound-docs` skill to document recurring patterns.
- `/hyper-verify` - Run comprehensive automated and manual verification
- `/hyper-init-stack` - Initialize stack-specific templates (node-typescript, python, go)

**Skill Integration**
Hyper-engineering commands leverage existing skills:
- `linear-cli-expert` - Used by hyper-plan, hyper-implement, hyper-review for Linear CLI guidance
- `git-worktree` - Used by hyper-implement for isolated parallel development
- `compound-docs` - Used by hyper-review to document recurring patterns and learnings

**New Skill (1)**
- `linear-cli-expert` - Expert guidance for spec-driven development with Linear CLI

**Stack Templates (4)**
- `node-typescript` - React, Next.js, Express patterns and verification
- `python` - FastAPI, Django, Flask patterns and verification
- `go` - Go backend services patterns and verification
- `_template` - Generic template for custom stacks

**Setup Script**
- `scripts/setup-linear-statuses.sh` - Configure Linear workflow states (Draft → Spec Review → Ready → In Progress → Verification → Done)

### Summary

| Component | Count |
|-----------|-------|
| Agents | 4 |
| Commands | 5 |
| Skills | 3 |
| MCP Servers | 2 |

### Notes

**v1.0.0 Cleanup:** Removed compound-engineering bloat, keeping only the core hyper-engineering workflow. All 4 agents are research agents (best-practices-researcher, framework-docs-researcher, git-history-analyzer, repo-research-analyst). All 5 commands are hyper-* prefixed (hyper-plan, hyper-implement, hyper-review, hyper-verify, hyper-init-stack). The 3 skills are linear-cli-expert, git-worktree, and compound-docs.


