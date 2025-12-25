---
name: python
description: Python web stack (FastAPI, Django, Flask)
---

# Python Stack Configuration

This template configures hyper-engineering for Python projects using FastAPI, Django, or Flask.

## Verification Commands

### Automated Checks

```yaml
verification:
  lint:
    primary: "ruff check ."
    fallback: "flake8"
    description: "Run Ruff linter (fast Python linter)"
    fail_on_error: true

  format_check:
    primary: "ruff format --check ."
    fallback: "black --check ."
    description: "Check code formatting"
    fail_on_error: true

  typecheck:
    primary: "mypy ."
    fallback: "pyright"
    description: "Run type checker"
    fail_on_error: true

  test:
    primary: "pytest"
    fallback: "python -m pytest"
    description: "Run all tests"
    fail_on_error: true

  build:
    primary: "pip install -e ."
    fallback: "python -m pip install -e ."
    description: "Install package in editable mode"
    fail_on_error: true
```

### Optional Checks

```yaml
optional_verification:
  test_coverage:
    command: "pytest --cov=. --cov-report=term-missing"
    description: "Generate test coverage report"
    threshold: "80%"

  security:
    command: "bandit -r ."
    description: "Run security checks"

  complexity:
    command: "radon cc . -a"
    description: "Check code complexity"
    threshold: "B"
```

## Common Patterns

### FastAPI Route Patterns

```python
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel, Field
from typing import List, Optional
from sqlalchemy.orm import Session

app = FastAPI()

# Pydantic models for request/response validation
class UserCreate(BaseModel):
    email: str = Field(..., example="user@example.com")
    name: str = Field(..., min_length=1, max_length=100)
    age: Optional[int] = Field(None, ge=0, le=150)

class UserResponse(BaseModel):
    id: int
    email: str
    name: str
    age: Optional[int]

    class Config:
        from_attributes = True

# Dependency injection
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Route with proper typing and validation
@app.post("/users", response_model=UserResponse, status_code=201)
async def create_user(
    user: UserCreate,
    db: Session = Depends(get_db)
) -> UserResponse:
    """Create a new user."""
    db_user = User(**user.model_dump())
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

@app.get("/users/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: int,
    db: Session = Depends(get_db)
) -> UserResponse:
    """Get user by ID."""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
```

### Django Model Patterns

```python
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from typing import Optional

class TimeStampedModel(models.Model):
    """Abstract base model with created/updated timestamps."""
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True

class User(TimeStampedModel):
    """User model with proper constraints and validation."""
    email = models.EmailField(unique=True, db_index=True)
    name = models.CharField(max_length=100)
    age = models.IntegerField(
        null=True,
        blank=True,
        validators=[MinValueValidator(0), MaxValueValidator(150)]
    )
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'users'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['email', 'is_active']),
        ]

    def __str__(self) -> str:
        return f"{self.name} ({self.email})"

    def get_full_profile(self) -> dict:
        """Return complete user profile."""
        return {
            'id': self.id,
            'email': self.email,
            'name': self.name,
            'age': self.age,
            'created_at': self.created_at.isoformat(),
        }

# Django view with proper typing
from django.http import JsonResponse, HttpRequest
from django.views.decorators.http import require_http_methods
import json

@require_http_methods(["GET", "POST"])
def user_list(request: HttpRequest) -> JsonResponse:
    """List or create users."""
    if request.method == 'GET':
        users = User.objects.filter(is_active=True)
        return JsonResponse({
            'users': [user.get_full_profile() for user in users]
        })

    data = json.loads(request.body)
    user = User.objects.create(**data)
    return JsonResponse(user.get_full_profile(), status=201)
```

### Async/Await Patterns

```python
import asyncio
from typing import List
import httpx

# Async database operations (with SQLAlchemy)
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.future import select

async def get_user_async(db: AsyncSession, user_id: int) -> Optional[User]:
    """Fetch user asynchronously."""
    result = await db.execute(
        select(User).filter(User.id == user_id)
    )
    return result.scalar_one_or_none()

# Async HTTP requests
async def fetch_data(url: str) -> dict:
    """Fetch data from external API."""
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
        response.raise_for_status()
        return response.json()

# Concurrent operations
async def fetch_multiple_users(user_ids: List[int]) -> List[dict]:
    """Fetch multiple users concurrently."""
    tasks = [fetch_user(user_id) for user_id in user_ids]
    return await asyncio.gather(*tasks)

# Background tasks in FastAPI
from fastapi import BackgroundTasks

@app.post("/send-notification")
async def send_notification(
    email: str,
    background_tasks: BackgroundTasks
):
    """Send email notification in background."""
    background_tasks.add_task(send_email, email)
    return {"message": "Notification scheduled"}
```

### Pydantic Validation

