#!/bin/bash
# Track activity on .hyper/ file modifications
# Called by PostToolUse hook after Write|Edit operations

# Read PostToolUse JSON from stdin
INPUT=$(cat)

# Extract fields using jq
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
PARENT_SESSION=$(echo "$INPUT" | jq -r '.parent_session_id // empty')

# Skip if not a .hyper/ file
if [[ "$FILE_PATH" != *".hyper/"* ]]; then
  exit 0
fi

# Skip if not an .mdx file
if [[ "$FILE_PATH" != *.mdx ]]; then
  exit 0
fi

# Skip if no session ID
if [[ -z "$SESSION_ID" ]]; then
  exit 0
fi

# Build command with actor schema
CMD="${CLAUDE_PLUGIN_ROOT}/binaries/hyper activity add"
CMD="$CMD --file \"$FILE_PATH\""
CMD="$CMD --actor-type session"
CMD="$CMD --actor-id \"$SESSION_ID\""

# Add parent session if present (for sub-agents)
if [[ -n "$PARENT_SESSION" && "$PARENT_SESSION" != "null" ]]; then
  CMD="$CMD --parent-id \"$PARENT_SESSION\""
fi

# Action is always "modified" for automatic tracking
CMD="$CMD --action modified"

# Execute (silently fail - don't block agent)
eval $CMD 2>/dev/null || true
exit 0
