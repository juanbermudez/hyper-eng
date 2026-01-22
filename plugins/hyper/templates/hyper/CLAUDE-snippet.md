<!-- HYPER ENGINEERING INTEGRATION - DO NOT EDIT MANUALLY -->
<!-- This section is managed by the Hyper Engineering plugin -->

## Hyper Engineering Integration

This project uses the [Hyper Engineering](https://github.com/juanbermudez/hyper-eng) plugin for spec-driven development workflows.

### Available Commands

| Command | Purpose |
|---------|---------|
| `/hyper:status` | View all projects and tasks |
| `/hyper:plan` | Create new project specifications with research |
| `/hyper:implement` | Execute tasks with verification gates |
| `/hyper:verify` | Run comprehensive verification loops |
| `/hyper:review` | Code review with checklist |
| `/hyper:init` | Initialize or repair workspace |
| `/hyper:import-external` | Import from external task systems |

### Development Workflow

```
1. PLAN    → Research and create specs via /hyper:plan
            Creates project in $HYPER_WORKSPACE_ROOT/projects/{slug}/

2. APPROVE → Review spec and approve task breakdown
            Project moves from 'planned' → 'in-progress'

3. IMPLEMENT → Execute tasks via /hyper:implement {project}/{task}
              Each task has verification gates before completion

4. VERIFY  → Quality checks via /hyper:verify
            Automated: lint, typecheck, test, build
            Manual: browser testing, code review

5. COMPLETE → All tasks done, project moves to 'completed'
```

### Workspace Structure

All planning data lives in HyperHome (outside this repository):

```
$HYPER_WORKSPACE_ROOT/
├── workspace.json       # Workspace metadata
├── projects/            # Feature projects
│   └── {slug}/
│       ├── _project.mdx # Project specification
│       ├── tasks/       # Task breakdown
│       └── resources/   # Research, docs
├── docs/                # Documentation
└── settings/            # Configuration
```

### Important Notes

- **Check status first**: Run `/hyper:status` before starting work
- **Use the workflow**: Don't skip verification gates
- **CLI for file ops**: Use CLI commands, never edit `$HYPER_WORKSPACE_ROOT/` files directly
- **Specs are truth**: Code is disposable; specifications are the source of truth

<!-- END HYPER ENGINEERING INTEGRATION -->
