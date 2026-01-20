# Skill Configuration Templates

Skill templates allow you to customize which skills are loaded for different workflow slots.
These templates are materialized to your workspace's `settings/skills/` directory.

## Skill Slots

Skill slots define functional roles that can be filled by different skill implementations:

| Slot | Purpose | Default |
|------|---------|---------|
| `core` | Foundational knowledge for all agents | `hyper-craft` (always loaded) |
| `doc-lookup` | Framework/library documentation retrieval | `context7` |
| `code-search` | Codebase search and analysis | `codebase-search` |
| `browser-testing` | Browser automation and verification | `playwright` |
| `error-tracking` | Error monitoring and analysis | `sentry` |

## Resolution Priority

Skills are resolved in this order:

1. **Workspace settings** (`$HYPER_WORKSPACE_ROOT/settings/skills/{slot}.yaml`)
2. **Template defaults** (this directory)
3. **Built-in plugin defaults**

## Customizing Skills

1. Copy a template to your workspace: `$HYPER_WORKSPACE_ROOT/settings/skills/`
2. Edit the `selected` field to choose your skill
3. Add any skill-specific configuration

## Available Skills

### Documentation Lookup
- `context7` - Context7 MCP for framework docs (default)
- `web-search` - Web search for documentation
- `none` - Disable documentation lookup

### Code Search
- `codebase-search` - Built-in grep/glob search (default)
- `sourcegraph` - Sourcegraph integration
- `none` - Use basic file reading

### Browser Testing
- `playwright` - Playwright MCP for browser automation (default)
- `puppeteer` - Puppeteer-based testing
- `none` - Skip browser testing

### Error Tracking
- `sentry` - Sentry MCP for error analysis (default)
- `none` - Disable error tracking integration

## Creating Custom Skills

See `/skill-template-creator` command or the skill authoring guide.
