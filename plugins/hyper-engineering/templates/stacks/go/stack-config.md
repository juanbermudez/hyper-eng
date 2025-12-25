---
name: go
description: Go backend services
---

# Go Stack Configuration

This template configures hyper-engineering for Go backend services and applications.

## Verification Commands

### Automated Checks

```yaml
verification:
  lint:
    primary: "golangci-lint run"
    fallback: "go vet ./..."
    description: "Run comprehensive linter suite"
    fail_on_error: true

  typecheck:
    # Go has built-in type checking
    description: "Type checking is built into go build"
    note: "No separate typecheck needed - handled by compiler"

  test:
    primary: "go test ./..."
    flags: "-race -cover"
    description: "Run all tests with race detector and coverage"
    fail_on_error: true

  build:
    primary: "go build ./..."
    description: "Build all packages"
    fail_on_error: true
```

### Optional Checks

```yaml
optional_verification:
  test_verbose:
    command: "go test -v ./..."
    description: "Run tests with verbose output"

  test_coverage:
    command: "go test -coverprofile=coverage.out ./... && go tool cover -html=coverage.out"
    description: "Generate detailed coverage report"
    threshold: "80%"

  benchmark:
    command: "go test -bench=. -benchmem ./..."
    description: "Run benchmarks"

  security:
    command: "gosec ./..."
    description: "Run security checks"

  mod_tidy:
    command: "go mod tidy && git diff --exit-code go.mod go.sum"
    description: "Verify go.mod and go.sum are tidy"
```

## Common Patterns

### Interface-Based Design

```go
package user

import (
    "context"
    "errors"
)

// Define small, focused interfaces
type UserRepository interface {
    Get(ctx context.Context, id string) (*User, error)
    Create(ctx context.Context, user *User) error
    Update(ctx context.Context, user *User) error
    Delete(ctx context.Context, id string) error
}

type EmailSender interface {
    Send(ctx context.Context, to, subject, body string) error
}

// Implementation with dependency injection
type UserService struct {
    repo   UserRepository
    mailer EmailSender
}

func NewUserService(repo UserRepository, mailer EmailSender) *UserService {
    return &UserService{
        repo:   repo,
        mailer: mailer,
    }
}

func (s *UserService) RegisterUser(ctx context.Context, user *User) error {
    if err := s.repo.Create(ctx, user); err != nil {
        return fmt.Errorf("create user: %w", err)
    }

    if err := s.mailer.Send(ctx, user.Email, "Welcome", "Thanks for signing up"); err != nil {
        // Log error but don't fail registration
        log.Printf("failed to send welcome email: %v", err)
    }

    return nil
}
```

### Error Handling Patterns

```go
package service

import (
    "errors"
    "fmt"
)

// Define sentinel errors for known error cases
var (
    ErrUserNotFound     = errors.New("user not found")
    ErrInvalidInput     = errors.New("invalid input")
    ErrUnauthorized     = errors.New("unauthorized")
    ErrDatabaseError    = errors.New("database error")
)

// Custom error types for additional context
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation error on field %s: %s", e.Field, e.Message)
}

// Error wrapping with context
func (s *UserService) GetUser(ctx context.Context, id string) (*User, error) {
    user, err := s.repo.Get(ctx, id)
    if err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return nil, ErrUserNotFound
        }
        // Wrap error with additional context
        return nil, fmt.Errorf("failed to get user %s: %w", id, err)
    }
    return user, nil
}

// Error checking
func HandleRequest(ctx context.Context, service *UserService, id string) error {
    user, err := service.GetUser(ctx, id)
    if err != nil {
        // Check for specific error types
        if errors.Is(err, ErrUserNotFound) {
            return fmt.Errorf("user not found")
        }

        // Check for custom error types
        var validationErr *ValidationError
        if errors.As(err, &validationErr) {
            return fmt.Errorf("validation failed: %s", validationErr.Message)
        }

        // Generic error
        return fmt.Errorf("internal error: %w", err)
    }

    // Process user...
    return nil
}
```

### Context Propagation

