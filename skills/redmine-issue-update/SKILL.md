---
name: redmine-issue-update
description: Update existing Redmine issues via REST API. Use when the user wants to change issue status, add comments, update progress, reassign issues, or modify any issue fields. Typical triggers include "update Redmine issue", "mark issue as resolved", "add comment to issue", "change issue status", or when documenting progress on tracked work.
---

# Redmine Issue Update

Update existing Redmine issues including status changes, progress tracking, adding comments, and modifying fields.

## Overview

This skill enables updating Redmine issues via REST API. Use it to change issue status, update progress, add comments, reassign issues, or modify any other issue fields without leaving your development workflow.

**IMPORTANT**: All comments (notes field) **MUST** use Textile markup format, which is Redmine's default text formatting system.

## Textile Formatting (REQUIRED)

Redmine uses Textile markup for text formatting. **Always format comments (notes) using Textile syntax.**

### Common Textile Syntax

- **Headers**: `h2.`, `h3.` followed by text
- **Bold**: `*text*`
- **Italic**: `_text_`
- **Inline code**: `@code@`
- **Code blocks**: `<pre><code>code</code></pre>`
- **Numbered lists**: `#` at start of line
- **Bulleted lists**: `*` at start of line (use `-` to avoid confusion with bold)
- **Links**: `"link text":url`

### Example Textile Comment

```textile
h3. Fix Applied

Fixed the authentication bug. The issue was in the @validatePassword()@ function.

h4. Changes Made

# Updated password regex to allow special characters
# Added unit tests for edge cases
# Updated documentation

See commit "abc123":https://github.com/project/commit/abc123 for details.
```

## Prerequisites

Set these environment variables:

- `REDMINE_URL` - Your Redmine server URL (e.g., `https://redmine.example.com`)
- `REDMINE_API_KEY` - Your API key (found at `/my/account` when logged in)

## Common Operations

### Update Issue Status

Change status to "In Progress" with **Textile-formatted comment**:
```bash
curl -X PUT \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "issue": {
      "status_id": 2,
      "notes": "h3. Status Update\n\nStarted working on this issue. Initial analysis complete."
    }
  }' \
  "${REDMINE_URL}/issues/123.json"
```

Common status IDs:
- 1: New
- 2: In Progress
- 3: Resolved
- 4: Feedback
- 5: Closed

### Add Comment

Add a note/comment to an issue using **Textile formatting**:
```bash
curl -X PUT \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "issue": {
      "notes": "h3. Bug Fixed\n\nFixed the authentication bug. The issue was in the @validatePassword()@ function in the password validation logic.\n\nh4. Root Cause\n\nThe regex pattern was rejecting special characters that should be allowed."
    }
  }' \
  "${REDMINE_URL}/issues/123.json"
```

### Update Progress

Set completion percentage with **Textile-formatted note**:
```bash
curl -X PUT \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "issue": {
      "done_ratio": 75,
      "notes": "h3. Progress Update: 75%\n\n*Current Phase:* Testing\n\nCompleted:\n# Implementation\n# Code review\n# Unit tests\n\nRemaining:\n# Integration testing\n# Documentation"
    }
  }' \
  "${REDMINE_URL}/issues/123.json"
```

### Reassign Issue

Assign to different user with **Textile-formatted note**:
```bash
curl -X PUT \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "issue": {
      "assigned_to_id": 5,
      "notes": "h3. Reassignment\n\nReassigning to *backend team* for database-related changes.\n\nThis requires expertise in PostgreSQL query optimization."
    }
  }' \
  "${REDMINE_URL}/issues/123.json"
```

### Close Issue

Mark issue as resolved and closed with **Textile-formatted note**:
```bash
curl -X PUT \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "issue": {
      "status_id": 5,
      "done_ratio": 100,
      "notes": "h3. Resolution\n\n*Status:* Issue resolved and tested successfully\n\nh4. Testing Completed\n\n# Unit tests passing\n# Integration tests passing\n# Manual QA completed\n\nReady for deployment."
    }
  }' \
  "${REDMINE_URL}/issues/123.json"
```

## Workflow

### 1. Get Current Issue State

