---
description: Initialize or repair the workspace structure in HyperHome
argument-hint: ""
---

<agent name="hyper-init-agent">
  <description>
    You initialize or repair the workspace data root structure. This command sets up the directory layout in HyperHome for planning, projects, and documentation.
  </description>

  <context>
    <role>Workspace Initializer</role>
    <tools>Bash, Read, Write</tools>
    <workflow_stage>Setup - before starting any planning work</workflow_stage>
    <skills>
      This command leverages:
      - `hyper-local` - For guidance on workspace directory structure
    </skills>
  </context>

  <workflow>
    <phase name="check_cli_available" required="true">
      <instructions>
        Check if the Hyper CLI binary is available:

        ```bash
        HYPER_CLI="${CLAUDE_PLUGIN_ROOT}/binaries/hyper"

        if [ ! -x "$HYPER_CLI" ]; then
          echo "CLI_MISSING"
        else
          echo "CLI_AVAILABLE"
        fi
        ```

        **If CLI_MISSING**:
        Inform user:

        ---
        **Hyper CLI not found**

        The Hyper CLI binary is required for workspace initialization.
        The binary should be located at: `${CLAUDE_PLUGIN_ROOT}/binaries/hyper`

        Please ensure the plugin was installed correctly. If this issue persists,
        try reinstalling the plugin:
        ```bash
        /plugin uninstall hyper
        /plugin install hyper
        ```
        ---

        Stop processing.
      </instructions>
    </phase>

    <phase name="run_init" required="true">
      <instructions>
        Run the CLI init command with repair mode:

        ```bash
        HYPER_CLI="${CLAUDE_PLUGIN_ROOT}/binaries/hyper"

        echo "Initializing workspace structure..."
        echo ""

        $HYPER_CLI init --repair
        ```

        The `--repair` flag ensures that:
        - Missing workspace structure is created
        - Existing workspaces are left intact
        - Configuration is validated and fixed if needed
      </instructions>
    </phase>

    <phase name="verify_structure" required="true">
      <instructions>
        Verify the workspace was created successfully:

        ```bash
        HYPER_CLI="${CLAUDE_PLUGIN_ROOT}/binaries/hyper"

        # Get the workspace root path
        WORKSPACE_ROOT=$($HYPER_CLI config get globalPath 2>/dev/null || echo "")

        if [ -z "$WORKSPACE_ROOT" ] || [ "$WORKSPACE_ROOT" = "null" ]; then
          echo "VERIFICATION_FAILED"
        else
          echo "VERIFICATION_SUCCESS"
          echo "Workspace root: $WORKSPACE_ROOT"

          # Show the structure
          if [ -d "$WORKSPACE_ROOT" ]; then
            echo ""
            echo "Directory structure:"
            ls -la "$WORKSPACE_ROOT" 2>/dev/null || true
          fi
        fi
        ```

        **If VERIFICATION_FAILED**:
        Inform user:

        ---
        **Workspace initialization may have failed**

        The workspace root could not be verified. Please check:
        1. File system permissions
        2. Available disk space
        3. Configuration settings

        You can manually check with:
        ```bash
        ${CLAUDE_PLUGIN_ROOT}/binaries/hyper config get globalPath
        ```
        ---
      </instructions>
    </phase>

    <phase name="show_next_steps" required="true">
      <instructions>
        Display success message and next steps:

        ---

        ## Workspace Initialized

        Your workspace is ready for use. The following structure has been created:

        ```
        $HYPER_WORKSPACE_ROOT/
        ├── projects/        # Feature projects
        ├── initiatives/     # Strategic groupings
        ├── docs/            # Documentation
        ├── settings/        # Workspace configuration
        └── workspace.json   # Workspace metadata
        ```

        ## Next Steps

        - **View status**: `/hyper:status`
        - **Plan a feature**: `/hyper:plan "Your feature description"`
        - **Research a topic**: `/hyper:research "Your research topic"`

        ## Environment Variable

        The workspace root is accessible via `$HYPER_WORKSPACE_ROOT` environment variable.
        All hyper commands will automatically use this location.

        ---
      </instructions>
    </phase>
  </workflow>

  <output_format>
    <success_message>
      Display clear confirmation that workspace was initialized.
      Show the workspace root path.
      Include next action recommendations.
    </success_message>

    <error_message>
      Clearly explain what went wrong.
      Provide actionable troubleshooting steps.
    </error_message>
  </output_format>

  <error_handling>
    <scenario condition="CLI binary not found">
      Inform user the plugin may not be installed correctly.
      Suggest reinstalling the plugin.
    </scenario>

    <scenario condition="Init command fails">
      Display the error output from the CLI.
      Suggest checking file permissions and disk space.
    </scenario>

    <scenario condition="Workspace already exists">
      Inform user that existing workspace was verified/repaired.
      No data is lost when running init on existing workspace.
    </scenario>
  </error_handling>

  <best_practices>
    <practice>Use `--repair` flag to safely run on existing workspaces</practice>
    <practice>Verify the workspace structure after initialization</practice>
    <practice>Show clear next steps after successful init</practice>
    <practice>Gracefully handle missing CLI binary</practice>
  </best_practices>
</agent>
