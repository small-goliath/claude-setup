# Redmine REST API Reference

Complete reference for Redmine REST API issue creation and management.

## Authentication

All API requests require authentication via one of these methods:

### API Key (Recommended)

**Header method:**
```bash
curl -H "X-Redmine-API-Key: YOUR_API_KEY" https://redmine.example.com/issues.json
```

**URL parameter method:**
```bash
curl https://redmine.example.com/issues.json?key=YOUR_API_KEY
```

**Basic auth method:**
```bash
curl https://YOUR_API_KEY:@redmine.example.com/issues.json
```

### Username/Password

```bash
curl -u username:password https://redmine.example.com/issues.json
```

## Issue Fields

### Required Fields

- `project_id` - Integer or string identifier of the project

### Common Fields

- `subject` - String (required) - Issue title
- `description` - Text - Detailed description
- `tracker_id` - Integer - Issue type (Bug, Feature, etc.)
- `status_id` - Integer - Issue status (New, In Progress, etc.)
- `priority_id` - Integer - Priority level (Low, Normal, High, etc.)
- `assigned_to_id` - Integer - User ID to assign
- `category_id` - Integer - Issue category
- `fixed_version_id` - Integer - Target version/milestone
- `parent_issue_id` - Integer - Parent issue for subtasks
- `start_date` - Date (YYYY-MM-DD) - Start date
- `due_date` - Date (YYYY-MM-DD) - Due date
- `estimated_hours` - Float - Estimated time
- `done_ratio` - Integer (0-100) - Completion percentage
- `watcher_user_ids` - Array of integers - Users to watch the issue

### Custom Fields

```json
{
  "issue": {
    "project_id": 1,
    "subject": "Issue with custom fields",
    "custom_fields": [
      {"id": 1, "value": "Custom value 1"},
      {"id": 2, "value": "Custom value 2"}
    ]
  }
}
```

## API Endpoints

### Create Issue

**POST** `/issues.json`

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "issue": {
      "project_id": 1,
      "subject": "New issue",
      "description": "Detailed description",
      "tracker_id": 1,
      "priority_id": 2
    }
  }' \
  "${REDMINE_URL}/issues.json"
```

### Get Issue

**GET** `/issues/{id}.json`

```bash
curl -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues/123.json"
```

Include related data:
```bash
curl -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues/123.json?include=children,attachments,relations,changesets,journals,watchers"
```

### Update Issue

**PUT** `/issues/{id}.json`

```bash
curl -X PUT \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "issue": {
      "status_id": 3,
      "notes": "Status updated to Resolved"
    }
  }' \
  "${REDMINE_URL}/issues/123.json"
```

### List Issues

**GET** `/issues.json`

```bash
# All issues
curl -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json"

# Filter by project
curl -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?project_id=1"

# Filter by assigned user
curl -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?assigned_to_id=me"

# Filter by status
curl -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?status_id=open"
```

### List Projects

**GET** `/projects.json`

```bash
curl -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/projects.json"
```

### Get Trackers

**GET** `/trackers.json`

```bash
curl -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/trackers.json"
```

### Get Priorities

**GET** `/enumerations/issue_priorities.json`

```bash
curl -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/enumerations/issue_priorities.json"
```

### Get Statuses

**GET** `/issue_statuses.json`

```bash
curl -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issue_statuses.json"
```

### Get Current User

**GET** `/users/current.json`

```bash
curl -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/users/current.json"
```

## File Attachments

### Upload Token

First, upload the file to get a token:

```bash
token=$(curl -X POST \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -H "Content-Type: application/octet-stream" \
  --data-binary "@/path/to/file.pdf" \
  "${REDMINE_URL}/uploads.json" | jq -r '.upload.token')
```

### Attach to Issue

Then include the token when creating/updating an issue:

```json
{
  "issue": {
    "project_id": 1,
    "subject": "Issue with attachment",
    "uploads": [
      {
        "token": "7167.ed1ccdb093229ca1bd0b043618d88743",
        "filename": "screenshot.png",
        "content_type": "image/png"
      }
    ]
  }
}
```

## Time Entries

### Log Time

**POST** `/time_entries.json`

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "time_entry": {
      "issue_id": 123,
      "hours": 2.5,
      "activity_id": 9,
      "comments": "Working on implementation"
    }
  }' \
  "${REDMINE_URL}/time_entries.json"
```

### Get Activities

**GET** `/enumerations/time_entry_activities.json`

```bash
curl -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/enumerations/time_entry_activities.json"
```

## Query Parameters

### Pagination

- `offset` - Skip this many results (default: 0)
- `limit` - Return this many results (default: 25, max: 100)

```bash
curl -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?offset=50&limit=100"
```

### Sorting

- `sort` - Sort by field (append `:desc` for descending)

```bash
curl -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?sort=priority:desc,updated_on:desc"
```

### Filtering

Multiple values can be separated by `|` (OR) or `,` (AND):

```bash
# Issues with priority High OR Urgent
curl -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?priority_id=3|4"

# Issues assigned to user 2 AND in project 1
curl -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?assigned_to_id=2&project_id=1"
```

## Response Format

### Success Response (201 Created)

```json
{
  "issue": {
    "id": 123,
    "project": {
      "id": 1,
      "name": "My Project"
    },
    "tracker": {
      "id": 1,
      "name": "Bug"
    },
    "status": {
      "id": 1,
      "name": "New"
    },
    "priority": {
      "id": 2,
      "name": "Normal"
    },
    "author": {
      "id": 1,
      "name": "John Doe"
    },
    "subject": "Issue subject",
    "description": "Issue description",
    "created_on": "2026-01-27T10:30:00Z",
    "updated_on": "2026-01-27T10:30:00Z"
  }
}
```

### Error Response (422 Unprocessable Entity)

```json
{
  "errors": [
    "Subject cannot be blank",
    "Priority is not included in the list"
  ]
}
```

## Common Use Cases

### Create Bug Report

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "issue": {
      "project_id": 1,
      "subject": "Login button not responding",
      "description": "Steps to reproduce:\n1. Go to login page\n2. Click login button\n3. Nothing happens\n\nExpected: User should be logged in\nActual: No response",
      "tracker_id": 1,
      "priority_id": 3
    }
  }' \
  "${REDMINE_URL}/issues.json"
```

### Create Feature Request

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "issue": {
      "project_id": 1,
      "subject": "Add dark mode support",
      "description": "Users have requested a dark mode option for better viewing in low-light environments.",
      "tracker_id": 2,
      "priority_id": 2
    }
  }' \
  "${REDMINE_URL}/issues.json"
```

### Create Task with Due Date

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  -d '{
    "issue": {
      "project_id": 1,
      "subject": "Update dependencies",
      "description": "Update all npm packages to latest versions",
      "tracker_id": 4,
      "priority_id": 2,
      "assigned_to_id": 5,
      "due_date": "2026-02-15"
    }
  }' \
  "${REDMINE_URL}/issues.json"
```

## References

- Official Redmine REST API: https://www.redmine.org/projects/redmine/wiki/rest_api
- REST Issues: https://www.redmine.org/projects/redmine/wiki/Rest_Issues
- REST Time Entries: https://www.redmine.org/projects/redmine/wiki/Rest_TimeEntries
