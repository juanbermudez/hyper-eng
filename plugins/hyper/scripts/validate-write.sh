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

resolve_hyper_bin() {
  local hyper_bin="${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft"
  if [[ -x "$hyper_bin" ]]; then
    echo "$hyper_bin"
    return
  fi

  hyper_bin="${CLAUDE_PLUGIN_ROOT}/binaries/hyper"
  if [[ -x "$hyper_bin" ]]; then
    echo "$hyper_bin"
    return
  fi

  echo "hypercraft"
}

resolve_workspace_root() {
  if [[ -n "$HYPER_WORKSPACE_ROOT" ]]; then
    echo "$HYPER_WORKSPACE_ROOT"
    return
  fi

  local hyper_bin
  hyper_bin="$(resolve_hyper_bin)"
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

# Check if file is in a Hyper-managed location:
# - Workspace root (if set)
# - Personal drive or other HyperHome locations (*.hyper/*)
IS_HYPER_FILE=false

if [[ -n "$WORKSPACE_ROOT" && "$FILE_PATH" == "$WORKSPACE_ROOT"/* ]]; then
  IS_HYPER_FILE=true
elif [[ "$FILE_PATH" == *".hyper/"* || "$FILE_PATH" == *"/.hyper/"* ]]; then
  # Personal drive, org drive, or other HyperHome files
  IS_HYPER_FILE=true
fi

if [[ "$IS_HYPER_FILE" != "true" ]]; then
  echo '{"decision": "allow"}'
  exit 0
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

# Get the script directory for locating Python validator
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_VALIDATOR="${SCRIPT_DIR}/validate-hyper-file.py"

# Try Python validator first (has PyYAML for robust parsing)
if [[ -x "$PYTHON_VALIDATOR" ]] || command -v python3 &>/dev/null; then
  # Write content to temp file for Python to read
  TEMP_FILE=$(mktemp)
  echo "$CONTENT" > "$TEMP_FILE"

  # Run Python validator in PreToolUse mode with timeout
  # 8-second timeout (hook timeout is 10s, leave buffer for cleanup)
  RESULT=$(timeout 8s python3 "$PYTHON_VALIDATOR" --pre-validate --path "$FILE_PATH" < "$TEMP_FILE" 2>&1)
  EXIT_CODE=$?
  rm -f "$TEMP_FILE"

  if [[ $EXIT_CODE -eq 0 ]]; then
    # Check if it was skipped (non-workspace file)
    SKIPPED=$(echo "$RESULT" | jq -r '.skipped // false' 2>/dev/null)
    if [[ "$SKIPPED" == "true" ]]; then
      echo '{"decision": "allow"}'
      exit 0
    fi
    echo '{"decision": "allow"}'
    exit 0
  else
    # Extract structured error for agent feedback
    ERROR_MSG=$(echo "$RESULT" | jq -r '.error.message // "Validation failed"' 2>/dev/null || echo "Validation failed")
    SUGGESTION=$(echo "$RESULT" | jq -r '.error.suggestion // ""' 2>/dev/null || echo "")
    FIRST_ERROR=$(echo "$RESULT" | jq -r '.error.context.errors[0].message // ""' 2>/dev/null || echo "")
    FIRST_FIX=$(echo "$RESULT" | jq -r '.error.context.errors[0].suggestion // ""' 2>/dev/null || echo "")

    # Build helpful error message
    if [[ -n "$FIRST_ERROR" ]]; then
      FULL_MSG="$FIRST_ERROR"
      if [[ -n "$FIRST_FIX" ]]; then
        FULL_MSG="$FULL_MSG. Fix: $FIRST_FIX"
      fi
    else
      FULL_MSG="$ERROR_MSG"
      if [[ -n "$SUGGESTION" ]]; then
        FULL_MSG="$FULL_MSG. Fix: $SUGGESTION"
      fi
    fi

    # Escape for JSON
    FULL_MSG=$(echo "$FULL_MSG" | sed 's/"/\\"/g')
    echo "{\"decision\": \"block\", \"reason\": \"$FULL_MSG\"}"
    exit 2
  fi
fi

# Fallback: Try Hypercraft CLI validation if Python not available
HYPER_BIN="$(resolve_hyper_bin)"
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

# Last resort fallback: basic frontmatter validation
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
    echo '{"decision": "block", "reason": "Project file missing required field: id. Fix: Add id: proj-your-project"}'
    exit 2
  fi
  if ! echo "$FRONTMATTER" | grep -q "^title:"; then
    echo '{"decision": "block", "reason": "Project file missing required field: title. Fix: Add title: Your Project Title"}'
    exit 2
  fi
  if ! echo "$FRONTMATTER" | grep -q "^type:"; then
    echo '{"decision": "block", "reason": "Project file missing required field: type. Fix: Add type: project"}'
    exit 2
  fi

elif [[ "$FILE_PATH" == *"/tasks/"*.mdx ]]; then
  # Task files need: id, title, type, parent
  if ! echo "$FRONTMATTER" | grep -q "^id:"; then
    echo '{"decision": "block", "reason": "Task file missing required field: id. Fix: Add id: task-001"}'
    exit 2
  fi
  if ! echo "$FRONTMATTER" | grep -q "^title:"; then
    echo '{"decision": "block", "reason": "Task file missing required field: title. Fix: Add title: Task Title"}'
    exit 2
  fi
  if ! echo "$FRONTMATTER" | grep -q "^type:"; then
    echo '{"decision": "block", "reason": "Task file missing required field: type. Fix: Add type: task"}'
    exit 2
  fi
  if ! echo "$FRONTMATTER" | grep -q "^parent:"; then
    echo '{"decision": "block", "reason": "Task file missing required field: parent. Fix: Add parent: proj-your-project"}'
    exit 2
  fi
fi

# Passed basic validation
echo '{"decision": "allow"}'
exit 0