```python
from pydantic import BaseModel, Field, field_validator, model_validator
from typing import Optional, List
from datetime import datetime

class UserBase(BaseModel):
    """Base user model with validation."""
    email: str = Field(..., pattern=r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
    name: str = Field(..., min_length=1, max_length=100)
    age: Optional[int] = Field(None, ge=0, le=150)
    tags: List[str] = Field(default_factory=list)

    @field_validator('email')
    @classmethod
    def email_must_be_lowercase(cls, v: str) -> str:
        """Ensure email is lowercase."""
        return v.lower()

    @field_validator('tags')
    @classmethod
    def tags_must_be_unique(cls, v: List[str]) -> List[str]:
        """Ensure tags are unique."""
        return list(set(v))

    @model_validator(mode='after')
    def check_age_for_tags(self) -> 'UserBase':
        """Validate age if certain tags are present."""
        if 'adult' in self.tags and (self.age is None or self.age < 18):
            raise ValueError("Users with 'adult' tag must be 18+")
        return self

class Config:
    from_attributes = True  # For ORM compatibility
    str_strip_whitespace = True
    validate_assignment = True
```

## Stack-Specific Reviewer Additions

### Type Hint Coverage

```markdown
## Python Type Hints

- [ ] All function signatures have type hints (params and return)
- [ ] No usage of `Any` type unless absolutely necessary
- [ ] Optional types used properly (not `Union[X, None]`)
- [ ] Complex types use proper generics (List[str], Dict[str, int])
- [ ] Type aliases defined for complex repeated types
- [ ] mypy --strict passes without errors
```

### Async Correctness

```markdown
## Async/Await Validation

- [ ] async functions properly awaited
- [ ] No blocking I/O in async functions
- [ ] Database sessions properly managed (async context managers)
- [ ] HTTP clients closed properly (async with)
- [ ] Background tasks don't block request handling
- [ ] Proper error handling in concurrent operations
```

### ORM Query Efficiency

```markdown
## Database Query Optimization

- [ ] N+1 queries avoided (use select_related/prefetch_related in Django)
- [ ] Eager loading used for related objects (joinedload in SQLAlchemy)
- [ ] Database indexes defined for filtered/sorted fields
- [ ] Pagination implemented for large datasets
- [ ] Query result sets limited appropriately
- [ ] No unnecessary database hits in loops
```

### FastAPI Best Practices

```markdown
## FastAPI Specific

- [ ] Pydantic models used for request/response validation
- [ ] Dependency injection used for database sessions
- [ ] Status codes explicitly set for all routes
- [ ] Response models defined for type safety
- [ ] OpenAPI documentation accurate (summary, description, tags)
- [ ] Background tasks used for non-blocking operations
```

### Django Best Practices

```markdown
## Django Specific

- [ ] Models have proper Meta class (ordering, indexes)
- [ ] Migrations are clean and reversible
- [ ] Queryset methods used instead of raw SQL
- [ ] Form validation used for user input
- [ ] CSRF protection not disabled without reason
- [ ] Static files properly configured
```

## Common Project Structures

### FastAPI Project

```
app/
├── main.py              # FastAPI app initialization
├── config.py            # Configuration settings
├── dependencies.py      # Dependency injection
├── models/              # SQLAlchemy models
│   ├── __init__.py
│   ├── user.py
│   └── post.py
├── schemas/             # Pydantic models
│   ├── __init__.py
│   ├── user.py
│   └── post.py
├── routers/             # API routes
│   ├── __init__.py
│   ├── users.py
│   └── posts.py
├── services/            # Business logic
│   ├── __init__.py
│   └── user_service.py
└── tests/
    ├── conftest.py      # Test fixtures
    └── test_users.py

alembic/                 # Database migrations
├── versions/
└── env.py
```

### Django Project

```
myproject/
├── manage.py
├── myproject/           # Project settings
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── apps/
│   ├── users/           # User app
│   │   ├── models.py
│   │   ├── views.py
│   │   ├── serializers.py  # DRF serializers
│   │   ├── urls.py
│   │   └── tests/
│   └── posts/           # Posts app
│       ├── models.py
│       ├── views.py
│       └── urls.py
├── templates/           # HTML templates
└── static/              # Static files
```

## Environment Variables

```bash
# .env - Never commit this file
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
SECRET_KEY=your-secret-key-here
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1

# .env.example - Commit this as template
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
SECRET_KEY=generate-a-secret-key
DEBUG=False
ALLOWED_HOSTS=
```

## Dependency Management

```yaml
# Detection order (first match wins)
dependency_managers:
  - file: "pyproject.toml"
    manager: "poetry"
    install: "poetry install"
    run: "poetry run"

  - file: "Pipfile"
    manager: "pipenv"
    install: "pipenv install --dev"
    run: "pipenv run"

  - file: "requirements.txt"
    manager: "pip"
    install: "pip install -r requirements.txt"
    run: ""
```

## Initialization Checklist

When setting up this stack for a project:

- [ ] Detect Python version (check .python-version or pyproject.toml)
- [ ] Create virtual environment (python -m venv venv)
- [ ] Activate virtual environment
- [ ] Detect dependency manager (poetry, pipenv, pip)
- [ ] Install dependencies
- [ ] Run database migrations if applicable
- [ ] Create .env from .env.example if it doesn't exist
- [ ] Run initial verification to ensure setup is correct
- [ ] Verify all verification commands work
- [ ] Document any project-specific patterns in .claude/stacks/README.md
