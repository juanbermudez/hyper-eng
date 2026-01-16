#!/bin/bash
# PreToolUse validation for workspace data root file writes
# Called BEFORE Write|Edit operations - can BLOCK invalid writes
#
# Exit codes:
#   0 = Allow the write
#   2 = Block the write with feedback
#
# Input format (stdin JSON):
# {
#   "session_id": "abc123",
#   "tool_name": "Write",
#   "tool_input": {
#     "file_path": "$HYPER_WORKSPACE_ROOT/projects/x/_project.mdx",
#     "content": "..."
#   }
# }

# Read PreToolUse JSON from stdin
INPUT=$(cat)

# Extract file_path from tool_input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# If no file path, allow (shouldn't happen but be safe)
if [[ -z "$FILE_PATH" ]]; then
  echo '{"decision": "allow"}'
  exit 0
fi

resolve_workspace_root() {
  if [[ -n "$HYPER_WORKSPACE_ROOT" ]]; then
    echo "$HYPER_WORKSPACE_ROOT"
    return
  fi

  local hyper_bin="${CLAUDE_PLUGIN_ROOT}/binaries/hyper"
  if [[ -x "$hyper_bin" ]]; then
    local resolved
    resolved=$("$hyper_bin" config get globalPath 2>/dev/null || true)
    if [[ -n "$resolved" && "$resolved" != "null" ]]; then
      echo "$resolved"
      return
    fi
  fi

  if [[ -d ".hyper" ]]; then
    echo "$PWD/.hyper"
    return
  fi

  echo ""
}

WORKSPACE_ROOT="$(resolve_workspace_root)"
WORKSPACE_ROOT="${WORKSPACE_ROOT%/}"

# Only validate workspace data root paths - passthrough all others
if [[ -n "$WORKSPACE_ROOT" ]]; then
  case "$FILE_PATH" in
    "$WORKSPACE_ROOT"/*) ;;
    *) echo '{"decision": "allow"}'; exit 0 ;;
  esac
else
  if [[ "$FILE_PATH" != *".hyper/"* && "$FILE_PATH" != *"/.hyper/"* ]]; then
    echo '{"decision": "allow"}'
    exit 0
  fi
fi

# Only validate .mdx files within the workspace data root
if [[ "$FILE_PATH" != *.mdx ]]; then
  echo '{"decision": "allow"}'
  exit 0
fi

# Get content to validate
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')

# If no content (Edit operation), allow - PostToolUse will validate after
if [[ -z "$CONTENT" ]]; then
  echo '{"decision": "allow"}'
  exit 0
fi

# Try to use hyper CLI for validation if available
HYPER_BIN="${CLAUDE_PLUGIN_ROOT}/binaries/hyper"
if [[ -x "$HYPER_BIN" ]]; then
  # Use CLI validation
  RESULT=$("$HYPER_BIN" file validate --path "$FILE_PATH" --content "$CONTENT" --json 2>&1)
  EXIT_CODE=$?

  if [[ $EXIT_CODE -eq 0 ]]; then
    echo '{"decision": "allow"}'
    exit 0
  else
    # Extract error message from CLI output
    ERROR_MSG=$(echo "$RESULT" | jq -r '.error.message // .message // "Validation failed"' 2>/dev/null || echo "Validation failed")
    echo "{\"decision\": \"block\", \"reason\": \"$ERROR_MSG\"}"
    exit 2
  fi
fi

# Fallback: basic frontmatter validation without CLI
# Check if content starts with frontmatter
if [[ "$CONTENT" != "---"* ]]; then
  # MDX files in the workspace data root should have frontmatter
  FILENAME=$(basename "$FILE_PATH")

  # Skip check for certain files that don't need frontmatter
  case "$FILENAME" in
    workspace.json|*.yaml|*.yml|*.json|*.md)
      echo '{"decision": "allow"}'
      exit 0
      ;;
  esac

  echo '{"decision": "block", "reason": "MDX files in the workspace data root must have YAML frontmatter (start with ---)"}'
  exit 2
fi

# Basic frontmatter field extraction
FRONTMATTER=$(echo "$CONTENT" | sed -n '/^---$/,/^---$/p' | sed '1d;$d')

# Check for required fields based on path
if [[ "$FILE_PATH" == *"/projects/"*"/_project.mdx" ]]; then
  # Project files need: id, title, type, status
  if ! echo "$FRONTMATTER" | grep -q "^id:"; then
    echo '{"decision": "block", "reason": "Project file missing required field: id"}'
    exit 2
  fi
  if ! echo "$FRONTMATTER" | grep -q "^title:"; then
    echo '{"decision": "block", "reason": "Project file missing required field: title"}'
    exit 2
  fi
  if ! echo "$FRONTMATTER" | grep -q "^type:"; then
    echo '{"decision": "block", "reason": "Project file missing required field: type"}'
    exit 2
  fi

elif [[ "$FILE_PATH" == *"/tasks/"*.mdx ]]; then
  # Task files need: id, title, type, parent
  if ! echo "$FRONTMATTER" | grep -q "^id:"; then
    echo '{"decision": "block", "reason": "Task file missing required field: id"}'
    exit 2
  fi
  if ! echo "$FRONTMATTER" | grep -q "^title:"; then
    echo '{"decision": "block", "reason": "Task file missing required field: title"}'
    exit 2
  fi
  if ! echo "$FRONTMATTER" | grep -q "^type:"; then
    echo '{"decision": "block", "reason": "Task file missing required field: type"}'
    exit 2
  fi
  if ! echo "$FRONTMATTER" | grep -q "^parent:"; then
    echo '{"decision": "block", "reason": "Task file missing required field: parent"}'
    exit 2
  fi
fi

# Passed basic validation
echo '{"decision": "allow"}'
exit 0
