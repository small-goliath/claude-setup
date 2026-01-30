---
name: redmine-log-time
description: Log time entries to Redmine issues for time tracking. Use when the user wants to record work hours, track time spent on tasks, or log billable hours. Typical triggers include "log time to Redmine", "record work hours", "track time on issue", or when documenting time spent on development work.
---

# Redmine Log Time

Log work hours and track time spent on Redmine issues.

## Overview

This skill enables creating time entries in Redmine via REST API. Track hours worked on issues, specify activities, and add descriptions directly from your development environment.

**IMPORTANT**: All time entry comments **MUST** use Textile markup format, which is Redmine's default text formatting system.

## Textile Formatting (REQUIRED)

Redmine uses Textile markup for text formatting. **Always format time entry comments using Textile syntax.**

### Common Textile Syntax

- **Headers**: `h3.`, `h4.` followed by text
- **Bold**: `*text*`
- **Italic**: `_text_`
- **Inline code**: `@code@`
- **Numbered lists**: `#` at start of line
- **Bulleted lists**: `-` at start of line (avoid `*` to prevent confusion with bold)
- **Links**: `"link text":url`

### Example Textile Comment

```textile
h3. Development Work

Implemented authentication feature:

# Updated @validatePassword()@ function
# Added unit tests
# Refactored login flow

See "commit abc123":https://github.com/project/commit/abc123
```

## Prerequisites

Set these environment variables:

- `REDMINE_URL` - Your Redmine server URL (e.g., `https://redmine.example.com`)
- `REDMINE_API_KEY` - Your API key (found at `/my/account` when logged in)

## Quick Usage

### Log Time to Issue

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "time_entry": {
      "issue_id": 123,
      "hours": 2.5,
      "activity_id": 9,
      "comments": "h3. Authentication Feature\n\nImplemented password validation:\n\n# Updated @validatePassword()@ function\n# Added special character support\n# Created unit tests"
    }
  }' \
  "${REDMINE_URL}/time_entries.json"
```

### Log Time to Project

When not tied to a specific issue:
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "time_entry": {
      "project_id": 1,
      "hours": 1.5,
      "activity_id": 9,
      "comments": "h3. Team Meeting\n\n*Sprint planning and retrospective*\n\nDiscussed:\n- Sprint goals\n- Task assignments\n- Technical challenges"
    }
  }' \
  "${REDMINE_URL}/time_entries.json"
```

## Time Entry Fields

### Required Fields

- `hours` - Decimal hours spent (e.g., 1.5 for 1 hour 30 minutes)
- `activity_id` - Activity type ID
- Either `issue_id` OR `project_id` (one is required)

### Optional Fields

- `comments` - Description of work performed
- `spent_on` - Date in YYYY-MM-DD format (default: today)
- `user_id` - User ID (for managers logging time for others)

## Activities

Common activity IDs (may vary by Redmine configuration):

- 8: Design
- 9: Development
- 10: Testing
- 11: Documentation
- 12: Support
- 13: Meeting

### Get Available Activities

Fetch activity list from your Redmine instance:
```bash
curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/enumerations/time_entry_activities.json" | \
  jq '.time_entry_activities[] | {id, name}'
```

## Workflow

### 1. Identify Issue or Project

Get issue ID:
```bash
# Find your open issues
curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?assigned_to_id=me&status_id=open" | \
  jq '.issues[] | {id, subject}'
```

### 2. Determine Activity Type

Choose appropriate activity ID based on work performed:
- Development: Code implementation
- Testing: QA and testing
- Documentation: Writing docs
- Support: Bug fixes and support

### 3. Calculate Hours

Convert time to decimal hours:
- 30 minutes = 0.5
- 1 hour 15 minutes = 1.25
- 2 hours 30 minutes = 2.5
- 45 minutes = 0.75

### 4. Create Time Entry

Submit time entry with **Textile-formatted description**:
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "time_entry": {
      "issue_id": 123,
      "hours": 2.5,
      "activity_id": 9,
      "comments": "h3. Bug Fix & Testing\n\nFixed authentication bug in @login.js@:\n\n# Updated password validation regex\n# Added edge case unit tests\n# Verified with manual testing\n\n*Status:* All tests passing"
    }
  }' \
  "${REDMINE_URL}/time_entries.json"
