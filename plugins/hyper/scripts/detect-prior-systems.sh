#!/usr/bin/env bash
# detect-prior-systems.sh
# Detects existing task tracking systems and steering documents in the current directory
# Returns JSON for use by init wizard and SessionStart hook

set -euo pipefail

# ==============================================================================
# Path Resolution
# ==============================================================================

# Source central path resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/resolve-paths.sh"

# ==============================================================================
# Detection Logic
# ==============================================================================

# Output JSON structure
OUTPUT='{}'

add_json() {
    local key="$1"
    local value="$2"
    OUTPUT=$(echo "$OUTPUT" | jq --arg k "$key" --argjson v "$value" '. + {($k): $v}')
}

# ============================================================
# STEERING DOCUMENT DETECTION
# ============================================================

detect_steering_docs() {
    local claude_md_info='{"exists": false, "path": null, "has_custom_workflow": false}'
    local agents_md_info='{"exists": false, "path": null}'

    # Check CLAUDE.md locations
    if [[ -f "CLAUDE.md" ]]; then
        local has_workflow=false
        local has_linear=false
        local has_github_issues=false

        # Check for workflow-related content
        if grep -qiE '(workflow|## tasks|task tracking|linear|jira)' CLAUDE.md 2>/dev/null; then
            has_workflow=true
        fi

        # Check for Linear references
        if grep -qE '(linear\.app|[A-Z]{2,5}-[0-9]+)' CLAUDE.md 2>/dev/null; then
            has_linear=true
        fi

        # Check for GitHub issue references
        if grep -qE '#[0-9]+' CLAUDE.md 2>/dev/null; then
            has_github_issues=true
        fi

        # Check for Hyper integration already present
        local has_hyper=false
        if grep -qE '(Hyper Engineering|/hyper:|HYPER_WORKSPACE_ROOT)' CLAUDE.md 2>/dev/null; then
            has_hyper=true
        fi

        claude_md_info=$(jq -n \
            --arg path "CLAUDE.md" \
            --argjson workflow "$has_workflow" \
            --argjson linear "$has_linear" \
            --argjson github "$has_github_issues" \
            --argjson hyper "$has_hyper" \
            '{
                exists: true,
                path: $path,
                has_custom_workflow: $workflow,
                has_linear_refs: $linear,
                has_github_refs: $github,
                has_hyper_integration: $hyper
            }')
    elif [[ -f ".claude/CLAUDE.md" ]]; then
        claude_md_info='{"exists": true, "path": ".claude/CLAUDE.md", "has_custom_workflow": false}'
    fi

    # Check AGENTS.md
    if [[ -f "AGENTS.md" ]]; then
        agents_md_info='{"exists": true, "path": "AGENTS.md"}'
    fi

    add_json "steering_docs" "$(jq -n \
        --argjson claude "$claude_md_info" \
        --argjson agents "$agents_md_info" \
        '{claude_md: $claude, agents_md: $agents}')"
}

# ============================================================
# TASK TRACKING SYSTEM DETECTION
# ============================================================

