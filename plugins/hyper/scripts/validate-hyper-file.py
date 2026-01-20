#!/usr/bin/env python3
"""
Hyper File Validator
Validates MDX files in the workspace data root for correct frontmatter schema.
Runs as a PostToolUse hook after Write/Edit operations.
Can also be called directly for PreToolUse validation with --pre-validate flag.
"""

import json
import sys
import re
import os
import argparse

# Try to import PyYAML for robust parsing
try:
    import yaml
    HAS_PYYAML = True
except ImportError:
    HAS_PYYAML = False

# Valid enum values (must match Hypercraft schemas)
VALID_TYPES = ['initiative', 'project', 'task', 'resource', 'doc']
VALID_STATUSES = [
    # Task statuses
    'draft', 'todo', 'in-progress', 'review', 'complete', 'blocked', 'qa',
    # Project statuses
    'planned', 'completed', 'canceled'
]
VALID_PRIORITIES = ['urgent', 'high', 'medium', 'low']

# Schema definitions for different artifact types
SCHEMAS = {
    'project': {
        'required': ['id', 'title', 'type', 'status', 'priority'],
        'optional': ['summary', 'created', 'updated', 'tags'],
        'enums': {
            'type': ['project'],
            'status': ['planned', 'todo', 'in-progress', 'qa', 'completed', 'canceled'],
            'priority': VALID_PRIORITIES,
        },
    },
    'task': {
        'required': ['id', 'title', 'type', 'status', 'priority', 'parent'],
        'optional': ['depends_on', 'created', 'updated', 'tags', 'activity'],
        'enums': {
            'type': ['task'],
            'status': ['draft', 'todo', 'in-progress', 'qa', 'review', 'complete', 'blocked'],
            'priority': VALID_PRIORITIES,
        },
    },
    'initiative': {
        'required': ['id', 'title', 'type'],
        'optional': ['status', 'priority', 'created', 'updated', 'tags'],
        'enums': {
            'type': ['initiative'],
            'status': VALID_STATUSES,
            'priority': VALID_PRIORITIES,
        },
    },
    'resource': {
        'required': ['title'],
        'optional': ['id', 'type', 'created', 'updated'],
        'enums': {},
    },
    'doc': {
        'required': ['id', 'title'],
        'optional': ['type', 'created', 'updated', 'tags'],
        'enums': {
            'type': ['doc'],
        },
    },
    'note': {
        'required': ['id', 'title'],
        'optional': ['created', 'updated', 'icon', 'sortPosition', 'activity'],
        'enums': {},
    },
}

# Naming conventions
FILENAME_PATTERNS = {
    'project': r'^_project\.mdx$',
    'task': r'^(task|verify-task)-\d{3}\.mdx$',
    'initiative': r'^[a-z0-9-]+\.mdx$',
    'doc': r'^[a-z0-9-]+\.mdx$',
    'resource': r'^[a-z0-9-]+\.(md|mdx)$',
}


def parse_frontmatter(content: str) -> tuple:
    """Extract YAML frontmatter from MDX content using PyYAML if available."""
    if not content.startswith('---'):
        return {}, content, None

    parts = content.split('---', 2)
    if len(parts) < 3:
        return {}, content, None

    frontmatter_str = parts[1].strip()
    body = parts[2].strip() if len(parts) > 2 else ''

    # Use PyYAML for robust parsing
    if HAS_PYYAML:
        try:
            frontmatter = yaml.safe_load(frontmatter_str)
            if frontmatter is None:
                frontmatter = {}
            return frontmatter, body, None
        except yaml.YAMLError as e:
            # Return parse error with helpful context
            error_info = {
                'code': 'YAML_PARSE_ERROR',
                'message': f'Invalid YAML in frontmatter: {str(e)}',
                'suggestion': _get_yaml_fix_suggestion(str(e), frontmatter_str),
            }
            return {}, body, error_info

    # Fallback: Simple YAML parsing for basic cases
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

    return frontmatter, body, None


