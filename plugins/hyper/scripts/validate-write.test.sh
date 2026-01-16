#!/bin/bash
# Tests for validate-write.sh PreToolUse hook
#
# Run with: bash validate-write.test.sh
# All tests should output PASS

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VALIDATE_SCRIPT="$SCRIPT_DIR/validate-write.sh"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

pass_count=0
fail_count=0

assert_allow() {
  local test_name="$1"
  local input="$2"

  local output
  output=$(echo "$input" | bash "$VALIDATE_SCRIPT" 2>/dev/null)
  local exit_code=$?

  if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q '"decision": "allow"'; then
    echo -e "${GREEN}PASS${NC}: $test_name"
    ((pass_count++))
  else
    echo -e "${RED}FAIL${NC}: $test_name (expected allow, got exit=$exit_code output=$output)"
    ((fail_count++))
  fi
}

assert_block() {
  local test_name="$1"
  local input="$2"
  local expected_reason="$3"

  local output
  output=$(echo "$input" | bash "$VALIDATE_SCRIPT" 2>/dev/null)
  local exit_code=$?

  if [[ $exit_code -eq 2 ]] && echo "$output" | grep -q '"decision": "block"'; then
    if [[ -z "$expected_reason" ]] || echo "$output" | grep -q "$expected_reason"; then
      echo -e "${GREEN}PASS${NC}: $test_name"
      ((pass_count++))
    else
      echo -e "${RED}FAIL${NC}: $test_name (block but wrong reason: $output)"
      ((fail_count++))
    fi
  else
    echo -e "${RED}FAIL${NC}: $test_name (expected block, got exit=$exit_code output=$output)"
    ((fail_count++))
  fi
}

echo "=== validate-write.sh tests ==="
echo ""

# Test 1: Non-.hyper path should be allowed
assert_allow "Non-.hyper path passes through" \
  '{"tool_name": "Write", "tool_input": {"file_path": "/some/other/path/file.ts", "content": "code"}}'

# Test 2: Non-MDX file in .hyper should be allowed
assert_allow "Non-MDX file in .hyper allowed" \
  '{"tool_name": "Write", "tool_input": {"file_path": "/project/.hyper/workspace.json", "content": "{}"}}'

# Test 3: MDX with valid frontmatter should be allowed
assert_allow "Valid MDX frontmatter allowed" \
  '{"tool_name": "Write", "tool_input": {"file_path": "/project/.hyper/projects/test/_project.mdx", "content": "---\nid: proj-test\ntitle: Test\ntype: project\nstatus: planned\n---\n\nContent"}}'

# Test 4: MDX without frontmatter should be blocked
# Note: In JSON, \n is an escape sequence. Use \\n for literal or proper JSON encoding
assert_block "MDX without frontmatter blocked" \
  '{"tool_name": "Write", "tool_input": {"file_path": "/project/.hyper/projects/test/_project.mdx", "content": "# No frontmatter"}}' \
  "frontmatter"

# Test 5: Project file missing id should be blocked (if CLI available)
# This test depends on the hyper CLI being available
if [[ -x "${CLAUDE_PLUGIN_ROOT:-/nonexistent}/binaries/hyper" ]]; then
  assert_block "Project missing id blocked" \
    '{"tool_name": "Write", "tool_input": {"file_path": "/project/.hyper/projects/test/_project.mdx", "content": "---\ntitle: Test\ntype: project\n---\n\nContent"}}' \
    "id"
fi

# Test 6: Task file with valid frontmatter passes basic validation
# Note: Basic validation only checks for frontmatter existence and specific required fields
# The full validation (with CLI) checks schema compliance
assert_allow "Task with basic required fields allowed" \
  '{"tool_name": "Write", "tool_input": {"file_path": "/project/.hyper/projects/test/tasks/task-001.mdx", "content": "---\nid: task-001\ntitle: Task\ntype: task\nparent: proj-test\n---\nContent"}}'

# Test 7: Empty file_path should allow (safety fallback)
assert_allow "Empty file_path allows" \
  '{"tool_name": "Write", "tool_input": {"content": "test"}}'

# Test 8: Edit without content should allow (PostToolUse will validate)
assert_allow "Edit without content allows" \
  '{"tool_name": "Edit", "tool_input": {"file_path": "/project/.hyper/test.mdx"}}'

echo ""
echo "=== Results ==="
echo -e "Passed: ${GREEN}$pass_count${NC}"
echo -e "Failed: ${RED}$fail_count${NC}"

if [[ $fail_count -gt 0 ]]; then
  exit 1
fi
exit 0
