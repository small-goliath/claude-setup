#!/bin/bash
# 권한 요청 시 Google Chat 알림 발송

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

MESSAGE="🔒 *권한 요청*\n\n도구: \`$TOOL_NAME\`\n명령: \`$COMMAND\`\n\nClaude Code에서 확인해주세요."

curl -X POST "$GOOGLE_CHAT_WEBHOOK" \
  -H 'Content-Type: application/json' \
  -d "{\"text\":\"$MESSAGE\"}" \
  > /dev/null 2>&1

exit 0