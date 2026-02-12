#!/bin/bash
# 곧 마감 예정인 이슈 조회

curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?assigned_to_id=me&status_id=open" | \
  jq '.issues[] | select(.due_date != null) | {id, subject, due_date, priority: .priority.name}' | \
  jq -s 'sort_by(.due_date)'
