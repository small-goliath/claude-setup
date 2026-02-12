#!/bin/bash
# 파일 수정 시 Google Chat 알림 발송

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -n "$FILE_PATH" ]]; then
  # 절대 경로를 상대 경로로 변환
  RELATIVE_PATH=$(echo "$FILE_PATH" | sed "s|$CLAUDE_PROJECT_DIR/||")

  MESSAGE="📝 *파일 수정됨*\n\n\`$RELATIVE_PATH\`\n\n확인이 필요합니다."

  curl -X POST "$GOOGLE_CHAT_WEBHOOK" \
    -H 'Content-Type: application/json' \
    -d "{\"text\":\"$MESSAGE\"}" \
    > /dev/null 2>&1
fi

exit 0