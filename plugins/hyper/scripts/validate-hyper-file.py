#!/usr/bin/env python3
"""
Hyper File Validator
Validates MDX files in .hyper/ directory for correct frontmatter schema.
Runs as a PostToolUse hook after Write/Edit operations.
"""

import json
import sys
import re
import os

# Valid enum values (must match Hyper Control schemas)
VALID_TYPES = ['initiative', 'project', 'task', 'resource', 'doc']
VALID_STATUSES = [
    # Task statuses
    'draft', 'todo', 'in-progress', 'review', 'complete', 'blocked',
    # Project statuses
    'planned', 'completed', 'canceled'
]
VALID_PRIORITIES = ['urgent', 'high', 'medium', 'low']

# Naming conventions
FILENAME_PATTERNS = {
    'project': r'^_project\.mdx$',
    'task': r'^(task|verify-task)-\d{3}\.mdx$',
    'initiative': r'^[a-z0-9-]+\.mdx$',
    'doc': r'^[a-z0-9-]+\.mdx$',
    'resource': r'^[a-z0-9-]+\.(md|mdx)$',
}


def parse_frontmatter(content: str) -> tuple:
    """Extract YAML frontmatter from MDX content."""
    if not content.startswith('---'):
        return {}, content

    parts = content.split('---', 2)
    if len(parts) < 3:
        return {}, content

    frontmatter_str = parts[1].strip()
    body = parts[2].strip()

    # Simple YAML parsing for our use case
    frontmatter = {}
    current_array_key = None

    for line in frontmatter_str.split('\n'):
        stripped = line.strip()

        # Handle array items
        if stripped.startswith('- ') and current_array_key:
            value = stripped[2:].strip().strip('"\'')
            if current_array_key not in frontmatter:
                frontmatter[current_array_key] = []
            frontmatter[current_array_key].append(value)
            continue

        # Reset array context on non-array line
        if not stripped.startswith('- '):
            current_array_key = None

        if ':' in line and not stripped.startswith('-'):
            key, value = line.split(':', 1)
            key = key.strip()
            value = value.strip().strip('"\'')

            # Handle inline arrays
            if value.startswith('['):
                value = [v.strip().strip('"\'') for v in value[1:-1].split(',') if v.strip()]
                frontmatter[key] = value
            elif value == '':
                # Might be a multi-line array
                current_array_key = key
            else:
                frontmatter[key] = value

    return frontmatter, body


def infer_type_from_path(file_path: str) -> str:
    """Derive expected document type from file path."""
    path = file_path.replace('\\', '/').lower()

    if '/.hyper/initiatives/' in path:
        return 'initiative'
    elif '/.hyper/projects/' in path:
        if path.endswith('/_project.mdx'):
            return 'project'
        elif '/tasks/' in path:
            return 'task'
        elif '/resources/' in path:
            return 'resource'
    elif '/.hyper/docs/' in path:
        return 'doc'

    return None


def validate_frontmatter(frontmatter: dict, expected_type: str, file_path: str) -> list:
    """Validate frontmatter against schema. Returns list of error messages."""
    errors = []
    filename = os.path.basename(file_path)

    # Required fields
    if 'id' not in frontmatter:
        errors.append("Missing required field: 'id'")

    if 'title' not in frontmatter:
        errors.append("Missing required field: 'title'")

    # Type validation
    doc_type = frontmatter.get('type')
    if doc_type:
        if doc_type not in VALID_TYPES:
            errors.append(f"Invalid type '{doc_type}'. Must be one of: {', '.join(VALID_TYPES)}")
        elif expected_type and doc_type != expected_type:
            errors.append(f"Type '{doc_type}' doesn't match expected type '{expected_type}' based on file location")
    elif expected_type:
        errors.append(f"Missing 'type' field. Expected: '{expected_type}'")

    # Status validation
    status = frontmatter.get('status')
    if status and status not in VALID_STATUSES:
        errors.append(f"Invalid status '{status}'. Must be one of: {', '.join(VALID_STATUSES)}")

    # Priority validation
    priority = frontmatter.get('priority')
    if priority and priority not in VALID_PRIORITIES:
        errors.append(f"Invalid priority '{priority}'. Must be one of: {', '.join(VALID_PRIORITIES)}")

    # Date format validation
    for date_field in ['created', 'updated']:
        date_value = frontmatter.get(date_field)
        if date_value:
            if not re.match(r'^\d{4}-\d{2}-\d{2}$', str(date_value)):
                errors.append(f"Invalid date format for '{date_field}': '{date_value}'. Use YYYY-MM-DD")

    # Filename convention check (warning only, not blocking)
    if expected_type and expected_type in FILENAME_PATTERNS:
        pattern = FILENAME_PATTERNS[expected_type]
        if not re.match(pattern, filename):
            # This is informational, not an error
            pass

    # Task-specific validation
    if expected_type == 'task':
        if 'parent' not in frontmatter:
            errors.append("Task missing 'parent' field (should reference parent project)")

    # Project-specific validation
    if expected_type == 'project':
        if 'summary' not in frontmatter:
            # Warning, not blocking
            pass

    return errors


def main():
    # Read hook input from stdin
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(1)

    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})
    file_path = tool_input.get("file_path", "")

    # Only validate .hyper/ files
    if '/.hyper/' not in file_path:
        sys.exit(0)  # Not a .hyper file, skip

    # Only validate MDX/MD files
    if not file_path.endswith(('.mdx', '.md')):
        sys.exit(0)

    # Skip workspace.json
    if file_path.endswith('workspace.json'):
        sys.exit(0)

    # Read the file content
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        # File was deleted or moved, that's okay
        sys.exit(0)
    except Exception as e:
        print(f"Error reading file: {e}", file=sys.stderr)
        sys.exit(1)

    # Parse frontmatter
    frontmatter, body = parse_frontmatter(content)

    if not frontmatter:
        # Provide helpful feedback
        print(f"Warning: File {os.path.basename(file_path)} is missing YAML frontmatter.", file=sys.stderr)
        print("Expected format:", file=sys.stderr)
        print("---", file=sys.stderr)
        print("id: unique-id", file=sys.stderr)
        print("title: Document Title", file=sys.stderr)
        print("type: task|project|initiative|doc|resource", file=sys.stderr)
        print("status: todo|in-progress|complete|...", file=sys.stderr)
        print("---", file=sys.stderr)
        # Don't block, just warn
        sys.exit(0)

    # Infer expected type from path
    expected_type = infer_type_from_path(file_path)

    # Validate
    errors = validate_frontmatter(frontmatter, expected_type, file_path)

    if errors:
        print(f"Validation warnings in {os.path.basename(file_path)}:", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)
        # Don't block, just warn
        sys.exit(0)

    # Success - silent
    sys.exit(0)


if __name__ == "__main__":
    main()
