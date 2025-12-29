# Changelog

All notable changes to the hyper-engineering plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-12-28

### Breaking Changes

**Local-First Architecture**
- Default backend changed from Linear CLI to local `.hyper/` directory
- All planning, implementation, and verification now writes to local files
- Linear integration is no longer the default (plugin works standalone)

### Added

**New Skill: hyper-local**
- Complete guidance for `.hyper/` directory operations
- Intake routing for different request types
- File operations reference with examples
- Template system documentation
- Directory structure: `initiatives/`, `projects/{slug}/`, `docs/`, `workspace.json`

**New Commands (2)**
- `/hyper-init` - Initialize `.hyper/` workspace structure with templates
- `/hyper-status` - View project and task status from CLI

**Template System (6 templates)**
- `workspace.json.template` - Workspace configuration
- `project.mdx.template` - Project definition with frontmatter
- `task.mdx.template` - Task with dependencies and verification
- `initiative.mdx.template` - Strategic grouping of projects
- `resource.mdx.template` - Supporting documentation
- `doc.mdx.template` - Standalone documentation

**Validation Hooks**
- PostToolUse hook validates `.hyper/` file frontmatter on Write/Edit
- SessionStart hook checks for `.hyper/` existence and structure
- `validate-hyper-file.py` - Python validation script for frontmatter schema

**Skill References (4)**
- `directory-structure.md` - Complete `.hyper/` layout documentation
- `frontmatter-schema.md` - Full YAML frontmatter schema reference
- `template-guide.md` - Template customization guide
- `workflow-guide.md` - Local mode workflow documentation

### Changed

**hyper-plan: Local File Operations**
- Creates project directory in `.hyper/projects/{slug}/`
- Writes research findings to `resources/research/`
- Creates `specification.md` with full spec
- Creates task files in `tasks/` after approval
- Updates frontmatter status at each workflow transition

**hyper-implement: Local File Operations**
- Reads tasks from `.hyper/projects/{project}/tasks/`
- Updates task status by editing frontmatter
- Tracks implementation progress in task content
- Creates fix tasks as new files when verification fails

**hyper-verify: Local File Operations**
- Creates verification tasks in `.hyper/projects/{project}/tasks/`
- Tracks verification results in task content
- Creates fix tasks for failed verifications

**Research Agents (4)**
- All research agents now include HYPER INTEGRATION section
- Agents return structured JSON for parent agent synthesis
- Output written to `.hyper/projects/{slug}/resources/research/`
- Updated: repo-research-analyst, best-practices-researcher, framework-docs-researcher, git-history-analyzer

### Compatibility

**Hyper Control UI**
- Compatible with Hyper Control desktop app (optional)
- Hyper Control watches `.hyper/` via file watcher
- TanStack DB syncs from `.hyper/` files
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
- All workflow operations use `.hyper/` directory instead of Linear

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


