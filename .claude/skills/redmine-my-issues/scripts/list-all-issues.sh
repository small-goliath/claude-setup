#!/bin/bash
# 내 이슈 전체 목록 조회

curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?assigned_to_id=me&limit=100" | \
  jq '.issues[] | {id, subject, status: .status.name, priority: .priority.name, project: .project.name}'
