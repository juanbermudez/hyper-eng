# OpenProse Language Reference

> **OpenProse** is a programming language for AI sessions. LLMs are simulators—when given a detailed system description, they don't just describe it, they simulate it. The VM specification describes a virtual machine with enough fidelity that an AI session reading it becomes that VM.

---

## Core Concept

```
You ARE the OpenProse VM
├── Your conversation history = VM's working memory
├── Your tool calls (Task) = VM's instruction execution
├── Your state tracking = VM's execution trace
└── Your judgment on **...** = VM's intelligent evaluation
```

**Key Insight**: Simulation with sufficient fidelity IS implementation. Each `session` spawns real subagents, outputs are real artifacts, state persists in files.

---

## Quick Reference

### Sessions (The Core Primitive)

```prose
# Simple session
session "Analyze the codebase"

# Session with output capture
let research = session "Research quantum computing"

# Session with agent template
session: researcher
  prompt: "Research AI safety"
  context: prior_research
```

### Agents (Templates for Sessions)

```prose
agent captain:
  model: opus
  persist: true              # Memory across invocations
  prompt: "You coordinate but never code directly"
  skills: ["code-analysis"]

agent worker:
  model: sonnet
  prompt: "You execute focused tasks"
```

**Agent Properties:**
| Property | Values | Description |
|----------|--------|-------------|
| `model:` | haiku, sonnet, opus | Model to use |
| `prompt:` | string | System prompt/instructions |
| `skills:` | array | Skills to enable |
| `persist:` | true, "project", "user", path | Memory scope |
| `retry:` | number | Retry count on failure |
| `backoff:` | none, linear, exponential | Retry strategy |

### Variables and Bindings

```prose
let research = session "Research"       # Mutable
const plan = session "Create plan"      # Immutable
output findings = session "Research"    # Program output
```

### Parallel Execution

```prose
parallel:
  a = session "Task A"
  b = session "Task B"
  c = session "Task C"

# With strategies
parallel ("first"):              # Race - first wins
parallel ("any", count: 2):      # Wait for N successes
parallel (on-fail: "continue"):  # Collect what you can
```

### Loops

```prose
repeat 3:
  session "Generate idea"

for topic in ["AI", "ML", "DL"]:
  session "Research {topic}"

loop until **the code is bug-free** (max: 10):
  session "Find and fix bugs"
```

### Conditionals

```prose
if **the plan has security issues**:
  session "Redesign for security"
elif **the plan is incomplete**:
  session "Expand the plan"
else:
  session "Proceed"

choice **the severity level**:
  option "Critical":
    session "Escalate immediately"
  option "Major":
    session "Prioritize"
  option "Minor":
    session "Log for later"
```

### Blocks (Reusable Composition)

```prose
block review-and-revise(artifact, criteria):
  let feedback = session "Review {artifact} against {criteria}"
  session "Revise {artifact} based on feedback"
    context: feedback

do review-and-revise("the architecture doc", "clarity")
```

### Context Passing

```prose
session "Process"
  context: research                    # Single variable

session "Synthesize"
  context: [research, analysis]        # Array

session "Integrate"
  context: { research, analysis }      # Named object
```

### Error Handling

```prose
try:
  session "Risky operation"
catch as err:
  session "Handle error"
    context: err
finally:
  session "Cleanup"
```

### Input/Output

```prose
input topic: "The subject to research"
input depth: "How deep: shallow, medium, deep"

output findings = session "Research"
output sources = session "Extract sources"
```

### Program Composition

```prose
use "alice/research" as research_prog

let { findings, sources } = research_prog(topic: "quantum computing")
```

---

## Discretion Conditions (`**...**`)

Conditions marked with `**...**` are AI-evaluated, not strict logic:

```prose
loop until **the code is bug-free**:
  session "Find and fix bugs"

if **the plan has security issues**:
  session "Redesign"
```

**Evaluation approach:**
1. Context awareness - consider all prior outputs
2. Semantic interpretation - understand intent
3. Conservative judgment - when uncertain, continue
4. Progress detection - exit if no meaningful progress

---

## Runtime Directory Structure

```
.prose/
├── .env                              # Config
├── runs/
│   └── {YYYYMMDD}-{HHMMSS}-{random}/
│       ├── program.prose             # Copy of running program
│       ├── state.md                  # Append-only execution log
│       ├── bindings/
│       │   ├── {name}.md             # Root scope bindings
│       │   └── {name}__{exec_id}.md  # Block-scoped bindings
│       └── agents/
│           └── {name}/
│               ├── memory.md         # Agent's current state
│               └── {name}-NNN.md     # Historical segments
└── agents/                           # Project-scoped agent memory
    └── {name}/
        ├── memory.md
        └── {name}-NNN.md
```

