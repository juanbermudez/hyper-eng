# Output Formats

All research documents follow consistent formats for easy consumption.

## File Structure

```
$HYPER_WORKSPACE_ROOT/projects/{slug}/resources/research/
├── codebase-analysis.md      # From repo-research-analyst
├── best-practices.md         # From best-practices-researcher
├── framework-docs.md         # From framework-docs-researcher
├── git-history.md            # From git-history-analyzer
└── research-summary.md       # Synthesized findings
```

## codebase-analysis.md

```markdown
# Codebase Analysis: [Feature Name]

## Similar Implementations

### [Pattern 1]
**Location**: `src/path/file.ts:23-45`
**Description**: [How this pattern is used]
**Relevance**: [Why this matters for our feature]

### [Pattern 2]
...

## File Organization

The codebase organizes [feature type] as:
- `src/components/` - UI components
- `src/hooks/` - Custom React hooks
- `src/services/` - API/data layer

## Conventions

| Convention | Pattern | Example |
|------------|---------|---------|
| Naming | [pattern] | [example] |
| Exports | [pattern] | [example] |
| Tests | [pattern] | [example] |

## Recommendations

1. Follow pattern from `src/similar/feature.ts`
2. Use existing hook `useXxx` for [purpose]
3. Place new component in `src/components/[area]/`
```

## best-practices.md

```markdown
# Best Practices: [Feature Name]

## Industry Standards

### [Practice 1]
**Source**: [Link to source]
**Summary**: [Key takeaway]
**Application**: [How to apply here]

## Security Considerations

- [ ] [Security item 1]
- [ ] [Security item 2]

## Performance Patterns

| Pattern | Benefit | Implementation |
|---------|---------|----------------|
| [Pattern] | [Benefit] | [How to implement] |

## Common Pitfalls

1. **[Pitfall]**: [Description]
   - **Avoid**: [What not to do]
   - **Instead**: [What to do]

## Sources

- [Source 1](https://example.com)
- [Source 2](https://example.com)
```

## framework-docs.md

```markdown
# Framework Documentation: [Frameworks]

## [Framework 1]

### Key APIs

```typescript
// API signature
function apiName(params: Type): ReturnType
```

**Usage**:
```typescript
// Example usage
```

### Version Notes
- Current version: X.Y.Z
- Breaking changes: [notes]

## [Framework 2]
...

## Integration Patterns

### Pattern: [Name]
[Description and code example]
```

## git-history.md

```markdown
# Git History Analysis: [Feature Area]

## File Evolution

### src/path/primary-file.ts
| Date | Author | Change | Commit |
|------|--------|--------|--------|
| 2025-01-10 | @user | Refactored X | abc1234 |
| 2025-01-05 | @user | Fixed Y | def5678 |

### src/path/related-file.ts
...

## Key Contributors

| Contributor | Commits | Expertise Areas |
|-------------|---------|-----------------|
| @user1 | 15 | Auth, Security |
| @user2 | 8 | Testing, CI |

## Significant Refactors

### [Refactor Name] (2025-01-10)
- **Commit**: abc1234
- **Purpose**: [Why refactored]
- **Impact**: [What changed]

## Bug Fix Patterns

Common issues in this area:
1. [Bug pattern 1] - Fixed by [approach]
2. [Bug pattern 2] - Fixed by [approach]
```

## research-summary.md

```markdown
# Research Summary: [Feature Name]

## Key Findings

### Recommended Approach
[2-3 paragraph summary of recommended approach based on all research]

### Key Decisions Needed
1. [Decision 1]: [Options and trade-offs]
2. [Decision 2]: [Options and trade-offs]

### Risk Areas
- **[Risk 1]**: [Description and mitigation]
- **[Risk 2]**: [Description and mitigation]

### Patterns to Follow
- Follow `src/path/file.ts` for [pattern]
- Use [library] for [purpose]
- Avoid [anti-pattern]

## Research Sources

| Source | Type | Key Insight |
|--------|------|-------------|
| Codebase Analysis | Internal | [Insight] |
| Best Practices | External | [Insight] |
| Framework Docs | Official | [Insight] |
| Git History | Historical | [Insight] |

## Synthesis

[Paragraph combining all findings into coherent recommendation]
```
