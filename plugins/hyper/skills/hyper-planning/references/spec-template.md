# Specification Template

Write the specification as inline content in `_project.mdx` AFTER the frontmatter.

## Spec Structure

```markdown
---
# Frontmatter (created by CLI)
---

# [TITLE] - Technical Specification

## Executive Summary

**What**: [One sentence describing what we're building]
**Why**: [One sentence on the business/user value]
**How**: [One sentence on the technical approach]

## Problem Statement

### Current State
- What exists today and how it works
- Specific pain points with file:line references
- Example: "Current auth flow in `src/auth/login.ts:45-67` requires manual token refresh"

### Desired State
- What the system should do after implementation
- Measurable improvements

### Impact if Not Addressed
- Consequences of maintaining status quo
- User/business impact

## Proposed Solution

### High-Level Approach
[2-3 paragraphs describing the solution strategy]

### Key Technical Decisions

| Decision | Choice | Rationale | Alternatives Considered |
|----------|--------|-----------|------------------------|
| [e.g., State management] | [e.g., Zustand] | [Why] | [What else considered] |

### Why This Approach
- Rationale for major architectural decisions
- Trade-offs acknowledged
- References to research findings

## Out of Scope (What We're NOT Doing)

| Item | Reason | Future Consideration |
|------|--------|---------------------|
| [Feature X] | [Why excluded] | [v2, never, TBD] |

## Architecture

### System Context

```mermaid
flowchart TB
    subgraph "Existing Components"
        A[Component from src/components/X.tsx]
    end
    subgraph "New Components"
        C[New component we're adding]
    end
    A --> C
```

**Diagram Notes**:
- A: Existing `src/components/X.tsx:23` - current entry point
- C: New component at `src/components/NewComponent.tsx`

### Data Flow

```mermaid
sequenceDiagram
    participant U as User
    participant C as Component
    participant S as Service
    participant A as API
    U->>C: User action
    C->>S: Call service
    S->>A: API request
    A-->>S: Response
    S-->>C: Processed data
    C-->>U: Updated UI
```

## Detailed Changes

### File-by-File Breakdown

#### 1. `src/path/ExistingFile.tsx` (MODIFY)

**Current** (lines 45-52):
```typescript
// Current implementation
```

**After**:
```typescript
// New implementation
```

**Why**: [Explanation]

#### 2. `src/path/NewFile.ts` (CREATE)

**New file**:
```typescript
// Full implementation template
```

**Pattern Reference**: Follow existing pattern in `src/path/Similar.ts:34-67`

## Implementation Phases

### Phase 1: [Foundation/Core]

**Goal**: [Specific deliverable]

**Files**:
| File | Action | Description |
|------|--------|-------------|
| `src/types/new.ts` | CREATE | New type definitions |

**Before/After**:
- Before: [State]
- After: [State]

**Dependencies**: None

**Verification**:
- `npm run typecheck` passes
- New types exported correctly

### Phase 2: [Business Logic]

[Same structure as Phase 1]

### Phase 3: [Integration & Testing]

[Same structure as Phase 1]

## Success Criteria

### Functional Requirements
- [ ] User can [specific action] from [specific location]
- [ ] System [specific behavior] when [specific condition]

### Non-Functional Requirements
- [ ] Page load time < [X]ms
- [ ] No console errors
- [ ] Accessibility: WCAG 2.1 AA compliance

### Definition of Done
- [ ] All acceptance criteria met
- [ ] Code reviewed and approved
- [ ] Tests written and passing
- [ ] Documentation updated

## Verification Requirements

### Automated Checks
| Check | Command | Required |
|-------|---------|----------|
| Lint | `npm run lint` | Yes |
| Typecheck | `npm run typecheck` | Yes |
| Unit Tests | `npm test` | Yes |
| Build | `npm run build` | Yes |

### Manual Verification Scenarios
| Scenario | Steps | Expected Result |
|----------|-------|-----------------|
| Happy path | 1. Navigate, 2. Click, 3. Enter | Result appears |
| Error case | 1. Navigate, 2. Submit empty | Error shown |

## Technical Notes

### Performance Considerations
- [Optimization needed]
- [Bundle size impact]

### Security Implications
- [Input validation]
- [Auth/authz changes]

### Accessibility Requirements
- [ARIA labels]
- [Keyboard navigation]

## Reference Documents

| Document | Location | Key Sections |
|----------|----------|--------------|
| Codebase Analysis | `resources/research/codebase-analysis.md` | Patterns |
| Best Practices | `resources/research/best-practices.md` | Recommendations |

## Open Questions (Must Resolve Before Approval)

| # | Question | Status | Resolution |
|---|----------|--------|------------|
| 1 | [Question] | Pending/Resolved | [Answer if resolved] |
```

## Quality Checklist

Before presenting for review:

- [ ] All file references include actual paths from codebase research
- [ ] Diagrams reference real component/file names
- [ ] Before/after examples show concrete code changes
- [ ] Each phase has clear files, dependencies, and verification
- [ ] Success criteria are measurable and testable
- [ ] No vague statements like "improve performance" without metrics
