---
name: compound-engineering
description: This skill detects compound engineering triggers (errors, corrections, retries) and captures learnings for future sessions. It enables automatic knowledge extraction from workflow execution.
model: sonnet
allowed-tools:
  - Read
  - Write
  - Grep
  - Bash
  - AskUserQuestion
includes:
  - hyper-craft
---

# Compound Engineering Skill

Automatically detect learning opportunities during workflow execution and capture them as searchable knowledge.

## Overview

Compound engineering transforms mistakes and corrections into institutional knowledge. This skill:

1. **Detects triggers** - Identifies events that indicate learning opportunities
2. **Captures context** - Extracts relevant details from the session
3. **Creates learnings** - Writes structured documentation
4. **Surfaces knowledge** - Makes learnings available to future sessions

## When to Use

This skill activates:

- At workflow completion (planning, implementation, verification)
- When explicitly invoked via `/compound` command
- When triggered by hypercraft workflows

## Trigger Detection

### Trigger Types

| Trigger Type | Detection Pattern | Priority |
|--------------|-------------------|----------|
| Tool errors | Non-zero exit code, error in result | High |
| User corrections | "actually", "you're right", "no, I meant" | High |
| Self-corrections | "my bad", "I apologize", "let me correct" | Medium |
| Multiple retries | Same operation attempted 3+ times | Medium |
| Unexpected behavior | "that's weird", "shouldn't happen" | Low |

### Detection Keywords

```yaml
user_correction_keywords:
  - "actually"
  - "you're right"
  - "you are right"
  - "no, I meant"
  - "that's not what I asked"
  - "let me clarify"
  - "that's wrong"
  - "not quite"

self_correction_keywords:
  - "my bad"
  - "I apologize"
  - "let me correct"
  - "I was wrong"
  - "I should have"
  - "mistake on my part"
  - "let me fix that"

unexpected_behavior_keywords:
  - "that's weird"
  - "shouldn't happen"
  - "unexpected"
  - "strange"
  - "interesting, that"
```

### Trigger Detection Logic

```
detectTriggers(session):
  triggers = []

  # Check tool results for errors
  for toolResult in session.toolResults:
    if toolResult.error or toolResult.exitCode != 0:
      triggers.push({
        type: 'tool_error',
        timestamp: toolResult.timestamp,
        tool: toolResult.toolName,
        detail: toolResult.error or toolResult.stderr,
        severity: 'high'
      })

  # Check for retry patterns (same command 3+ times)
  commandCounts = {}
  for toolResult in session.toolResults:
    key = hash(toolResult.command or toolResult.toolName)
    commandCounts[key] = (commandCounts[key] or 0) + 1
    if commandCounts[key] >= 3:
      triggers.push({
        type: 'multiple_retries',
        command: toolResult.command,
        count: commandCounts[key],
        severity: 'medium'
      })

  # Check user messages for corrections
  for message in session.userMessages:
    if containsKeywords(message, user_correction_keywords):
      triggers.push({
        type: 'user_correction',
        message: message.content,
        severity: 'high'
      })

  # Check assistant messages for self-corrections
  for message in session.assistantMessages:
    if containsKeywords(message, self_correction_keywords):
      triggers.push({
        type: 'self_correction',
        message: message.content,
        severity: 'medium'
      })

  return triggers
```

## Learnings Capture

### Learnings File Format

Create learnings at: `projects/{slug}/resources/learnings.md`

```markdown
# Learnings: {project-title}

## [Category]: [Title]

**Date**: YYYY-MM-DD
**Session ID**: {session-id}
**Trigger Type**: {tool_error|user_correction|self_correction|multiple_retries}
**Severity**: {high|medium|low}

### Context
What you were trying to accomplish when this happened.

### What Happened
The specific issue, error, or insight.
Include exact error messages when available.

### Root Cause
Why this happened - the technical or conceptual explanation.

### Solution
How it was resolved. Include code if applicable.

### Future Prevention
Actionable guidance to avoid this in future sessions.

### Tags
#category #technology #pattern
```

### Example Learning Entry

```markdown
## Testing: Mock Service Worker Configuration

**Date**: 2026-01-20
**Session ID**: impl-20260120-143052-a1b2c3d4
**Trigger Type**: multiple_retries
**Severity**: medium

### Context
Implementing integration tests for the API client. Tests were failing intermittently.

### What Happened
Tests passed locally but failed in CI. MSW handlers were not being registered before test execution.

### Root Cause
The test setup was using `beforeAll` but MSW requires async setup. The handlers were racing with the first test.

### Solution
```typescript
// Before (incorrect)
beforeAll(() => {
  server.listen();
});

// After (correct)
beforeAll(async () => {
  await server.listen();
});
```

### Future Prevention
- Always use async/await with MSW setup
- Add explicit wait for server ready state
- Run CI tests multiple times during development

### Tags
#testing #msw #async #ci
```

## Workflow Integration

### In Hypercraft Workflows

Add compound engineering phase at workflow end:

```prose
# At workflow completion
let triggers = **detect_compound_triggers(session)**

if triggers.length > 0:
  session: compounding-agent
    prompt: """Review the session for compound engineering opportunities.

    Triggers detected:
    {triggers}

    For each significant trigger, extract and write learnings to:
    projects/{project_slug}/resources/learnings.md

    Format: See compound-engineering skill for structure."""
```

### Manual Capture

Users can manually capture learnings:

```
/compound "Brief description of what was learned"
```

This bypasses automatic trigger detection and directly creates a learning entry.

## Integration Points

### Query Learnings Before Research

During `/hyper:plan`, query existing learnings:

```bash
# Search for relevant learnings
grep -r "Tags.*#relevant-tag" $HYPER_WORKSPACE_ROOT/projects/*/resources/learnings.md
```

### Surface During Implementation

When similar errors occur, surface relevant learnings:

```bash
# Find learnings with matching error patterns
grep -l "similar error message" $HYPER_WORKSPACE_ROOT/projects/*/resources/learnings.md
```

### Compounding Agent Definition

```prose
agent compounding-agent:
  model: sonnet
  skills:
    - hyper-craft
    - compound-engineering
  prompt: """You extract and document learnings from session events.

Your responsibilities:
1. Analyze triggers detected during the session
2. Extract meaningful insights (not trivial errors)
3. Format learnings using the standard structure
4. Write to the appropriate learnings file
5. Cross-reference with existing learnings if related

Skip documentation for:
- Simple typos or syntax errors
- Trivial fixes immediately corrected
- Transient issues (network timeouts, etc.)

Document when:
- Investigation took multiple attempts
- Solution was non-obvious
- Future sessions would benefit from this knowledge"""
```

## Best Practices

### When to Capture

1. **Do capture**: Non-obvious solutions, patterns that emerged from trial and error, configuration gotchas
2. **Don't capture**: Simple typos, obvious mistakes, one-off issues

### Writing Good Learnings

1. **Be specific**: Include exact error messages, file paths, line numbers
2. **Explain why**: The root cause is more valuable than just the fix
3. **Make it actionable**: Future prevention should be concrete steps
4. **Tag appropriately**: Use consistent tags for searchability

### Cross-Referencing

Link related learnings:

```markdown
### Related
- [Performance: N+1 Query Fix](./learnings.md#performance-n1-query-fix)
- See also: compound-docs at `docs/solutions/`
```

## References

- [trigger-detection.md](./references/trigger-detection.md) - Detailed trigger patterns
- [learnings-schema.md](./references/learnings-schema.md) - Full schema for learnings