First fetch the current issue to see its status:
```bash
curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues/123.json" | \
  jq '{id: .issue.id, subject: .issue.subject, status: .issue.status.name, progress: .issue.done_ratio}'
```

### 2. Prepare Update

Determine which fields to update:
- Status change (status_id)
- Progress update (done_ratio)
- Assignment (assigned_to_id)
- Priority (priority_id)
- Due date (due_date)
- Comment (notes)

### 3. Send Update Request

Use PUT request with updated fields:
```bash
curl -X PUT \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "issue": {
      "field_to_update": "new_value",
      "notes": "Optional comment explaining the change"
    }
  }' \
  "${REDMINE_URL}/issues/{issue_id}.json"
```

### 4. Verify Update

Check response status:
- 200 OK: Update successful (response may be empty)
- 404 Not Found: Issue doesn't exist
- 422 Unprocessable Entity: Validation error

## Advanced Updates

### Update Multiple Fields

```bash
curl -X PUT \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "issue": {
      "status_id": 2,
      "priority_id": 3,
      "done_ratio": 50,
      "due_date": "2026-02-15",
      "notes": "h3. Updates Applied\n\n*Priority:* Increased to *High* due to customer impact\n*Due Date:* Set to 2026-02-15\n*Progress:* 50% complete\n\nNext steps:\n# Complete implementation\n# Code review\n# Testing"
    }
  }' \
  "${REDMINE_URL}/issues/123.json"
```

### Update Custom Fields

```bash
curl -X PUT \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "issue": {
      "custom_fields": [
        {"id": 1, "value": "Updated value"}
      ],
      "notes": "h3. Custom Field Updated\n\nUpdated *Environment* field to reflect new deployment target."
    }
  }' \
  "${REDMINE_URL}/issues/123.json"
```

### Add Private Note

```bash
curl -X PUT \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "issue": {
      "notes": "h3. Internal Note\n\n_Private comment for team only_\n\nThis issue requires database credentials update. Contact ops team for production access.",
      "private_notes": true
    }
  }' \
  "${REDMINE_URL}/issues/123.json"
```

## Common Workflows

### Mark as In Progress

When starting work on an issue:
```bash
curl -X PUT \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "issue": {
      "status_id": 2,
      "done_ratio": 10,
      "notes": "h3. Work Started\n\nBeginning implementation. Initial analysis shows:\n\n# Need to update @auth@ module\n# Requires new unit tests\n# Documentation update needed"
    }
  }' \
  "${REDMINE_URL}/issues/123.json"
```

### Request Feedback

When ready for review:
```bash
curl -X PUT \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "issue": {
      "status_id": 4,
      "done_ratio": 90,
      "notes": "h3. Ready for Review\n\n*Status:* Implementation complete\n\nh4. Please Review\n\n# Code changes in @src/auth@ module\n# New unit tests added\n# Documentation updated\n\nSee \"pull request\":https://github.com/project/pull/123 for details."
    }
  }' \
  "${REDMINE_URL}/issues/123.json"
```

### Resolve Issue

When work is complete:
```bash
curl -X PUT \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "issue": {
      "status_id": 3,
      "done_ratio": 100,
      "notes": "h3. Resolution Complete\n\n*Status:* Bug fixed and tested successfully\n\nh4. Changes Made\n\nFixed password validation logic in @validatePassword()@ function.\n\nh4. Testing\n\n# Unit tests: *PASS*\n# Integration tests: *PASS*\n# Manual testing: *PASS*\n\nSee \"commit abc123\":https://github.com/project/commit/abc123 for details."
    }
  }' \
  "${REDMINE_URL}/issues/123.json"
```

## Tips

- **ALWAYS use Textile formatting** for all notes/comments
- Always include `notes` field to document what changed and why
- Use Textile headers (h3., h4.) to structure longer comments
- Check current issue state before updating to avoid conflicts
- Use appropriate status transitions (some statuses may require specific workflows)
- Update `done_ratio` to reflect actual progress
- Private notes are useful for internal team communication
- Link to commits/branches using Textile link syntax: `"commit abc123":url`
- Use inline code formatting with `@code@` for function/variable names
- Update due dates when timeline changes
- Structure complex updates with Textile lists for clarity
