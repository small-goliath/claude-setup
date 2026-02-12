#!/bin/bash
# 프로젝트별로 그룹화

curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?assigned_to_id=me&status_id=open&limit=100" | \
  jq '.issues | group_by(.project.name) | map({project: .[0].project.name, count: length})'
