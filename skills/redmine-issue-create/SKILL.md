---
name: redmine-issue-create
description: Create new issues in Redmine project management system via REST API. Use when the user wants to create a new bug report, feature request, task, or any other issue type in Redmine. Typical triggers include "create a Redmine issue", "log this bug in Redmine", "add a task to Redmine", or when documenting problems that should be tracked.
---

# Redmine Issue Create

Create new issues in Redmine project management system directly from your coding workflow.

## Overview

This skill enables creating Redmine issues via the REST API without leaving your development environment. It's useful for quickly logging bugs, feature requests, tasks, or any other issue types discovered during development.

**IMPORTANT**: All issue descriptions and comments **MUST** use Textile markup format, which is Redmine's default text formatting system.

## Textile Formatting (REQUIRED)

Redmine uses Textile markup for text formatting. **Always format descriptions and comments using Textile syntax.**

### Common Textile Syntax

- **Headers**: `h1.`, `h2.`, `h3.` followed by text
- **Bold**: `*text*`
- **Italic**: `_text_`
- **Inline code**: `@code@`
- **Code blocks**: `<pre><code>your code here</code></pre>`
- **Numbered lists**: `#` at start of line
- **Bulleted lists**: `*` at start of line
- **Links**: `"link text":url`
- **Line break**: Leave empty line between paragraphs

### Example Textile Formatting

```textile
h2. Bug Description

When using special characters like @#$@ in password, login fails.

h3. Steps to Reproduce

# Navigate to login page
# Enter valid username
# Enter password with special chars
# Click login button

h3. Expected vs Actual

*Expected:* Login succeeds with valid credentials
*Actual:* Error message displayed

See @validatePassword()@ function in "authentication module":https://example.com/auth.js
```

## Prerequisites

Set these environment variables before using this skill:

- `REDMINE_URL` - Your Redmine server URL (e.g., `https://redmine.example.com`)
- `REDMINE_API_KEY` - Your API key (found at `/my/account` when logged in)
- `REDMINE_PROJECT_ID` (optional) - Default project ID to use

Example setup in `~/.bashrc` or `~/.zshrc`:
```bash
export REDMINE_URL="https://redmine.example.com"
export REDMINE_API_KEY="your_api_key_here"
export REDMINE_PROJECT_ID="1"
```

## Workflow

### 1. Gather Issue Information

Ask the user for:
- **Project** - Project ID or identifier (optional if `REDMINE_PROJECT_ID` is set)
- **Subject** - Brief title for the issue (required)
- **Description** - Detailed description (optional but recommended)
- **Tracker** - Issue type: Bug, Feature, Support, Task (default: Bug)
- **Priority** - Priority level: Low, Normal, High, Urgent, Immediate (default: Normal)
- **Assigned to** - User ID to assign (optional)
- **Status** - Initial status (optional, uses project default)

If project ID is not provided and `REDMINE_PROJECT_ID` is not set, first fetch the list of available projects.

### 2. Get Available Projects (if needed)

Fetch projects list to help user choose:

```bash
curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/projects.json" | jq '.projects[] | {id, name, identifier}'
```

### 3. Map Tracker and Priority to IDs

Redmine uses numeric IDs for trackers and priorities. Common mappings:

**Trackers:**
- Bug: 1
- Feature: 2
- Support: 3
- Task: 4

**Priorities:**
- Low: 1
- Normal: 2
- High: 3
- Urgent: 4
- Immediate: 5

If unsure, fetch the actual values:
```bash
# Get trackers
curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/trackers.json" | jq '.trackers[] | {id, name}'

# Get priorities
curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/enumerations/issue_priorities.json" | jq '.issue_priorities[] | {id, name}'
```

### 4. Create the Issue

Build JSON payload with **Textile-formatted description** and send POST request:

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "issue": {
      "project_id": 1,
      "subject": "Bug: Login fails with special characters",
      "description": "h2. Bug Description\n\nWhen using special characters like @#$@ in password, login fails.\n\nh3. Steps to Reproduce\n\n# Navigate to login page\n# Enter valid username\n# Enter password with special chars\n# Click login button\n\nh3. Expected vs Actual\n\n*Expected:* Login succeeds with valid credentials\n*Actual:* Error message displayed",
      "tracker_id": 1,
      "priority_id": 3,
      "status_id": 1
    }
  }' \
  "${REDMINE_URL}/issues.json"
```

### 5. Handle Response

Parse the response to:
- Extract the created issue ID
- Build the issue URL: `${REDMINE_URL}/issues/{issue_id}`
- Display success message with clickable link
- Handle errors gracefully (authentication failures, validation errors, network issues)

Example success response parsing:
```bash
response=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{...}' \
  "${REDMINE_URL}/issues.json")

issue_id=$(echo "$response" | jq -r '.issue.id')
if [ "$issue_id" != "null" ]; then
  echo "✅ Issue created successfully: ${REDMINE_URL}/issues/${issue_id}"
else
  echo "❌ Failed to create issue"
  echo "$response" | jq '.errors'
fi
```

## Advanced Features

### Add Watchers

Include watcher user IDs when creating:
```json
{
  "issue": {
    "project_id": 1,
    "subject": "Issue title",
    "watcher_user_ids": [2, 5, 10]
  }
}
```

### Set Due Date

Add a due date (YYYY-MM-DD format):
```json
{
  "issue": {
    "project_id": 1,
    "subject": "Issue title",
    "due_date": "2026-02-15"
  }
}
```

### Include File Context

When creating issues from code, automatically include:
- File path where issue was found
- Line numbers if applicable
- Code snippet in description using Textile formatting

Example description with context in **Textile format**:
```textile
h2. Bug in Authentication Module

*File:* @src/auth/login.js:45-52@

<pre><code class="javascript">
function validatePassword(password) {
  // Bug: doesn't escape special characters
  return password.match(/^[a-zA-Z0-9]+$/);
}
</code></pre>

h3. Problem

*Expected:* Should allow special characters in passwords
*Actual:* Rejects valid passwords containing special characters like @@, #, $
```

## Error Handling

Common errors and solutions:

- **401 Unauthorized**: Invalid API key or API not enabled
  - Check `REDMINE_API_KEY` is correct
  - Verify REST API is enabled in Redmine (Administration → Settings → API)

- **403 Forbidden**: Insufficient permissions
  - Ensure user has permission to create issues in the project

- **404 Not Found**: Invalid project ID or endpoint
  - Verify `REDMINE_URL` is correct
  - Check project ID exists

- **422 Unprocessable Entity**: Validation errors
  - Check required fields are provided
  - Verify tracker_id and priority_id are valid

## Resources

### references/

See `references/api_reference.md` for complete Redmine REST API documentation including:
- All available issue fields
- Custom fields support
- Attachment uploads
- Advanced query options
