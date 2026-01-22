---
type: resource
category: research
title: Best Practices Research
project: hyper-research-command
created: 2026-01-03
---

# Best Practices Research: Research Project Management

## Executive Summary

Research project management in AI-assisted development benefits from established patterns in knowledge management systems, research documentation frameworks, and progressive disclosure methodologies. This document synthesizes best practices for implementing a standalone research command.

## Industry Standards

### 1. Knowledge Base Organization (PARA Method)

The PARA method (Projects, Areas, Resources, Archives) provides a proven framework:

| Category | Description | Application to /hyper:research |
|----------|-------------|-------------------------------|
| Projects | Active, time-bound work | Research projects with status tracking |
| Areas | Ongoing responsibilities | N/A for research |
| Resources | Reference materials | Research documents (codebase-analysis, best-practices, etc.) |
| Archives | Completed/inactive items | Archived research with `status: archived` |

**Recommendation**: Implement archive status for completed research that should be preserved but not actively displayed.

### 2. Research Documentation Patterns

From academic and industry research practices:

#### Progressive Elaboration
Research should flow from broad to specific:
1. **Discovery Phase**: Initial exploration, identifying scope
2. **Deep Dive Phase**: Focused investigation of key areas
3. **Synthesis Phase**: Combining findings into actionable insights
4. **Review Phase**: Human validation before archiving

**Application**: Research project statuses should reflect these phases:
- `planned` - Research topic identified
- `in-progress` - Active investigation
- `ready-for-review` - Synthesis complete, awaiting feedback
- `archived` - Concluded and preserved

#### Structured Output Format
Research should produce consistent artifacts:

```
Research Project Structure:
├── _project.mdx           # Overview, goals, conclusions
└── resources/
    └── research/
        ├── codebase-analysis.md    # Internal patterns
        ├── best-practices.md       # External knowledge
        ├── framework-docs.md       # Technical docs
        ├── git-history.md          # Code evolution
        └── research-summary.md     # Executive synthesis
```

### 3. AI-Assisted Research Workflows

Best practices from AI documentation systems:

#### Parallel Agent Pattern
Spawn multiple specialized agents simultaneously:
- Reduces research time by 4x (parallelization)
- Ensures comprehensive coverage
- Enables cross-referencing

**Current Implementation**: research-orchestrator already follows this pattern

#### Iterative Refinement
Allow for research loops:
```
Start → Research → Review → Refine → Review → Archive
                 ↑_________|
```

**Recommendation**: `/hyper:research` should support iterative refinement:
- `hyper-research continue [project]` - Add to existing research
- `hyper-research refine [project]` - Focus on specific areas

### 4. Knowledge Handoff Patterns

From DevOps and SRE documentation:

#### Just-In-Time Documentation
- Research should be discoverable when needed
- Link research to related implementation projects
- Surfacing mechanism in desktop app

#### Decision Records
Research should capture:
- Options considered
- Trade-offs analyzed
- Recommendations with rationale
- Confidence levels

**Template Addition to research-summary.md**:
```markdown
## Key Decisions

| Decision | Options | Recommendation | Confidence |
|----------|---------|----------------|------------|
| Auth approach | JWT vs Session | Session-based | High |
| State management | Zustand vs Context | Zustand | Medium |
```

## Recommended Patterns

### 1. Research Project Lifecycle

```
┌─────────────┐     ┌─────────────┐     ┌─────────────────┐     ┌──────────┐
│  planned    │────▶│ in-progress │────▶│ ready-for-review│────▶│ archived │
└─────────────┘     └─────────────┘     └─────────────────┘     └──────────┘
                           │                      │
                           │                      ▼
                           │              ┌─────────────┐
                           └──────────────│ in-progress │ (refinement loop)
                                          └─────────────┘
```

### 2. Research Quality Checklist

Before marking research as `ready-for-review`:

**Coverage Gates**:
- [ ] Codebase patterns documented
- [ ] External best practices gathered
- [ ] Framework documentation reviewed
- [ ] Key decisions identified

**Quality Gates**:
- [ ] Sources cited for external claims
- [ ] File:line references for codebase findings
- [ ] Trade-offs explicitly stated
- [ ] Actionable recommendations provided

### 3. Research-to-Implementation Handoff

When research informs implementation:

```yaml
# Implementation project references research
---
id: proj-auth-implementation
type: project
project_type: implementation
research_ref: proj-auth-research    # Link to source research
---
```

### 4. Research Archival Best Practices

When archiving research:
1. Add conclusion section to `research-summary.md`
2. Update status to `archived`
3. Add `archived_at` timestamp
4. Optionally link to resulting implementation

## Anti-Patterns to Avoid

### 1. Research Without Synthesis
**Problem**: Dumping raw findings without analysis
**Solution**: Always require `research-summary.md` with executive summary

### 2. Stale Research
**Problem**: Research sitting in `in-progress` indefinitely
**Solution**:
- Prompt for status update after 7 days inactive
- Dashboard showing research age

### 3. Orphaned Research
**Problem**: Research not linked to any outcome
**Solution**:
- Encourage linking to implementation projects
- Track research utilization

### 4. Over-Research
**Problem**: Researching endlessly without moving to action
**Solution**:
- Time-box research phases
- Clear "good enough" criteria
- Iterative refinement supported (can always add more later)

## Sources

### Academic/Industry
- PARA Method - Tiago Forte (Building a Second Brain)
- Progressive Elaboration - PMI Project Management
- Design Docs - Google Engineering Practices

### Technical Documentation
- ADRs (Architecture Decision Records) - Michael Nygard
- RFCs - IETF process adapted for engineering
- Technical Writing - Google Developer Documentation Guide

### AI-Assisted Development
- Claude Code Sub-Agents Documentation
- LangChain Agent Patterns
- AutoGPT Research Methodology

## Recommendations Summary

| Area | Recommendation | Priority |
|------|----------------|----------|
| Status Workflow | Add `ready-for-review` and `archived` | High |
| Project Type | Use `project_type: research` field | High |
| Lifecycle | Support iterative refinement loops | Medium |
| Handoff | Link research to implementation projects | Medium |
| Quality Gates | Add research completion checklist | Low |
| Archival | Standardize archive process | Low |
