#!/bin/bash
# migrate-claude-md.sh
# Parses CLAUDE.md and classifies sections into tiers for intelligent merging
# Returns JSON with section analysis for use by init wizard

set -e

CLAUDE_MD_PATH="${1:-CLAUDE.md}"

if [ ! -f "$CLAUDE_MD_PATH" ]; then
    echo '{"error": "CLAUDE.md not found", "path": "'$CLAUDE_MD_PATH'"}'
    exit 1
fi

# ============================================================
# SECTION CLASSIFICATION
# ============================================================

# Tier 1: Project-Specific Content (PRESERVE VERBATIM)
# Markers: tech stack, architecture, patterns, framework names, project description
TIER1_PATTERNS=(
    'tech stack'
    'architecture'
    'patterns'
    'conventions'
    'project overview'
    'project description'
    'project structure'
    'directory structure'
    'folder structure'
    'dependencies'
    'requirements'
    'setup'
    'installation'
    'environment'
    'configuration'
    'testing'
    'commands'
    'scripts'
    'deployment'
    'api'
    'database'
    'models'
    'components'
    'routes'
    'endpoints'
    'auth'
    'security'
    'coding standards'
    'style guide'
    'naming conventions'
    'error handling'
    'logging'
    'monitoring'
    'domain'
    'business logic'
    'features'
    'modules'
    'packages'
)

# Tier 2: Task Tracking (DETECT & OFFER MIGRATION)
# Markers: Linear, GitHub Issues, JIRA, TODO sections
TIER2_PATTERNS=(
    'linear'
    'github issues'
    'jira'
    'asana'
    'trello'
    'task tracking'
    '## tasks'
    '## todo'
    '## backlog'
    '## roadmap'
    'issue template'
    'pull request'
    'pr template'
    'workflow.*status'
    'ticket'
    'sprint'
    'milestone'
    'LIN-[0-9]+'
    '[A-Z]{2,5}-[0-9]+'
    '#[0-9]+'
)

# Tier 3: AI Assistant Instructions (MERGE INTELLIGENTLY)
# Markers: Claude instructions, development rules, AI guidance
TIER3_PATTERNS=(
    'development rules'
    'claude'
    'ai assistant'
    'when working'
    'guidelines'
    'best practices.*development'
    'rules for'
    'instructions for'
    'how to work'
    'coding rules'
    'commit.*rules'
    'pr.*rules'
    'review.*rules'
    'agent'
    'assistant'
    'llm'
)

# Build grep pattern for each tier
build_pattern() {
    local patterns=("$@")
    local result=""
    for p in "${patterns[@]}"; do
        if [ -z "$result" ]; then
            result="$p"
        else
            result="$result|$p"
        fi
    done
    echo "$result"
}

TIER1_REGEX=$(build_pattern "${TIER1_PATTERNS[@]}")
TIER2_REGEX=$(build_pattern "${TIER2_PATTERNS[@]}")
TIER3_REGEX=$(build_pattern "${TIER3_PATTERNS[@]}")

# ============================================================
# PARSE CLAUDE.MD INTO SECTIONS
# ============================================================

