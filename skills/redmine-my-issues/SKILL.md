---
name: redmine-my-issues
description: View and filter issues assigned to you in Redmine. Use when the user wants to check their assigned issues, see what tasks they need to work on, check issue priorities, or review their workload. Typical triggers include "show my Redmine issues", "what issues am I working on", "check my tasks", or "list my assigned issues".
---

# Redmine My Issues

View and manage issues assigned to you in Redmine.

## Overview

This skill enables querying your assigned Redmine issues directly from your development environment. Quickly see what's on your plate, check priorities, and filter by status.

## Prerequisites

Set these environment variables:

- `REDMINE_URL` - Your Redmine server URL (e.g., `https://redmine.example.com`)
- `REDMINE_API_KEY` - Your API key (found at `/my/account` when logged in)

## Quick Usage

### List All My Issues

```bash
curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?assigned_to_id=me&limit=100" | \
  jq '.issues[] | {id, subject, status: .status.name, priority: .priority.name, project: .project.name}'
```

### List Open Issues Only

```bash
curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?assigned_to_id=me&status_id=open&limit=100" | \
  jq '.issues[] | {id, subject, status: .status.name, priority: .priority.name}'
```

### List by Priority

High priority issues:
```bash
curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?assigned_to_id=me&priority_id=3|4|5&status_id=open" | \
  jq '.issues[] | {id, subject, priority: .priority.name, due_date}'
```

### Group by Project

```bash
curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?assigned_to_id=me&status_id=open&limit=100" | \
  jq 'group_by(.issues[].project.name) | map({project: .[0].project.name, count: length})'
```

## Workflow

1. **Fetch Issues**: Query API with `assigned_to_id=me` filter
2. **Parse Response**: Extract relevant fields (id, subject, status, priority, due_date)
3. **Format Output**: Present in readable format with key information
4. **Provide Links**: Include clickable URLs to issues: `${REDMINE_URL}/issues/{id}`

## Common Filters

### By Status

- `status_id=open` - All open issues
- `status_id=1` - New issues
- `status_id=2` - In Progress
- `status_id=3` - Resolved
- `status_id=5` - Closed

### By Priority

- `priority_id=1` - Low
- `priority_id=2` - Normal
- `priority_id=3` - High
- `priority_id=4` - Urgent
- `priority_id=5` - Immediate

### By Due Date

Issues due soon:
```bash
curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?assigned_to_id=me&status_id=open" | \
  jq '.issues[] | select(.due_date != null) | {id, subject, due_date, priority: .priority.name}' | \
  jq -s 'sort_by(.due_date)'
```

## Output Format

Present issues in a clear, actionable format:

```
Your Redmine Issues (5 open)

High Priority:
#123 - Fix login bug [High] - Due: 2026-02-01
  Project: Website
  https://redmine.example.com/issues/123

#124 - Security patch [Urgent] - Due: 2026-01-29
  Project: API
  https://redmine.example.com/issues/124

Normal Priority:
#125 - Update documentation [Normal]
  Project: Website
  https://redmine.example.com/issues/125
```

## Advanced Features

### Include Related Data

Get detailed information:
```bash
curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?assigned_to_id=me&include=attachments,journals" | \
  jq '.issues[] | {id, subject, last_update: .updated_on, attachments: (.attachments | length)}'
```

### Filter by Project

```bash
curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?assigned_to_id=me&project_id=1" | \
  jq '.issues[] | {id, subject, status: .status.name}'
```

### Sort Results

By priority (descending):
```bash
curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?assigned_to_id=me&sort=priority:desc,updated_on:desc"
```

## Tips

- Default limit is 25 issues, use `&limit=100` for more
- Use `&offset=N` for pagination
- Combine filters with `&` for AND logic
- Use `|` in values for OR logic (e.g., `priority_id=3|4|5`)
- Always filter by `status_id=open` to exclude closed issues
- Check `due_date` field to prioritize urgent work
