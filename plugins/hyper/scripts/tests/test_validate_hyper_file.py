#!/usr/bin/env python3
"""
Unit tests for validate-hyper-file.py
Tests PyYAML schema validation for Hyper MDX files.
"""

import os
import sys
import unittest

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from importlib.util import spec_from_loader, module_from_spec
from importlib.machinery import SourceFileLoader

# Load the validator module (has hyphen in name)
validator_path = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    'validate-hyper-file.py'
)
loader = SourceFileLoader('validate_hyper_file', validator_path)
spec = spec_from_loader('validate_hyper_file', loader)
validator = module_from_spec(spec)
loader.exec_module(validator)


class TestParseYAMLFrontmatter(unittest.TestCase):
    """Test YAML frontmatter parsing with PyYAML."""

    def test_valid_simple_frontmatter(self):
        """Test parsing simple valid frontmatter."""
        content = '''---
id: proj-test
title: Test Project
type: project
status: todo
priority: high
---
# Content here
'''
        frontmatter, body, error = validator.parse_frontmatter(content)
        self.assertIsNone(error)
        self.assertEqual(frontmatter['id'], 'proj-test')
        self.assertEqual(frontmatter['title'], 'Test Project')
        self.assertEqual(frontmatter['type'], 'project')

    def test_quoted_id_with_colon(self):
        """Test that quoted IDs with colons are parsed correctly."""
        content = '''---
id: "personal:artifact-my-note-1234"
title: My Note
---
# Content
'''
        frontmatter, body, error = validator.parse_frontmatter(content)
        self.assertIsNone(error)
        self.assertEqual(frontmatter['id'], 'personal:artifact-my-note-1234')

    def test_unquoted_colon_space_error(self):
        """Test that unquoted colon-space in values produces a parse error."""
        # Note: id: personal:value works in YAML (no space after second colon)
        # But id: foo: bar fails (space after colon makes it look like a key)
        content = '''---
id: foo: bar
title: My Note
---
# Content
'''
        frontmatter, body, error = validator.parse_frontmatter(content)
        # PyYAML should catch this as invalid
        if validator.HAS_PYYAML:
            self.assertIsNotNone(error)
            self.assertEqual(error['code'], 'YAML_PARSE_ERROR')

    def test_unquoted_colon_no_space_works(self):
        """Test that unquoted colons without following space work fine."""
        # This is valid YAML - no space after the colon in the value
        content = '''---
id: personal:artifact-my-note-1234
title: My Note
---
# Content
'''
        frontmatter, body, error = validator.parse_frontmatter(content)
        self.assertIsNone(error)
        self.assertEqual(frontmatter['id'], 'personal:artifact-my-note-1234')

    def test_single_quoted_id_with_colon(self):
        """Test that single-quoted IDs with colons work."""
        content = """---
id: 'personal:artifact-my-note-1234'
title: My Note
---
# Content
"""
        frontmatter, body, error = validator.parse_frontmatter(content)
        self.assertIsNone(error)
        self.assertEqual(frontmatter['id'], 'personal:artifact-my-note-1234')

    def test_array_fields(self):
        """Test parsing array fields."""
        content = '''---
id: task-001
title: Test Task
type: task
status: todo
priority: high
parent: proj-test
depends_on:
  - task-000
tags:
  - feature
  - backend
---
# Content
'''
        frontmatter, body, error = validator.parse_frontmatter(content)
        self.assertIsNone(error)
        self.assertIn('task-000', frontmatter['depends_on'])
        self.assertIn('feature', frontmatter['tags'])
        self.assertIn('backend', frontmatter['tags'])

    def test_inline_array(self):
        """Test parsing inline array syntax."""
        content = '''---
id: task-001
title: Test Task
type: task
status: todo
priority: high
parent: proj-test
tags: [feature, backend]
---
# Content
'''
        frontmatter, body, error = validator.parse_frontmatter(content)
        self.assertIsNone(error)
        self.assertIn('feature', frontmatter['tags'])

    def test_multiline_body(self):
        """Test that body content is preserved."""
        content = '''---
id: test
title: Test
---
# Header

Paragraph 1.

Paragraph 2.
'''
        frontmatter, body, error = validator.parse_frontmatter(content)
        self.assertIsNone(error)
        self.assertIn('Header', body)
        self.assertIn('Paragraph 1', body)

    def test_no_frontmatter(self):
        """Test content without frontmatter."""
        content = '''# Just content
No frontmatter here.
'''
        frontmatter, body, error = validator.parse_frontmatter(content)
        self.assertIsNone(error)
        self.assertEqual(frontmatter, {})


