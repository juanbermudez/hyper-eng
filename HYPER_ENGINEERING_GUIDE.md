# Hyper-Engineering Plugin - Comprehensive Guide

**Version 2.1.0** | Local-first, spec-driven development for Claude Code

---

## Table of Contents

1. [Philosophy](#philosophy)
2. [Installation](#installation)
3. [Directory Structure](#directory-structure)
4. [Workflow Overview](#workflow-overview)
5. [Commands Reference](#commands-reference)
6. [Agents Reference](#agents-reference)
7. [Skills Reference](#skills-reference)
8. [MCP Server](#mcp-server)

---

## Philosophy

**Specs matter more than code. Code is disposable; specifications are the source of truth.**

The hyper-engineering workflow inverts traditional development:

1. **Research First** - 4 specialized agents explore codebase, docs, and best practices in parallel
2. **Spec Before Code** - Human approval required before any tasks are created
3. **Verification Always** - Every implementation goes through automated + manual verification
4. **Local-First** - All state lives in `$HYPER_WORKSPACE_ROOT/` directory (works offline, no external dependencies)

---

## Installation

```bash
# Step 1: Add the marketplace
claude /plugin marketplace add https://github.com/juanbermudez/hyper-eng

# Step 2: Install the plugin
claude /plugin install hyper

# Step 3: Initialize your workspace
/hyper-init

# Step 4: Verify installation
/hyper-status
```

---

## Directory Structure

After running `/hyper-init`, your project will have:

```
$HYPER_WORKSPACE_ROOT/
├── workspace.json           # Workspace configuration
├── initiatives/             # Strategic groupings
│   └── {slug}.mdx
├── projects/                # Active projects
│   └── {slug}/
│       ├── project.mdx      # Project definition
│       ├── specification.md # Full specification
│       ├── tasks/           # Task files
│       │   └── {id}.mdx
│       └── resources/       # Supporting docs
│           └── research/    # Research findings
└── docs/                    # Standalone documentation
    └── {slug}.mdx
```

---

## Workflow Overview

```
Draft → Spec Review → Ready → In Progress → Verification → Done
         ↑                                        ↓
         └────────── Fix Tasks (if needed) ←──────┘
```

| Stage | Description | Gate |
|-------|-------------|------|
| **Draft** | Research phase - agents explore codebase | - |
| **Spec Review** | Human reviews spec | **APPROVAL REQUIRED** |
| **Ready** | Tasks created from approved spec | - |
| **In Progress** | Implementation | - |
| **Verification** | Automated + manual checks | **MUST PASS** |
| **Done** | All verification passed | - |

---

## Commands Reference

### `/hyper-init`

**Purpose:** Initialize `$HYPER_WORKSPACE_ROOT/` workspace structure with templates.

**What it does:**
1. Creates `$HYPER_WORKSPACE_ROOT/` directory structure
2. Copies template files for projects, tasks, initiatives
3. Creates `workspace.json` configuration
4. Sets up resource directories

**Usage:**
```bash
/hyper-init
```

**When to use:** First time setting up hyper-engineering in a project.

---

### `/hyper-status`

**Purpose:** View project and task status from CLI.

**What it does:**
1. Reads all projects from `$HYPER_WORKSPACE_ROOT/projects/`
2. Parses frontmatter to get status, priority, dates
3. Displays overview or detailed project view
4. Shows task progress and blockers

**Usage:**
```bash
# Overview of all projects
/hyper-status

# Detailed view of specific project
/hyper-status user-authentication
```

**Output example:**
```
## Workspace Status

### Projects (3)
| Project | Status | Tasks | Progress |
|---------|--------|-------|----------|
| user-auth | in-progress | 5 | 60% |
| api-redesign | draft | 0 | 0% |
| dark-mode | complete | 8 | 100% |
```

---

### `/hyper-plan`

**Purpose:** Create comprehensive specs by spawning 4 research agents in parallel.

**What it does:**
1. **Research Phase** - Spawns 4 agents in parallel:
   - `repo-research-analyst` - Analyzes codebase patterns
   - `best-practices-researcher` - Searches external docs
   - `framework-docs-researcher` - Fetches official docs via Context7
   - `git-history-analyzer` - Traces code evolution

2. **Synthesis** - Combines research into comprehensive spec with:
   - Problem statement and goals
   - Mermaid diagrams (architecture, sequence, state)
   - ASCII layouts for UI
   - Implementation approach
   - Task breakdown

3. **Approval Gate** - Presents spec for human approval

4. **Task Creation** - After approval, creates task files in `$HYPER_WORKSPACE_ROOT/projects/{slug}/tasks/`

**Usage:**
```bash
/hyper-plan "Add user authentication with OAuth"
```

**Output:**
- `$HYPER_WORKSPACE_ROOT/projects/user-auth/project.mdx`
- `$HYPER_WORKSPACE_ROOT/projects/user-auth/specification.md`
- `$HYPER_WORKSPACE_ROOT/projects/user-auth/resources/research/*.md`
- `$HYPER_WORKSPACE_ROOT/projects/user-auth/tasks/*.mdx` (after approval)

---

### `/hyper-implement`

**Purpose:** Implement a task with verification loop.

**What it does:**
1. Reads task from `$HYPER_WORKSPACE_ROOT/projects/{project}/tasks/{task}.mdx`
2. Reads project spec and codebase patterns
3. Implements following existing conventions
4. Uses `git-worktree` skill for isolated development (optional)
5. Updates task frontmatter status
6. Runs verification when complete
7. Creates fix tasks if verification fails

**Usage:**
```bash
/hyper-implement auth-login

# With project context
/hyper-implement user-auth/auth-login
```

**Workflow:**
```
Read Task → Read Spec → Implement → Update Status → Verify
                                                      ↓
                                              Pass? → Done
                                              Fail? → Create Fix Task → Loop
```

---

### `/hyper-review`

**Purpose:** Orchestrate parallel code reviews using specialized domain sub-agents.

**What it does:**
1. Determines review scope (files or task ID)
2. Spawns 4 review sub-agents in parallel:
   - **Security Reviewer** - OWASP Top 10, auth, input validation
   - **Architecture Reviewer** - SOLID, coupling, patterns
   - **Performance Reviewer** - N+1 queries, complexity, caching
   - **Code Quality Reviewer** - Naming, clarity, tests, docs

3. Synthesizes findings by severity (Critical/High/Medium/Low)
4. Generates review report
5. Creates fix tasks for critical issues

**Usage:**
```bash
# Review specific files
/hyper-review src/auth/

# Review by task ID
/hyper-review auth-login
```

**Output:**
```markdown
# Code Review Report

## Summary
- Critical Issues: 1
- High Priority: 3
- Medium Priority: 5

## Critical Issues
### SQL Injection in UserController
**Location:** `src/controllers/user.ts:45`
**Problem:** User input passed directly to query
**Fix:** Use parameterized queries
```

---

### `/hyper-verify`

**Purpose:** Run comprehensive automated and manual verification.

**What it does:**
1. **Automated Verification:**
   - Lint (`npm run lint` or equivalent)
   - Test (`npm test`)
   - Typecheck (`tsc --noEmit`)
   - Build (`npm run build`)

2. **Manual Verification:**
   - UI/UX testing (if applicable)
   - Edge case testing
   - Integration testing

3. **Results Handling:**
   - Pass → Updates task status to `complete`
   - Fail → Creates fix tasks with specific issues

**Usage:**
```bash
/hyper-verify auth-login
```

---

### `/hyper-init-stack`

**Purpose:** Initialize stack-specific templates and verification commands.

**What it does:**
1. Detects or asks for tech stack
2. Configures appropriate verification commands
3. Sets up patterns for the stack

**Available stacks:**
- `node-typescript` - React, Next.js, Express
- `python` - FastAPI, Django, Flask
- `go` - Go backend services

**Usage:**
```bash
/hyper-init-stack
# or
/hyper-init-stack node-typescript
```

---

### `/hyper-statusline:setup`

**Purpose:** Install the Dracula-themed statusline.

**What it does:**
1. Configures Claude Code statusline setting
2. Shows context usage (green/yellow/red)
3. Displays model badge with colors
4. Shows git branch and uncommitted changes
5. Tracks session stats (lines added/removed, cost)

**Usage:**
```bash
/hyper-statusline:setup
```

---

### `/hyper-statusline:optout`

**Purpose:** Opt out of statusline setup prompt.

**What it does:**
- Sets preference to not show statusline prompt on session start

**Usage:**
```bash
/hyper-statusline:optout
```

---

## Agents Reference

### Research Agents (4)

These agents are spawned in parallel by `/hyper-plan`:

#### `repo-research-analyst`

**Purpose:** Research repository structure and conventions.

**What it analyzes:**
- ARCHITECTURE.md, README.md, CONTRIBUTING.md, CLAUDE.md
- GitHub issue patterns and label conventions
- Code patterns and naming conventions
- Template files (.github/ISSUE_TEMPLATE/, etc.)

**Output:** JSON structure with file references, patterns, conventions

**Direct usage:**
```bash
claude agent repo-research-analyst "Analyze authentication patterns in this codebase"
```

---

#### `best-practices-researcher`

**Purpose:** Gather external best practices and examples.

**What it searches:**
- Official documentation via Context7
- Web searches for current best practices
- GitHub repositories with similar implementations
- Industry standards (OWASP for security, etc.)

**Authoritative sources table:**
| Topic | Sources |
|-------|---------|
| Security | OWASP, NIST, CWE |
| React | react.dev, Kent C. Dodds |
| TypeScript | TypeScript handbook, Matt Pocock |
| API Design | Microsoft/Google REST guidelines |
| Testing | Testing Library, Martin Fowler |

**Direct usage:**
```bash
claude agent best-practices-researcher "JWT authentication best practices 2025"
```

---

#### `framework-docs-researcher`

**Purpose:** Research framework documentation and best practices.

**What it accesses:**
- Context7 MCP for official docs
- Direct access to 40+ official doc sites
- Version-specific documentation
- Migration guides and deprecation notes

**Framework docs table (partial):**
| Framework | Docs URL |
|-----------|----------|
| React | https://react.dev |
| Next.js | https://nextjs.org/docs |
| Vue.js | https://vuejs.org/guide |
| Django | https://docs.djangoproject.com |
| Rails | https://guides.rubyonrails.org |
| TailwindCSS | https://tailwindcss.com/docs |

**Direct usage:**
```bash
claude agent framework-docs-researcher "Next.js 14 server actions documentation"
```

---

#### `git-history-analyzer`

**Purpose:** Analyze git history and code evolution.

**What it traces:**
- File evolution with `git log --follow`
- Code origins with `git blame`
- Commit patterns and themes
- Key contributors by area

**Output:** Timeline, contributors, relevant commits

**Direct usage:**
```bash
claude agent git-history-analyzer "Trace the evolution of the auth module"
```

---

### Testing Agent (1)

#### `web-app-debugger`

**Purpose:** Debug web applications using Claude Code Chrome extension.

**What it does:**
1. Uses AskUserQuestion to gather issue context
2. Guides user through Chrome DevTools:
   - Console tab for errors
   - Network tab for API issues
   - Elements tab for DOM/CSS
   - React/Vue DevTools for state
3. Forms and tests hypotheses
4. Provides fix with verification steps

**Debugging patterns:**
| Pattern | Symptoms | Investigation |
|---------|----------|---------------|
| React State | Not re-rendering, stale data | useState, useEffect deps |
| API Issues | Data not loading | Network tab, response |
| Styling | Elements not visible | Computed styles, z-index |
| Events | Clicks not working | Event listeners, overlays |

**Direct usage:**
```bash
claude agent web-app-debugger "Login button not responding when clicked"
```

---

## Skills Reference

### `hyper-local`

**Purpose:** Expert guidance for `$HYPER_WORKSPACE_ROOT/` directory operations.

**What it provides:**
- Directory structure documentation
- Frontmatter schema reference
- Template customization guide
- Workflow stage transitions

**When invoked:** Automatically by all hyper-* commands

**Direct usage:**
```
skill: hyper-local
```

---

### `git-worktree`

**Purpose:** Manage Git worktrees for parallel development.

**What it enables:**
- Work on multiple branches simultaneously
- Isolated development environments
- No context switching between features

**When invoked:** By `/hyper-implement` for isolated development

**Direct usage:**
```
skill: git-worktree
```

---

### `compound-docs`

**Purpose:** Capture solved problems as categorized documentation.

**What it does:**
- Documents recurring patterns
- Creates searchable knowledge base
- Uses YAML frontmatter for categorization
- Prevents same mistakes from recurring

**When invoked:** By `/hyper-review` when patterns are discovered

**Direct usage:**
```
skill: compound-docs
```

---

## MCP Server

### Context7

**Purpose:** Fetch framework documentation in real-time.

**Tools provided:**
- `resolve-library-id` - Find library ID for a framework
- `get-library-docs` - Get documentation for a library

**Supported frameworks:** 100+ including React, Next.js, Vue, Django, Rails, Laravel, and more.

**Configuration (if not auto-loading):**

Add to `.claude/settings.json`:
```json
{
  "mcpServers": {
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp"
    }
  }
}
```

---

## Quick Reference

### Common Workflows

**Starting a new feature:**
```bash
/hyper-plan "Add dark mode toggle"
# Review and approve spec
/hyper-implement dark-mode-toggle
/hyper-verify dark-mode-toggle
```

**Debugging an issue:**
```bash
claude agent web-app-debugger "Form submission not working"
```

**Code review before PR:**
```bash
/hyper-review src/features/auth/
```

**Research before implementation:**
```bash
claude agent framework-docs-researcher "React Server Components patterns"
claude agent best-practices-researcher "Form validation best practices"
```

### Status Values

| Status | Meaning |
|--------|---------|
| `draft` | Initial research phase |
| `todo` | Ready to be worked on |
| `in-progress` | Currently being implemented |
| `review` | Awaiting code review |
| `blocked` | Waiting on dependency |
| `complete` | Done and verified |

### Priority Values

| Priority | Meaning |
|----------|---------|
| `urgent` | Drop everything |
| `high` | Do this week |
| `medium` | Do this sprint |
| `low` | Nice to have |

---

## Version History

- **2.1.0** (2025-12-29): Added web-app-debugger agent, removed Playwright MCP, added AskUserQuestion protocol, added framework doc URLs
- **2.0.0** (2025-12-28): Local-first architecture with $HYPER_WORKSPACE_ROOT/ directory
- **1.1.0** (2025-12-23): Added Dracula statusline, two-gate approval
- **1.0.0** (2025-12-22): Initial release
