#!/bin/bash

# Hyper-Engineering Linear Workflow Setup
# This script configures custom workflow states in Linear for the hyper-engineering workflow

set -e  # Exit on error

echo "🚀 Hyper-Engineering Linear Workflow Setup"
echo "=========================================="
echo ""

# Check if Linear CLI is installed
if ! command -v linear &> /dev/null; then
    echo "❌ Error: Linear CLI not found"
    echo ""
    echo "Please install the Linear CLI first:"
    echo "  npm install -g @linear/cli"
    echo "  linear auth"
    echo ""
    exit 1
fi

# Check if Linear CLI is authenticated
if ! linear whoami &> /dev/null; then
    echo "❌ Error: Linear CLI not authenticated"
    echo ""
    echo "Please authenticate with Linear:"
    echo "  linear auth"
    echo ""
    exit 1
fi

echo "✅ Linear CLI found and authenticated"
echo ""

# Get team ID (user must specify their team)
echo "Please enter your Linear team ID or key (e.g., 'ENG' or team UUID):"
read -p "Team: " TEAM_ID

if [ -z "$TEAM_ID" ]; then
    echo "❌ Error: Team ID required"
    exit 1
fi

echo ""
echo "📋 Creating custom workflow states for team: $TEAM_ID"
echo ""

# Note: Linear CLI doesn't have direct workflow state creation commands
# This will require using the GraphQL API directly
# Users should create these states manually via Linear UI or API

cat << 'EOF'
⚠️  MANUAL SETUP REQUIRED

The Linear CLI does not currently support creating custom workflow states.
Please create the following custom workflow states manually in Linear:

1. Go to: Settings → Teams → [Your Team] → Workflow States
2. Create the following states:

┌──────────────┬──────────┬────────────────────────────────────────────────┐
│ State Name   │ Type     │ Description                                    │
├──────────────┼──────────┼────────────────────────────────────────────────┤
│ Draft        │ started  │ Agent researching and drafting specification   │
│              │          │ Color: #6B7280 (Gray)                          │
├──────────────┼──────────┼────────────────────────────────────────────────┤
│ Spec Review  │ started  │ Awaiting human review and feedback on spec     │
│              │          │ Color: #F59E0B (Amber)                         │
├──────────────┼──────────┼────────────────────────────────────────────────┤
│ Ready        │ unstarted│ Spec approved, ready for task breakdown        │
│              │          │ Color: #10B981 (Green)                         │
├──────────────┼──────────┼────────────────────────────────────────────────┤
│ In Progress  │ started  │ Active implementation                          │
│              │          │ Color: #3B82F6 (Blue)                          │
├──────────────┼──────────┼────────────────────────────────────────────────┤
│ Verification │ started  │ Running verification checks                    │
│              │          │ Color: #8B5CF6 (Purple)                        │
├──────────────┼──────────┼────────────────────────────────────────────────┤
│ Done         │ completed│ All verification passed                        │
│              │          │ Color: #22C55E (Green)                         │
└──────────────┴──────────┴────────────────────────────────────────────────┘

WORKFLOW FLOW:
Draft → Spec Review → Ready → In Progress → Verification → Done
        ↑             ↓
        └─────────────┘ (iteration loop)

ALTERNATIVE: Use Linear GraphQL API

If you prefer to automate this, use the Linear GraphQL API:

mutation CreateWorkflowState {
  workflowStateCreate(input: {
    teamId: "YOUR_TEAM_ID"
    name: "Draft"
    color: "#6B7280"
    type: "started"
    description: "Agent researching and drafting specification"
  }) {
    success
    workflowState {
      id
      name
    }
  }
}

Repeat for each state above.

API Documentation: https://developers.linear.app/docs/graphql/working-with-the-graphql-api

EOF

echo ""
echo "📝 Verification"
echo ""
echo "After creating the states, verify them with:"
echo "  linear workflow list --team $TEAM_ID"
echo ""
echo "✅ Setup instructions displayed"
echo ""
echo "Once you've created the workflow states, you can use the hyper-engineering commands:"
echo "  /hyper:plan    - Create specifications with review gates"
echo "  /hyper:implement - Implement tasks with verification loops"
echo "  /hyper:verify  - Run comprehensive verification"
echo "  /hyper:review  - Orchestrate code review with sub-agents"
echo ""
