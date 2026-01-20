# Sub-Agent Output Contracts

All hyper sub-agents MUST return structured responses following these output contracts. This enables orchestrators to reliably parse results, track artifacts, and coordinate multi-agent workflows.

## Standard Response Format

Every sub-agent response MUST include a JSON block with this structure:

```json
{
  "meta": {
    "agent_name": "string",
    "status": "complete|partial|error",
    "execution_time_ms": number
  },
  "artifacts": [
    {
      "type": "document|code|data",
      "path": "string",
      "summary": "string (1-2 sentences)",
      "key_points": ["string", "..."]
    }
  ],
  "next_steps": ["string", "..."]
}
```

## Field Specifications

### meta (Required)

| Field | Type | Description |
|-------|------|-------------|
| `agent_name` | string | Agent identifier (e.g., `"repo-research-analyst"`) |
| `status` | enum | Execution status: `"complete"`, `"partial"`, or `"error"` |
| `execution_time_ms` | number | Execution time in milliseconds |

Status values:
- `complete` - All objectives achieved
- `partial` - Some objectives achieved, others blocked or skipped
- `error` - Critical failure, unable to proceed

### artifacts (Required, may be empty)

Array of artifacts created during execution:

| Field | Type | Description |
|-------|------|-------------|
| `type` | enum | Artifact type: `"document"`, `"code"`, or `"data"` |
| `path` | string | Relative path from `$HYPER_WORKSPACE_ROOT/` |
| `summary` | string | Brief description (1-2 sentences max) |
| `key_points` | string[] | 3-5 key findings or highlights |

Artifact types:
- `document` - Markdown/MDX files (research, specs, docs)
- `code` - Source code files created or modified
- `data` - JSON, YAML, or other data files

### next_steps (Required, may be empty)

Array of recommended follow-up actions. Use imperative form:
- "Research OAuth provider documentation"
- "Create task for database migration"
- "Review security implications"

## Examples by Agent Type

### Research Agents

```json
{
  "meta": {
    "agent_name": "repo-research-analyst",
    "status": "complete",
    "execution_time_ms": 15230
  },
  "artifacts": [
    {
      "type": "document",
      "path": "projects/auth-system/resources/research/codebase-analysis.md",
      "summary": "Analysis of existing authentication patterns in the codebase",
      "key_points": [
        "JWT tokens used for session management",
        "No existing OAuth integration found",
        "User model at src/models/user.ts supports external auth IDs",
        "Authentication middleware in src/middleware/auth.ts"
      ]
    }
  ],
  "next_steps": [
    "Research OAuth provider SDKs for Google and GitHub",
    "Review JWT token expiration strategy",
    "Check for existing social login UI components"
  ]
}
```

### Implementation Agents

```json
{
  "meta": {
    "agent_name": "implementation-orchestrator",
    "status": "complete",
    "execution_time_ms": 45000
  },
  "artifacts": [
    {
      "type": "code",
      "path": "src/auth/oauth-provider.ts",
      "summary": "OAuth provider abstraction supporting Google and GitHub",
      "key_points": [
        "Implements OAuthProvider interface",
        "Token refresh handled automatically",
        "Environment-based configuration"
      ]
    },
    {
      "type": "code",
      "path": "src/auth/oauth-callback.ts",
      "summary": "OAuth callback handler for authentication flow",
      "key_points": [
        "Handles code exchange",
        "Creates or updates user records",
        "Issues JWT session tokens"
      ]
    }
  ],
  "next_steps": [
    "Run lint and typecheck",
    "Add unit tests for OAuth flow",
    "Test with staging OAuth credentials"
  ]
}
```

### Verification Agents

```json
{
  "meta": {
    "agent_name": "web-app-debugger",
    "status": "partial",
    "execution_time_ms": 8500
  },
  "artifacts": [
    {
      "type": "data",
      "path": "projects/auth-system/resources/verification/browser-test-results.json",
      "summary": "Browser test results for OAuth login flow",
      "key_points": [
        "Google login redirects correctly",
        "GitHub login button not visible on mobile",
        "Session persists across page refresh"
      ]
    }
  ],
  "next_steps": [
    "Fix GitHub login button responsive styling",
    "Rerun mobile viewport tests"
  ]
}
```

### Error Response

```json
{
  "meta": {
    "agent_name": "framework-docs-researcher",
    "status": "error",
    "execution_time_ms": 3200
  },
  "artifacts": [],
  "next_steps": [
    "Retry with alternative documentation sources",
    "Check network connectivity",
    "Verify MCP server configuration"
  ],
  "error": {
    "code": "MCP_CONNECTION_FAILED",
    "message": "Unable to connect to Context7 MCP server",
    "details": "Connection timeout after 3000ms"
  }
}
```

## Response Location

Sub-agents should output their JSON response:

1. **In the final message** - As a fenced JSON code block
2. **Tagged for parsing** - Use `json` fence with comment marker

Example output format:

```markdown
## Research Complete

I've analyzed the codebase for authentication patterns.

### Findings

[Detailed explanation here...]

### Structured Output

<!-- AGENT_OUTPUT_START -->
```json
{
  "meta": { ... },
  "artifacts": [ ... ],
  "next_steps": [ ... ]
}
```
<!-- AGENT_OUTPUT_END -->
```

## Orchestrator Expectations

Orchestrators (research-orchestrator, implementation-orchestrator) expect:

1. **All sub-agents return valid JSON** matching this contract
2. **Artifacts are written to disk** before reporting
3. **Partial status** includes explanation in `next_steps`
4. **Error status** includes `error` object with details

## Validation Checklist

Before returning, verify:

- [ ] `meta.agent_name` matches your agent file name
- [ ] `meta.status` accurately reflects execution result
- [ ] All `artifacts` have been written to disk
- [ ] `artifacts[].path` is relative to `$HYPER_WORKSPACE_ROOT/`
- [ ] `artifacts[].summary` is concise (1-2 sentences)
- [ ] `next_steps` uses imperative form
- [ ] JSON is valid and properly formatted

## TypeScript Schema

```typescript
interface AgentOutput {
  meta: {
    agent_name: string;
    status: 'complete' | 'partial' | 'error';
    execution_time_ms: number;
  };
  artifacts: Array<{
    type: 'document' | 'code' | 'data';
    path: string;
    summary: string;
    key_points: string[];
  }>;
  next_steps: string[];
  error?: {
    code: string;
    message: string;
    details?: string;
  };
}
```

## Integration with Activity Tracking

When artifacts are written, the PostToolUse hook automatically tracks activity. Sub-agents do NOT need to manually log activity - the hook captures:

- Session ID
- Parent session (for sub-agents)
- File path and operation type
- Timestamp

This activity appears in the `activity` array in affected file frontmatter.
