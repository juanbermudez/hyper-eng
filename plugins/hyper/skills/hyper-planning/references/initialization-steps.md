# Initialization Steps

## Check Workspace

```bash
if [ ! -d "$HYPER_WORKSPACE_ROOT" ]; then
  echo "NO_HYPER"
else
  echo "HYPER_EXISTS"
fi
```

## Create Structure (if NO_HYPER)

```bash
mkdir -p $HYPER_WORKSPACE_ROOT/{initiatives,projects,docs}
echo '{"workspacePath": "'$(pwd)'", "name": "'$(basename $(pwd))'", "created": "'$(date +%Y-%m-%d)'"}' > $HYPER_WORKSPACE_ROOT/workspace.json
echo "Created $HYPER_WORKSPACE_ROOT/ directory structure"
```

## Generate Project Slug

From feature name:
- Convert to kebab-case
- Remove special characters
- Truncate to max 50 chars

**Examples**:
- "Add user authentication with OAuth" → `user-auth-oauth`
- "Implement dark mode toggle" → `dark-mode-toggle`

## Check Existing Project

```bash
PROJECT_SLUG="[generated-slug]"
if [ -d "$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}" ]; then
  echo "PROJECT_EXISTS"
fi
```

If exists, ask user:
1. Continue existing project
2. Create new with different name

## Create Project Directory

```bash
mkdir -p "$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/tasks"
mkdir -p "$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/resources/research"
```

## Create Project File

Use CLI to create with validated frontmatter:

```bash
${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft project create \
  --slug "${PROJECT_SLUG}" \
  --title "[TITLE]" \
  --priority "[PRIORITY]" \
  --summary "[BRIEF_SUMMARY]"
```

The CLI creates `_project.mdx` with proper frontmatter. Add specification content to the body during spec_creation phase.

## Activity Tracking Note

Activity tracking happens automatically via PostToolUse hook - no manual logging needed.
