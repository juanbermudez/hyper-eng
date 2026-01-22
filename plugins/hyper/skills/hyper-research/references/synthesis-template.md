# Synthesis Template

Combine findings from all research agents into actionable recommendations.

## Synthesis Process

### Step 1: Collect All Findings

Read all research documents:

```bash
cat "$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/resources/codebase-analysis.md"
cat "$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/resources/best-practices.md"
cat "$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/resources/framework-docs.md"
cat "$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/resources/git-history.md"
```

### Step 2: Identify Themes

Look for patterns across sources:

| Theme | Codebase | Best Practices | Framework | Git History |
|-------|----------|----------------|-----------|-------------|
| [Theme 1] | [Finding] | [Finding] | [Finding] | [Finding] |
| [Theme 2] | [Finding] | [Finding] | [Finding] | [Finding] |

### Step 3: Flag Conflicts

Document disagreements between sources:

```markdown
## Conflicts Identified

### [Conflict 1]
- **Codebase says**: [X]
- **Best practices say**: [Y]
- **Resolution**: [Recommendation with reasoning]

### [Conflict 2]
...
```

### Step 4: Rank by Relevance

Prioritize findings:

1. **Critical** - Must address for success
2. **Important** - Should address for quality
3. **Nice-to-have** - Consider for polish

### Step 5: Extract Decisions

List decisions that need user input:

```markdown
## Decisions Needed

1. **[Decision Name]**
   - Option A: [Description] - Pros: [X], Cons: [Y]
   - Option B: [Description] - Pros: [X], Cons: [Y]
   - Recommendation: [Option] because [reason]

2. **[Decision Name]**
   ...
```

## Synthesis Output Template

```markdown
# Research Summary: [Feature Name]

## Executive Summary

[2-3 sentences summarizing the key research findings]

## Recommended Approach

Based on [codebase patterns / best practices / framework docs], the recommended approach is:

1. [Approach point 1]
2. [Approach point 2]
3. [Approach point 3]

**Rationale**: [Why this approach]

## Key Technical Decisions

### 1. [Decision Name]

| Option | Pros | Cons | Source |
|--------|------|------|--------|
| [A] | [Pros] | [Cons] | [Research source] |
| [B] | [Pros] | [Cons] | [Research source] |

**Recommendation**: [Option] because [reasoning]

### 2. [Decision Name]
...

## Risk Areas

| Risk | Severity | Mitigation | Source |
|------|----------|------------|--------|
| [Risk 1] | High/Med/Low | [Mitigation] | [Source] |
| [Risk 2] | High/Med/Low | [Mitigation] | [Source] |

## Patterns to Follow

From codebase analysis:
- Follow `src/path/file.ts:23-45` for [pattern]
- Use existing `useHook` for [purpose]

From best practices:
- Implement [pattern] for [benefit]
- Avoid [anti-pattern] because [reason]

From framework docs:
- Use `api.method()` for [purpose]
- Configure [setting] as [value]

## Files to Create/Modify

Based on research, implementation will touch:

| File | Action | Reason |
|------|--------|--------|
| `src/path/new.ts` | CREATE | [Reason] |
| `src/path/existing.ts` | MODIFY | [Reason] |

## Open Questions

Questions that need user clarification:
1. [Question requiring user input]
2. [Question requiring user input]

## Research Sources

- Codebase: [Key files analyzed]
- Best Practices: [Key sources]
- Framework: [Documentation used]
- History: [Key commits/contributors]
```

## Quality Checklist

Before finalizing synthesis:

- [ ] All 4 research documents reviewed
- [ ] Conflicts identified and resolved
- [ ] Decisions clearly presented with options
- [ ] Risks documented with mitigations
- [ ] Actionable patterns extracted
- [ ] Open questions flagged for user
