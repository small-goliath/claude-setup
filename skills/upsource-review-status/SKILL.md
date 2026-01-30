---
name: upsource-review-status
description: "Check status of code reviews in JetBrains Upsource. WARNING: Upsource is discontinued (EOL Jan 2023). Legacy systems only. Use to check review status, comments, and approvals in existing Upsource installations. Migrate to GitLab (skills available) or GitHub for ongoing support."
---

# Upsource Review Status

⚠️ **IMPORTANT**: Upsource was discontinued in January 2023. This skill is for legacy systems only. Consider migrating to GitLab (skills already available) or GitHub.

## Overview

Check code review status in legacy Upsource installations via RPC API.

## Prerequisites

- `UPSOURCE_URL` - Upsource server URL
- `UPSOURCE_USERNAME` - Username
- `UPSOURCE_PASSWORD` - Password

## Quick Usage

### List My Reviews

```bash
AUTH_TOKEN=$(echo -n "${UPSOURCE_USERNAME}:${UPSOURCE_PASSWORD}" | base64)

curl -s \
  -H "Authorization: Basic ${AUTH_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"projectId\": \"${PROJECT_ID}\",
    \"query\": \"state: open\"
  }" \
  "${UPSOURCE_URL}/~rpc/getReviews" | \
  jq '.result.reviews[] | {reviewId: .reviewId.reviewId, title, state}'
```

### Get Review Details

```bash
REVIEW_ID="PR-123"

curl -s \
  -H "Authorization: Basic ${AUTH_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"reviewId\": {
      \"projectId\": \"${PROJECT_ID}\",
      \"reviewId\": \"${REVIEW_ID}\"
    }
  }" \
  "${UPSOURCE_URL}/~rpc/getReviewDetails" | \
  jq '{
    title: .result.title,
    state: .result.state,
    participants: [.result.participants[] | {userId, role}],
    completionRate: .result.completionRate
  }'
```

### Check Comments

```bash
curl -s \
  -H "Authorization: Basic ${AUTH_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"reviewId\": {
      \"projectId\": \"${PROJECT_ID}\",
      \"reviewId\": \"${REVIEW_ID}\"
    }
  }" \
  "${UPSOURCE_URL}/~rpc/getReviewComments" | \
  jq '.result.comments[] | {author, text, created}'
```

## Output Format

Present reviews in actionable format:

```
Your Upsource Reviews

Open Reviews (3):
PR-123 - Authentication module review [60% complete]
  2 unresolved discussions
  http://upsource.company.com/project/review/PR-123

PR-124 - Bug fix for login [✓ Ready to merge]
  All discussions resolved
  http://upsource.company.com/project/review/PR-124
```

## Common Filters

- `state: open` - Open reviews
- `state: closed` - Closed reviews
- `author: me` - My reviews
- `reviewer: me` - Reviews assigned to me

## Tips

- Check unresolved discussions before merging
- Monitor completion rate
- **Most important**: Plan migration to supported platform

⚠️ **Legacy System Warning**: No security updates since January 2023. Migrate to GitLab (skills available) or GitHub ASAP.
