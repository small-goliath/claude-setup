#!/bin/bash
# 워크플로우 완료 시 Google Chat 알림

MESSAGE="🎉 *워크플로우 완료*\n\n모든 작업이 성공적으로 완료되었습니다."

curl -X POST "$GOOGLE_CHAT_WEBHOOK" \
  -H 'Content-Type: application/json' \
  -d "{\"text\":\"$MESSAGE\"}" \
  > /dev/null 2>&1

exit 0