# Research Patterns

## Sub-Agent Coordination

### Parallel Execution

Launch all 4 research agents simultaneously:

```javascript
// In a single tool call block, spawn all agents
Task(subagent_type: "hyper:repo-research-analyst", prompt: "...")
Task(subagent_type: "hyper:best-practices-researcher", prompt: "...")
Task(subagent_type: "hyper:framework-docs-researcher", prompt: "...")
Task(subagent_type: "hyper:git-history-analyzer", prompt: "...")
```

### Agent Responsibilities

| Agent | Focus | Output |
|-------|-------|--------|
| repo-research-analyst | Internal patterns | file:line pointers, JSON patterns |
| best-practices-researcher | External sources | Markdown with links |
| framework-docs-researcher | Official docs | API references, examples |
| git-history-analyzer | Code evolution | Timeline, contributors |

## Agent-Specific Patterns

### repo-research-analyst

**Focus Areas**:
- Similar implementations in codebase
- File organization patterns
- Import/export conventions
- Error handling patterns
- Test patterns for similar features

**Output Format**:
```json
{
  "patterns": [
    {
      "name": "Pattern Name",
      "files": ["src/path/file.ts:23-45"],
      "description": "How it's used"
    }
  ],
  "conventions": {
    "naming": "camelCase for variables",
    "file_organization": "feature-based folders"
  },
  "recommendations": ["..."]
}
```

### best-practices-researcher

**Focus Areas**:
- Industry standard approaches
- Security considerations
- Performance patterns
- Accessibility requirements
- Common pitfalls to avoid

**Sources**:
- Official framework documentation
- Security advisories
- Performance benchmarks
- A11y guidelines (WCAG)
- Community best practices

### framework-docs-researcher

**Tools**:
- Context7 MCP for documentation
- WebFetch for additional sources

**Output Includes**:
- API signatures
- Code examples
- Version compatibility
- Migration notes

### git-history-analyzer

**Focus Areas**:
- Recent changes to related files
- Contributors with expertise
- Refactoring patterns
- Bug fix patterns

**Output Format**:
```markdown
## File Evolution

### src/path/file.ts
- 2025-01-10: Refactored by @user - "Improve performance"
- 2025-01-05: Bug fix by @user - "Fix null check"
- 2024-12-20: Created by @user - "Initial implementation"

## Key Contributors
- @user1: 15 commits to auth module
- @user2: 8 commits to testing
```

## Synthesis Pattern

After all agents return:

1. **Identify Agreements** - What do multiple sources confirm?
2. **Flag Conflicts** - Where do recommendations differ?
3. **Rank by Relevance** - What's most applicable to this project?
4. **Extract Actionables** - What decisions need to be made?

## Quality Criteria

Good research output has:
- File:line pointers, not full content
- JSON summaries for structured data
- Clear source attribution
- Actionable recommendations
- Trade-offs explained
