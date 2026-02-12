#!/bin/bash
# 사용 가능한 이슈 우선순위 조회

curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/enumerations/issue_priorities.json" | \
  jq '.issue_priorities[] | {id, name, is_default}'
