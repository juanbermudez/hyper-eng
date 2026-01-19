#!/usr/bin/env python3
"""
Unit tests for relationship validation in validate-hyper-file.py
Tests parent, depends_on, and circular dependency validation.
"""

import os
import sys
import tempfile
import shutil
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


class TestRelationshipValidation(unittest.TestCase):
    """Test relationship validation for tasks."""

    def setUp(self):
        """Create a temporary workspace with projects and tasks."""
        self.temp_dir = tempfile.mkdtemp()
        self.projects_dir = os.path.join(self.temp_dir, 'projects')
        os.makedirs(self.projects_dir)

        # Create test project
        self.project_slug = 'test-project'
        project_dir = os.path.join(self.projects_dir, self.project_slug)
        os.makedirs(project_dir)

        # Create _project.mdx
        project_content = '''---
id: proj-test-project
title: Test Project
type: project
status: todo
priority: high
---
# Test Project
'''
        with open(os.path.join(project_dir, '_project.mdx'), 'w') as f:
            f.write(project_content)

        # Create tasks directory
        tasks_dir = os.path.join(project_dir, 'tasks')
        os.makedirs(tasks_dir)

        # Create task-001.mdx
        task1_content = '''---
id: tp-001
title: Task 1
type: task
status: todo
priority: high
parent: proj-test-project
---
# Task 1
'''
        with open(os.path.join(tasks_dir, 'task-001.mdx'), 'w') as f:
            f.write(task1_content)

        # Create task-002.mdx with depends_on task-001
        task2_content = '''---
id: tp-002
title: Task 2
type: task
status: todo
priority: high
parent: proj-test-project
depends_on:
- tp-001
---
# Task 2
'''
        with open(os.path.join(tasks_dir, 'task-002.mdx'), 'w') as f:
            f.write(task2_content)

        # Set workspace root for validation
        validator.WORKSPACE_ROOT = self.temp_dir

    def tearDown(self):
        """Clean up temporary workspace."""
        shutil.rmtree(self.temp_dir)
        validator.WORKSPACE_ROOT = ''

    def test_list_project_ids(self):
        """Test listing project IDs."""
        project_ids = validator.list_project_ids()
        self.assertIn('proj-test-project', project_ids)

    def test_list_task_ids_for_project(self):
        """Test listing task IDs for a project."""
        task_ids = validator.list_task_ids_for_project('test-project')
        self.assertIn('tp-001', task_ids)
        self.assertIn('tp-002', task_ids)

    def test_get_project_slug_from_path(self):
        """Test extracting project slug from path."""
        path = '/some/path/.hyper/projects/test-project/tasks/task-001.mdx'
        slug = validator.get_project_slug_from_path(path)
        self.assertEqual(slug, 'test-project')

    def test_valid_parent_reference(self):
        """Test that valid parent reference passes."""
        frontmatter = {
            'id': 'tp-003',
            'title': 'Task 3',
            'type': 'task',
            'status': 'todo',
            'priority': 'high',
            'parent': 'proj-test-project',
        }
        file_path = os.path.join(
            self.projects_dir, 'test-project', 'tasks', 'task-003.mdx'
        )
        errors = validator.validate_relationships(frontmatter, 'task', file_path)
        parent_errors = [e for e in errors if e['code'] == 'INVALID_PARENT_REFERENCE']
        self.assertEqual(len(parent_errors), 0)

    def test_invalid_parent_reference(self):
        """Test that invalid parent reference is caught."""
        frontmatter = {
            'id': 'tp-003',
            'title': 'Task 3',
            'type': 'task',
            'status': 'todo',
            'priority': 'high',
            'parent': 'proj-nonexistent',
        }
        file_path = os.path.join(
            self.projects_dir, 'test-project', 'tasks', 'task-003.mdx'
        )
        errors = validator.validate_relationships(frontmatter, 'task', file_path)
        self.assertTrue(any(e['code'] == 'INVALID_PARENT_REFERENCE' for e in errors))

    def test_valid_dependency_reference(self):
        """Test that valid dependency reference passes."""
        frontmatter = {
            'id': 'tp-003',
            'title': 'Task 3',
            'type': 'task',
            'status': 'todo',
            'priority': 'high',
            'parent': 'proj-test-project',
            'depends_on': ['tp-001'],
        }
        file_path = os.path.join(
            self.projects_dir, 'test-project', 'tasks', 'task-003.mdx'
        )
        errors = validator.validate_relationships(frontmatter, 'task', file_path)
        dep_errors = [e for e in errors if e['code'] == 'INVALID_DEPENDENCY_REFERENCE']
        self.assertEqual(len(dep_errors), 0)

    def test_invalid_dependency_reference(self):
        """Test that invalid dependency reference is caught."""
        frontmatter = {
            'id': 'tp-003',
            'title': 'Task 3',
            'type': 'task',
            'status': 'todo',
            'priority': 'high',
            'parent': 'proj-test-project',
            'depends_on': ['tp-nonexistent'],
        }
        file_path = os.path.join(
            self.projects_dir, 'test-project', 'tasks', 'task-003.mdx'
        )
        errors = validator.validate_relationships(frontmatter, 'task', file_path)
        self.assertTrue(any(e['code'] == 'INVALID_DEPENDENCY_REFERENCE' for e in errors))

    def test_self_dependency(self):
        """Test that self-dependency is caught."""
        frontmatter = {
            'id': 'tp-001',
            'title': 'Task 1',
            'type': 'task',
            'status': 'todo',
            'priority': 'high',
            'parent': 'proj-test-project',
            'depends_on': ['tp-001'],  # Self-reference
        }
        file_path = os.path.join(
            self.projects_dir, 'test-project', 'tasks', 'task-001.mdx'
        )
        errors = validator.validate_relationships(frontmatter, 'task', file_path)
        self.assertTrue(any(e['code'] == 'SELF_DEPENDENCY' for e in errors))

    def test_direct_circular_dependency(self):
        """Test that direct circular dependency (A->B->A) is caught."""
        # tp-002 already depends on tp-001
        # Now try to make tp-001 depend on tp-002
        frontmatter = {
            'id': 'tp-001',
            'title': 'Task 1',
            'type': 'task',
            'status': 'todo',
            'priority': 'high',
            'parent': 'proj-test-project',
            'depends_on': ['tp-002'],  # tp-002 depends on tp-001 already
        }
        file_path = os.path.join(
            self.projects_dir, 'test-project', 'tasks', 'task-001.mdx'
        )
        errors = validator.validate_relationships(frontmatter, 'task', file_path)
        self.assertTrue(any(e['code'] == 'CIRCULAR_DEPENDENCY' for e in errors))

    def test_no_validation_for_non_tasks(self):
        """Test that relationship validation is skipped for non-tasks."""
        frontmatter = {
            'id': 'proj-test',
            'title': 'Project',
            'type': 'project',
            'status': 'todo',
            'priority': 'high',
        }
        errors = validator.validate_relationships(frontmatter, 'project', '/some/path')
        self.assertEqual(len(errors), 0)


