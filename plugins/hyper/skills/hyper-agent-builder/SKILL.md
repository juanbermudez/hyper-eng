---
name: hyper-agent-builder
description: |
  Dynamic discovery of skills, workflows, and agent composition.
  Use when: building worker agents, finding workflows for intents, composing skill sets.
  Triggers: "find skills for", "compose worker", "what workflow handles", "discover"
---

# Hyper Agent Builder

Enables Captains and Squad Leaders to dynamically discover skills, workflows, and compose workers.

## Discovery Commands

### Find Workflows by Intent

```bash
hypercraft find "plan" --type workflows --json
hypercraft find --type workflows --all --json
hypercraft find "HITL" --type workflows --json
```

### Find Skills for a Task

```bash
hypercraft find --type skills --all --json
hypercraft find "testing" --type skills --json
hypercraft find "documentation" --type skills --json
```

### Find Agents by Role

```bash
hypercraft find --type agents --all --json
hypercraft find "captain" --type agents --json
hypercraft find "squad-leader" --type agents --json
```

### Find Projects & Tasks

```bash
hypercraft find "authentication" --json
hypercraft find --type projects --status in-progress --json
hypercraft find --type tasks --all --json
```

## Skill Composition

When composing a worker:

```prose
# Step 1: Search for relevant skills
let skills_result = bash("hypercraft find '{task_domain}' --type skills --json")
let available_skills = parse_json(skills_result)

# Step 2: Compose worker with discovered skills
session: task-worker
  model: sonnet
  skills: [hypercraft, ...available_skills.results[:3]]
  env:
    HYPER_AGENT_ROLE: "worker"
  prompt: "{task_instructions}"
```

## Workflow Discovery

When routing a request:

```prose
# Step 1: Determine intent
let intent = classify_intent(user_request)

# Step 2: Search for matching workflow
let workflow_search = bash("hypercraft find '{intent}' --type workflows --json")
let workflows = parse_json(workflow_search)

# Step 3: Execute or clarify
if len(workflows.results) == 1:
  import workflows.results[0].path
  execute()
elif len(workflows.results) > 1:
  present_options(workflows.results)
else:
  suggest_creating_workflow(intent)
```

## Output Format

When returning discovery results:

```json
{
  "skills": {
    "recommended": ["hypercraft", "testing"],
    "optional": ["documentation"]
  },
  "workflow": {
    "matched": "hyper-plan.prose",
    "path": "commands/workflows/hyper-plan.prose",
    "confidence": "high"
  },
  "agents": {
    "captain": "captains/hyper-captain.md",
    "squad_leader": "squad-leaders/plan-squad-leader.md"
  }
}
```