detect_task_systems() {
    local linear='{"detected": false, "evidence": []}'
    local github='{"detected": false, "evidence": [], "has_templates": false}'
    local todo_files='{"detected": false, "files": []}'
    local jira='{"detected": false, "evidence": []}'

    # Linear detection
    local linear_evidence=()
    if grep -rqE 'linear\.app' . --include="*.md" 2>/dev/null; then
        linear_evidence+=("linear.app URL found")
    fi
    if grep -rqE '[A-Z]{2,5}-[0-9]+' . --include="*.md" 2>/dev/null; then
        # This could be Linear OR JIRA, need more context
        if grep -rqiE 'linear' . --include="*.md" 2>/dev/null; then
            linear_evidence+=("Linear-style issue IDs found")
        fi
    fi
    if [[ ${#linear_evidence[@]} -gt 0 ]]; then
        linear=$(jq -n --argjson evidence "$(printf '%s\n' "${linear_evidence[@]}" | jq -R . | jq -s .)" \
            '{detected: true, evidence: $evidence}')
    fi

    # GitHub Issues detection
    local github_evidence=()
    local has_templates=false
    if [[ -d ".github/ISSUE_TEMPLATE" ]]; then
        github_evidence+=(".github/ISSUE_TEMPLATE/ directory exists")
        has_templates=true
    fi
    if [[ -f ".github/ISSUE_TEMPLATE.md" ]] || [[ -f "ISSUE_TEMPLATE.md" ]]; then
        github_evidence+=("Issue template found")
        has_templates=true
    fi
    if grep -rqE '#[0-9]+' . --include="*.md" 2>/dev/null; then
        github_evidence+=("Issue references (#123) found in docs")
    fi
    if [[ ${#github_evidence[@]} -gt 0 ]]; then
        github=$(jq -n \
            --argjson evidence "$(printf '%s\n' "${github_evidence[@]}" | jq -R . | jq -s .)" \
            --argjson templates "$has_templates" \
            '{detected: true, evidence: $evidence, has_templates: $templates}')
    fi

    # TODO/Task file detection
    local todo_file_list=()
    for f in TODO.md TODOS.md TODO.txt TASKS.md TASK.md ROADMAP.md BACKLOG.md; do
        if [[ -f "$f" ]]; then
            todo_file_list+=("$f")
        fi
    done
    if [[ ${#todo_file_list[@]} -gt 0 ]]; then
        todo_files=$(jq -n \
            --argjson files "$(printf '%s\n' "${todo_file_list[@]}" | jq -R . | jq -s .)" \
            '{detected: true, files: $files}')
    fi

    # JIRA detection (distinct from Linear by looking for jira-specific patterns)
    local jira_evidence=()
    if grep -rqiE '(jira|atlassian)' . --include="*.md" 2>/dev/null; then
        jira_evidence+=("JIRA/Atlassian references found")
    fi
    if [[ -d ".jira" ]] || [[ -f "jira.config" ]]; then
        jira_evidence+=("JIRA configuration found")
    fi
    if [[ ${#jira_evidence[@]} -gt 0 ]]; then
        jira=$(jq -n --argjson evidence "$(printf '%s\n' "${jira_evidence[@]}" | jq -R . | jq -s .)" \
            '{detected: true, evidence: $evidence}')
    fi

    add_json "task_systems" "$(jq -n \
        --argjson linear "$linear" \
        --argjson github "$github" \
        --argjson todo "$todo_files" \
        --argjson jira "$jira" \
        '{linear: $linear, github_issues: $github, todo_files: $todo, jira: $jira}')"
}

# ============================================================
# HYPER STATE DETECTION
# ============================================================

resolve_hyper_bin() {
    local hyper_bin="${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft"
    if [[ -x "$hyper_bin" ]]; then
        echo "$hyper_bin"
        return
    fi

    hyper_bin="${CLAUDE_PLUGIN_ROOT}/binaries/hyper"
    if [[ -x "$hyper_bin" ]]; then
        echo "$hyper_bin"
        return
    fi

    echo "hypercraft"
}

detect_hyper_state() {
    local workspace_configured=false
    local workspace_path=""
    local legacy_local=false
    local local_path=""
    local needs_migration=false

    # Check for HYPER_WORKSPACE_ROOT env var
    if [[ -n "$HYPER_WORKSPACE_ROOT" ]] && [[ -d "$HYPER_WORKSPACE_ROOT" ]]; then
        workspace_configured=true
        workspace_path="$HYPER_WORKSPACE_ROOT"
    fi

    # Try to get from CLI
    if [[ "$workspace_configured" == "false" ]]; then
        local hyper_bin
        hyper_bin="$(resolve_hyper_bin)"
        if [[ -x "$hyper_bin" ]]; then
            local resolved
            resolved=$("$hyper_bin" config get globalPath 2>/dev/null || true)
            if [[ -n "$resolved" && "$resolved" != "null" && -d "$resolved" ]]; then
                workspace_configured=true
                workspace_path="$resolved"
            fi
        fi
    fi

    # Check for legacy local .hyper directory
    if [[ -d ".hyper" ]]; then
        legacy_local=true
        local_path="$(pwd)/.hyper"
        # If we have a global workspace but also local, suggest migration
        if [[ "$workspace_configured" == "true" ]]; then
            needs_migration=true
        fi
    fi

    add_json "hyper_state" "$(jq -n \
        --argjson configured "$workspace_configured" \
        --arg path "$workspace_path" \
        --argjson legacy "$legacy_local" \
        --arg local_path "$local_path" \
        --argjson migrate "$needs_migration" \
        '{
            workspace_root_configured: $configured,
            workspace_root_path: $path,
            legacy_local_hyper: $legacy,
            local_hyper_path: $local_path,
            needs_migration: $migrate
        }')"
}

# ============================================================
# RECOMMENDATIONS
# ============================================================

generate_recommendations() {
    local backup_needed=false
    local merge_strategy="none"
    local import_candidates='[]'
    local migration_needed=false

    # Parse current output for recommendations
    local claude_exists=$(echo "$OUTPUT" | jq -r '.steering_docs.claude_md.exists // false')
    local has_hyper=$(echo "$OUTPUT" | jq -r '.steering_docs.claude_md.has_hyper_integration // false')
    local has_workflow=$(echo "$OUTPUT" | jq -r '.steering_docs.claude_md.has_custom_workflow // false')
    local linear_detected=$(echo "$OUTPUT" | jq -r '.task_systems.linear.detected // false')
    local todo_detected=$(echo "$OUTPUT" | jq -r '.task_systems.todo_files.detected // false')
    local github_detected=$(echo "$OUTPUT" | jq -r '.task_systems.github_issues.detected // false')
    local legacy_hyper=$(echo "$OUTPUT" | jq -r '.hyper_state.legacy_local_hyper // false')

    # Determine if backup is needed
    if [[ "$claude_exists" == "true" && "$has_hyper" == "false" ]]; then
        backup_needed=true
        if [[ "$has_workflow" == "true" ]]; then
            merge_strategy="three-tier-with-custom"
        else
            merge_strategy="three-tier"
        fi
    fi

    # Collect import candidates
    local candidates=()
    if [[ "$linear_detected" == "true" ]]; then
        candidates+=("linear")
    fi
    if [[ "$todo_detected" == "true" ]]; then
        candidates+=("todo_files")
    fi
    if [[ "$github_detected" == "true" ]]; then
        candidates+=("github_issues")
    fi
    if [[ ${#candidates[@]} -gt 0 ]]; then
        import_candidates=$(printf '%s\n' "${candidates[@]}" | jq -R . | jq -s .)
    fi

    # Check migration
    if [[ "$legacy_hyper" == "true" ]]; then
        migration_needed=true
    fi

    add_json "recommendations" "$(jq -n \
        --argjson backup "$backup_needed" \
        --arg strategy "$merge_strategy" \
        --argjson imports "$import_candidates" \
        --argjson migrate "$migration_needed" \
        '{
            backup_claude_md: $backup,
            merge_strategy: $strategy,
            import_candidates: $imports,
            migration_needed: $migrate
        }')"
}

# ============================================================
# MAIN
# ============================================================

main() {
    # Initialize jq if not available
    if ! command -v jq &> /dev/null; then
        echo '{"error": "jq is required for detection script"}'
        exit 1
    fi

    detect_steering_docs
    detect_task_systems
    detect_hyper_state
    generate_recommendations

    echo "$OUTPUT" | jq .
}

main "$@"
