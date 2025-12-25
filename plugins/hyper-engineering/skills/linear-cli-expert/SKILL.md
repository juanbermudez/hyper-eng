---
name: linear-cli-expert
description: This skill provides expert guidance for spec-driven development using the Linear CLI and AI agents. Use when orchestrating research, planning, and implementation workflows with Linear as the source of truth.
model: sonnet
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Task
  - WebFetch
---

<skill name="linear-cli-expert">

<description>
Expert guidance for spec-driven development with Linear CLI and AI agents. Orchestrates research, planning, and implementation workflows using specialized sub-agents with Linear as the single source of truth.
</description>

<intake>
What would you like to do?

1. **Plan a new feature** - Research codebase, create spec, get approval, then break down into tasks
2. **Implement a task** - Execute a Linear task with verification loop
3. **Review code** - Run comprehensive review with domain sub-agents
4. **Verify implementation** - Run automated and manual verification checks
5. **Learn about the workflow** - Understand the hyper-engineering process

Please select an option or describe what you need.
</intake>

<routing>
| User Intent | Action |
|-------------|--------|
| Plan, new feature, spec, PRD | Invoke `/hyper-plan` command |
| Implement, work on, build, code | Invoke `/hyper-implement` command |
| Review, check, audit | Invoke `/hyper-review` command |
| Verify, test, check | Invoke `/hyper-verify` command |
| Learn, understand, help | Read [workflow-guide.md](./references/workflow-guide.md) |
</routing>

<context>
<linear_cli_reference>
The Linear CLI provides comprehensive project management commands:

## Issue Commands
```bash
linear issue create --title "Title" --team LOT --priority 2
linear issue view LOT-123
linear issue list --state "In Progress"
linear issue update LOT-123 --state "Done"
linear issue relate LOT-123 LOT-456 --blocks
linear issue comment create LOT-123 --body "Comment text"
```

## Project Commands
```bash
linear project create --name "Project Name" --team LOT --status planned
linear project create --name "Feature" --with-doc --doc-title "PRD: Feature"
linear project view [project-id]
linear project list --status planned
linear project update [project-id] --status started
```

## Document Commands
```bash
linear document create --title "Title" --project [project-id] --content "..."
linear document view [document-id]
linear document update [document-id] --content "..."
linear document list --project [project-id]
```

## Workflow Commands
```bash
linear workflow list              # List workflow states
linear workflow cache             # Refresh cache
linear status list                # List project statuses
```

## Configuration
```bash
linear config setup               # Interactive setup
linear config set api_key "..."   # Set API key
linear whoami                     # Show current user
```
</linear_cli_reference>

<workflow_stages>
## Hyper-Engineering Workflow

### 1. Research Phase
- Agent asks clarifying questions (5-7 questions)
- Parallel sub-agents explore codebase
- Creates Linear draft project with research document
- Status: **Draft**

### 2. Planning Phase
- Agent reads research, asks scope questions
- Creates detailed spec with mermaid diagrams
- Includes ASCII layouts for frontend work
- Includes verification requirements
- Status: **Spec Review** (awaits human approval)

### 3. Task Breakdown (After Approval)
- Agent creates Linear issues from spec
- Sets up blocking relationships
- Each task includes verification sub-task
- Status: **Ready**

### 4. Implementation Phase
- Agent reads task spec from Linear
- Implements following codebase patterns
- Runs verification loop
- Status: **In Progress** → **Verification** → **Done**

### 5. Review Phase (Optional)
- Review orchestrator spawns domain sub-agents
- Security, architecture, performance, code quality
- Creates fix tasks for P1 issues
</workflow_stages>

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
1. Document the failure in Linear comment
2. Create fix sub-task
3. Implement fix
4. Re-run verification
5. Repeat until all checks pass
</verification_requirements>

<diagram_requirements>
## Required Diagrams in Specs

### Mermaid Diagrams (Required)
Use appropriate diagram type:

**Flowchart** - For process flows
```mermaid
flowchart TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Action]
    B -->|No| D[Other Action]
```

**Sequence** - For API/service interactions
```mermaid
sequenceDiagram
    Client->>API: Request
    API->>DB: Query
    DB-->>API: Result
    API-->>Client: Response
```

**Entity Relationship** - For data models
```mermaid
erDiagram
    USER ||--o{ ORDER : places
    ORDER ||--|{ ITEM : contains
```

**State** - For state machines
```mermaid
stateDiagram-v2
    [*] --> Draft
    Draft --> SpecReview
    SpecReview --> Ready
    Ready --> InProgress
```

### ASCII Layouts (Required for Frontend)
```
+------------------------------------------+
|  Header                        [Actions] |
+------------------------------------------+
|  Sidebar  |  Main Content               |
|           |  +------------------------+ |
|  - Nav 1  |  | Card Component         | |
|  - Nav 2  |  | - Title                | |
|  - Nav 3  |  | - Description          | |
|           |  | [Primary] [Secondary]  | |
|           |  +------------------------+ |
+------------------------------------------+
```
</diagram_requirements>
</context>

<examples>
<example name="planning_new_feature">
User: I want to add user authentication with OAuth

Agent:
1. Runs `/hyper-plan "Add user authentication with OAuth"`
2. Asks clarifying questions:
   - Which OAuth providers? (Google, GitHub, etc.)
   - Session storage approach? (JWT, cookies)
   - Protected routes scope?
3. Launches research sub-agents
4. Creates Linear project with PRD including:
   - Architecture diagram (mermaid sequence)
   - Login flow diagram (mermaid flowchart)
   - UI layout (ASCII)
5. Sets status to "Spec Review"
6. Waits for human approval
7. Creates tasks with dependencies after approval
</example>

<example name="implementing_task">
User: Implement LOT-123

Agent:
1. Runs `/hyper-implement LOT-123`
2. Reads task spec from Linear
3. Reads related documentation
4. Creates verification sub-task
5. Implements code following patterns
6. Runs verification:
   - `pnpm lint` ✓
   - `pnpm typecheck` ✓
   - `pnpm test` ✓
   - `pnpm build` ✓
7. Manual verification via Playwright
8. Updates Linear status to Done
</example>
</examples>

</skill>
