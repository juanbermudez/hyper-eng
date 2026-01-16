# Manual Verification

Scenario-based testing beyond automated checks.

## When Required

Manual verification is needed for:
- User experience validation
- Visual design review
- Complex user flows
- Edge cases not covered by tests
- Integration with external systems

## Verification Scenarios

From task acceptance criteria, create test scenarios:

### Scenario Format

```markdown
### Scenario: [Name]

**Given**: [Initial state/context]
**When**: [User action]
**Then**: [Expected result]

**Steps**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected**: [Detailed expected outcome]
**Actual**: [What actually happened]
**Status**: Pass/Fail
```

## Common Scenario Types

### Happy Path

Test the main success flow:

```markdown
### Scenario: Successful Form Submission

**Given**: User is on the contact form
**When**: User fills all required fields and submits
**Then**: Success message appears, form clears

**Steps**:
1. Navigate to /contact
2. Fill email: test@example.com
3. Fill message: "Test message"
4. Click Submit

**Expected**: Green success toast, form resets
```

### Error Cases

Test error handling:

```markdown
### Scenario: Invalid Email

**Given**: User is on the contact form
**When**: User enters invalid email and submits
**Then**: Validation error appears

**Steps**:
1. Navigate to /contact
2. Fill email: "invalid-email"
3. Click Submit

**Expected**: Red error message: "Please enter a valid email"
```

### Edge Cases

Test boundary conditions:

```markdown
### Scenario: Empty State

**Given**: User has no items
**When**: User views the list page
**Then**: Empty state message appears

**Steps**:
1. Clear all user items
2. Navigate to /items

**Expected**: "No items yet" message with CTA
```

### Permission Cases

Test authorization:

```markdown
### Scenario: Unauthorized Access

**Given**: User is not logged in
**When**: User tries to access protected route
**Then**: Redirected to login

**Steps**:
1. Clear session/cookies
2. Navigate to /dashboard

**Expected**: Redirect to /login
```

## Verification Checklist Template

From task spec, create checklist:

```markdown
## Manual Verification Checklist

### Core Functionality
- [ ] Feature works as specified
- [ ] All acceptance criteria met
- [ ] No regression in existing features

### User Experience
- [ ] Intuitive to use
- [ ] Feedback is clear (loading, success, error)
- [ ] No confusing states

### Edge Cases
- [ ] Empty state handled
- [ ] Maximum values handled
- [ ] Invalid input handled

### Integration
- [ ] Works with existing features
- [ ] Data persists correctly
- [ ] API calls succeed
```

## Documenting Results

Record verification in task file:

```markdown
## Manual Verification Results

### Date: [DATE]

| Scenario | Status | Notes |
|----------|--------|-------|
| Happy path | ✓ Pass | |
| Invalid email | ✓ Pass | |
| Empty state | ✓ Pass | |
| Unauthorized | ✓ Pass | |

### Issues Found
- None

### Overall: PASS
```

## When Verification Fails

```markdown
## Verification Failure

### Scenario: [Name]

**Expected**: [What should happen]
**Actual**: [What happened]

**Evidence**: [Screenshot/recording if applicable]

**Severity**: Critical/High/Medium/Low

**Fix Required**: Yes/No

**Next Steps**:
1. [Action to take]
```

## Best Practices

- Test as an actual user would use it
- Don't assume - verify explicitly
- Document everything (screenshots help)
- Test on different browsers if relevant
- Clear cache/cookies between tests
- Test with realistic data
- Verify both positive and negative cases
