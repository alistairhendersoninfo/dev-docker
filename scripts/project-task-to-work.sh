#!/bin/bash

# Project Task to Enhancement Issue and Branch Creator
# This script helps convert GitHub Project tasks into actionable work items

set -e

# Configuration
PROJECT_NUMBER="6"
PROJECT_OWNER="alistairhendersoninfo"
REPO_OWNER="alistairhendersoninfo"
REPO_NAME="dev-docker"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if gh CLI is installed and authenticated
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) is not installed. Please install it first."
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        log_error "GitHub CLI is not authenticated. Please run 'gh auth login' first."
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# List project tasks
list_project_tasks() {
    log_info "Fetching project tasks..."
    
    echo
    echo "📋 Available Project Tasks:"
    echo "=========================="
    
    gh project item-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format table
}

# Get task details
get_task_details() {
    local task_title="$1"
    
    if [ -z "$task_title" ]; then
        log_error "Task title is required"
        return 1
    fi
    
    log_info "Getting details for task: $task_title"
    
    # Get task information from project
    TASK_DATA=$(gh project item-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json)
    
    # Find matching task (case-insensitive partial match)
    TASK_INFO=$(echo "$TASK_DATA" | jq -r --arg title "$task_title" '
        .items[] | 
        select(.content.title | test($title; "i")) | 
        {id: .id, title: .content.title, status: .status}
    ')
    
    if [ -z "$TASK_INFO" ] || [ "$TASK_INFO" = "null" ]; then
        log_error "Task not found: $task_title"
        log_info "Available tasks:"
        echo "$TASK_DATA" | jq -r '.items[].content.title'
        return 1
    fi
    
    echo "$TASK_INFO"
}

# Create enhancement issue
create_enhancement_issue() {
    local task_title="$1"
    local task_id="$2"
    
    log_info "Creating enhancement issue for: $task_title"
    
    # Create issue body
    local issue_body="## Enhancement Request

This issue was automatically created from GitHub Project task.

**Project**: [Dev-Docker Development Roadmap](https://github.com/users/$PROJECT_OWNER/projects/$PROJECT_NUMBER)
**Task**: $task_title
**Project Item ID**: $task_id

## Implementation Plan

- [ ] Analyze requirements and design approach
- [ ] Implement core functionality
- [ ] Add tests and documentation
- [ ] Create pull request for review

## Acceptance Criteria

To be defined based on project task requirements and technical analysis.

## Implementation Notes

Use this section to document:
- Technical decisions and rationale
- Dependencies and requirements
- Architecture considerations
- Testing strategy

---
*Auto-generated from GitHub Project task via automation script*"
    
    # Create the issue
    local issue_url
    issue_url=$(gh issue create \
        --repo "$REPO_OWNER/$REPO_NAME" \
        --title "Enhancement: $task_title" \
        --body "$issue_body" \
        --label "enhancement,project-task" \
        --assignee "$PROJECT_OWNER")
    
    local issue_number
    issue_number=$(echo "$issue_url" | grep -o '[0-9]*$')
    
    log_success "Created issue #$issue_number: $issue_url"
    
    # Add issue to project
    log_info "Adding issue to project board..."
    gh project item-add "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --url "$issue_url"
    
    echo "$issue_number"
}

# Create feature branch
create_feature_branch() {
    local issue_number="$1"
    local task_title="$2"
    
    log_info "Creating feature branch for issue #$issue_number"
    
    # Create branch name
    local branch_name
    branch_name="feature/issue-${issue_number}-$(echo "$task_title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')"
    branch_name=$(echo "$branch_name" | cut -c1-60)
    
    log_info "Branch name: $branch_name"
    
    # Ensure we're on main and up to date
    git checkout main
    git pull origin main
    
    # Create and checkout new branch
    git checkout -b "$branch_name"
    
    # Create work directory structure
    local work_dir="work/issue-${issue_number}"
    mkdir -p "$work_dir"
    
    # Create initial README
    cat > "$work_dir/README.md" << EOF
# Enhancement: $task_title

**Issue**: #${issue_number}
**Branch**: \`$branch_name\`
**Project**: [Dev-Docker Development Roadmap](https://github.com/users/$PROJECT_OWNER/projects/$PROJECT_NUMBER)

## Overview

This directory contains work for the enhancement: "$task_title"

## Implementation Progress

- [ ] Requirements analysis completed
- [ ] Design and architecture defined
- [ ] Core functionality implemented
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Integration testing completed
- [ ] Ready for code review

## Files and Structure

\`\`\`
$work_dir/
├── README.md           # This file
├── implementation/     # Core implementation files
├── tests/             # Test files
├── docs/              # Documentation
└── notes/             # Development notes and decisions
\`\`\`

## Development Notes

### Technical Decisions

Document key technical decisions and rationale here.

### Dependencies

List any new dependencies or requirements.

### Testing Strategy

Describe how this enhancement will be tested.

### Integration Points

Note any integration considerations with existing system.

## Resources

- **Issue**: #${issue_number}
- **Project Board**: https://github.com/users/$PROJECT_OWNER/projects/$PROJECT_NUMBER
- **Repository**: https://github.com/$REPO_OWNER/$REPO_NAME

---

*Created via project task automation*
EOF

    # Create supporting directories
    mkdir -p "$work_dir/implementation"
    mkdir -p "$work_dir/tests"
    mkdir -p "$work_dir/docs"
    mkdir -p "$work_dir/notes"
    
    # Create placeholder files
    echo "# Implementation files will go here" > "$work_dir/implementation/README.md"
    echo "# Test files will go here" > "$work_dir/tests/README.md"
    echo "# Documentation will go here" > "$work_dir/docs/README.md"
    echo "# Development notes and decisions" > "$work_dir/notes/README.md"
    
    # Initial commit
    git add .
    git commit -m "feat: Initialize work for issue #${issue_number} - $task_title

- Created work directory structure for enhancement
- Added initial README with task overview and progress tracking
- Created placeholder directories for implementation, tests, docs, notes
- Ready for development work

Relates to #${issue_number}
Project: https://github.com/users/$PROJECT_OWNER/projects/$PROJECT_NUMBER"
    
    # Push the branch
    git push origin "$branch_name"
    
    log_success "Created and pushed branch: $branch_name"
    echo "$branch_name"
}

# Create draft pull request
create_draft_pr() {
    local branch_name="$1"
    local issue_number="$2"
    local task_title="$3"
    
    log_info "Creating draft pull request..."
    
    local pr_body="## Enhancement Implementation

**Implements**: #${issue_number}
**Project Board**: [Dev-Docker Development Roadmap](https://github.com/users/$PROJECT_OWNER/projects/$PROJECT_NUMBER)

## Overview

This pull request implements the enhancement: \"$task_title\"

## Changes

- [ ] Core functionality implemented
- [ ] Tests added and passing
- [ ] Documentation updated
- [ ] Integration with existing system verified
- [ ] Code review feedback addressed

## Implementation Details

### Architecture

(Describe the architectural approach and key design decisions)

### Key Components

(List the main components/files changed or added)

### Dependencies

(Note any new dependencies or requirements)

## Testing

### Test Strategy

(Describe the testing approach)

### Test Coverage

- [ ] Unit tests added
- [ ] Integration tests added
- [ ] Manual testing completed
- [ ] Performance testing (if applicable)

## Documentation

- [ ] Code comments added
- [ ] README updated (if applicable)
- [ ] Architecture documentation updated
- [ ] User documentation updated (if applicable)

## Checklist

- [ ] Code follows project standards and conventions
- [ ] All tests pass
- [ ] Documentation is updated and accurate
- [ ] No breaking changes introduced
- [ ] Security considerations addressed
- [ ] Performance impact evaluated
- [ ] Ready for code review

## Deployment Notes

(Any special considerations for deployment)

## Breaking Changes

(List any breaking changes, or note 'None')

---

**Closes**: #${issue_number}
**Project**: https://github.com/users/$PROJECT_OWNER/projects/$PROJECT_NUMBER"
    
    # Create draft PR
    local pr_url
    pr_url=$(gh pr create \
        --repo "$REPO_OWNER/$REPO_NAME" \
        --title "feat: $task_title" \
        --body "$pr_body" \
        --head "$branch_name" \
        --base "main" \
        --draft \
        --label "enhancement,project-task")
    
    log_success "Created draft PR: $pr_url"
    
    # Add PR to project
    log_info "Adding PR to project board..."
    gh project item-add "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --url "$pr_url"
    
    echo "$pr_url"
}

# Main function
main() {
    echo "🚀 Project Task to Enhancement Workflow"
    echo "======================================="
    echo
    
    check_prerequisites
    
    if [ $# -eq 0 ]; then
        echo "Usage: $0 [TASK_TITLE_PATTERN]"
        echo
        echo "Examples:"
        echo "  $0 \"n8n\"                    # Find tasks containing 'n8n'"
        echo "  $0 \"Create PostgreSQL\"      # Find tasks containing 'Create PostgreSQL'"
        echo "  $0                           # Show all tasks and prompt for selection"
        echo
        list_project_tasks
        echo
        read -p "Enter task title or pattern to search for: " task_input
    else
        task_input="$1"
    fi
    
    if [ -z "$task_input" ]; then
        log_error "No task specified"
        exit 1
    fi
    
    # Get task details
    task_info=$(get_task_details "$task_input")
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    task_title=$(echo "$task_info" | jq -r '.title')
    task_id=$(echo "$task_info" | jq -r '.id')
    task_status=$(echo "$task_info" | jq -r '.status')
    
    echo
    log_info "Selected task: $task_title"
    log_info "Task ID: $task_id"
    log_info "Current status: $task_status"
    echo
    
    # Confirm action
    read -p "Create enhancement issue and branch for this task? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Operation cancelled"
        exit 0
    fi
    
    echo
    log_info "Starting workflow automation..."
    
    # Create enhancement issue
    issue_number=$(create_enhancement_issue "$task_title" "$task_id")
    
    # Create feature branch
    branch_name=$(create_feature_branch "$issue_number" "$task_title")
    
    # Create draft PR
    pr_url=$(create_draft_pr "$branch_name" "$issue_number" "$task_title")
    
    echo
    log_success "🎉 Workflow completed successfully!"
    echo
    echo "📋 Summary:"
    echo "==========="
    echo "• Issue: #$issue_number"
    echo "• Branch: $branch_name"
    echo "• PR: $pr_url"
    echo "• Work Directory: work/issue-$issue_number/"
    echo
    echo "🔧 Next Steps:"
    echo "=============="
    echo "1. Switch to the branch: git checkout $branch_name"
    echo "2. Start implementing in: work/issue-$issue_number/"
    echo "3. Update the PR when ready for review"
    echo "4. Link the PR to close the issue when merged"
    echo
}

# Run main function
main "$@"
