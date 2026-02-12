#!/bin/bash
# 우선순위별 정렬 (내림차순)

curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?assigned_to_id=me&sort=priority:desc,updated_on:desc" | \
  jq '.issues[] | {id, subject, priority: .priority.name, status: .status.name}'
