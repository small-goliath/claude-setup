---
name: upsource-add-comment
description: "Add comments to code reviews in JetBrains Upsource. WARNING: Upsource discontinued (EOL Jan 2023). Legacy only. Use to add review comments, discussions, and feedback in existing Upsource installations. Migrate to GitLab (skills available) or GitHub."
---

# Upsource Add Comment

⚠️ **IMPORTANT**: Upsource was discontinued in January 2023. This skill is for legacy systems only. Migrate to GitLab (skills available) or GitHub.

## Overview

Add comments to code reviews in legacy Upsource installations via RPC API.

**IMPORTANT**: All comments **MUST** use Markdown formatting, which Upsource supports for rich text display.

## Markdown Formatting (REQUIRED)

Upsource supports Markdown for comment formatting. **Always format comments using Markdown syntax.**

### Common Markdown Syntax

- **Headers**: `## Heading`, `### Subheading`
- **Bold**: `**text**`
- **Italic**: `*text*`
- **Inline code**: `` `code` ``
- **Code blocks**: ` ```language` ... ` ``` `
- **Numbered lists**: `1.`, `2.`, `3.`
- **Bulleted lists**: `-` or `*` at start of line
- **Links**: `[link text](url)`
- **Line break**: Empty line between paragraphs

### Example Markdown Comment

