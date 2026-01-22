---
name: hyper-research
description: This skill should be used when the user asks to "research a topic", "gather best practices", "analyze the codebase", or needs comprehensive research before implementation. Orchestrates 4 specialized research agents in parallel.
version: 1.0.0
model: sonnet
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Task
  - WebFetch
  - WebSearch
includes:
  - hyper-craft
  - hyper-local
---

# Hyper Research Skill

Orchestrate comprehensive research using parallel sub-agents to gather codebase patterns, best practices, framework documentation, and code evolution history. Requires `hyper-craft` as the core skill.

## Overview

This skill coordinates 4 specialized research agents:

1. **repo-research-analyst** - Codebase patterns and conventions
2. **best-practices-researcher** - External best practices via web search
3. **framework-docs-researcher** - Framework documentation via Context7 MCP
4. **git-history-analyzer** - Code evolution and contributor patterns

## Reference Documents

- [Research Patterns](./references/research-patterns.md) - Sub-agent patterns and coordination
- [Output Formats](./references/output-formats.md) - Research document templates
- [Research Scope Template](./references/research-scope-template.md) - Defining research scope
- [Synthesis Template](./references/synthesis-template.md) - Combining findings

## Workflow

### Step 1: Define Research Scope

<hyper-embed file="references/research-scope-template.md" />

### Step 2: Spawn Research Agents

Launch all 4 agents in parallel using the Task tool:

```javascript
// Spawn all 4 research agents in parallel
Task(subagent_type: "hyper:repo-research-analyst", prompt: "...")
Task(subagent_type: "hyper:best-practices-researcher", prompt: "...")
Task(subagent_type: "hyper:framework-docs-researcher", prompt: "...")
Task(subagent_type: "hyper:git-history-analyzer", prompt: "...")
```

<hyper-embed file="references/research-patterns.md" />

### Step 3: Synthesize Findings

After all agents return, synthesize the findings:

<hyper-embed file="references/synthesis-template.md" />

### Step 4: Write Research Documents

Output to: `$HYPER_WORKSPACE_ROOT/projects/{slug}/resources/`

<hyper-embed file="references/output-formats.md" />

## Research Agent Prompts

### repo-research-analyst

```
Analyze the codebase for patterns related to: [FEATURE]

Focus on:
1. Similar implementations in this codebase
2. File organization patterns
3. Import/export conventions
4. Error handling patterns
5. Test patterns for similar features

Return file:line pointers, not full content.
Output: JSON summary with key patterns.
```

### best-practices-researcher

```
Research external best practices for: [FEATURE]

Focus on:
1. Industry standard approaches
2. Security considerations
3. Performance patterns
4. Accessibility requirements
5. Common pitfalls to avoid

Use WebSearch and WebFetch for external sources.
Return: Markdown with links to sources.
```

### framework-docs-researcher

```
Gather framework documentation for: [FRAMEWORKS]

Use Context7 MCP to fetch:
1. Official API documentation
2. Integration patterns
3. Version-specific features
4. Migration guides if relevant

Return: Key code examples and API references.
```

### git-history-analyzer

```
Analyze git history for relevant files: [FILE_PATTERNS]

Focus on:
1. Recent changes to related files
2. Contributors with expertise
3. Refactoring patterns
4. Bug fix patterns

Return: Timeline of evolution with key commits.
```

## Output Location

All research documents are written to:

```
$HYPER_WORKSPACE_ROOT/projects/{slug}/resources/
├── codebase-analysis.md
├── best-practices.md
├── framework-docs.md
├── git-history.md
└── research-summary.md
```

## Return Format

After completion, return JSON summary:

```json
{
  "status": "complete",
  "project_slug": "{slug}",
  "research_location": "$HYPER_WORKSPACE_ROOT/projects/{slug}/resources/",
  "key_findings": {
    "recommended_approach": "...",
    "key_decisions": ["..."],
    "risk_areas": ["..."],
    "patterns_to_follow": ["..."]
  }
}
```

## Best Practices

- Spawn all 4 agents in parallel for efficiency
- Sub-agents return summaries, not raw data
- Use file:line pointers, not full file contents
- Say "need more context about X" rather than exploring blindly
- Synthesize findings into actionable recommendations
- Flag conflicts between research sources

## Error Handling

| Condition | Action |
|-----------|--------|
| Sub-agent returns insufficient info | Launch focused follow-up research |
| Conflicting recommendations | Present both with trade-offs |
| Framework docs unavailable | Use web search as fallback |
| No codebase patterns found | Note as greenfield and proceed |

## Includes

This skill depends on:

- **hyper-local** - Directory structure guidance
