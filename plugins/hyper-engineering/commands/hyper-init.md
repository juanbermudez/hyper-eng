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
        echo ""
        echo "Core directories:"
        [ -d ".hyper/initiatives" ] && echo "✓ initiatives/" || echo "✗ initiatives/ missing"
        [ -d ".hyper/projects" ] && echo "✓ projects/" || echo "✗ projects/ missing"
        [ -d ".hyper/docs" ] && echo "✓ docs/" || echo "✗ docs/ missing"
        echo ""
        echo "Settings (customization):"
        [ -d ".hyper/settings" ] && echo "✓ settings/" || echo "✗ settings/ missing"
        [ -d ".hyper/settings/agents" ] && echo "✓ settings/agents/" || echo "✗ settings/agents/ missing"
        [ -d ".hyper/settings/commands" ] && echo "✓ settings/commands/" || echo "✗ settings/commands/ missing"
        echo ""
        echo "Configuration files:"
        [ -f ".hyper/workspace.json" ] && echo "✓ workspace.json" || echo "✗ workspace.json missing"
        [ -f ".hyper/settings/workflows.yaml" ] && echo "✓ settings/workflows.yaml" || echo "✗ settings/workflows.yaml missing"
        echo ""
        echo "Existing content:"
        [ -d ".hyper/projects" ] && echo "Projects: $(ls -d .hyper/projects/*/ 2>/dev/null | wc -l | tr -d ' ')" || echo "Projects: 0"
        [ -d ".hyper/initiatives" ] && echo "Initiatives: $(ls .hyper/initiatives/*.mdx 2>/dev/null | wc -l | tr -d ' ')" || echo "Initiatives: 0"
        ```

        **IMPORTANT: Preserve existing content!**

        If .hyper/ exists with projects or other content:
        - DO NOT overwrite or delete existing projects, tasks, or docs
        - Only ADD missing directories (mkdir -p is safe)
        - Only create missing config files if they don't exist

        Present options to user:

        ---
        **Existing .hyper/ Directory Found**

        [Show status output above]

        Options:
        1. **Repair/Upgrade** - Add missing directories and settings (preserves all existing content)
        2. **Skip** - Keep existing structure unchanged
        3. **View existing projects** - List current projects before deciding

        What would you like to do?

        ---

        **If user selects Repair/Upgrade**: Proceed to repair_existing phase
        **If user selects Skip**: Show completion with current status
        **If user selects View**: List projects, then ask again

        **If NOT_EXISTS**:
        Proceed to get_workspace_name phase for fresh initialization.
      </instructions>
    </phase>

    <phase name="repair_existing" conditional="true">
      <instructions>
        **Only runs when user chooses to repair/upgrade existing .hyper/ directory**

        **CRITICAL: Do NOT overwrite existing files!**

        1. **Create only missing directories** (safe - mkdir -p doesn't overwrite):
        ```bash
        mkdir -p .hyper/{initiatives,projects,docs,settings/agents,settings/commands}
        ```

        2. **Only create workspace.json if it doesn't exist**:
        ```bash
        if [ ! -f ".hyper/workspace.json" ]; then
          echo "Creating workspace.json..."
          # Create workspace.json
        else
          echo "✓ workspace.json already exists - preserving"
        fi
        ```

        3. **Only create workflows.yaml if it doesn't exist**:
        ```bash
        if [ ! -f ".hyper/settings/workflows.yaml" ]; then
          echo "Creating workflows.yaml with default configuration..."
          # Create workflows.yaml
        else
          echo "✓ workflows.yaml already exists - preserving"
        fi
        ```

        4. **Only create README files if they don't exist**:
        ```bash
        if [ ! -f ".hyper/settings/agents/README.md" ]; then
          echo "Creating agents/README.md..."
          # Create README
        else
          echo "✓ agents/README.md already exists - preserving"
        fi

        if [ ! -f ".hyper/settings/commands/README.md" ]; then
          echo "Creating commands/README.md..."
          # Create README
        else
          echo "✓ commands/README.md already exists - preserving"
        fi
        ```

        5. **Report what was added**:
        ```bash
        echo ""
        echo "Upgrade complete!"
        echo "Added missing components while preserving existing content."
        ```

        **After repair, skip to copy_templates phase** (optional templates).
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
        mkdir -p .hyper/{initiatives,projects,docs,settings/agents,settings/commands}
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

    <phase name="copy_settings" required="true">
      <instructions>
        Copy default settings and customization templates.

        **IMPORTANT: Only create files that don't already exist!**

        1. **Check and create workflows.yaml** (only if missing):
        ```bash
        if [ ! -f ".hyper/settings/workflows.yaml" ]; then
          echo "Creating workflows.yaml..."
          # Write workflows.yaml
        else
          echo "✓ workflows.yaml already exists - preserving"
        fi
        ```

        Write the workflows.yaml file to `.hyper/settings/workflows.yaml` with:
        - Project workflow stages (planned → review → todo → in-progress → verification → complete)
        - Task workflow stages (todo → in-progress → blocked → review → complete)
        - Quality gates configuration
        - Tags configuration (priority and type)

        Use the hyper-local skill to get the template content, or inline from plugin templates.

        2. **Check and create README files** (only if missing):
        ```bash
        if [ ! -f ".hyper/settings/agents/README.md" ]; then
          echo "Creating agents/README.md..."
          # Write README
        else
          echo "✓ agents/README.md already exists - preserving"
        fi

        if [ ! -f ".hyper/settings/commands/README.md" ]; then
          echo "Creating commands/README.md..."
          # Write README
        else
          echo "✓ commands/README.md already exists - preserving"
        fi
        ```

        **Verify settings**:
        ```bash
        echo ""
        echo "Settings directory:"
        ls -la .hyper/settings/
        ls -la .hyper/settings/agents/
        ls -la .hyper/settings/commands/
        ```
      </instructions>
    </phase>

    <phase name="copy_templates" optional="true">
      <instructions>
        **Check for existing customization files first:**

        ```bash
        echo "Checking for existing customization files..."
        EXISTING_AGENTS=$(ls .hyper/settings/agents/*.yaml 2>/dev/null | wc -l | tr -d ' ')
        EXISTING_COMMANDS=$(ls .hyper/settings/commands/*.yaml 2>/dev/null | wc -l | tr -d ' ')
        echo "Existing agent configs: $EXISTING_AGENTS"
        echo "Existing command configs: $EXISTING_COMMANDS"
        ```

        **If customization files already exist**, ask:

        ---
        **Existing Customization Files Found**

        - Agent configurations: [EXISTING_AGENTS] files
        - Command configurations: [EXISTING_COMMANDS] files

        Would you like to:
        1. **Keep existing** - Don't overwrite any customization files
        2. **Add missing only** - Copy templates for agents/commands that don't have configs yet
        3. **View existing** - List current customization files

        ---

        **If no existing files or user wants to add templates:**

        ---
        **Full Customization Templates**

        Would you like to copy customization templates?

        This includes:
        - Agent customization templates (7 agents)
        - Command customization templates (5 commands)

        These templates are pre-filled with examples showing customization options.
        Edit them to customize agent/command behavior for your project.

        (y/n)

        ---

        **IMPORTANT: Only copy files that don't already exist!**

        For each file, check first:
        ```bash
        if [ ! -f ".hyper/settings/agents/research-orchestrator.yaml" ]; then
          echo "Creating research-orchestrator.yaml..."
          # Write file
        else
          echo "✓ research-orchestrator.yaml already exists - preserving"
        fi
        ```

        Files to copy (only if missing):
        **Agents:**
        - research-orchestrator.yaml
        - implementation-orchestrator.yaml
        - repo-research-analyst.yaml
        - best-practices-researcher.yaml
        - framework-docs-researcher.yaml
        - git-history-analyzer.yaml
        - web-app-debugger.yaml

        **Commands:**
        - hyper-plan.yaml
        - hyper-implement.yaml
        - hyper-review.yaml
        - hyper-verify.yaml
        - hyper-init-stack.yaml
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
        ├── workspace.json           # Workspace metadata
        ├── initiatives/             # Strategic groupings
        ├── projects/                # Project containers
        ├── docs/                    # Standalone documentation
        └── settings/                # Customization
            ├── workflows.yaml       # Project/task workflow stages
            ├── agents/              # Agent customization
            │   └── README.md
            └── commands/            # Command customization
                └── README.md
        ```

        ### Customization

        Edit files in `.hyper/settings/` to customize:
        - **workflows.yaml** - Modify project/task workflow stages and quality gates
        - **agents/*.yaml** - Customize agent behavior (add context, modify instructions)
        - **commands/*.yaml** - Customize command behavior (override phases, add checks)

        [If full templates copied: "Full customization templates installed. Edit any .yaml file to customize."]

        ### Next Steps

        1. **Plan a feature**: `/hyper-plan "Add user authentication"`
        2. **View status**: `/hyper-status`
        3. **Customize workflows**: Edit `.hyper/settings/workflows.yaml`
        4. **Open Hyper Control** for visual project management (optional)

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
    <practice>NEVER overwrite existing projects, tasks, or user customizations</practice>
    <practice>Only create files/directories that don't already exist</practice>
    <practice>Use mkdir -p for directories (safe, won't overwrite)</practice>
    <practice>Always check if file exists before writing config files</practice>
    <practice>Show users what exists before making changes</practice>
    <practice>Offer "repair/upgrade" option for existing directories</practice>
    <practice>Use directory name as default workspace name</practice>
    <practice>Suggest git tracking for team collaboration</practice>
    <practice>Point users to next steps after initialization</practice>
  </best_practices>
</agent>
