# Work Directory

This directory contains active development work for GitHub Project tasks that have been converted to enhancement issues and feature branches.

## Structure

Each enhancement gets its own subdirectory named `issue-{NUMBER}`:

```
work/
├── README.md           # This file
├── issue-1/           # Work for issue #1
│   ├── README.md      # Issue overview and progress
│   ├── implementation/ # Core implementation files
│   ├── tests/         # Test files
│   ├── docs/          # Documentation
│   └── notes/         # Development notes
├── issue-2/           # Work for issue #2
│   └── ...
└── issue-N/           # Work for issue #N
    └── ...
```

## Workflow

### 1. Task to Issue Conversion

Use the automation script to convert a GitHub Project task to an enhancement issue:

```bash
# Interactive mode - shows all tasks
./scripts/project-task-to-work.sh

# Search for specific task
./scripts/project-task-to-work.sh "n8n"
./scripts/project-task-to-work.sh "PostgreSQL"
```

This script will:
- Create an enhancement issue from the project task
- Create a feature branch
- Set up the work directory structure
- Create a draft pull request
- Link everything together

### 2. Development Process

1. **Switch to feature branch**:
   ```bash
   git checkout feature/issue-{NUMBER}-{task-name}
   ```

2. **Work in the issue directory**:
   ```bash
   cd work/issue-{NUMBER}/
   ```

3. **Implement the enhancement**:
   - Add code to `implementation/`
   - Add tests to `tests/`
   - Update documentation in `docs/`
   - Record decisions in `notes/`

4. **Update progress**:
   - Check off items in the issue README
   - Update the pull request description
   - Commit changes regularly

5. **Ready for review**:
   - Mark PR as ready for review (remove draft status)
   - Request code review
   - Address feedback

6. **Merge and cleanup**:
   - Merge the PR
   - Delete the feature branch
   - Move work directory to `work/completed/` (optional)

### 3. Directory Guidelines

#### `implementation/`
- Core implementation files
- New Docker containers, scripts, configurations
- Follow existing project structure and naming conventions

#### `tests/`
- Unit tests for new functionality
- Integration tests
- Test data and fixtures
- Testing documentation

#### `docs/`
- Feature documentation
- API documentation
- Architecture decisions
- User guides

#### `notes/`
- Development journal
- Technical decisions and rationale
- Meeting notes and discussions
- Research findings
- Troubleshooting notes

## Automation Integration

### GitHub Actions

The project includes GitHub Actions workflows that can:
- Automatically create issues and branches when tasks move to "In Progress"
- Update project status based on PR progress
- Run tests and checks on feature branches

### Manual Scripts

- `scripts/project-task-to-work.sh` - Convert project task to working issue/branch
- `scripts/create-project.sh` - Create new project structures (existing)

## Best Practices

### Commit Messages

Use conventional commit format:
```
feat: implement n8n automation server container
fix: resolve DNS configuration issue
docs: add API documentation
test: add integration tests for container management
```

### Branch Naming

Branches are automatically named as:
```
feature/issue-{NUMBER}-{shortened-task-name}
```

### Work Organization

- Keep work directories focused on single enhancements
- Document decisions and rationale in `notes/`
- Maintain clear separation between implementation and tests
- Update README progress regularly

### Integration

- Test integration with existing system early
- Follow existing code patterns and conventions
- Update relevant documentation
- Consider backward compatibility

## Examples

### Example 1: n8n Server Implementation

```
work/issue-15/
├── README.md                    # Overview and progress tracking
├── implementation/
│   ├── docker/
│   │   └── n8n/
│   │       ├── Dockerfile
│   │       └── n8n.yml
│   └── scripts/
│       └── setup-n8n.sh
├── tests/
│   ├── test-n8n-deployment.sh
│   └── test-webhooks.py
├── docs/
│   ├── n8n-setup-guide.md
│   └── webhook-api.md
└── notes/
    ├── technical-decisions.md
    └── integration-points.md
```

### Example 2: PostgreSQL Database

```
work/issue-16/
├── README.md
├── implementation/
│   ├── docker/
│   │   └── postgresql/
│   │       ├── Dockerfile
│   │       └── init-scripts/
│   ├── sql/
│   │   ├── schema.sql
│   │   └── migrations/
│   └── api/
│       └── database-config.js
├── tests/
│   ├── test-schema.sql
│   └── test-api-integration.js
├── docs/
│   ├── database-schema.md
│   └── api-endpoints.md
└── notes/
    └── performance-considerations.md
```

## Cleanup

### Completed Work

When an enhancement is completed and merged:

1. **Archive the work directory**:
   ```bash
   mkdir -p work/completed/
   mv work/issue-{NUMBER}/ work/completed/
   ```

2. **Update documentation**:
   - Add to main project documentation
   - Update architecture diagrams
   - Record lessons learned

3. **Clean up branches**:
   ```bash
   git branch -d feature/issue-{NUMBER}-{name}
   git push origin --delete feature/issue-{NUMBER}-{name}
   ```

### Work in Progress

- Keep active work directories in `work/`
- Regular commits and pushes
- Update progress tracking
- Communicate status in PR and project board

---

## Related Documentation

- [GitHub Project Management](../.claude/project-workflow/GITHUB-PROJECT.md)
- [Architecture Overview](../docs/AUTOMATION-ARCHITECTURE.md)
- [Development Workflow](../docs/README.md)

---

**Last Updated**: August 22, 2025  
**Purpose**: Organize feature development from GitHub Project tasks  
**Automation**: Integrated with GitHub Actions and project management