parse_sections() {
    local current_section=""
    local current_content=""
    local sections_json="[]"
    local in_code_block=false

    while IFS= read -r line || [ -n "$line" ]; do
        # Track code blocks to avoid matching headers inside code
        if [[ "$line" =~ ^\`\`\` ]]; then
            if [ "$in_code_block" = true ]; then
                in_code_block=false
            else
                in_code_block=true
            fi
            current_content="$current_content$line"$'\n'
            continue
        fi

        # Check for section header (## ) outside code blocks
        if [ "$in_code_block" = false ] && [[ "$line" =~ ^##[[:space:]] ]]; then
            # Save previous section if exists
            if [ -n "$current_section" ]; then
                # Classify the section
                local tier="project_specific"
                local section_lower=$(echo "$current_section" | tr '[:upper:]' '[:lower:]')
                local content_lower=$(echo "$current_content" | tr '[:upper:]' '[:lower:]')

                # Check tier 2 first (more specific)
                if echo "$section_lower $content_lower" | grep -qiE "$TIER2_REGEX" 2>/dev/null; then
                    tier="task_tracking"
                # Then tier 3
                elif echo "$section_lower $content_lower" | grep -qiE "$TIER3_REGEX" 2>/dev/null; then
                    tier="ai_instructions"
                # Finally tier 1 (default if matches or unknown)
                fi

                # Escape content for JSON
                local escaped_content=$(echo "$current_content" | jq -Rs .)
                local escaped_section=$(echo "$current_section" | jq -Rs .)

                sections_json=$(echo "$sections_json" | jq \
                    --argjson name "$escaped_section" \
                    --argjson content "$escaped_content" \
                    --arg tier "$tier" \
                    '. + [{"name": $name, "tier": $tier, "line_count": ($content | split("\n") | length), "preview": ($content | .[0:200])}]')
            fi

            # Start new section
            current_section="${line#\#\# }"
            current_content=""
        else
            current_content="$current_content$line"$'\n'
        fi
    done < "$CLAUDE_MD_PATH"

    # Don't forget the last section
    if [ -n "$current_section" ]; then
        local tier="project_specific"
        local section_lower=$(echo "$current_section" | tr '[:upper:]' '[:lower:]')
        local content_lower=$(echo "$current_content" | tr '[:upper:]' '[:lower:]')

        if echo "$section_lower $content_lower" | grep -qiE "$TIER2_REGEX" 2>/dev/null; then
            tier="task_tracking"
        elif echo "$section_lower $content_lower" | grep -qiE "$TIER3_REGEX" 2>/dev/null; then
            tier="ai_instructions"
        fi

        local escaped_content=$(echo "$current_content" | jq -Rs .)
        local escaped_section=$(echo "$current_section" | jq -Rs .)

        sections_json=$(echo "$sections_json" | jq \
            --argjson name "$escaped_section" \
            --argjson content "$escaped_content" \
            --arg tier "$tier" \
            '. + [{"name": $name, "tier": $tier, "line_count": ($content | split("\n") | length), "preview": ($content | .[0:200])}]')
    fi

    echo "$sections_json"
}

# ============================================================
# ANALYZE OVERALL FILE
# ============================================================

analyze_file() {
    local total_lines=$(wc -l < "$CLAUDE_MD_PATH")
    local has_hyper_integration=false
    local has_custom_workflow=false
    local external_refs="[]"

    # Check for existing Hyper integration
    if grep -qE '(Hyper Engineering|/hyper:|HYPER_WORKSPACE_ROOT)' "$CLAUDE_MD_PATH" 2>/dev/null; then
        has_hyper_integration=true
    fi

    # Check for custom workflow sections
    if grep -qiE '(## workflow|## process|## development flow)' "$CLAUDE_MD_PATH" 2>/dev/null; then
        has_custom_workflow=true
    fi

    # Find external references
    local linear_refs=$(grep -oE '[A-Z]{2,5}-[0-9]+' "$CLAUDE_MD_PATH" 2>/dev/null | sort -u | head -10)
    local github_refs=$(grep -oE '#[0-9]+' "$CLAUDE_MD_PATH" 2>/dev/null | sort -u | head -10)

    if [ -n "$linear_refs" ]; then
        external_refs=$(echo "$external_refs" | jq --arg refs "$linear_refs" '. + [{"type": "linear", "refs": ($refs | split("\n"))}]')
    fi

    if [ -n "$github_refs" ]; then
        external_refs=$(echo "$external_refs" | jq --arg refs "$github_refs" '. + [{"type": "github", "refs": ($refs | split("\n"))}]')
    fi

    jq -n \
        --arg path "$CLAUDE_MD_PATH" \
        --argjson total_lines "$total_lines" \
        --argjson has_hyper "$has_hyper_integration" \
        --argjson has_workflow "$has_custom_workflow" \
        --argjson refs "$external_refs" \
        '{
            path: $path,
            total_lines: $total_lines,
            has_hyper_integration: $has_hyper,
            has_custom_workflow: $has_workflow,
            external_references: $refs
        }'
}

# ============================================================
# GENERATE SUMMARY
# ============================================================

generate_summary() {
    local sections="$1"
    local analysis="$2"

    local tier1_count=$(echo "$sections" | jq '[.[] | select(.tier == "project_specific")] | length')
    local tier2_count=$(echo "$sections" | jq '[.[] | select(.tier == "task_tracking")] | length')
    local tier3_count=$(echo "$sections" | jq '[.[] | select(.tier == "ai_instructions")] | length')

    local tier1_names=$(echo "$sections" | jq '[.[] | select(.tier == "project_specific") | .name]')
    local tier2_names=$(echo "$sections" | jq '[.[] | select(.tier == "task_tracking") | .name]')
    local tier3_names=$(echo "$sections" | jq '[.[] | select(.tier == "ai_instructions") | .name]')

    jq -n \
        --argjson analysis "$analysis" \
        --argjson sections "$sections" \
        --argjson tier1_count "$tier1_count" \
        --argjson tier2_count "$tier2_count" \
        --argjson tier3_count "$tier3_count" \
        --argjson tier1_names "$tier1_names" \
        --argjson tier2_names "$tier2_names" \
        --argjson tier3_names "$tier3_names" \
        '{
            file_info: $analysis,
            sections: $sections,
            summary: {
                tier_counts: {
                    project_specific: $tier1_count,
                    task_tracking: $tier2_count,
                    ai_instructions: $tier3_count
                },
                tier_sections: {
                    project_specific: $tier1_names,
                    task_tracking: $tier2_names,
                    ai_instructions: $tier3_names
                }
            },
            recommendation: (
                if $analysis.has_hyper_integration then "already_integrated"
                elif $tier2_count > 0 then "merge_with_import"
                elif $tier3_count > 0 then "merge_sections"
                else "append_only"
                end
            )
        }'
}

# ============================================================
# MAIN
# ============================================================

main() {
    if ! command -v jq &> /dev/null; then
        echo '{"error": "jq is required for this script"}'
        exit 1
    fi

    local sections=$(parse_sections)
    local analysis=$(analyze_file)
    local result=$(generate_summary "$sections" "$analysis")

    echo "$result" | jq .
}

main "$@"
