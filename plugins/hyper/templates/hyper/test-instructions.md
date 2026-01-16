# Test Instructions Template

## Unit Tests

### Test File Location

Following project conventions:
- Colocated: `src/path/Component.test.tsx`
- Separate: `tests/path/Component.test.tsx`

### Test Structure

```typescript
describe('ComponentName', () => {
  describe('when [condition]', () => {
    it('should [expected behavior]', () => {
      // Arrange
      const props = { /* ... */ };

      // Act
      const result = render(<Component {...props} />);

      // Assert
      expect(result).toBe(expected);
    });
  });
});
```

### What to Test

- [ ] Happy path (main success scenario)
- [ ] Error cases (invalid input, failures)
- [ ] Edge cases (empty, null, max values)
- [ ] State changes
- [ ] User interactions

### What NOT to Test

- Third-party library internals
- Simple getters/setters
- Framework code
- Implementation details

## Integration Tests

### Setup

```typescript
describe('Feature: [Feature Name]', () => {
  beforeEach(() => {
    // Setup
  });

  afterEach(() => {
    // Cleanup
  });

  it('should complete full workflow', async () => {
    // Test complete user flow
  });
});
```

## E2E Tests (if applicable)

### Playwright Example

```typescript
test('user can [action]', async ({ page }) => {
  await page.goto('/path');
  await page.fill('[name="field"]', 'value');
  await page.click('button[type="submit"]');

  await expect(page).toHaveURL('/expected');
  await expect(page.locator('h1')).toHaveText('Expected');
});
```

## Running Tests

```bash
# Unit tests
npm test

# Watch mode
npm test -- --watch

# Coverage
npm test -- --coverage

# E2E
npx playwright test
```

## Test Quality Checklist

- [ ] Tests are independent (no shared state)
- [ ] Tests have clear names describing behavior
- [ ] Tests use arrange/act/assert pattern
- [ ] Tests clean up after themselves
- [ ] Mocks are specific (not over-mocking)
