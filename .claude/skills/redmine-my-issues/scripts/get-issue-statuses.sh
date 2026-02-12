#!/bin/bash
# 사용 가능한 이슈 상태 조회

curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issue_statuses.json" | \
  jq '.issue_statuses[] | {id, name, is_closed}'