class TestGetTaskDependencies(unittest.TestCase):
    """Test the get_task_dependencies helper function."""

    def setUp(self):
        """Create a temporary workspace."""
        self.temp_dir = tempfile.mkdtemp()
        self.projects_dir = os.path.join(self.temp_dir, 'projects', 'test')
        tasks_dir = os.path.join(self.projects_dir, 'tasks')
        os.makedirs(tasks_dir)

        # Create task with dependencies
        task_content = '''---
id: task-a
title: Task A
type: task
parent: proj-test
depends_on:
- task-b
- task-c
---
# Task A
'''
        with open(os.path.join(tasks_dir, 'task-a.mdx'), 'w') as f:
            f.write(task_content)

        validator.WORKSPACE_ROOT = self.temp_dir

    def tearDown(self):
        shutil.rmtree(self.temp_dir)
        validator.WORKSPACE_ROOT = ''

    def test_get_task_dependencies(self):
        """Test getting dependencies for a task."""
        deps = validator.get_task_dependencies('task-a', 'test')
        self.assertIn('task-b', deps)
        self.assertIn('task-c', deps)

    def test_get_dependencies_nonexistent_task(self):
        """Test getting dependencies for nonexistent task returns empty."""
        deps = validator.get_task_dependencies('task-nonexistent', 'test')
        self.assertEqual(deps, [])


class TestCircularDependencyDetection(unittest.TestCase):
    """Test cycle detection in dependency graphs."""

    def setUp(self):
        """Create workspace with chain of dependencies."""
        self.temp_dir = tempfile.mkdtemp()
        self.projects_dir = os.path.join(self.temp_dir, 'projects', 'chain')
        tasks_dir = os.path.join(self.projects_dir, 'tasks')
        os.makedirs(tasks_dir)

        # Create chain: A -> B -> C
        tasks = [
            ('task-a', 'task-b'),
            ('task-b', 'task-c'),
            ('task-c', None),
        ]

        for task_id, depends_on in tasks:
            depends_line = f"depends_on:\n- {depends_on}\n" if depends_on else ""
            content = f'''---
id: {task_id}
title: {task_id}
type: task
parent: proj-chain
{depends_line}---
# {task_id}
'''
            with open(os.path.join(tasks_dir, f'{task_id}.mdx'), 'w') as f:
                f.write(content)

        validator.WORKSPACE_ROOT = self.temp_dir

    def tearDown(self):
        shutil.rmtree(self.temp_dir)
        validator.WORKSPACE_ROOT = ''

    def test_no_cycle_in_valid_chain(self):
        """Test that valid chain has no cycle."""
        # task-a depends on task-b, which depends on task-c
        # Adding a new task-d that depends on task-c should be fine
        cycle = validator.detect_circular_dependency(
            'task-d', ['task-c'], 'chain'
        )
        self.assertEqual(cycle, '')

    def test_cycle_when_closing_chain(self):
        """Test that closing the chain creates a cycle."""
        # task-c -> task-a would create A -> B -> C -> A
        cycle = validator.detect_circular_dependency(
            'task-c', ['task-a'], 'chain'
        )
        self.assertIn('task-c', cycle)
        self.assertIn('task-a', cycle)


if __name__ == '__main__':
    unittest.main()