class TestInferTypeFromPath(unittest.TestCase):
    """Test path-based type inference."""

    def test_project_path(self):
        """Test project file detection."""
        path = '/some/path/.hyper/projects/my-project/_project.mdx'
        self.assertEqual(validator.infer_type_from_path(path), 'project')

    def test_task_path(self):
        """Test task file detection."""
        path = '/some/path/.hyper/projects/my-project/tasks/task-001.mdx'
        self.assertEqual(validator.infer_type_from_path(path), 'task')

    def test_resource_path(self):
        """Test resource file detection."""
        path = '/some/path/.hyper/projects/my-project/resources/doc.md'
        self.assertEqual(validator.infer_type_from_path(path), 'resource')

    def test_note_path(self):
        """Test note file detection."""
        path = '/some/path/.hyper/notes/my-note.mdx'
        self.assertEqual(validator.infer_type_from_path(path), 'note')

    def test_nested_note_path(self):
        """Test nested note file detection."""
        path = '/some/path/.hyper/notes/folder/my-note.mdx'
        self.assertEqual(validator.infer_type_from_path(path), 'note')

    def test_doc_path(self):
        """Test doc file detection."""
        path = '/some/path/.hyper/docs/guide.mdx'
        self.assertEqual(validator.infer_type_from_path(path), 'doc')