```

### 5. Verify Entry

Response includes created time entry:
```json
{
  "time_entry": {
    "id": 456,
    "project": {"id": 1, "name": "Project Name"},
    "issue": {"id": 123},
    "user": {"id": 1, "name": "John Doe"},
    "activity": {"id": 9, "name": "Development"},
    "hours": 2.5,
    "comments": "Fixed authentication bug and added unit tests",
    "spent_on": "2026-01-27",
    "created_on": "2026-01-27T15:30:00Z"
  }
}
```

## Common Scenarios

### Log Today's Work

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "time_entry": {
      "issue_id": 123,
      "hours": 4.0,
      "activity_id": 9,
      "comments": "h3. User Dashboard Implementation\n\n*Frontend & Backend Development*\n\nCompleted:\n# Created React components (@Dashboard.jsx@, @UserCard.jsx@)\n# Added API endpoints (@/api/dashboard@)\n# Wrote unit tests with Jest\n\n*Status:* Ready for code review"
    }
  }' \
  "${REDMINE_URL}/time_entries.json"
```

### Log Past Work

Backlog time for a specific date:
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "time_entry": {
      "issue_id": 123,
      "hours": 3.0,
      "activity_id": 9,
      "spent_on": "2026-01-25",
      "comments": "h3. Database Optimization\n\nOptimized slow queries:\n\n# Added indexes to @users@ table\n# Refactored @getUserStats()@ query\n# Reduced query time from 2.5s to 150ms\n\n*Result:* 94% performance improvement"
    }
  }' \
  "${REDMINE_URL}/time_entries.json"
```

### Log Multiple Activities

For different types of work on same issue:
```bash
# Development time
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "time_entry": {
      "issue_id": 123,
      "hours": 3.0,
      "activity_id": 9,
      "comments": "h3. Feature Implementation\n\nDeveloped new export functionality:\n\n# Created @ExportService@ class\n# Implemented CSV and PDF export\n# Added error handling"
    }
  }' \
  "${REDMINE_URL}/time_entries.json"

# Testing time
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "time_entry": {
      "issue_id": 123,
      "hours": 1.5,
      "activity_id": 10,
      "comments": "h3. Testing & Bug Fixes\n\n*QA Activities:*\n\n# Unit test coverage: 95%\n# Integration tests created\n# Fixed edge case bugs\n# Manual testing completed"
    }
  }' \
  "${REDMINE_URL}/time_entries.json"
```

## View Time Entries

### Get Time Entries for Issue

```bash
curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/time_entries.json?issue_id=123" | \
  jq '.time_entries[] | {user: .user.name, hours, activity: .activity.name, comments, date: .spent_on}'
```

### Get My Time Entries

```bash
curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/time_entries.json?user_id=me&limit=100" | \
  jq '.time_entries[] | {issue: .issue.id, hours, activity: .activity.name, date: .spent_on}'
```

### Get Time Entries for Date Range

```bash
curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/time_entries.json?user_id=me&from=2026-01-20&to=2026-01-27" | \
  jq '.time_entries | group_by(.spent_on) | map({date: .[0].spent_on, total_hours: (map(.hours) | add)})'
```

## Tips

- **ALWAYS use Textile formatting** for all comments
- Be descriptive in comments - explain what was accomplished using Textile headers (h3., h4.)
- Log time daily to ensure accuracy
- Use appropriate activity types for better reporting
- Round to nearest 0.25 hours for simplicity
- Include context like file paths using inline code format: `@filename.js@`
- Use Textile lists to structure work accomplished
- Link to commits using Textile syntax: `"commit abc123":url`
- Split different activity types into separate entries
- Log time as you work or at end of day while fresh in memory
- Use consistent Textile format for easier tracking and readability
- Bold key achievements with `*text*` for quick scanning

## Integration with Development Workflow

### Log Time After Commit

```bash
# After committing code, log the time spent
git commit -m "Fix authentication bug"
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-KEY: ${REDMINE_API_KEY}" \
  -d '{
    "time_entry": {
      "issue_id": 123,
      "hours": 2.0,
      "activity_id": 9,
      "comments": "h3. Authentication Bug Fix\n\nFixed password validation issue:\n\n# Updated @validatePassword()@ in @auth/login.js@\n# Added regex to support special characters\n# Created unit tests\n\nSee \"commit abc123\":https://github.com/project/commit/abc123"
    }
  }' \
  "${REDMINE_URL}/time_entries.json"
```

### Log Time When Closing Issue

```bash
# Update issue and log final time in one workflow
curl -X PUT \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "issue": {
      "status_id": 5,
      "done_ratio": 100
    }
  }' \
  "${REDMINE_URL}/issues/123.json"

curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "time_entry": {
      "issue_id": 123,
      "hours": 1.0,
      "activity_id": 10,
      "comments": "h3. Final Testing & Closure\n\n*QA Complete:*\n\n# Regression testing: *PASS*\n# Performance testing: *PASS*\n# Security review: *PASS*\n\n*Status:* Issue verified and closed. Ready for deployment."
    }
  }' \
  "${REDMINE_URL}/time_entries.json"
```
