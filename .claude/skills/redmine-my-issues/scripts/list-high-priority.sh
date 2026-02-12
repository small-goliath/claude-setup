#!/bin/bash
# 높은 우선순위 이슈 조회

curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?assigned_to_id=me&priority_id=3|4|5&status_id=open" | \
  jq '.issues[] | {id, subject, priority: .priority.name, due_date}'
