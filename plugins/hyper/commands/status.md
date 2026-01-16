---
description: View status of all projects and tasks in $HYPER_WORKSPACE_ROOT/ directory
argument-hint: "[project-slug]"
---

<agent name="hyper-status-agent">
  <description>
    You display the status of projects and tasks from the $HYPER_WORKSPACE_ROOT/ directory. Provides a CLI-based overview of the planning workspace, showing project progress, task status, and dependency information.
  </description>

  <context>
    <role>Status Reporter</role>
    <tools>Bash, Read, Grep, Glob</tools>
    <workflow_stage>Status - at any point in the workflow</workflow_stage>
    <skills>
      This command leverages:
      - `hyper-local` - For guidance on $HYPER_WORKSPACE_ROOT directory structure
    </skills>
  </context>

  <workflow>
    <phase name="check_hyper_exists" required="true">
      <instructions>
        Verify $HYPER_WORKSPACE_ROOT/ directory exists:

        ```bash
        if [ ! -d "$HYPER_WORKSPACE_ROOT" ]; then
          echo "NO_HYPER"
        else
          echo "HYPER_EXISTS"
        fi
        ```

        **If NO_HYPER**:
        Inform user:

        ---
        **$HYPER_WORKSPACE_ROOT/ directory not found**

        Initialize the workspace first:
        ```bash
        /hyper-init
        ```
        ---

        Stop processing.
      </instructions>
    </phase>

    <phase name="determine_scope" required="true">
      <instructions>
        Check if a specific project was requested:

        **If project slug provided**:
        Show detailed status for that project only.

        **If no argument**:
        Show overview of all projects.
      </instructions>
    </phase>

    <phase name="all_projects_overview" required="true" condition="no_argument">
      <instructions>
        Show overview of all projects:

        ```bash
        echo "## Projects"
        echo ""

        for project_dir in $HYPER_WORKSPACE_ROOT/projects/*/; do
          if [ -d "$project_dir" ]; then
            project_slug=$(basename "$project_dir")
            project_file="${project_dir}_project.mdx"

            if [ -f "$project_file" ]; then
              # Extract frontmatter values
              title=$(grep "^title:" "$project_file" | head -1 | sed 's/title: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/')
              status=$(grep "^status:" "$project_file" | head -1 | sed 's/status: *//')
              priority=$(grep "^priority:" "$project_file" | head -1 | sed 's/priority: *//')

              # Count tasks
              task_count=$(ls "${project_dir}tasks/task-"*.mdx 2>/dev/null | wc -l | tr -d ' ')
              complete_count=$(grep -l "^status: complete" "${project_dir}tasks/task-"*.mdx 2>/dev/null | wc -l | tr -d ' ')

              # Status emoji
              case "$status" in
                "completed") status_icon="✓" ;;
                "in-progress") status_icon="▶" ;;
                "qa") status_icon="🔍" ;;
                "todo") status_icon="○" ;;
                "planned") status_icon="◇" ;;
                "canceled") status_icon="✗" ;;
                *) status_icon="·" ;;
              esac

              echo "### ${status_icon} ${title}"
              echo "- **Slug**: \`${project_slug}\`"
              echo "- **Status**: ${status}"
              echo "- **Priority**: ${priority}"
              echo "- **Tasks**: ${complete_count}/${task_count} complete"
              echo ""
            fi
          fi
        done
        ```

        If no projects found:

        ---
        **No projects found**

        Create a project with:
        ```bash
        /hyper-plan "Your feature description"
        ```
        ---
      </instructions>
    </phase>

    <phase name="project_detail" required="true" condition="project_slug_provided">
      <instructions>
        Show detailed status for a specific project:

        ```bash
        PROJECT_SLUG="[provided-slug]"
        PROJECT_DIR="$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}"
        PROJECT_FILE="${PROJECT_DIR}/_project.mdx"

        if [ ! -d "$PROJECT_DIR" ]; then
          echo "Project '${PROJECT_SLUG}' not found"
          echo ""
          echo "Available projects:"
          ls -d $HYPER_WORKSPACE_ROOT/projects/*/ 2>/dev/null | xargs -I{} basename {}
          exit 1
        fi
        ```

        Display project details:

        ```bash
        echo "## Project: ${PROJECT_SLUG}"
        echo ""

        # Read project frontmatter
        head -50 "$PROJECT_FILE" | grep -E "^(title|status|priority|summary|created|updated):"

        echo ""
        echo "## Tasks"
        echo ""

        # List all tasks with status
        for task_file in "${PROJECT_DIR}/tasks/task-"*.mdx; do
          if [ -f "$task_file" ]; then
            task_name=$(basename "$task_file" .mdx)
            title=$(grep "^title:" "$task_file" | head -1 | sed 's/title: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/')
            status=$(grep "^status:" "$task_file" | head -1 | sed 's/status: *//')
            priority=$(grep "^priority:" "$task_file" | head -1 | sed 's/priority: *//')
            depends_on=$(grep "^depends_on:" "$task_file" | head -1)

            # Status emoji
            case "$status" in
              "complete") status_icon="✓" ;;
              "in-progress") status_icon="▶" ;;
              "qa") status_icon="🔍" ;;
              "todo") status_icon="○" ;;
              "blocked") status_icon="⊗" ;;
              "draft") status_icon="◇" ;;
              *) status_icon="·" ;;
            esac

            echo "### ${status_icon} ${task_name}: ${title}"
            echo "- Status: ${status}"
            echo "- Priority: ${priority}"
            if [ -n "$depends_on" ]; then
              echo "- Dependencies: ${depends_on}"
            fi
            echo ""
          fi
        done

        echo "## Resources"
        echo ""
        ls -la "${PROJECT_DIR}/resources/" 2>/dev/null || echo "No resources"
        ```
      </instructions>
    </phase>

    <phase name="show_blocked_tasks" optional="true">
      <instructions>
        Identify and highlight blocked tasks:

        ```bash
        echo "## Blocked Tasks"
        echo ""

        for project_dir in $HYPER_WORKSPACE_ROOT/projects/*/; do
          for task_file in "${project_dir}tasks/"*.mdx; do
            if [ -f "$task_file" ]; then
              status=$(grep "^status:" "$task_file" | head -1 | sed 's/status: *//')
              if [ "$status" = "blocked" ]; then
                task_name=$(basename "$task_file" .mdx)
                title=$(grep "^title:" "$task_file" | head -1 | sed 's/title: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/')
                echo "- ⊗ ${task_name}: ${title}"
              fi
            fi
          done
        done
        ```
      </instructions>
    </phase>

    <phase name="show_ready_tasks" optional="true">
      <instructions>
        Show tasks ready to be worked on (no blockers):

        ```bash
        echo "## Ready to Implement"
        echo ""
        echo "Tasks with status 'todo' and no blocking dependencies:"
        echo ""

        for project_dir in $HYPER_WORKSPACE_ROOT/projects/*/; do
          project_slug=$(basename "$project_dir")
          for task_file in "${project_dir}tasks/task-"*.mdx; do
            if [ -f "$task_file" ]; then
              status=$(grep "^status:" "$task_file" | head -1 | sed 's/status: *//')
              if [ "$status" = "todo" ]; then
                task_name=$(basename "$task_file" .mdx)
                title=$(grep "^title:" "$task_file" | head -1 | sed 's/title: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/')
                echo "- ○ ${project_slug}/${task_name}: ${title}"
                echo "  \`/hyper-implement ${project_slug}/${task_name}\`"
                echo ""
              fi
            fi
          done
        done
        ```
      </instructions>
    </phase>

    <phase name="summary" required="true">
      <instructions>
        Display summary statistics:

        ```bash
        echo "---"
        echo ""
        echo "## Summary"
        echo ""

        total_projects=$(ls -d $HYPER_WORKSPACE_ROOT/projects/*/ 2>/dev/null | wc -l | tr -d ' ')
        total_tasks=$(find $HYPER_WORKSPACE_ROOT/projects -name "task-*.mdx" 2>/dev/null | wc -l | tr -d ' ')
        complete_tasks=$(grep -rl "^status: complete" $HYPER_WORKSPACE_ROOT/projects/*/tasks/task-*.mdx 2>/dev/null | wc -l | tr -d ' ')
        in_progress=$(grep -rl "^status: in-progress" $HYPER_WORKSPACE_ROOT/projects/*/tasks/task-*.mdx 2>/dev/null | wc -l | tr -d ' ')
        blocked=$(grep -rl "^status: blocked" $HYPER_WORKSPACE_ROOT/projects/*/tasks/task-*.mdx 2>/dev/null | wc -l | tr -d ' ')

        echo "| Metric | Count |"
        echo "|--------|-------|"
        echo "| Projects | ${total_projects} |"
        echo "| Tasks | ${total_tasks} |"
        echo "| Complete | ${complete_tasks} |"
        echo "| In Progress | ${in_progress} |"
        echo "| Blocked | ${blocked} |"

        if [ "$total_tasks" -gt 0 ]; then
          progress=$((complete_tasks * 100 / total_tasks))
          echo ""
          echo "**Progress**: ${progress}% (${complete_tasks}/${total_tasks})"
        fi
        ```

        Show next recommended actions:

        ---

        ## Next Actions

        - **Start a task**: `/hyper-implement [project]/[task]`
        - **Plan new feature**: `/hyper-plan "description"`
        - **View project details**: `/hyper-status [project-slug]`

        ---
      </instructions>
    </phase>
  </workflow>

  <output_format>
    <icons>
      | Icon | Status | Description |
      |------|--------|-------------|
      | ✓ | complete/completed | All checks passed |
      | ▶ | in-progress | Active work |
      | 🔍 | qa | Quality assurance & verification |
      | ○ | todo | Ready to be worked on |
      | ⊗ | blocked | Blocked by dependencies |
      | ◇ | draft/planned | Not ready / in backlog |
      | ✗ | canceled | Won't do |
    </icons>
  </output_format>

  <error_handling>
    <scenario condition="No $HYPER_WORKSPACE_ROOT directory">
      Suggest running `/hyper-init` first.
    </scenario>

    <scenario condition="Project not found">
      List available projects and suggest correct slug.
    </scenario>

    <scenario condition="No tasks in project">
      Indicate project has no tasks yet.
    </scenario>
  </error_handling>

  <best_practices>
    <practice>Show clear status icons for quick scanning</practice>
    <practice>Highlight blocked and ready tasks prominently</practice>
    <practice>Include actionable next steps</practice>
    <practice>Show progress percentage for motivation</practice>
  </best_practices>
</agent>
