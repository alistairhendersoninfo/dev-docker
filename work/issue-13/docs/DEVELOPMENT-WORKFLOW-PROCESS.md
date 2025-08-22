# Development Workflow Process

## Mandatory Process Flow for All Development Tasks

This document defines the **mandatory workflow** that Claude must follow for all development tasks to prevent errors and ensure proper testing.

### 🚨 Critical Rules

1. **NEVER mark tasks complete without testing**
2. **ALWAYS work on remote server for builds/tests**
3. **ALWAYS use GitHub MCP server for GitHub operations**
4. **ALWAYS report back with results**
5. **ALWAYS follow the TODO workflow**

### 📋 Step-by-Step Process

#### Phase 1: Task Planning
```
1. Create comprehensive TODO list
2. Break down complex tasks into testable steps
3. Identify which tasks need local vs remote work
4. Mark first task as "in_progress"
```

#### Phase 2: Server Context Decision
```
LOCAL ONLY:
- Documentation writing
- Git operations (commit, push)
- Code editing
- File creation

REMOTE ONLY:
- Docker builds
- Container testing
- Service deployment
- System configuration
- Port/network testing

BOTH (Local → Remote):
- Create files locally
- Commit and push
- Pull and test on remote
```

#### Phase 3: Execution

**For Local Work:**
```
1. Work in local environment
2. Create/edit files as needed
3. Commit changes with descriptive messages
4. Push to repository
5. Update TODO status
```

**For Remote Work:**
```
1. Connect via SSH MCP server
2. Verify connection: whoami && hostname && pwd
3. Navigate to project directory
4. Pull latest changes from repository
5. Execute the task
6. Test and verify results
7. ONLY mark complete if tests pass
```

**For GitHub Operations:**
```
1. Use GitHub MCP server tools (PRIMARY)
2. Use gh CLI only for Projects V2 or as backup
3. Examples:
   - mcp_github-mcp-server_create_issue (NOT gh issue create)
   - mcp_github-mcp-server_list_issues (NOT gh issue list)
```

#### Phase 4: Testing & Validation

**Before Marking Complete:**
```
1. Run actual tests (build, deploy, access)
2. Verify functionality works as expected
3. Check logs for errors
4. Test integration points
5. Document any issues found
```

**Testing Examples:**
```
Docker Build: docker build -t image:tag .
Service Test: curl http://localhost:port/health
Container Run: docker run -d --name test image:tag
Log Check: docker logs container_name
```

#### Phase 5: Completion & Reporting

**Task Completion:**
```
1. Mark TODO as completed ONLY after successful testing
2. Update issue with progress
3. Report results to user with specific details
4. Move to next task or mark issue complete
```

**Reporting Format:**
```
REPORT:
✅/❌ [Task Status]
- Server: [hostname]
- Action: [what was done]
- Result: [what was found/created/status]
- Tests: [what tests were run]
- Issues: [any problems encountered]
```

### 🔄 Error Recovery Process

**When Things Go Wrong:**
```
1. Stop current process
2. Identify what went wrong
3. Update TODO status to reflect reality
4. Clean up any partial work
5. Fix the issue
6. Re-test from the beginning
7. Only then mark as complete
```

**Common Mistakes to Avoid:**
```
❌ Working locally for Docker builds
❌ Marking tasks complete without testing
❌ Using gh CLI instead of GitHub MCP server
❌ Not reporting back to user
❌ Skipping the TODO workflow
❌ Not cleaning up failed attempts
```

### 📊 Process Validation Checklist

Before marking any task complete, verify:

- [ ] Task was executed in correct environment (local/remote)
- [ ] All tests passed successfully
- [ ] Integration points work correctly
- [ ] No errors in logs
- [ ] Documentation is updated
- [ ] Changes are committed and pushed
- [ ] User has been informed of results

### 🎯 Success Criteria

A task is only complete when:

1. **Functionality works** as specified
2. **Tests pass** in the target environment
3. **Integration** with existing systems verified
4. **Documentation** is updated
5. **Code is committed** and pushed
6. **User is informed** with detailed report

### 🔧 Tools & Commands Reference

**SSH MCP Server:**
```
mcp_ssh-mcp-server_exec: whoami && hostname && pwd
mcp_ssh-mcp-server_exec: cd project && git pull origin branch
mcp_ssh-mcp-server_exec: docker build -t image .
```

**GitHub MCP Server:**
```
mcp_github-mcp-server_list_issues(owner="user", repo="repo")
mcp_github-mcp-server_create_issue(owner="user", repo="repo", title="Title")
mcp_github-mcp-server_get_issue(owner="user", repo="repo", issue_number=13)
```

**TODO Management:**
```
todo_write(merge=true, todos=[{id, content, status}])
Status options: "pending", "in_progress", "completed", "cancelled"
```

### 📈 Continuous Improvement

This process should be:
- **Followed strictly** for all development tasks
- **Updated** when new patterns emerge
- **Referenced** when things go wrong
- **Used as training** for consistent behavior

---

**Remember: The goal is reliable, tested, working code - not just files that look correct!**