```go
package api

import (
    "context"
    "log"
    "net/http"
    "time"
)

// Context with timeout
func (h *Handler) HandleRequest(w http.ResponseWriter, r *http.Request) {
    // Create context with timeout
    ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
    defer cancel()

    // Pass context through the call chain
    user, err := h.service.GetUser(ctx, r.URL.Query().Get("id"))
    if err != nil {
        if ctx.Err() == context.DeadlineExceeded {
            http.Error(w, "Request timeout", http.StatusRequestTimeout)
            return
        }
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    json.NewEncoder(w).Encode(user)
}

// Context with values (use sparingly, prefer explicit parameters)
type contextKey string

const (
    userIDKey    contextKey = "userID"
    requestIDKey contextKey = "requestID"
)

func withUserID(ctx context.Context, userID string) context.Context {
    return context.WithValue(ctx, userIDKey, userID)
}

func getUserID(ctx context.Context) (string, bool) {
    userID, ok := ctx.Value(userIDKey).(string)
    return userID, ok
}

// Middleware pattern
func LoggingMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        start := time.Now()

        // Add request ID to context
        requestID := generateRequestID()
        ctx := context.WithValue(r.Context(), requestIDKey, requestID)

        // Call next handler with new context
        next.ServeHTTP(w, r.WithContext(ctx))

        log.Printf("Request %s completed in %v", requestID, time.Since(start))
    })
}
```

### Struct Embedding

```go
package model

import "time"

// Base model with common fields
type BaseModel struct {
    ID        string    `json:"id" db:"id"`
    CreatedAt time.Time `json:"created_at" db:"created_at"`
    UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

// Embed base model in other structs
type User struct {
    BaseModel              // Embedded struct (composition)
    Email     string       `json:"email" db:"email"`
    Name      string       `json:"name" db:"name"`
    IsActive  bool         `json:"is_active" db:"is_active"`
}

// User now has ID, CreatedAt, UpdatedAt fields
func ExampleUsage() {
    user := User{
        BaseModel: BaseModel{
            ID:        "123",
            CreatedAt: time.Now(),
            UpdatedAt: time.Now(),
        },
        Email:    "user@example.com",
        Name:     "John Doe",
        IsActive: true,
    }

    // Can access embedded fields directly
    fmt.Println(user.ID)        // "123"
    fmt.Println(user.CreatedAt) // timestamp
}

// Interface embedding
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

type ReadWriter interface {
    Reader  // Embedded interface
    Writer  // Embedded interface
}
```

### HTTP Handler Patterns

```go
package api

import (
    "encoding/json"
    "net/http"
    "github.com/gorilla/mux"
)

// Handler struct with dependencies
type Handler struct {
    service *UserService
    logger  *log.Logger
}

func NewHandler(service *UserService, logger *log.Logger) *Handler {
    return &Handler{
        service: service,
        logger:  logger,
    }
}

// Register routes
func (h *Handler) RegisterRoutes(r *mux.Router) {
    r.HandleFunc("/users", h.ListUsers).Methods(http.MethodGet)
    r.HandleFunc("/users/{id}", h.GetUser).Methods(http.MethodGet)
    r.HandleFunc("/users", h.CreateUser).Methods(http.MethodPost)
    r.HandleFunc("/users/{id}", h.UpdateUser).Methods(http.MethodPut)
    r.HandleFunc("/users/{id}", h.DeleteUser).Methods(http.MethodDelete)
}

// Handler with proper error handling
func (h *Handler) GetUser(w http.ResponseWriter, r *http.Request) {
    vars := mux.Vars(r)
    id := vars["id"]

    user, err := h.service.GetUser(r.Context(), id)
    if err != nil {
        h.handleError(w, err)
        return
    }

    h.respondJSON(w, http.StatusOK, user)
}

// Helper for JSON responses
func (h *Handler) respondJSON(w http.ResponseWriter, status int, data interface{}) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)

    if err := json.NewEncoder(w).Encode(data); err != nil {
        h.logger.Printf("failed to encode response: %v", err)
    }
}

// Helper for error responses
func (h *Handler) handleError(w http.ResponseWriter, err error) {
    h.logger.Printf("error: %v", err)

    status := http.StatusInternalServerError
    message := "Internal server error"

    if errors.Is(err, ErrUserNotFound) {
        status = http.StatusNotFound
        message = "User not found"
    } else if errors.Is(err, ErrInvalidInput) {
        status = http.StatusBadRequest
        message = err.Error()
    }

    h.respondJSON(w, status, map[string]string{"error": message})
}
```