```markdown
## Code Review Feedback

Great implementation overall! Just a few suggestions:

### Issues Found

1. Consider using `async/await` in `validatePassword()`
2. Add error handling for edge cases
3. Update documentation

### Code Suggestion

```javascript
async function validatePassword(password) {
  // Handle special characters properly
  return /^[a-zA-Z0-9@#$%^&*]+$/.test(password);
}
```

See [authentication docs](https://example.com/docs) for more details.
```

## Prerequisites

- `UPSOURCE_URL` - Upsource server URL
- `UPSOURCE_USERNAME` - Username
- `UPSOURCE_PASSWORD` - Password

## Quick Usage

### Create General Review Discussion

Create a new discussion (comment thread) on a review without attaching to specific code:

```bash
AUTH_TOKEN=$(echo -n "${UPSOURCE_USERNAME}:${UPSOURCE_PASSWORD}" | base64)

PROJECT_ID="your-project"
REVIEW_ID="PR-123"
COMMENT_TEXT="## Review Complete

**LGTM!** Great implementation of the authentication feature.

### Highlights

- Clean code structure
- Good error handling
- Comprehensive tests"

# Use jq to properly construct JSON payload
PAYLOAD=$(jq -n \
  --arg projectId "$PROJECT_ID" \
  --arg reviewId "$REVIEW_ID" \
  --arg text "$COMMENT_TEXT" \
  '{
    projectId: $projectId,
    anchor: {},
    text: $text,
    reviewId: {
      projectId: $projectId,
      reviewId: $reviewId
    }
  }')

curl -X POST \
  -H "Authorization: Basic ${AUTH_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  "${UPSOURCE_URL}/~rpc/createDiscussion"
```

**Critical Requirements:**
- `projectId` must exist at **both** top level AND inside `reviewId` object
- `anchor` must be an empty object `{}`, NOT null or omitted
- Use `jq` to properly escape multi-line Markdown text

### Create Line Comment

Create a discussion attached to a specific file (and optionally a line):

```bash
COMMENT_TEXT="### Suggestion

Consider using \`async/await\` here instead of promises for better readability:

\`\`\`javascript
async function login() {
  const result = await validatePassword(password);
  return result;
}
\`\`\`"

PAYLOAD=$(jq -n \
  --arg projectId "$PROJECT_ID" \
  --arg reviewId "$REVIEW_ID" \
  --arg fileId "src/auth/login.js" \
  --arg revisionId "abc123def456" \
  --arg text "$COMMENT_TEXT" \
  '{
    projectId: $projectId,
    anchor: {
      fileId: $fileId,
      revisionId: $revisionId
    },
    text: $text,
    reviewId: {
      projectId: $projectId,
      reviewId: $reviewId
    }
  }')

curl -X POST \
  -H "Authorization: Basic ${AUTH_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  "${UPSOURCE_URL}/~rpc/createDiscussion"
```

**Note**: For file-specific comments, include `fileId` and `revisionId` in the anchor. Upsource handles line context automatically.

### Reply to Existing Discussion

Add a comment (reply) to an existing discussion thread:

```bash
DISCUSSION_ID="discussion-123"
REPLY_TEXT="### Response

**Good point!** I'll update the code.

#### Action Items

1. Refactor \`validatePassword()\` to use async/await
2. Add unit tests for new implementation
3. Update documentation

Expected completion: Today"

PAYLOAD=$(jq -n \
  --arg projectId "$PROJECT_ID" \
  --arg discussionId "$DISCUSSION_ID" \
  --arg text "$REPLY_TEXT" \
  '{
    projectId: $projectId,
    discussionId: $discussionId,
    text: $text
  }')

curl -X POST \
  -H "Authorization: Basic ${AUTH_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  "${UPSOURCE_URL}/~rpc/addComment"
```

**Note**: Use `addComment` for replying to existing discussions. For nested replies, include `parentId` field with the comment ID you're replying to.

## Common Scenarios

### Approve Review

```bash
# Create approval discussion
APPROVAL_TEXT="## ✅ Approved

**Looks good to merge!**

### Review Summary

- Code quality: **Excellent**
- Test coverage: **95%**
- Documentation: **Complete**
- Security: **No issues found**

Ready for production deployment."

PAYLOAD=$(jq -n \
  --arg projectId "$PROJECT_ID" \
  --arg reviewId "$REVIEW_ID" \
  --arg text "$APPROVAL_TEXT" \
  '{
    projectId: $projectId,
    anchor: {},
    text: $text,
    reviewId: {
      projectId: $projectId,
      reviewId: $reviewId
    }
  }')

curl -X POST \
  -H "Authorization: Basic ${AUTH_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  "${UPSOURCE_URL}/~rpc/createDiscussion"

# Mark review as accepted
ACCEPT_PAYLOAD=$(jq -n \
  --arg projectId "$PROJECT_ID" \
  --arg reviewId "$REVIEW_ID" \
  '{
    reviewId: {
      projectId: $projectId,
      reviewId: $reviewId
    },
    accepted: true
  }')

curl -X POST \
  -H "Authorization: Basic ${AUTH_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$ACCEPT_PAYLOAD" \
  "${UPSOURCE_URL}/~rpc/acceptReview"
```

### Request Changes

```bash
CHANGES_TEXT="## Changes Requested

Good progress, but a few items need attention before merge:

### Required Changes

1. **Add unit tests** for \`validatePassword()\` function
   - Test special characters
   - Test edge cases (empty string, null, etc.)

2. **Update documentation**
   - Add JSDoc comments to new functions
   - Update README with API changes

3. **Fix linting errors**
   - Run \`npm run lint\` and fix all errors
   - Ensure consistent code style

### Optional Improvements

- Consider adding input validation
- Refactor for better performance

Please address these and request re-review when ready."

PAYLOAD=$(jq -n \
  --arg projectId "$PROJECT_ID" \
  --arg reviewId "$REVIEW_ID" \
  --arg text "$CHANGES_TEXT" \
  '{
    projectId: $projectId,
    anchor: {},
    text: $text,
    reviewId: {
      projectId: $projectId,
      reviewId: $reviewId
    },
    labels: [
      {name: "changes-requested", colorId: "1"}
    ]
  }')

curl -X POST \
  -H "Authorization: Basic ${AUTH_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  "${UPSOURCE_URL}/~rpc/createDiscussion"
```

## API Methods Summary

### createDiscussion
- **Use for**: New comment threads on reviews
- **Endpoint**: `${UPSOURCE_URL}/~rpc/createDiscussion`
- **Required fields**:
  - `projectId` (at top level)
  - `anchor` (empty object `{}` for general comments, or with `fileId`/`revisionId` for file comments)
  - `text` (Markdown formatted comment)
  - `reviewId` object with `projectId` and `reviewId` fields
- **Optional fields**: `markupType`, `labels`
- **Critical**: `projectId` must be present at BOTH top level AND inside `reviewId` object

### addComment
- **Use for**: Replying to existing discussions
- **Endpoint**: `${UPSOURCE_URL}/~rpc/addComment`
- **Required fields**: `projectId`, `discussionId`, `text`
- **Optional fields**: `parentId` (for nested replies), `markupType`

## Tips

- **ALWAYS use Markdown formatting** for all comments
- **ALWAYS use `jq`** to construct JSON payloads for proper escaping of multi-line text
- **CRITICAL**: For `createDiscussion`, `projectId` must appear at BOTH:
  1. Top level of the request
  2. Inside the `reviewId` object
- **CRITICAL**: `anchor` field is REQUIRED for `createDiscussion`:
  - Use empty object `{}` for general review comments
  - Use `{fileId: "...", revisionId: "..."}` for file-specific comments
  - Never use `null` or omit the anchor field
- Use `createDiscussion` for new comment threads
- Use `addComment` for replies to existing discussions
- Use headers (`##`, `###`) to structure longer comments
- Format code with inline backticks `` `code` `` or code blocks ` ```language `
- Be specific and constructive in comments
- Use **bold** for emphasis on important points
- Include numbered or bulleted lists for clarity
- Add labels to discussions for categorization (e.g., "changes-requested", "question")
- Link to documentation or resources using `[text](url)`
- **Most important**: Migrate to supported platform

⚠️ **Legacy Warning**: No security updates since Jan 2023. Use GitLab skills (available) for modern code review workflow.
