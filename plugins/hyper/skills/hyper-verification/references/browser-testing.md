# Browser Testing

Visual and interactive testing for UI changes using web-app-debugger agent.

## When to Use

Browser testing is required when:
- UI components are added or modified
- User interactions are implemented
- Visual appearance matters
- Responsive design is important

## Web-App-Debugger Agent

Spawn the web-app-debugger for browser testing:

```
Task(subagent_type: "hyper:web-app-debugger", prompt: "
Test the following UI changes in the browser:

Project: ${PROJECT_SLUG}
Task: ${TASK_ID}
Changes: [list of UI changes]

Verify:
1. Visual appearance matches spec
2. No console errors
3. Interactive elements work
4. Responsive on mobile and desktop

Return verification results.
")
```

## Manual Browser Checklist

If not using web-app-debugger:

### Visual Inspection

- [ ] Component renders correctly
- [ ] Layout matches spec/wireframe
- [ ] Colors and typography correct
- [ ] Icons display properly
- [ ] Animations work smoothly

### Console Check

```javascript
// In browser DevTools Console
// Should be empty or only expected logs
```

- [ ] No errors (red)
- [ ] No unexpected warnings (yellow)
- [ ] No React/framework warnings

### Interactive Elements

- [ ] Buttons are clickable
- [ ] Forms submit correctly
- [ ] Links navigate properly
- [ ] Hover states work
- [ ] Focus states visible

### Responsive Design

Test at these breakpoints:

| Breakpoint | Width | Device |
|------------|-------|--------|
| Mobile | 375px | iPhone SE |
| Tablet | 768px | iPad |
| Desktop | 1280px | Laptop |
| Wide | 1920px | Monitor |

- [ ] Layout adapts to each breakpoint
- [ ] No horizontal scroll
- [ ] Touch targets adequate on mobile
- [ ] Text readable at all sizes

### Accessibility

- [ ] Keyboard navigation works
- [ ] Tab order makes sense
- [ ] Focus indicators visible
- [ ] Screen reader friendly (aria labels)
- [ ] Color contrast adequate

## Browser Testing Results

Document results in task file:

```markdown
## Browser Verification

### Visual Check
| Element | Status | Notes |
|---------|--------|-------|
| Layout | ✓ Pass | Matches spec |
| Colors | ✓ Pass | |
| Icons | ✓ Pass | |

### Console
| Type | Count | Details |
|------|-------|---------|
| Errors | 0 | |
| Warnings | 2 | React dev warnings (expected) |

### Interactive
| Element | Status | Notes |
|---------|--------|-------|
| Submit button | ✓ Pass | |
| Form validation | ✓ Pass | |

### Responsive
| Breakpoint | Status | Notes |
|------------|--------|-------|
| Mobile | ✓ Pass | |
| Tablet | ✓ Pass | |
| Desktop | ✓ Pass | |

### Accessibility
| Check | Status | Notes |
|-------|--------|-------|
| Keyboard | ✓ Pass | |
| Focus | ✓ Pass | |
```

## Common Issues

### Console Errors

```markdown
### Console Error: [Error Type]

**Error**:
```
Uncaught TypeError: Cannot read property 'x' of undefined
```

**Source**: `src/components/Widget.tsx:45`
**Fix**: Add null check before accessing property
```

### Layout Issues

```markdown
### Layout Issue: [Description]

**Observed**: [What's wrong]
**Expected**: [What should happen]
**Cause**: [Root cause]
**Fix**: [Solution]
```

### Responsive Issues

```markdown
### Responsive Issue: [Breakpoint]

**Device**: Mobile (375px)
**Issue**: Button text truncated
**Fix**: Reduce font size or allow wrap
```

## E2E Test Commands

For Playwright tests:

```bash
# Run all E2E tests
npx playwright test

# Run specific test
npx playwright test login.spec.ts

# Run with UI mode
npx playwright test --ui

# Run headed (visible browser)
npx playwright test --headed
```

For Cypress:

```bash
# Run all tests
npx cypress run

# Open interactive mode
npx cypress open
```
