---
name: node-typescript
description: Node.js/TypeScript web stack (React, Next.js, Express)
---

# Node/TypeScript Stack Configuration

This template configures hyper-engineering for Node.js/TypeScript projects using React, Next.js, or Express.

## Verification Commands

### Automated Checks

```yaml
verification:
  lint:
    primary: "pnpm lint"
    fallback: "npm run lint"
    description: "Run ESLint or Biome linter"
    fail_on_error: true

  typecheck:
    primary: "pnpm typecheck"
    fallback: "tsc --noEmit"
    description: "Run TypeScript type checking"
    fail_on_error: true

  test:
    primary: "pnpm test"
    fallback: "npm test"
    description: "Run all tests (Vitest, Jest, Playwright)"
    fail_on_error: true

  build:
    primary: "pnpm build"
    fallback: "npm run build"
    description: "Build the application"
    fail_on_error: true
```

### Optional Checks

```yaml
optional_verification:
  test_unit:
    command: "pnpm test:unit"
    description: "Run unit tests only"

  test_e2e:
    command: "pnpm test:e2e"
    description: "Run end-to-end tests (Playwright, Cypress)"

  test_coverage:
    command: "pnpm test:coverage"
    description: "Generate test coverage report"
    threshold: "80%"
```

## Common Patterns

### React Component Patterns

```typescript
// Functional component with TypeScript
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
}

export function Button({ label, onClick, variant = 'primary', disabled = false }: ButtonProps) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={`btn btn-${variant}`}
    >
      {label}
    </button>
  );
}

// Custom hooks
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const handler = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(handler);
  }, [value, delay]);

  return debouncedValue;
}
```

### Next.js App Router Conventions

```typescript
// app/page.tsx - Server Component (default)
export default async function HomePage() {
  const data = await fetchData(); // Server-side fetch

  return (
    <main>
      <h1>Welcome</h1>
      <DataDisplay data={data} />
    </main>
  );
}

// app/dashboard/layout.tsx - Nested layouts
export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="dashboard-layout">
      <Sidebar />
      <main>{children}</main>
    </div>
  );
}

// app/api/users/route.ts - API routes
export async function GET(request: Request) {
  const users = await db.user.findMany();
  return Response.json(users);
}

export async function POST(request: Request) {
  const body = await request.json();
  const user = await db.user.create({ data: body });
  return Response.json(user, { status: 201 });
}
```

### Express Middleware Patterns

```typescript
// Type-safe middleware
import { Request, Response, NextFunction } from 'express';

interface AuthRequest extends Request {
  user?: { id: string; email: string };
}

export const authenticate = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const user = await verifyToken(token);
    req.user = user;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
};

// Error handling middleware
export const errorHandler = (
  error: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error('Error:', error);

  if (error instanceof ValidationError) {
    return res.status(400).json({ error: error.message });
  }

  res.status(500).json({ error: 'Internal server error' });
};
```

### TypeScript Strict Mode

```json
// tsconfig.json - Recommended strict settings
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "exactOptionalPropertyTypes": true,
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve"
  }
}
```

## Stack-Specific Reviewer Additions

### React Hooks Rules

```markdown
## React Hooks Validation

- [ ] All hooks called at top level (not in loops, conditions, or nested functions)
- [ ] Dependencies arrays are complete and accurate
- [ ] useEffect cleanup functions return properly
- [ ] useState updates use functional form when referencing previous state
- [ ] Custom hooks start with "use" prefix
- [ ] No unnecessary useCallback/useMemo (avoid premature optimization)
```

### TypeScript Strict Checks

```markdown
## TypeScript Quality

- [ ] No `any` types (use `unknown` with type guards instead)
- [ ] No type assertions unless absolutely necessary
- [ ] Interfaces preferred over types for object shapes
- [ ] Proper null/undefined handling (no loose equality)
- [ ] Generics used appropriately (not over-engineered)
- [ ] Return types explicitly defined for public APIs
```

### Bundle Size Awareness

```markdown
## Performance Considerations

- [ ] Large dependencies dynamically imported where possible
- [ ] Images optimized and properly sized
- [ ] Heavy components lazy-loaded
- [ ] No unnecessary client-side JavaScript in Server Components
- [ ] Bundle analyzer run for significant additions
```

### Next.js Specific

```markdown
## Next.js Best Practices

- [ ] Server Components used by default
- [ ] Client Components marked with 'use client' only when needed
- [ ] Data fetching done in Server Components when possible
- [ ] Metadata exported from pages for SEO
- [ ] Loading and error states defined
- [ ] Dynamic routes use proper type-safe params
```

### Testing Requirements

```markdown
## Testing Coverage

- [ ] Unit tests for business logic and utilities
- [ ] Integration tests for API routes
- [ ] Component tests for interactive UI
- [ ] E2E tests for critical user flows
- [ ] Edge cases and error states tested
- [ ] Async operations properly mocked/awaited
```

## Common Project Structures

### Next.js App Router

```
app/
├── (auth)/              # Route group
│   ├── login/
│   └── register/
├── (dashboard)/         # Route group
│   ├── layout.tsx       # Shared layout
│   ├── page.tsx         # /dashboard
│   └── settings/
│       └── page.tsx     # /dashboard/settings
├── api/                 # API routes
│   └── users/
│       └── route.ts
├── layout.tsx           # Root layout
└── page.tsx             # Home page

components/              # Shared components
├── ui/                  # Base UI components
├── forms/               # Form components
└── layouts/             # Layout components

lib/                     # Utilities and helpers
├── db.ts                # Database client
├── auth.ts              # Auth utilities
└── utils.ts             # Helper functions
```

### React + Vite

```
src/
├── components/
│   ├── common/          # Shared components
│   ├── features/        # Feature-specific components
│   └── layouts/         # Layout components
├── hooks/               # Custom hooks
├── pages/               # Page components
├── services/            # API clients
├── stores/              # State management (Zustand, Redux)
├── types/               # TypeScript types
├── utils/               # Helper functions
└── main.tsx             # Entry point
```

## Environment Variables

```bash
# .env.local - Never commit this file
DATABASE_URL="postgresql://..."
NEXT_PUBLIC_API_URL="http://localhost:3000/api"
SECRET_KEY="..."

# .env.example - Commit this as template
DATABASE_URL="postgresql://user:password@localhost:5432/dbname"
NEXT_PUBLIC_API_URL="http://localhost:3000/api"
SECRET_KEY="your-secret-key-here"
```

## Package Manager Detection

```yaml
# Detection order (first match wins)
package_managers:
  - file: "pnpm-lock.yaml"
    manager: "pnpm"

  - file: "yarn.lock"
    manager: "yarn"

  - file: "package-lock.json"
    manager: "npm"

  - file: "bun.lockb"
    manager: "bun"
```

## Initialization Checklist

When setting up this stack for a project:

- [ ] Detect package manager (pnpm, npm, yarn, bun)
- [ ] Verify Node.js version (check .nvmrc or package.json engines)
- [ ] Install dependencies
- [ ] Run initial verification to ensure setup is correct
- [ ] Create .env.local from .env.example if it doesn't exist
- [ ] Verify all verification commands work
- [ ] Document any project-specific patterns in .claude/stacks/README.md
