#!/bin/bash
# 프로젝트별 필터링
# 사용법: list-by-project.sh <project_id>

PROJECT_ID=${1:-1}

curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?assigned_to_id=me&project_id=${PROJECT_ID}" | \
  jq '.issues[] | {id, subject, status: .status.name}'