def _get_yaml_fix_suggestion(error_msg: str, yaml_str: str) -> str:
    """Generate a helpful fix suggestion based on the YAML error."""
    error_lower = error_msg.lower()

    # Check for common issues
    if 'found character' in error_lower and ':' in error_lower:
        # Likely unquoted colon issue
        return 'Values containing colons must be quoted. Example: id: "personal:note-123"'

    if 'expected' in error_lower and 'block' in error_lower:
        return 'Check indentation. YAML requires consistent spacing (2 spaces recommended).'

    if 'duplicate key' in error_lower:
        return 'Remove duplicate field names in frontmatter.'

    # Check for unquoted colons in values
    for line in yaml_str.split('\n'):
        if ':' in line:
            parts = line.split(':', 1)
            if len(parts) == 2:
                value = parts[1].strip()
                # If value has colon and isn't quoted
                if ':' in value and not (value.startswith('"') or value.startswith("'")):
                    field = parts[0].strip()
                    return f'The "{field}" field value contains a colon. Wrap it in quotes: {field}: "{value}"'

    return 'Check YAML syntax. Ensure proper quoting for special characters (: @ # etc.).'


def normalize_path(file_path: str) -> str:
    return file_path.replace('\\', '/').rstrip('/')


def resolve_workspace_root() -> str:
    root = os.environ.get('HYPER_WORKSPACE_ROOT', '').strip()
    if not root:
        return ''
    return normalize_path(root)


WORKSPACE_ROOT = resolve_workspace_root()


def is_workspace_file(file_path: str) -> bool:
    path = normalize_path(file_path)
    if WORKSPACE_ROOT:
        return path == WORKSPACE_ROOT or path.startswith(f"{WORKSPACE_ROOT}/")
    return '/.hyper/' in path


def infer_type_from_path(file_path: str) -> str:
    """Derive expected document type from file path."""
    path = normalize_path(file_path).lower()
    rel_path = path

    if WORKSPACE_ROOT and path.startswith(f"{WORKSPACE_ROOT}/"):
        rel_path = path[len(WORKSPACE_ROOT) + 1 :]
    elif '/workspaces/' in path:
        tail = path.split('/workspaces/', 1)[1]
        parts = tail.split('/', 1)
        if len(parts) == 2:
            rel_path = parts[1]
    elif '/.hyper/' in path:
        rel_path = path.split('/.hyper/', 1)[1]

    # Handle notes (personal drive or workspace notes)
    if rel_path.startswith('notes/'):
        return 'note'
    elif '/notes/' in rel_path:
        return 'note'
    elif rel_path.startswith('initiatives/'):
        return 'initiative'
    elif rel_path.startswith('projects/'):
        if rel_path.endswith('/_project.mdx'):
            return 'project'
        elif '/tasks/' in rel_path:
            return 'task'
        elif '/resources/' in rel_path:
            return 'resource'
    elif rel_path.startswith('docs/'):
        return 'doc'

    return None


def get_projects_dir() -> str:
    """Get the projects directory path."""
    if WORKSPACE_ROOT:
        return os.path.join(WORKSPACE_ROOT, 'projects')
    return ''