### Run ID Format
- Format: `{YYYYMMDD}-{HHMMSS}-{random6}`
- Example: `20260115-143052-a7b3c9`

### State.md Event Markers

```
# run:20260115-143052-a7b3c9 feature.prose

1→ research ✓                    # Statement completed
2→ ∥start a,b,c                  # Parallel started
2a→ a ✓                          # Branch completed
2→ ∥done                         # Parallel joined
3→ loop:1/5                      # Loop iteration
3→ loop:2/5 exit(**complete**)   # Loop exited
---end 2026-01-15T14:35:22Z      # Program completed
---error 2026-01-15T14:35:22Z    # Program failed
```

### Binding File Format

```markdown
# {name}

kind: let
execution_id: 43  # If inside block invocation

source:
```prose
let research = session: researcher
  prompt: "Research AI safety"
```

---

[Actual output here]
```

---

## Agent Memory

### Memory Scopes

| Scope | Declaration | Path | Lifetime |
|-------|-------------|------|----------|
| Execution | `persist: true` | `.prose/runs/{id}/agents/` | Dies with run |
| Project | `persist: project` | `.prose/agents/` | Survives runs |
| User | `persist: user` | `~/.prose/agents/` | Cross-project |
| Custom | `persist: "path"` | Specified path | User-controlled |

### Memory File Format

```markdown
# Agent Memory: captain

## Current Understanding
[Accumulated knowledge]

## Decisions Made
- 2026-01-15: Chose JWT — better for distributed systems

## Open Concerns
- Need to verify OAuth rate limiting
```

### Resume vs Session

```prose
# Fresh session (new memory)
session: captain
  prompt: "Review the plan"

# Resume (loads existing memory)
resume: captain
  prompt: "Continue where you left off"
```

---

## Design Patterns

### Captain's Chair Pattern

```prose
agent captain:
  model: opus
  persist: true
  prompt: "You coordinate, never implement directly"

agent worker:
  model: sonnet
  prompt: "You execute focused tasks"

# Captain orchestrates
session: captain
  prompt: "Break down the task"

parallel:
  research = session: worker
    prompt: "Research component A"
  analysis = session: worker
    prompt: "Analyze component B"

session: captain
  prompt: "Synthesize and plan next steps"
  context: { research, analysis }
```

### Fan-Out-Fan-In

```prose
parallel for item in items:
  session "Process {item}"

session "Synthesize all results"
```

### Bounded Iteration

```prose
# ALWAYS use max: to prevent runaway
loop until **complete** (max: 10):
  session "Work"
```

---

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| God Session | One session doing too much | Decompose into focused sessions |
| Sequential When Parallel | Independent ops run sequentially | Parallelize independent work |
| Spaghetti Context | Context passed haphazardly | Minimize to actual dependencies |
| Unbounded Loops | Loops without max: | Always use `max:` constraint |

---

## Commands

```bash
prose run feature.prose           # Execute program
prose run alice/research          # Run from registry
prose compile feature.prose       # Validate syntax
prose boot                        # Initialize workspace
prose update                      # Migrate legacy files
```

---

## Hypercraft Integration

Hypercraft uses OpenProse as its execution engine. The relationship:

```
prose (VM) + hypercraft context = hypercraft (framework)
```

When running `/hyper:plan`:
1. Load `hypercraft` skill (includes prose VM)
2. Hypercraft adds artifact rules, CLI, directory structure
3. Execute `hyper-plan.prose` with the VM
4. Agents have access to framework knowledge

### Hypercraft-Specific Additions

- **Artifact rules**: Projects, tasks, drives in `$HYPER_WORKSPACE_ROOT`
- **CLI reference**: `hypercraft project/task/drive` commands
- **Output contracts**: Standard response format
- **Agent hierarchy**: Captain → Squad Leader → Worker

---

## Further Reading

- Full VM semantics: `prose-main/skills/prose/prose.md`
- State backends: `prose-main/skills/prose/state/`
- Examples (52): `prose-main/skills/prose/examples/`
- Patterns: `prose-main/skills/prose/guidance/patterns.md`

---

*Reference: OpenProse v0.8.1*
