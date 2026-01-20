# Trigger Detection Reference

Detailed patterns for detecting compound engineering triggers.

## Tool Error Detection

### Bash Command Errors

```yaml
detection:
  - exit_code: != 0
  - stderr: non-empty
  - output_contains:
    - "Error:"
    - "error:"
    - "FAILED"
    - "fatal:"
    - "command not found"
    - "No such file"
    - "Permission denied"
```

### Edit Tool Errors

```yaml
detection:
  - result_contains:
    - "old_string not found"
    - "File not found"
    - "Cannot edit"
```

### Write Tool Errors

```yaml
detection:
  - result_contains:
    - "Permission denied"
    - "Directory not found"
    - "File exists"
```

## User Correction Detection

### Strong Indicators (High Confidence)

```yaml
patterns:
  - "no, I meant"
  - "that's not what I asked"
  - "that's wrong"
  - "you misunderstood"
  - "I said"
  - "let me clarify"
```

### Moderate Indicators (Medium Confidence)

```yaml
patterns:
  - "actually"
  - "not quite"
  - "close, but"
  - "you're right, but"
  - "almost"
```

### Context Required (Low Confidence)

```yaml
patterns:
  - "hmm"
  - "interesting"
  - "wait"
```

## Self-Correction Detection

### Explicit Corrections

```yaml
patterns:
  - "I apologize"
  - "my mistake"
  - "I was wrong"
  - "let me correct"
  - "I should have"
  - "I missed"
```

### Implicit Corrections

```yaml
patterns:
  - "looking more closely"
  - "on second thought"
  - "I see now"
  - "actually, that's"
  - "I misread"
```

## Retry Detection

### Same Command Retry

Count identical or near-identical commands:

```yaml
same_command:
  threshold: 3
  window: 10_commands  # Look at last 10 commands
  similarity: 0.9      # 90% similar = retry
```

### Same File Retry

Multiple edits to same file with errors:

```yaml
same_file_edits:
  threshold: 3
  with_errors: true
```

### Same Operation Retry

Same operation type with different parameters:

```yaml
same_operation:
  - "grep for X" then "grep for Y" then "grep for Z"
  - Multiple read attempts on same file
  - Multiple edit attempts on same location
```

## Trigger Prioritization

### Priority Matrix

| Trigger Type | Count | Priority |
|--------------|-------|----------|
| Tool error + user correction | Any | Critical |
| User correction | 1+ | High |
| Tool error | 3+ | High |
| Self-correction | 1+ | Medium |
| Multiple retries | 3+ | Medium |
| Single tool error | 1 | Low |

### Filtering Non-Learnable Events

Skip triggers that are:

1. **Transient**: Network timeouts, temporary service issues
2. **Trivial**: Simple typos caught immediately
3. **Expected**: Known limitations, documented behavior
4. **Duplicate**: Same trigger already captured in session

## Implementation Notes

### Session Context Boundaries

Only analyze triggers within the current session context:

- Start: Session initialization
- End: Workflow completion or manual trigger

### Deduplication

Multiple related triggers should be grouped:

```yaml
grouping:
  - Same error message → single trigger
  - Same file, multiple errors → single trigger
  - User correction after self-correction → single trigger (user correction wins)
```

### Severity Escalation

Triggers can escalate:

```yaml
escalation:
  - 3+ retries: low → medium
  - User correction follows error: medium → high
  - Same error in different sessions: high → critical
```