def list_project_ids() -> list:
    """List all available project IDs in the workspace."""
    projects_dir = get_projects_dir()
    if not projects_dir or not os.path.exists(projects_dir):
        return []

    project_ids = []
    try:
        for entry in os.listdir(projects_dir):
            project_path = os.path.join(projects_dir, entry, '_project.mdx')
            if os.path.isfile(project_path):
                try:
                    with open(project_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    fm, _, _ = parse_frontmatter(content)
                    if fm and 'id' in fm:
                        project_ids.append(fm['id'])
                except Exception:
                    pass
    except Exception:
        pass
    return project_ids


def list_task_ids_for_project(project_slug: str) -> list:
    """List all task IDs for a given project slug."""
    projects_dir = get_projects_dir()
    if not projects_dir:
        return []

    tasks_dir = os.path.join(projects_dir, project_slug, 'tasks')
    if not os.path.exists(tasks_dir):
        return []

    task_ids = []
    try:
        for entry in os.listdir(tasks_dir):
            if entry.endswith('.mdx'):
                task_path = os.path.join(tasks_dir, entry)
                try:
                    with open(task_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    fm, _, _ = parse_frontmatter(content)
                    if fm and 'id' in fm:
                        task_ids.append(fm['id'])
                except Exception:
                    pass
    except Exception:
        pass
    return task_ids


def get_project_slug_from_path(file_path: str) -> str:
    """Extract project slug from a file path."""
    path = normalize_path(file_path)
    # Look for pattern: .../projects/<slug>/...
    if '/projects/' in path:
        after_projects = path.split('/projects/', 1)[1]
        parts = after_projects.split('/')
        if parts:
            return parts[0]
    return ''


def get_task_dependencies(task_id: str, project_slug: str) -> list:
    """Get depends_on list for a task."""
    projects_dir = get_projects_dir()
    if not projects_dir:
        return []

    tasks_dir = os.path.join(projects_dir, project_slug, 'tasks')
    if not os.path.exists(tasks_dir):
        return []

    try:
        for entry in os.listdir(tasks_dir):
            if entry.endswith('.mdx'):
                task_path = os.path.join(tasks_dir, entry)
                try:
                    with open(task_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    fm, _, _ = parse_frontmatter(content)
                    if fm and fm.get('id') == task_id:
                        deps = fm.get('depends_on', [])
                        if isinstance(deps, list):
                            return deps
                        elif isinstance(deps, str):
                            return [deps]
                except Exception:
                    pass
    except Exception:
        pass
    return []


def detect_circular_dependency(task_id: str, depends_on: list, project_slug: str) -> str:
    """
    Detect if adding these dependencies would create a circular dependency.
    Returns the cycle path string if cycle found, empty string otherwise.
    """
    if not depends_on:
        return ''

    # Build dependency graph starting from the dependencies
    visited = set()
    path = [task_id]

    def dfs(current_id, current_path):
        if current_id in visited:
            return ''
        if current_id == task_id:
            # Found cycle back to original task
            return ' -> '.join(current_path + [current_id])

        visited.add(current_id)
        deps = get_task_dependencies(current_id, project_slug)
        for dep_id in deps:
            result = dfs(dep_id, current_path + [current_id])
            if result:
                return result
        return ''

    # Check each dependency
    for dep_id in depends_on:
        # Check if dep_id depends on task_id (direct cycle)
        dep_deps = get_task_dependencies(dep_id, project_slug)
        if task_id in dep_deps:
            return f"{task_id} -> {dep_id} -> {task_id}"

        # Check for indirect cycles
        visited.clear()
        result = dfs(dep_id, [task_id])
        if result:
            return result

    return ''


def validate_relationships(frontmatter: dict, expected_type: str, file_path: str) -> list:
    """Validate relationship fields (parent, depends_on, blocks)."""
    errors = []

    # Only validate relationships for tasks
    if expected_type != 'task':
        return errors

    project_slug = get_project_slug_from_path(file_path)
    task_id = frontmatter.get('id', '')

    # Validate parent field
    parent = frontmatter.get('parent')
    if parent:
        available_projects = list_project_ids()
        if available_projects and parent not in available_projects:
            errors.append({
                'code': 'INVALID_PARENT_REFERENCE',
                'field': 'parent',
                'message': f"Parent project '{parent}' does not exist",
                'suggestion': f"Available projects: {', '.join(available_projects[:5])}{'...' if len(available_projects) > 5 else ''}",
            })

    # Validate depends_on field
    depends_on = frontmatter.get('depends_on', [])
    if depends_on:
        if isinstance(depends_on, str):
            depends_on = [depends_on]

        if project_slug:
            available_tasks = list_task_ids_for_project(project_slug)
            if available_tasks:
                for dep_id in depends_on:
                    # Skip self-reference (will be caught by cycle detection)
                    if dep_id == task_id:
                        errors.append({
                            'code': 'SELF_DEPENDENCY',
                            'field': 'depends_on',
                            'message': f"Task cannot depend on itself",
                            'suggestion': 'Remove self-reference from depends_on',
                        })
                    elif dep_id not in available_tasks:
                        errors.append({
                            'code': 'INVALID_DEPENDENCY_REFERENCE',
                            'field': 'depends_on',
                            'message': f"Dependency '{dep_id}' does not exist in project",
                            'suggestion': f"Available tasks: {', '.join(available_tasks[:5])}{'...' if len(available_tasks) > 5 else ''}",
                        })

            # Check for circular dependencies
            if task_id:
                cycle = detect_circular_dependency(task_id, depends_on, project_slug)
                if cycle:
                    errors.append({
                        'code': 'CIRCULAR_DEPENDENCY',
                        'field': 'depends_on',
                        'message': f"Circular dependency detected: {cycle}",
                        'suggestion': 'Remove one of the dependencies to break the cycle',
                    })

    return errors


def validate_frontmatter(frontmatter: dict, expected_type: str, file_path: str) -> list:
    """Validate frontmatter against schema. Returns list of structured error dicts."""
    errors = []
    filename = os.path.basename(file_path)

    # Get schema for this type
    schema = SCHEMAS.get(expected_type, {})
    required_fields = schema.get('required', ['id', 'title'])
    enum_fields = schema.get('enums', {})

    # Check required fields
    for field in required_fields:
        if field not in frontmatter:
            suggestion = _get_field_suggestion(field, expected_type)
            errors.append({
                'code': 'MISSING_REQUIRED_FIELD',
                'field': field,
                'message': f"Missing required field: '{field}'",
                'suggestion': suggestion,
            })

    # Type validation
    doc_type = frontmatter.get('type')
    if doc_type:
        allowed_types = enum_fields.get('type', VALID_TYPES)
        if doc_type not in allowed_types:
            errors.append({
                'code': 'INVALID_ENUM_VALUE',
                'field': 'type',
                'message': f"Invalid type '{doc_type}'",
                'suggestion': f"Must be one of: {', '.join(allowed_types)}",
            })
        elif expected_type and doc_type != expected_type:
            errors.append({
                'code': 'TYPE_MISMATCH',
                'field': 'type',
                'message': f"Type '{doc_type}' doesn't match expected type '{expected_type}' for this location",
                'suggestion': f"Use type: {expected_type}",
            })

    # Status validation
    status = frontmatter.get('status')
    if status:
        allowed_statuses = enum_fields.get('status', VALID_STATUSES)
        if status not in allowed_statuses:
            errors.append({
                'code': 'INVALID_ENUM_VALUE',
                'field': 'status',
                'message': f"Invalid status '{status}'",
                'suggestion': f"Must be one of: {', '.join(allowed_statuses)}",
            })

    # Priority validation
    priority = frontmatter.get('priority')
    if priority:
        allowed_priorities = enum_fields.get('priority', VALID_PRIORITIES)
        if priority not in allowed_priorities:
            errors.append({
                'code': 'INVALID_ENUM_VALUE',
                'field': 'priority',
                'message': f"Invalid priority '{priority}'",
                'suggestion': f"Must be one of: {', '.join(allowed_priorities)}",
            })

    # Date format validation
    for date_field in ['created', 'updated']:
        date_value = frontmatter.get(date_field)
        if date_value:
            if not re.match(r'^\d{4}-\d{2}-\d{2}$', str(date_value)):
                errors.append({
                    'code': 'INVALID_DATE_FORMAT',
                    'field': date_field,
                    'message': f"Invalid date format for '{date_field}': '{date_value}'",
                    'suggestion': 'Use YYYY-MM-DD format (e.g., 2026-01-19)',
                })

    # ID format validation (must be quoted if contains colon)
    id_value = frontmatter.get('id')
    if id_value and isinstance(id_value, str):
        # Check if ID looks malformed (YAML might have truncated at colon)
        if id_value in ['personal', 'ws', 'proj', 'task']:
            errors.append({
                'code': 'MALFORMED_ID',
                'field': 'id',
                'message': f"ID '{id_value}' appears truncated (missing part after colon?)",
                'suggestion': 'IDs with colons must be quoted: id: "personal:my-note-123"',
            })

    # Validate relationships (parent, depends_on)
    relationship_errors = validate_relationships(frontmatter, expected_type, file_path)
    errors.extend(relationship_errors)

    return errors


def _get_field_suggestion(field: str, expected_type: str) -> str:
    """Get a helpful suggestion for a missing field."""
    suggestions = {
        'id': 'Add unique identifier. Example: id: "proj-my-project" (quote if contains colon)',
        'title': 'Add title field. Example: title: My Project Title',
        'type': f'Add type field. Example: type: {expected_type}' if expected_type else 'Add type field',
        'status': 'Add status field. Example: status: todo',
        'priority': 'Add priority field. Example: priority: high',
        'parent': 'Add parent field referencing the project. Example: parent: proj-my-project',
    }
    return suggestions.get(field, f'Add the {field} field')


def format_error_response(errors: list, file_path: str, expected_type: str) -> dict:
    """Format errors as structured JSON response."""
    return {
        'success': False,
        'error': {
            'code': 'SCHEMA_VALIDATION_FAILED',
            'message': f"Invalid frontmatter for {expected_type or 'file'} schema",
            'context': {
                'detected_schema': expected_type,
                'file_path': file_path,
                'errors': errors,
            },
            'suggestion': errors[0].get('suggestion', '') if errors else '',
        }
    }


def validate_content(file_path: str, content: str, output_json: bool = False) -> tuple:
    """
    Validate MDX content. Returns (is_valid, errors_or_none).
    If output_json is True, prints JSON and exits with appropriate code.
    """
    # Parse frontmatter
    frontmatter, body, parse_error = parse_frontmatter(content)

    # Check for YAML parse errors
    if parse_error:
        errors = [parse_error]
        if output_json:
            response = format_error_response(errors, file_path, infer_type_from_path(file_path))
            print(json.dumps(response))
            sys.exit(2)
        return False, errors

    if not frontmatter:
        errors = [{
            'code': 'MISSING_FRONTMATTER',
            'field': None,
            'message': 'File is missing YAML frontmatter',
            'suggestion': 'Add frontmatter block starting with --- and ending with ---',
        }]
        if output_json:
            response = format_error_response(errors, file_path, infer_type_from_path(file_path))
            print(json.dumps(response))
            sys.exit(2)
        return False, errors

    # Infer expected type from path
    expected_type = infer_type_from_path(file_path)

    # Validate against schema
    errors = validate_frontmatter(frontmatter, expected_type, file_path)

    if errors:
        if output_json:
            response = format_error_response(errors, file_path, expected_type)
            print(json.dumps(response))
            sys.exit(2)
        return False, errors

    # Success
    if output_json:
        print(json.dumps({'success': True, 'schema': expected_type}))
        sys.exit(0)
    return True, None


def main():
    # Check for PreToolUse validation mode (direct invocation)
    parser = argparse.ArgumentParser(description='Validate Hyper MDX files')
    parser.add_argument('--pre-validate', action='store_true',
                        help='Run in PreToolUse mode (validate before write)')
    parser.add_argument('--path', type=str, help='File path to validate')
    parser.add_argument('--content', type=str, help='Content to validate (reads from stdin if not provided)')
    parser.add_argument('--json', action='store_true', help='Output JSON response')

    # Try to parse args, but fall back to hook mode if no args
    args, remaining = parser.parse_known_args()

    # PreToolUse mode: validate content before writing
    if args.pre_validate or args.path:
        file_path = args.path
        if not file_path:
            print(json.dumps({'success': False, 'error': {'message': 'Missing --path argument'}}))
            sys.exit(2)

        # Get content from argument or stdin
        if args.content:
            content = args.content
        else:
            content = sys.stdin.read()

        # Skip non-workspace files
        if not is_workspace_file(file_path):
            print(json.dumps({'success': True, 'skipped': True, 'reason': 'Not a workspace file'}))
            sys.exit(0)

        # Skip non-MDX files
        if not file_path.endswith(('.mdx', '.md')):
            print(json.dumps({'success': True, 'skipped': True, 'reason': 'Not an MDX file'}))
            sys.exit(0)

        validate_content(file_path, content, output_json=True)
        return

    # PostToolUse hook mode: read from stdin JSON
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(1)

    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})
    file_path = tool_input.get("file_path", "")

    # Only validate workspace data files
    if not is_workspace_file(file_path):
        sys.exit(0)  # Not a workspace data file, skip

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
    frontmatter, body, parse_error = parse_frontmatter(content)

    if parse_error:
        # YAML parse error - show helpful message
        print(f"YAML Error in {os.path.basename(file_path)}:", file=sys.stderr)
        print(f"  {parse_error['message']}", file=sys.stderr)
        print(f"  Fix: {parse_error['suggestion']}", file=sys.stderr)
        # Don't block, just warn (PostToolUse)
        sys.exit(0)

    if not frontmatter:
        # Provide helpful feedback
        print(f"Warning: File {os.path.basename(file_path)} is missing YAML frontmatter.", file=sys.stderr)
        print("Expected format:", file=sys.stderr)
        print("---", file=sys.stderr)
        print('id: "unique-id"  # Quote if contains colon', file=sys.stderr)
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
            if isinstance(error, dict):
                print(f"  - {error['message']}", file=sys.stderr)
                if error.get('suggestion'):
                    print(f"    Fix: {error['suggestion']}", file=sys.stderr)
            else:
                print(f"  - {error}", file=sys.stderr)
        # Don't block, just warn
        sys.exit(0)

    # Success - silent
    sys.exit(0)


if __name__ == "__main__":
    main()
