#!/bin/bash
# Task 완료 시 검증 및 Google Chat 알림

INPUT=$(cat)
TASK_SUBJECT=$(echo "$INPUT" | jq -r '.task_subject')

# Git status 확인 - 커밋되지 않은 변경사항 확인
if ! git diff --quiet HEAD 2>/dev/null; then
  MESSAGE="⚠️ *Task 완료 검증 실패*\n\nTask: \`$TASK_SUBJECT\`\n\n커밋되지 않은 변경사항이 있습니다."

  curl -X POST "$GOOGLE_CHAT_WEBHOOK" \
    -H 'Content-Type: application/json' \
    -d "{\"text\":\"$MESSAGE\"}" \
    > /dev/null 2>&1

  echo "커밋되지 않은 변경사항이 있습니다. Task를 완료하기 전에 커밋해주세요." >&2
  exit 2
fi

# 성공 알림
MESSAGE="✅ *Task 완료*\n\n\`$TASK_SUBJECT\`"

curl -X POST "$GOOGLE_CHAT_WEBHOOK" \
  -H 'Content-Type: application/json' \
  -d "{\"text\":\"$MESSAGE\"}" \
  > /dev/null 2>&1

exit 0