## Stack-Specific Reviewer Additions

### Error Wrapping

```markdown
## Error Handling

- [ ] Errors wrapped with context using fmt.Errorf("%w", err)
- [ ] Sentinel errors defined as package-level variables
- [ ] Custom error types implement error interface
- [ ] errors.Is and errors.As used for error checking (not ==)
- [ ] Error messages provide actionable context
- [ ] Errors not ignored (no _ = err without comment)
```

### Goroutine Leaks

```markdown
## Concurrency Safety

- [ ] All goroutines have clear termination conditions
- [ ] Context cancellation propagated to goroutines
- [ ] sync.WaitGroup used for goroutine coordination
- [ ] Channels properly closed by sender
- [ ] No goroutines started without context or cancel mechanism
- [ ] Race detector passes (go test -race)
```

### Interface Segregation

```markdown
## Interface Design

- [ ] Interfaces defined by consumer, not producer
- [ ] Interfaces small and focused (1-3 methods ideal)
- [ ] Accept interfaces, return structs (where appropriate)
- [ ] No unnecessary interface abstractions
- [ ] Dependencies injected as interfaces
- [ ] Mock implementations available for testing
```

### Go Best Practices

```markdown
## Go Idioms

- [ ] Package names are lowercase, no underscores
- [ ] Exported names properly capitalized
- [ ] defer used for cleanup (Close, Unlock, etc.)
- [ ] Pointer receivers used consistently
- [ ] Table-driven tests for multiple cases
- [ ] Context as first parameter in functions
```

### Performance

```markdown
## Performance Considerations

- [ ] Unnecessary allocations avoided
- [ ] Strings concatenation uses strings.Builder for loops
- [ ] Benchmark tests for performance-critical code
- [ ] Profiling data reviewed for bottlenecks
- [ ] Goroutines not created in tight loops without pooling
- [ ] Database queries use prepared statements where appropriate
```

## Common Project Structures

### Standard Go Project Layout

```
myapp/
├── cmd/                 # Main applications
│   ├── server/
│   │   └── main.go      # Server entry point
│   └── worker/
│       └── main.go      # Worker entry point
├── internal/            # Private application code
│   ├── api/             # HTTP handlers
│   │   ├── handler.go
│   │   └── middleware.go
│   ├── service/         # Business logic
│   │   └── user.go
│   ├── repository/      # Data access
│   │   └── postgres.go
│   └── model/           # Domain models
│       └── user.go
├── pkg/                 # Public library code
│   └── logger/
│       └── logger.go
├── migrations/          # Database migrations
├── scripts/             # Build and deployment scripts
├── go.mod
└── go.sum
```

### Hexagonal/Clean Architecture

```
myapp/
├── cmd/
│   └── server/
│       └── main.go
├── internal/
│   ├── domain/          # Core business logic
│   │   ├── user.go      # Domain models
│   │   └── errors.go    # Domain errors
│   ├── ports/           # Interfaces
│   │   ├── repository.go
│   │   └── service.go
│   ├── adapters/        # Implementations
│   │   ├── http/        # HTTP adapter
│   │   ├── postgres/    # Database adapter
│   │   └── redis/       # Cache adapter
│   └── app/             # Application services
│       └── user_service.go
└── go.mod
```

## Environment Variables

```bash
# .env - Never commit this file
DATABASE_URL=postgres://user:password@localhost:5432/dbname?sslmode=disable
REDIS_URL=redis://localhost:6379/0
PORT=8080
LOG_LEVEL=info

# .env.example - Commit this as template
DATABASE_URL=postgres://user:password@localhost:5432/dbname?sslmode=disable
REDIS_URL=redis://localhost:6379/0
PORT=8080
LOG_LEVEL=debug
```

## Initialization Checklist

When setting up this stack for a project:

- [ ] Verify Go version (check go.mod or .go-version)
- [ ] Run go mod download to install dependencies
- [ ] Verify go.mod and go.sum are tidy
- [ ] Install golangci-lint for comprehensive linting
- [ ] Run initial verification to ensure setup is correct
- [ ] Configure editor for gofmt/goimports on save
- [ ] Verify all verification commands work
- [ ] Document any project-specific patterns in .claude/stacks/README.md