class TestValidateFrontmatter(unittest.TestCase):
    """Test frontmatter validation against schemas."""

    def test_valid_project(self):
        """Test valid project frontmatter."""
        frontmatter = {
            'id': 'proj-test',
            'title': 'Test Project',
            'type': 'project',
            'status': 'todo',
            'priority': 'high',
        }
        errors = validator.validate_frontmatter(
            frontmatter, 'project', '/path/to/_project.mdx'
        )
        self.assertEqual(len(errors), 0)

    def test_missing_required_field(self):
        """Test missing required field detection."""
        frontmatter = {
            'id': 'proj-test',
            # Missing title
            'type': 'project',
            'status': 'todo',
            'priority': 'high',
        }
        errors = validator.validate_frontmatter(
            frontmatter, 'project', '/path/to/_project.mdx'
        )
        self.assertTrue(any(e['field'] == 'title' for e in errors))
        self.assertTrue(any(e['code'] == 'MISSING_REQUIRED_FIELD' for e in errors))

    def test_invalid_status(self):
        """Test invalid status value detection."""
        frontmatter = {
            'id': 'proj-test',
            'title': 'Test Project',
            'type': 'project',
            'status': 'invalid-status',
            'priority': 'high',
        }
        errors = validator.validate_frontmatter(
            frontmatter, 'project', '/path/to/_project.mdx'
        )
        self.assertTrue(any(e['field'] == 'status' for e in errors))
        self.assertTrue(any(e['code'] == 'INVALID_ENUM_VALUE' for e in errors))

    def test_invalid_priority(self):
        """Test invalid priority value detection."""
        frontmatter = {
            'id': 'proj-test',
            'title': 'Test Project',
            'type': 'project',
            'status': 'todo',
            'priority': 'super-urgent',  # Invalid
        }
        errors = validator.validate_frontmatter(
            frontmatter, 'project', '/path/to/_project.mdx'
        )
        self.assertTrue(any(e['field'] == 'priority' for e in errors))

    def test_task_missing_parent(self):
        """Test task missing parent field."""
        frontmatter = {
            'id': 'task-001',
            'title': 'Test Task',
            'type': 'task',
            'status': 'todo',
            'priority': 'high',
            # Missing parent
        }
        errors = validator.validate_frontmatter(
            frontmatter, 'task', '/path/to/task-001.mdx'
        )
        self.assertTrue(any(e['field'] == 'parent' for e in errors))

    def test_valid_note(self):
        """Test valid note frontmatter."""
        frontmatter = {
            'id': 'personal:artifact-my-note-1234',
            'title': 'My Note',
        }
        errors = validator.validate_frontmatter(
            frontmatter, 'note', '/path/to/notes/my-note.mdx'
        )
        self.assertEqual(len(errors), 0)

    def test_truncated_id_detection(self):
        """Test detection of truncated IDs (unquoted colon issue)."""
        frontmatter = {
            'id': 'personal',  # Truncated - missing :artifact-...
            'title': 'My Note',
        }
        errors = validator.validate_frontmatter(
            frontmatter, 'note', '/path/to/notes/my-note.mdx'
        )
        self.assertTrue(any(e['code'] == 'MALFORMED_ID' for e in errors))

    def test_invalid_date_format(self):
        """Test invalid date format detection."""
        frontmatter = {
            'id': 'proj-test',
            'title': 'Test Project',
            'type': 'project',
            'status': 'todo',
            'priority': 'high',
            'created': '01/19/2026',  # Wrong format
        }
        errors = validator.validate_frontmatter(
            frontmatter, 'project', '/path/to/_project.mdx'
        )
        self.assertTrue(any(e['field'] == 'created' for e in errors))
        self.assertTrue(any(e['code'] == 'INVALID_DATE_FORMAT' for e in errors))

    def test_type_mismatch(self):
        """Test type mismatch between frontmatter and path."""
        frontmatter = {
            'id': 'task-001',
            'title': 'Test',
            'type': 'task',  # Wrong - should be project
            'status': 'todo',
            'priority': 'high',
        }
        errors = validator.validate_frontmatter(
            frontmatter, 'project', '/path/to/_project.mdx'
        )
        # 'task' isn't in the project schema's allowed types, so it's INVALID_ENUM_VALUE
        self.assertTrue(any(e['field'] == 'type' for e in errors))
        self.assertTrue(any(e['code'] == 'INVALID_ENUM_VALUE' for e in errors))


class TestValidateContent(unittest.TestCase):
    """Test full content validation flow."""

    def test_valid_task_content(self):
        """Test validating complete valid task content."""
        content = '''---
id: task-001
title: Test Task
type: task
status: todo
priority: high
parent: proj-test
---
# Task Content
'''
        is_valid, errors = validator.validate_content(
            '/path/.hyper/projects/test/tasks/task-001.mdx',
            content,
            output_json=False
        )
        self.assertTrue(is_valid)
        self.assertIsNone(errors)

    def test_invalid_yaml_content(self):
        """Test validation catches YAML errors."""
        # Use colon-space in value which is invalid YAML
        content = '''---
id: foo: bar
title: Test
---
# Content
'''
        is_valid, errors = validator.validate_content(
            '/path/.hyper/notes/test.mdx',
            content,
            output_json=False
        )
        if validator.HAS_PYYAML:
            self.assertFalse(is_valid)
            self.assertIsNotNone(errors)
            self.assertEqual(errors[0]['code'], 'YAML_PARSE_ERROR')


class TestGetYamlFixSuggestion(unittest.TestCase):
    """Test fix suggestion generation."""

    def test_colon_suggestion(self):
        """Test suggestion for unquoted colon."""
        yaml_str = 'id: personal:note-123'
        suggestion = validator._get_yaml_fix_suggestion(
            'found character that cannot start',
            yaml_str
        )
        self.assertIn('colon', suggestion.lower())
        self.assertIn('quote', suggestion.lower())


if __name__ == '__main__':
    unittest.main()
