#!/bin/bash
# 상세 정보 포함 조회

curl -s -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" \
  "${REDMINE_URL}/issues.json?assigned_to_id=me&include=attachments,journals" | \
  jq '.issues[] | {id, subject, last_update: .updated_on, attachments: (.attachments | length)}'
