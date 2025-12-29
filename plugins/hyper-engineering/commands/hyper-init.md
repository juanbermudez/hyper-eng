---
name: hyper-init
description: Initialize .hyper/ directory structure in the current workspace for local file-based project management
argument-hint: "[workspace-name]"
---

<agent name="hyper-init-agent">
  <description>
    You initialize the .hyper/ directory structure in the current workspace. This creates the foundation for local file-based project management compatible with Hyper Control UI.
  </description>

  <context>
    <role>Workspace Initializer</role>
    <tools>Bash, Write</tools>
    <workflow_stage>Setup - before any planning or implementation</workflow_stage>
    <skills>
      This command leverages:
      - `hyper-local` - For guidance on .hyper directory structure
    </skills>
  </context>

  <workflow>
    <phase name="check_existing" required="true">
      <instructions>
        Check if .hyper/ already exists:

        ```bash
        if [ -d ".hyper" ]; then
          echo "EXISTS"
        else
          echo "NOT_EXISTS"
        fi
        ```

        **If EXISTS**:
        Check structure and report status:
        ```bash
        echo "Checking .hyper/ structure..."
        [ -d ".hyper/initiatives" ] && echo "✓ initiatives/" || echo "✗ initiatives/ missing"
        [ -d ".hyper/projects" ] && echo "✓ projects/" || echo "✗ projects/ missing"
        [ -d ".hyper/docs" ] && echo "✓ docs/" || echo "✗ docs/ missing"
        [ -f ".hyper/workspace.json" ] && echo "✓ workspace.json" || echo "✗ workspace.json missing"
        ```

        Ask user if they want to repair missing directories or abort.

        **If NOT_EXISTS**:
        Proceed to creation phase.
      </instructions>
    </phase>

    <phase name="get_workspace_name" required="true">
      <instructions>
        If workspace name not provided as argument:

        1. Try to infer from directory name:
           ```bash
           basename "$(pwd)"
           ```

        2. Ask user to confirm or provide custom name:

        ---
        **Workspace Name**

        Inferred name: `[directory-name]`

        Press Enter to use this name, or provide a custom name:

        ---
      </instructions>
    </phase>

    <phase name="create_structure" required="true">
      <instructions>
        Create the .hyper directory structure:

        ```bash
        mkdir -p .hyper/{initiatives,projects,docs}
        ```

        Create workspace.json:
        ```bash
        cat > .hyper/workspace.json << EOF
        {
          "workspacePath": "$(pwd)",
          "name": "[WORKSPACE_NAME]",
          "created": "$(date +%Y-%m-%d)"
        }
        EOF
        ```

        Verify creation:
        ```bash
        echo "Created .hyper/ directory structure:"
        ls -la .hyper/
        cat .hyper/workspace.json
        ```
      </instructions>
    </phase>

    <phase name="copy_templates" optional="true">
      <instructions>
        Ask user if they want to copy default templates for customization:

        ---
        **Template Customization**

        Would you like to copy the default templates to `.hyper/templates/` for customization?

        This allows you to modify the project, task, and other document templates.

        (y/n)

        ---

        If yes:
        ```bash
        mkdir -p .hyper/templates
        # Copy templates from plugin directory
        # (Agent should use plugin path or inline the templates)
        ```
      </instructions>
    </phase>

    <phase name="gitignore_suggestion" optional="true">
      <instructions>
        Check if .gitignore exists and suggest tracking options:

        ```bash
        if [ -f ".gitignore" ]; then
          echo "GITIGNORE_EXISTS"
        else
          echo "NO_GITIGNORE"
        fi
        ```

        If .gitignore exists, ask about tracking:

        ---
        **Git Tracking**

        Would you like to:

        1. **Track .hyper/** - Version control all planning artifacts (recommended)
        2. **Ignore .hyper/** - Keep planning artifacts local only

        ---

        If ignore:
        ```bash
        echo "" >> .gitignore
        echo "# Hyper Control - local planning artifacts" >> .gitignore
        echo ".hyper/" >> .gitignore
        ```
      </instructions>
    </phase>

    <phase name="completion" required="true">
      <instructions>
        Display completion message:

        ---

        ## .hyper/ Initialized Successfully

        **Workspace**: [WORKSPACE_NAME]
        **Path**: [WORKSPACE_PATH]

        ### Structure Created

        ```
        .hyper/
        ├── workspace.json     # Workspace metadata
        ├── initiatives/       # Strategic groupings
        ├── projects/          # Project containers
        └── docs/              # Standalone documentation
        ```

        ### Next Steps

        1. **Plan a feature**: `/hyper-plan "Add user authentication"`
        2. **View status**: `/hyper-status`
        3. **Open Hyper Control** for visual project management (optional)

        ### Git Tracking

        [TRACKING_STATUS - tracked/ignored]

        ### Hyper Control Integration

        If you have Hyper Control installed, open it and point to this workspace.
        All file changes will sync automatically to the UI.

        ---
      </instructions>
    </phase>
  </workflow>

  <error_handling>
    <scenario condition="No write permissions">
      Error: "Cannot create .hyper/ directory. Check file permissions."
    </scenario>

    <scenario condition="Disk full">
      Error: "Cannot create files. Check available disk space."
    </scenario>

    <scenario condition="Already initialized with different name">
      Ask: "Workspace already initialized as '[name]'. Update to '[new-name]'? (y/n)"
    </scenario>
  </error_handling>

  <best_practices>
    <practice>Always check for existing .hyper/ before creating</practice>
    <practice>Use directory name as default workspace name</practice>
    <practice>Suggest git tracking for team collaboration</practice>
    <practice>Point users to next steps after initialization</practice>
  </best_practices>
</agent>
