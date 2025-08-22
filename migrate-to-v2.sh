#!/bin/bash

# GitHub Projects V2 Migration Script
# Migrates all DraftIssues from old project to new V2 project

PROJECT_V2_ID="7"
OWNER="alistairhendersoninfo"

echo "Starting migration to GitHub Projects V2..."
echo "Target Project ID: $PROJECT_V2_ID"
echo ""

# Read each task and create it in the V2 project
cat detailed-draft-issues.json | jq -c '.' | while read -r task; do
    title=$(echo "$task" | jq -r '.title')
    body=$(echo "$task" | jq -r '.body')
    status=$(echo "$task" | jq -r '.status')
    
    echo "Creating: $title"
    
    # Create the item in V2 project
    gh project item-create "$PROJECT_V2_ID" \
        --owner "$OWNER" \
        --title "$title" \
        --body "$body"
    
    if [ $? -eq 0 ]; then
        echo "✓ Created successfully"
    else
        echo "✗ Failed to create"
    fi
    echo ""
done

echo "Migration completed!"
echo "Checking new project contents..."
gh project item-list "$PROJECT_V2_ID" --owner "$OWNER" --format json | jq -r '.items | length' | xargs printf "Total items in V2 project: %s\n"

