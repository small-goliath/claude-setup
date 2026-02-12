#!/bin/bash
# 진행 중인 이슈만 목록 조회

curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?assigned_to_id=me&status_id=open&limit=100" | \
  jq '.issues[] | {id, subject, status: .status.name, priority: .priority.name}'
