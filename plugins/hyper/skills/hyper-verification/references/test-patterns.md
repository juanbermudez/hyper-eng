# Test Patterns

Guidelines for writing and organizing tests.

## Test Organization

### File Location

| Project Type | Test Location |
|--------------|---------------|
| Colocated | `src/components/Button.test.tsx` |
| Separate | `tests/components/Button.test.tsx` |
| E2E | `e2e/` or `tests/e2e/` |

### Naming Convention

```
[Feature].[test|spec].[ts|tsx|js]
```

Examples:
- `Button.test.tsx`
- `useAuth.spec.ts`
- `api-routes.test.ts`

## Test Structure

### Unit Test Pattern

```typescript
describe('ComponentName', () => {
  describe('when [condition]', () => {
    it('should [expected behavior]', () => {
      // Arrange
      const props = { ... };

      // Act
      const result = render(<Component {...props} />);

      // Assert
      expect(result).toBe(expected);
    });
  });
});
```

### Integration Test Pattern

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

## Test Categories

### Unit Tests

Test individual functions/components in isolation.

```typescript
// Good: Tests single behavior
it('should return sum of two numbers', () => {
  expect(add(2, 3)).toBe(5);
});

// Bad: Tests multiple behaviors
it('should handle math', () => {
  expect(add(2, 3)).toBe(5);
  expect(subtract(5, 3)).toBe(2);
  expect(multiply(2, 3)).toBe(6);
});
```

### Integration Tests

Test multiple components working together.

```typescript
it('should submit form and show success message', async () => {
  render(<ContactForm />);

  await userEvent.type(screen.getByLabelText('Email'), 'test@example.com');
  await userEvent.click(screen.getByRole('button', { name: 'Submit' }));

  expect(await screen.findByText('Success!')).toBeInTheDocument();
});
```

### E2E Tests

Test complete user flows in real browser.

```typescript
test('user can sign in and view dashboard', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[name="email"]', 'test@example.com');
  await page.fill('[name="password"]', 'password123');
  await page.click('button[type="submit"]');

  await expect(page).toHaveURL('/dashboard');
  await expect(page.locator('h1')).toHaveText('Welcome');
});
```

## Test Coverage

### What to Test

- ✓ Happy path (main success scenario)
- ✓ Error cases (invalid input, failures)
- ✓ Edge cases (empty, null, max values)
- ✓ Boundary conditions
- ✓ State changes

### What Not to Test

- ✗ Third-party library internals
- ✗ Simple getters/setters
- ✗ Framework code
- ✗ Implementation details

## Mocking

### When to Mock

- External APIs
- Database calls
- File system
- Time-dependent code
- Random values

### Mock Pattern

```typescript
// Mock module
jest.mock('./api', () => ({
  fetchUser: jest.fn()
}));

// Mock return value
(api.fetchUser as jest.Mock).mockResolvedValue({
  id: 1,
  name: 'Test User'
});
```

## Testing React Components

### Testing Library Best Practices

```typescript
// Good: Query by role
screen.getByRole('button', { name: 'Submit' });

// Avoid: Query by test ID (use only when necessary)
screen.getByTestId('submit-button');

// Good: Query by label
screen.getByLabelText('Email');

// Avoid: Query by class
document.querySelector('.submit-btn');
```

### Async Testing

```typescript
// Use findBy for async elements
const element = await screen.findByText('Loaded');

// Use waitFor for assertions
await waitFor(() => {
  expect(screen.getByText('Success')).toBeInTheDocument();
});
```

## Test Quality Checklist

- [ ] Tests are independent (no shared state)
- [ ] Tests have clear names describing behavior
- [ ] Tests use arrange/act/assert pattern
- [ ] Tests don't depend on execution order
- [ ] Tests clean up after themselves
- [ ] Mocks are specific (not over-mocking)
