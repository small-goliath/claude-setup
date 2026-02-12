# Hooks 레퍼런스

> Claude Code 훅 이벤트, 설정 스키마, JSON 입출력 형식, 종료 코드, 비동기 훅, 프롬프트 훅 및 MCP 도구 훅에 대한 레퍼런스.

## 훅 수명 주기

훅(Hooks)은 Claude Code의 수명 주기 중 특정 시점에서 자동으로 실행되는 사용자 정의 셸 명령어 또는 LLM 프롬프트다. 훅은 Claude Code 세션 중 특정 시점에서 발동된다. 이벤트가 발생하고 매처가 일치하면, Claude Code는 이벤트에 대한 JSON 컨텍스트를 훅 핸들러에 전달한다. 명령어 훅의 경우 stdin으로 전달된다. 핸들러는 입력을 검사하고 작업을 수행한 후 선택적으로 결정을 반환할 수 있다. 일부 이벤트는 세션당 한 번 발생하는 반면, 다른 이벤트는 에이전틱 루프 내에서 반복적으로 발생한다.

<div style={{maxWidth: "500px", margin: "0 auto"}}>
  <Frame>
    <img src="https://mintcdn.com/claude-code/tpQvD9DKENFo4zX_/images/hooks-lifecycle.svg?fit=max&auto=format&n=tpQvD9DKENFo4zX_&q=85&s=7a351ea1cc3d5da7a2176bf51196bc1a" alt="SessionStart부터 에이전틱 루프를 거쳐 SessionEnd까지의 훅 시퀀스를 보여주는 훅 수명 주기 다이어그램" />
  </Frame>
</div>

아래 표는 각 이벤트가 언제 발생하는지를 나타낸다.

| 이벤트                | 발생 시점                                                      |
| :------------------- | :----------------------------------------------------------------- |
| `SessionStart`       | 세션이 시작되거나 재개될 때                                   |
| `UserPromptSubmit`   | 프롬프트를 제출할 때, Claude가 처리하기 전               |
| `PreToolUse`         | 도구 호출이 실행되기 전. 차단 가능                          |
| `PermissionRequest`  | 권한 대화 상자가 나타날 때                                   |
| `PostToolUse`        | 도구 호출이 성공한 후                                         |
| `PostToolUseFailure` | 도구 호출이 실패한 후                                         |
| `Notification`       | Claude Code가 알림을 보낼 때                              |
| `SubagentStart`      | 서브에이전트가 생성될 때                                         |
| `SubagentStop`       | 서브에이전트가 종료될 때                                           |
| `Stop`               | Claude가 응답을 완료할 때                                    |
| `TeammateIdle`       | [에이전트 팀](https://maeng-dev.tistory.com/226) 팀원이 유휴 상태가 되려고 할 때 |
| `TaskCompleted`      | 작업이 완료로 표시되려고 할 때                           |
| `PreCompact`         | 컨텍스트 압축 전                                          |
| `SessionEnd`         | 세션이 종료될 때                                          |

### 훅이 해결되는 방법

이러한 조각들이 어떻게 함께 작동하는지 보기 위해, 파괴적인 셸 명령어를 차단하는 `PreToolUse` 훅을 고려해보자. 이 훅은 모든 Bash 도구 호출 전에 `block-rm.sh`를 실행한다.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/block-rm.sh"
          }
        ]
      }
    ]
  }
}
```

스크립트는 stdin에서 JSON 입력을 읽고, 명령어를 추출하고, `rm -rf`가 포함되어 있으면 `permissionDecision`을 `"deny"`로 반환한다.

```bash
#!/bin/bash
# .claude/hooks/block-rm.sh
COMMAND=$(jq -r '.tool_input.command')

if echo "$COMMAND" | grep -q 'rm -rf'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Destructive command blocked by hook"
    }
  }'
else
  exit 0  # 명령어 허용
fi
```

이제 Claude Code가 `Bash "rm -rf /tmp/build"`를 실행하기로 결정했다고 가정해보겠다. 다음과 같은 일이 발생한다.

<Frame>
  <img src="https://mintcdn.com/claude-code/s7NM0vfd_wres2nf/images/hook-resolution.svg?fit=max&auto=format&n=s7NM0vfd_wres2nf&q=85&s=7c13f51ffcbc37d22a593b27e2f2de72" alt="훅 해결 흐름: PreToolUse 이벤트 발생, 매처가 Bash 매칭 확인, 훅 핸들러 실행, 결과가 Claude Code로 반환" />
</Frame>

<Steps>
  <Step title="이벤트 발생">
    `PreToolUse` 이벤트가 발생한. Claude Code는 도구 입력을 JSON으로 훅의 stdin에 전송한다.

    ```json
    { "tool_name": "Bash", "tool_input": { "command": "rm -rf /tmp/build" }, ... }
    ```
  </Step>

  <Step title="매처 확인">
    매처 `"Bash"`가 도구 이름과 일치하므로 `block-rm.sh`가 실행된다. 매처를 생략하거나 `"*"`를 사용하면 이벤트의 모든 발생에서 훅이 실행된다. 훅은 매처가 정의되어 있고 일치하지 않을 때만 건너뛴다.
  </Step>

  <Step title="훅 핸들러 실행">
    스크립트는 입력에서 `"rm -rf /tmp/build"`를 추출하고 `rm -rf`를 찾으므로 결정을 stdout에 출력한다.

    ```json
    {
      "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": "Destructive command blocked by hook"
      }
    }
    ```

    명령어가 안전했다면(예: `npm test`) 스크립트는 `exit 0`을 실행했을 것이고, 이는 Claude Code에게 추가 작업 없이 도구 호출을 허용하도록 지시한다.
  </Step>

  <Step title="Claude Code가 결과에 따라 동작">
    Claude Code는 JSON 결정을 읽고 도구 호출을 차단하며 Claude에게 이유를 표시한다.
  </Step>
</Steps>

## 설정

훅은 JSON 설정 파일에서 정의된다. 설정은 세 단계의 중첩을 가진다.

1. `PreToolUse` 또는 `Stop`과 같이 응답할 훅 이벤트 선택
2. "Bash 도구에서만"과 같이 발동 시점을 필터링하는 매처 그룹 추가
3. 일치할 때 실행할 하나 이상의 훅 핸들러 정의


<Note>
  이 포스트는 각 레벨에 대해 특정 용어를 사용한다.
  수명 주기 시점에 대해서는 **훅 이벤트**, 필터에 대해서는 **매처 그룹**, 실행되는 셸 명령어, 프롬프트 또는 에이전트에 대해서는 **훅 핸들러**다. "훅" 자체는 일반적인 기능을 의미한다.
</Note>

### 훅 위치

훅을 정의하는 위치가 범위를 결정한다.

| 위치                                                   | 범위                         | 공유 가능                          |
| :--------------------------------------------------------- | :---------------------------- | :--------------------------------- |
| `~/.claude/settings.json`                                  | 모든 프로젝트             | 아니오, 로컬 머신에만          |
| `.claude/settings.json`                                    | 단일 프로젝트                | 예, 저장소에 커밋 가능  |
| `.claude/settings.local.json`                              | 단일 프로젝트                | 아니오, gitignore됨                     |
| 관리 정책 설정                                    | 조직 전체             | 예, 관리자 제어              |
| [플러그인](https://code.claude.com/docs/en/plugins) `hooks/hooks.json`                   | 플러그인이 활성화되었을 때        | 예, 플러그인과 함께 번들됨       |
| [스킬](https://code.claude.com/docs/en/skills) 또는 [에이전트](https://maeng-dev.tistory.com/225) frontmatter | 컴포넌트가 활성화되어 있는 동안 | 예, 컴포넌트 파일에 정의됨 |

설정 파일 해결에 대한 자세한 내용은 [설정](https://code.claude.com/docs/en/settings)을 참조하자. 엔터프라이즈 관리자는 `allowManagedHooksOnly`를 사용하여 사용자, 프로젝트 및 플러그인 훅을 차단할 수 있다.

### 매처 패턴

`matcher` 필드는 훅이 언제 발동되는지 필터링하는 정규식 문자열이다. 모든 발생과 일치하려면 `"*"`, `""`를 사용하거나 `matcher`를 완전히 생략하면 된다. 각 이벤트 유형은 다른 필드에서 매칭한다.

| 이벤트                                                                  | 매처가 필터링하는 대상  | 매처 값 예시                                                         |
| :--------------------------------------------------------------------- | :------------------------ | :----------------------------------------------------------------------------- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest` | 도구 이름                 | `Bash`, `Edit\|Write`, `mcp__.*`                                               |
| `SessionStart`                                                         | 세션 시작 방법   | `startup`, `resume`, `clear`, `compact`                                        |
| `SessionEnd`                                                           | 세션 종료 이유     | `clear`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification`                                                         | 알림 유형         | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`       |
| `SubagentStart`                                                        | 에이전트 유형                | `Bash`, `Explore`, `Plan` 또는 커스텀 에이전트 이름                               |
| `PreCompact`                                                           | 압축을 트리거한 것 | `manual`, `auto`                                                               |
| `SubagentStop`                                                         | 에이전트 유형                | `SubagentStart`와 동일한 값                                                 |
| `UserPromptSubmit`, `Stop`, `TeammateIdle`, `TaskCompleted`            | 매처 지원 없음        | 모든 발생에서 항상 발동                                               |

매처는 정규식이므로 `Edit|Write`는 두 도구 중 하나와 일치하고 `Notebook.*`는 Notebook으로 시작하는 모든 도구와 일치한다. 매처는 Claude Code가 stdin에서 훅에 보내는 JSON 입력의 필드에 대해 실행된다. 도구 이벤트의 경우 해당 필드는 `tool_name`다. 각 훅 이벤트 섹션에는 해당 이벤트에 대한 전체 매처 값 세트와 입력 스키마가 나열된다.

이 예제는 Claude가 파일을 작성하거나 편집할 때만 린팅 스크립트를 실행한다.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/lint-check.sh"
          }
        ]
      }
    ]
  }
}
```

`UserPromptSubmit`과 `Stop`은 매처를 지원하지 않으며 모든 발생에서 항상 발동된다. 이러한 이벤트에 `matcher` 필드를 추가하면 자동으로 무시된다.

#### MCP 도구 매칭

[MCP](https://code.claude.com/docs/en/mcp) 서버 도구는 도구 이벤트(`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`)에서 일반 도구로 나타나므로 다른 도구 이름과 동일한 방식으로 매칭할 수 있다.

MCP 도구는 `mcp__<server>__<tool>` 명명 패턴을 따른다.

* `mcp__memory__create_entities`: Memory 서버의 엔티티 생성 도구
* `mcp__filesystem__read_file`: 파일시스템 서버의 파일 읽기 도구
* `mcp__github__search_repositories`: GitHub 서버의 검색 도구

정규식 패턴을 사용하여 특정 MCP 도구 또는 도구 그룹을 대상으로 지정한다.

* `mcp__memory__.*`는 `memory` 서버의 모든 도구와 일치
* `mcp__.*__write.*`는 모든 서버에서 "write"를 포함하는 모든 도구와 일치

이 예제는 모든 메모리 서버 작업을 로깅하고 모든 MCP 서버의 쓰기 작업을 검증한다.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "mcp__memory__.*",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Memory operation initiated' >> ~/mcp-operations.log"
          }
        ]
      },
      {
        "matcher": "mcp__.*__write.*",
        "hooks": [
          {
            "type": "command",
            "command": "/home/user/scripts/validate-mcp-write.py"
          }
        ]
      }
    ]
  }
}
```

### 훅 핸들러 필드

내부 `hooks` 배열의 각 객체는 훅 핸들러다: 매처가 일치할 때 실행되는 셸 명령어, LLM 프롬프트 또는 에이전트다. 세 가지 유형이 있다.

* **[명령어 훅](#명령어-훅-필드)** (`type: "command"`): 셸 명령어를 실행한다. 스크립트는 stdin으로 이벤트의 JSON 입력을 받고 종료 코드와 stdout을 통해 결과를 전달한다.
* **[프롬프트 훅](#프롬프트-및-에이전트-훅-필드)** (`type: "prompt"`): 단일 턴 평가를 위해 Claude 모델에 프롬프트를 보낸다. 모델은 예/아니오 결정을 JSON으로 반환한다.
* **[에이전트 훅](#프롬프트-및-에이전트-훅-필드)** (`type: "agent"`): 결정을 반환하기 전에 조건을 확인하기 위해 Read, Grep, Glob와 같은 도구를 사용할 수 있는 서브에이전트를 생성한다.

#### 공통 필드

이러한 필드는 모든 훅 유형에 적용된다.

| 필드           | 필수 | 설명                                                                                                                                   |
| :-------------- | :------- | :-------------------------------------------------------------------------------------------------------------------------------------------- |
| `type`          | 예      | `"command"`, `"prompt"` 또는 `"agent"`                                                                                                         |
| `timeout`       | 아니오       | 취소되기 전 시간(초). 기본값: command는 600, prompt는 30, agent는 60                                                              |
| `statusMessage` | 아니오       | 훅이 실행되는 동안 표시되는 커스텀 스피너 메시지                                                                                          |
| `once`          | 아니오       | `true`이면 세션당 한 번만 실행된 후 제거된다. 스킬만 해당, 에이전트는 아님. |

#### 명령어 훅 필드

공통 필드 외에도 명령어 훅은 다음 필드를 허용한다.

| 필드     | 필수 | 설명                                                                                                         |
| :-------- | :------- | :------------------------------------------------------------------------------------------------------------------ |
| `command` | 예      | 실행할 셸 명령어                                                                                            |
| `async`   | 아니오       | `true`이면 차단하지 않고 백그라운드에서 실행된다. |

#### 프롬프트 및 에이전트 훅 필드

공통 필드 외에도 프롬프트 및 에이전트 훅은 다음 필드를 허용한다.

| 필드    | 필수 | 설명                                                                                 |
| :------- | :------- | :------------------------------------------------------------------------------------------ |
| `prompt` | 예      | 모델에 보낼 프롬프트 텍스트. 훅 입력 JSON의 플레이스홀더로 `$ARGUMENTS` 사용 |
| `model`  | 아니오       | 평가에 사용할 모델. 기본값은 빠른 모델                                       |

모든 일치하는 훅은 병렬로 실행되며, 동일한 핸들러는 자동으로 중복 제거된다. 핸들러는 Claude Code의 환경에서 현재 디렉토리에서 실행된다. `$CLAUDE_CODE_REMOTE` 환경 변수는 원격 웹 환경에서 `"true"`로 설정되고 로컬 CLI에서는 설정되지 않는다.

### 경로로 스크립트 참조

환경 변수를 사용하여 훅이 실행될 때 작업 디렉토리와 관계없이 프로젝트 또는 플러그인 루트에 상대적인 훅 스크립트를 참조한다.

* `$CLAUDE_PROJECT_DIR`: 프로젝트 루트. 공백이 있는 경로를 처리하려면 따옴표로 감싸야한다.
* `${CLAUDE_PLUGIN_ROOT}`: [플러그인](https://code.claude.com/docs/en/plugins)과 함께 번들된 스크립트를 위한 플러그인의 루트 디렉토리.

<Tabs>
  <Tab title="프로젝트 스크립트">
    이 예제는 `$CLAUDE_PROJECT_DIR`을 사용하여 `Write` 또는 `Edit` 도구 호출 후 프로젝트의 `.claude/hooks/` 디렉토리에서 스타일 체커를 실행한다.

    ```json
    {
      "hooks": {
        "PostToolUse": [
          {
            "matcher": "Write|Edit",
            "hooks": [
              {
                "type": "command",
                "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/check-style.sh"
              }
            ]
          }
        ]
      }
    }
    ```
  </Tab>

  <Tab title="플러그인 스크립트">
    선택적 최상위 `description` 필드와 함께 `hooks/hooks.json`에서 플러그인 훅을 정의한다. 플러그인이 활성화되면 훅이 사용자 및 프로젝트 훅과 병합된다.

    이 예제는 플러그인과 함께 번들된 포맷팅 스크립트를 실행한다.

    ```json
    {
      "description": "Automatic code formatting",
      "hooks": {
        "PostToolUse": [
          {
            "matcher": "Write|Edit",
            "hooks": [
              {
                "type": "command",
                "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh",
                "timeout": 30
              }
            ]
          }
        ]
      }
    }
    ```

    플러그인 훅 생성에 대한 자세한 내용은 [플러그인 컴포넌트 레퍼런스](https://code.claude.com/docs/en/plugins-reference#hooks)를 참조하면 좋다.
  </Tab>
</Tabs>

### 스킬 및 에이전트의 훅

설정 파일과 플러그인 외에도 frontmatter를 사용하여 [스킬](https://code.claude.com/docs/en/skills) 및 [서브에이전트](https://maeng-dev.tistory.com/225)에서 직접 훅을 정의할 수 있다. 이러한 훅은 컴포넌트의 수명 주기로 범위가 지정되며 해당 컴포넌트가 활성화되어 있을 때만 실행된다.

모든 훅 이벤트가 지원된다. 서브에이전트의 경우 `Stop` 훅은 서브에이전트가 완료될 때 발생하는 이벤트이므로 자동으로 `SubagentStop`으로 변환된다.

훅은 설정 기반 훅과 동일한 설정 형식을 사용하지만 컴포넌트의 수명으로 범위가 지정되며 완료되면 정리된다.

이 스킬은 각 `Bash` 명령어 전에 보안 검증 스크립트를 실행하는 `PreToolUse` 훅을 정의한다.

```yaml
---
name: secure-operations
description: Perform operations with security checks
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
---
```

에이전트는 YAML frontmatter에서 동일한 형식을 사용한다.

### `/hooks` 메뉴

Claude Code에서 `/hooks`를 입력하여 설정 파일을 직접 편집하지 않고도 훅을 보고, 추가하고, 삭제할 수 있는 대화형 훅 관리자를 열 수 있다.

메뉴의 각 훅에는 소스를 나타내는 대괄호 접두사가 레이블로 지정된다.

* `[User]`: `~/.claude/settings.json`에서
* `[Project]`: `.claude/settings.json`에서
* `[Local]`: `.claude/settings.local.json`에서
* `[Plugin]`: 플러그인의 `hooks/hooks.json`에서, 읽기 전용

### 훅 비활성화 또는 제거

훅을 제거하려면 설정 JSON 파일에서 항목을 삭제하거나 `/hooks` 메뉴를 사용하여 훅을 선택하여 삭제한다.

훅을 제거하지 않고 일시적으로 비활성화하려면 설정 파일에서 `"disableAllHooks": true`로 설정하거나 `/hooks` 메뉴에서 토글을 사용한다. 설정에 유지하면서 개별 훅을 비활성화하는 방법은 없다.

설정 파일의 훅을 직접 편집해도 즉시 적용되지 않는다. Claude Code는 시작 시 훅의 스냅샷을 캡처하고 세션 내내 사용한다. 이는 악의적이거나 우발적인 훅 수정이 검토 없이 세션 중간에 적용되는 것을 방지한다. 훅이 외부에서 수정되면 Claude Code는 경고하고 변경 사항이 적용되기 전에 `/hooks` 메뉴에서 검토를 요구한다.

## 훅 입출력

훅은 stdin을 통해 JSON 데이터를 수신하고 종료 코드, stdout 및 stderr를 통해 결과를 전달한다.

### 공통 입력 필드

모든 훅 이벤트는 훅 이벤트 섹션에 문서화된 이벤트별 필드 외에도 이러한 필드를 stdin을 통해 JSON으로 수신한다.

| 필드             | 설명                                                                                                                                |
| :---------------- | :----------------------------------------------------------------------------------------------------------------------------------------- |
| `session_id`      | 현재 세션 식별자                                                                                                                 |
| `transcript_path` | 대화 JSON 경로                                                                                                                  |
| `cwd`             | 훅이 호출될 때의 현재 작업 디렉토리                                                                                         |
| `permission_mode` | 현재 [권한 모드](https://code.claude.com/docs/en/permissions#permission-modes): `"default"`, `"plan"`, `"acceptEdits"`, `"dontAsk"` 또는 `"bypassPermissions"` |
| `hook_event_name` | 발생한 이벤트의 이름                                                                                                               |

예를 들어, Bash 명령어에 대한 `PreToolUse` 훅은 stdin에서 다음을 수신한다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/home/user/.claude/projects/.../transcript.jsonl",
  "cwd": "/home/user/my-project",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm test"
  }
}
```

### 종료 코드 출력

훅 명령어의 종료 코드는 작업이 진행되어야 하는지, 차단되어야 하는지 또는 무시되어야 하는지를 Claude Code에 전달한다.

**종료 0**은 성공을 의미한다. Claude Code는 JSON 출력 필드에 대해 stdout을 구문 분석한다. JSON 출력은 종료 0에서만 처리된다. 대부분의 이벤트에서 stdout은 상세 모드(`Ctrl+O`)에서만 표시된다. 예외는 `UserPromptSubmit`과 `SessionStart`로, stdout이 Claude가 볼 수 있고 행동할 수 있는 컨텍스트로 추가된다.

**종료 2**는 차단 오류를 의미한다. Claude Code는 stdout과 그 안의 JSON을 무시한다. 대신 stderr 텍스트가 Claude에게 오류 메시지로 피드백된다. 효과는 이벤트에 따라 다르다. `PreToolUse`는 도구 호출을 차단하고, `UserPromptSubmit`은 프롬프트를 거부하는 식이다.

**기타 종료 코드**는 비차단 오류다. stderr는 상세 모드(`Ctrl+O`)에서 표시되고 실행은 계속된다.

예를 들어, 위험한 Bash 명령어를 차단하는 훅 명령어 스크립트를 보자.

```bash
#!/bin/bash
# stdin에서 JSON 입력을 읽고 명령어를 확인한다
command=$(jq -r '.tool_input.command' < /dev/stdin)

if [[ "$command" == rm* ]]; then
  echo "Blocked: rm commands are not allowed" >&2
  exit 2  # 차단 오류: 도구 호출이 방지됨
fi

exit 0  # 성공: 도구 호출 진행
```

#### 이벤트별 종료 코드 2 동작

종료 코드 2는 훅이 "중지, 이것을 하지 마세요"라고 신호하는 방법이다. 효과는 이벤트에 따라 다르다. 일부 이벤트는 차단할 수 있는 작업(아직 발생하지 않은 도구 호출 등)을 나타내고, 다른 이벤트는 이미 발생한 일이나 방지할 수 없는 일을 나타내기 때문이다.

| 훅 이벤트           | 차단 가능? | 종료 2에서 발생하는 일                                             |
| :------------------- | :--------- | :----------------------------------------------------------------- |
| `PreToolUse`         | 예        | 도구 호출 차단                                               |
| `PermissionRequest`  | 예        | 권한 거부                                              |
| `UserPromptSubmit`   | 예        | 프롬프트 처리 차단 및 프롬프트 삭제                     |
| `Stop`               | 예        | Claude가 중지하는 것을 방지, 대화 계속          |
| `SubagentStop`       | 예        | 서브에이전트 중지 방지                                |
| `TeammateIdle`       | 예        | 팀원이 유휴 상태가 되는 것을 방지 (팀원 계속 작업) |
| `TaskCompleted`      | 예        | 작업이 완료로 표시되는 것을 방지                   |
| `PostToolUse`        | 아니오         | stderr를 Claude에게 표시 (도구가 이미 실행됨)                          |
| `PostToolUseFailure` | 아니오         | stderr를 Claude에게 표시 (도구가 이미 실패함)                       |
| `Notification`       | 아니오         | stderr를 사용자에게만 표시                          |
| `SubagentStart`      | 아니오         | stderr를 사용자에게만 표시                          |
| `SessionStart`       | 아니오         | stderr를 사용자에게만 표시                          |
| `SessionEnd`         | 아니오         | stderr를 사용자에게만 표시                          |
| `PreCompact`         | 아니오         | stderr를 사용자에게만 표시                          |

### JSON 출력

종료 코드를 사용하면 허용하거나 차단할 수 있지만, JSON 출력을 사용하면 더 세밀한 제어가 가능하다. 차단하기 위해 코드 2로 종료하는 대신 0으로 종료하고 JSON 객체를 stdout에 출력한다. Claude Code는 해당 JSON에서 특정 필드를 읽어 차단, 허용 또는 사용자에게 에스컬레이션을 포함한 결정 제어를 포함한 동작을 제어한다.

<Note>
  훅당 한 가지 접근 방식을 선택해야 하며, 둘 다 사용할 수는 없다. 신호 전달을 위해 종료 코드만 사용하거나, 0으로 종료하고 구조화된 제어를 위해 JSON을 출력해야한다. Claude Code는 종료 0에서만 JSON을 처리한다. 2로 종료하면 JSON이 무시된다.
</Note>

훅의 stdout은 JSON 객체만 포함해야 한다. 셸 프로필이 시작 시 텍스트를 출력하면 JSON 파싱을 방해할 수 있다. 문제 해결 가이드의 [JSON 검증 실패](https://code.claude.com/docs/en/hooks-guide#json-validation-failed)를 참조하면 좋다.

JSON 객체는 세 가지 종류의 필드를 지원한다.

* `continue`와 같은 **범용 필드**는 모든 이벤트에서 작동한다. 아래 표에 나열되어 있다.
* **최상위 `decision`과 `reason`**은 일부 이벤트에서 차단하거나 피드백을 제공하는 데 사용된다.
* **`hookSpecificOutput`**은 더 풍부한 제어가 필요한 이벤트를 위한 중첩된 객체다. 이벤트 이름으로 설정된 `hookEventName` 필드가 필요하다.

| 필드            | 기본값 | 설명                                                                                                                |
| :--------------- | :------ | :------------------------------------------------------------------------------------------------------------------------- |
| `continue`       | `true`  | `false`이면 훅이 실행된 후 Claude가 완전히 처리를 중지한다. 이벤트별 결정 필드보다 우선한다 |
| `stopReason`     | 없음    | `continue`가 `false`일 때 사용자에게 표시되는 메시지. Claude에게는 표시되지 않음                                                  |
| `suppressOutput` | `false` | `true`이면 상세 모드 출력에서 stdout을 숨김                                                           |
| `systemMessage`  | 없음    | 사용자에게 표시되는 경고 메시지                                                                           |

이벤트 유형에 관계없이 Claude를 완전히 중지하려면 아래와 같이 하면 된다.

```json
{ "continue": false, "stopReason": "Build failed, fix errors before continuing" }
```

#### 결정 제어

모든 이벤트가 JSON을 통한 차단이나 동작 제어를 지원하는 것은 아니다. 지원하는 이벤트는 각각 다른 필드 세트를 사용하여 결정을 표현한다.

| 이벤트                                                                | 결정 패턴     | 주요 필드                                                        |
| :-------------------------------------------------------------------- | :------------------- | :---------------------------------------------------------------- |
| UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop | 최상위 `decision` | `decision: "block"`, `reason`                                     |
| TeammateIdle, TaskCompleted                                           | 종료 코드만       | 종료 코드 2가 작업을 차단, stderr가 피드백으로 전달됨     |
| PreToolUse                                                            | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask), `permissionDecisionReason` |
| PermissionRequest                                                     | `hookSpecificOutput` | `decision.behavior` (allow/deny)                                  |


Bash 명령어 검증, 프롬프트 필터링 및 자동 승인 스크립트를 포함한 확장된 예제는 가이드의 [자동화할 수 있는 것](https://code.claude.com/docs/en/hooks-guide#what-you-can-automate)과 [Bash 명령어 검증기 참조 구현](https://github.com/anthropics/claude-code/blob/main/examples/hooks/bash_command_validator_example.py)을 참조하면 도움이 많이 된다.

## 훅 이벤트

각 이벤트는 훅이 실행될 수 있는 Claude Code의 수명 주기 시점에 해당한다. 아래 섹션은 수명 주기에 맞춰 정렬되어 있다.
세션 설정에서 에이전틱 루프를 거쳐 세션 종료까지다. 각 섹션에서는 이벤트가 언제 발생하는지, 지원하는 매처, 수신하는 JSON 입력 및 출력을 통해 동작을 제어하는 방법을 알아보자.

### SessionStart

Claude Code가 새 세션을 시작하거나 기존 세션을 재개할 때 실행된다. 기존 이슈나 코드베이스의 최근 변경 사항과 같은 개발 컨텍스트를 로드하거나 환경 변수를 설정하는 데 유용하다. 스크립트가 필요하지 않은 정적 컨텍스트의 경우 CLAUDE.md를 대신 사용하자.

SessionStart는 모든 세션에서 실행되므로 이러한 훅을 빠르게 유지할 수 있다.

매처 값은 세션이 시작된 방법에 해당한다.

| 매처   | 발생 시점                          |
| :-------- | :------------------------------------- |
| `startup` | 새 세션                            |
| `resume`  | `--resume`, `--continue` 또는 `/resume` |
| `clear`   | `/clear`                               |
| `compact` | 자동 또는 수동 압축              |

#### SessionStart 입력

공통 입력 필드 외에도 SessionStart 훅은 `source`, `model` 및 선택적으로 `agent_type`을 수신한다. `source` 필드는 세션이 시작된 방법을 나타낸다. 새 세션의 경우 `"startup"`, 재개된 세션의 경우 `"resume"`, `/clear` 후 `"clear"`, 압축 후 `"compact"`. `model` 필드에는 모델 식별자가 포함된다. `claude --agent <name>`으로 Claude Code를 시작하면 `agent_type` 필드에 에이전트 이름이 포함된다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "SessionStart",
  "source": "startup",
  "model": "claude-sonnet-4-5-20250929"
}
```

#### SessionStart 결정 제어

훅 스크립트가 stdout에 출력하는 모든 텍스트는 Claude의 컨텍스트로 추가된다. 모든 훅에서 사용 가능한 JSON 출력 필드 외에도 다음 이벤트별 필드를 반환할 수 있다.

| 필드               | 설명                                                               |
| :------------------ | :------------------------------------------------------------------------ |
| `additionalContext` | Claude의 컨텍스트에 추가되는 문자열. 여러 훅의 값이 연결됨 |

```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "My additional context here"
  }
}
```

#### 환경 변수 유지

SessionStart 훅은 `CLAUDE_ENV_FILE` 환경 변수에 액세스할 수 있으며, 이는 후속 Bash 명령어에 대한 환경 변수를 유지할 수 있는 파일 경로를 제공한다.

개별 환경 변수를 설정하려면 `CLAUDE_ENV_FILE`에 `export` 문을 작성하면 된다. 다른 훅에서 설정한 변수를 유지하려면 추가(`>>`)를 사용하면 된다.

```bash
#!/bin/bash

if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo 'export NODE_ENV=production' >> "$CLAUDE_ENV_FILE"
  echo 'export DEBUG_LOG=true' >> "$CLAUDE_ENV_FILE"
  echo 'export PATH="$PATH:./node_modules/.bin"' >> "$CLAUDE_ENV_FILE"
fi

exit 0
```

설정 명령어의 모든 환경 변경 사항을 캡처하려면 전후에 내보낸 변수를 비교하면 된다.

```bash
#!/bin/bash

ENV_BEFORE=$(export -p | sort)

# 환경을 수정하는 설정 명령어 실행
source ~/.nvm/nvm.sh
nvm use 20

if [ -n "$CLAUDE_ENV_FILE" ]; then
  ENV_AFTER=$(export -p | sort)
  comm -13 <(echo "$ENV_BEFORE") <(echo "$ENV_AFTER") >> "$CLAUDE_ENV_FILE"
fi

exit 0
```

이 파일에 작성된 모든 변수는 세션 동안 Claude Code가 실행하는 모든 후속 Bash 명령어에서 사용할 수 있다.

<Note>
  `CLAUDE_ENV_FILE`은 SessionStart 훅에서 사용할 수 있다. 다른 훅 유형은 이 변수에 액세스할 수 없다.
</Note>

### UserPromptSubmit

사용자가 프롬프트를 제출할 때, Claude가 처리하기 전에 실행된다. 이를 통해 프롬프트/대화를 기반으로 추가 컨텍스트를 추가하거나, 프롬프트를 검증하거나, 특정 유형의 프롬프트를 차단할 수 있다.

#### UserPromptSubmit 입력

공통 입력 필드 외에도 UserPromptSubmit 훅은 사용자가 제출한 텍스트를 포함하는 `prompt` 필드를 수신한다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "UserPromptSubmit",
  "prompt": "Write a function to calculate the factorial of a number"
}
```

#### UserPromptSubmit 결정 제어

`UserPromptSubmit` 훅은 사용자 프롬프트가 처리되는지 여부를 제어하고 컨텍스트를 추가할 수 있다. 모든 JSON 출력 필드를 사용할 수 있다.

종료 코드 0에서 대화에 컨텍스트를 추가하는 두 가지 방법이 있다.

* **일반 텍스트 stdout**: stdout에 작성된 모든 비-JSON 텍스트가 컨텍스트로 추가됨
* **`additionalContext`가 있는 JSON**: 더 많은 제어를 위해 아래 JSON 형식을 사용하자. `additionalContext` 필드가 컨텍스트로 추가된다.

일반 stdout은 트랜스크립트에서 훅 출력으로 표시된다. `additionalContext` 필드는 더 신중하게 추가된다.

프롬프트를 차단하려면 `decision`이 `"block"`으로 설정된 JSON 객체를 반환한다.

| 필드               | 설명                                                                                                        |
| :------------------ | :----------------------------------------------------------------------------------------------------------------- |
| `decision`          | `"block"`은 프롬프트가 처리되지 않도록 하고 컨텍스트에서 삭제한다. 프롬프트를 진행하려면 생략 |
| `reason`            | `decision`이 `"block"`일 때 사용자에게 표시된다. 컨텍스트에 추가되지 않음                                               |
| `additionalContext` | Claude의 컨텍스트에 추가되는 문자열                                                                                   |

```json
{
  "decision": "block",
  "reason": "Explanation for decision",
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "My additional context here"
  }
}
```

<Note>
  간단한 사용 사례에는 JSON 형식이 필요하지 않는다. 컨텍스트를 추가하려면 종료 코드 0으로 일반 텍스트를 stdout에 출력할 수 있다. 프롬프트를 차단하거나 더 구조화된 제어가 필요한 경우 JSON을 사용하는 것을 권장한다.
</Note>

### PreToolUse

Claude가 도구 매개변수를 생성한 후 도구 호출을 처리하기 전에 실행된다. 도구 이름에서 매칭한다: `Bash`, `Edit`, `Write`, `Read`, `Glob`, `Grep`, `Task`, `WebFetch`, `WebSearch` 및 모든 MCP 도구 이름.

PreToolUse 결정 제어를 사용하여 도구 사용을 허용, 거부 또는 권한을 섷정해야한다.

#### PreToolUse 입력

공통 입력 필드 외에도 PreToolUse 훅은 `tool_name`, `tool_input` 및 `tool_use_id`를 수신한다. `tool_input` 필드는 도구에 따라 다르다.

##### Bash

셸 명령어를 실행한다.

| 필드               | 유형    | 예            | 설명                                   |
| :------------------ | :------ | :----------------- | :-------------------------------------------- |
| `command`           | string  | `"npm test"`       | 실행할 셸 명령어                  |
| `description`       | string  | `"Run test suite"` | 명령어가 수행하는 작업에 대한 선택적 설명 |
| `timeout`           | number  | `120000`           | 선택적 타임아웃(밀리초)              |
| `run_in_background` | boolean | `false`            | 명령어를 백그라운드에서 실행할지 여부      |

##### Write

파일을 생성하거나 덮어쓴다.

| 필드       | 유형   | 예               | 설명                        |
| :---------- | :----- | :-------------------- | :--------------------------------- |
| `file_path` | string | `"/path/to/file.txt"` | 작성할 파일의 절대 경로 |
| `content`   | string | `"file content"`      | 파일에 작성할 내용       |

##### Edit

기존 파일의 문자열을 대체한다.

| 필드         | 유형    | 예               | 설명                        |
| :------------ | :------ | :-------------------- | :--------------------------------- |
| `file_path`   | string  | `"/path/to/file.txt"` | 편집할 파일의 절대 경로  |
| `old_string`  | string  | `"original text"`     | 찾아서 대체할 텍스트           |
| `new_string`  | string  | `"replacement text"`  | 대체 텍스트                   |
| `replace_all` | boolean | `false`               | 모든 발생을 대체할지 여부 |

##### Read

파일 내용을 읽는다.

| 필드       | 유형   | 예               | 설명                                |
| :---------- | :----- | :-------------------- | :----------------------------------------- |
| `file_path` | string | `"/path/to/file.txt"` | 읽을 파일의 절대 경로          |
| `offset`    | number | `10`                  | 읽기를 시작할 선택적 줄 번호 |
| `limit`     | number | `50`                  | 읽을 선택적 줄 수           |

##### Glob

글롭 패턴과 일치하는 파일을 찾는다.

| 필드     | 유형   | 예          | 설명                                                            |
| :-------- | :----- | :--------------- | :--------------------------------------------------------------------- |
| `pattern` | string | `"**/*.ts"`      | 파일과 일치시킬 글롭 패턴                                    |
| `path`    | string | `"/path/to/dir"` | 검색할 선택적 디렉토리. 기본값은 현재 작업 디렉토리 |

##### Grep

정규식으로 파일 내용을 검색한다.

| 필드         | 유형    | 예          | 설명                                                                           |
| :------------ | :------ | :--------------- | :------------------------------------------------------------------------------------ |
| `pattern`     | string  | `"TODO.*fix"`    | 검색할 정규식 패턴                                              |
| `path`        | string  | `"/path/to/dir"` | 검색할 선택적 파일 또는 디렉토리                                               |
| `glob`        | string  | `"*.ts"`         | 파일을 필터링하는 선택적 글롭 패턴                                                 |
| `output_mode` | string  | `"content"`      | `"content"`, `"files_with_matches"` 또는 `"count"`. 기본값은 `"files_with_matches"` |
| `-i`          | boolean | `true`           | 대소문자를 구분하지 않는 검색                                                               |
| `multiline`   | boolean | `false`          | 멀티라인 매칭 활성화                                                             |

##### WebFetch

웹 콘텐츠를 가져오고 처리한다.

| 필드    | 유형   | 예                       | 설명                          |
| :------- | :----- | :---------------------------- | :----------------------------------- |
| `url`    | string | `"https://example.com/api"`   | 콘텐츠를 가져올 URL            |
| `prompt` | string | `"Extract the API endpoints"` | 가져온 콘텐츠에서 실행할 프롬프트 |

##### WebSearch

웹을 검색한다.

| 필드             | 유형   | 예                        | 설명                                       |
| :---------------- | :----- | :----------------------------- | :------------------------------------------------ |
| `query`           | string | `"react hooks best practices"` | 검색 쿼리                                      |
| `allowed_domains` | array  | `["docs.example.com"]`         | 선택사항: 이러한 도메인의 결과만 포함 |
| `blocked_domains` | array  | `["spam.example.com"]`         | 선택사항: 이러한 도메인의 결과 제외      |

##### Task

[서브에이전트](https://maeng-dev.tistory.com/225)를 생성한다.

| 필드           | 유형   | 예                    | 설명                                  |
| :-------------- | :----- | :------------------------- | :------------------------------------------- |
| `prompt`        | string | `"Find all API endpoints"` | 에이전트가 수행할 작업            |
| `description`   | string | `"Find API endpoints"`     | 작업에 대한 짧은 설명                |
| `subagent_type` | string | `"Explore"`                | 사용할 전문 에이전트 유형             |
| `model`         | string | `"sonnet"`                 | 기본값을 재정의하는 선택적 모델 별칭 |

#### PreToolUse 결정 제어

`PreToolUse` 훅은 도구 호출이 진행되는지 여부를 제어할 수 있다. 최상위 `decision` 필드를 사용하는 다른 훅과 달리 PreToolUse는 `hookSpecificOutput` 객체 내부에 결정을 반환한다. 이를 통해 세 가지 결과(허용, 거부 또는 요청)와 실행 전에 도구 입력을 수정하는 기능을 포함하여 더 풍부한 제어가 가능하다.

| 필드                      | 설명                                                                                                                                      |
| :------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------- |
| `permissionDecision`       | `"allow"`는 권한 시스템을 우회, `"deny"`는 도구 호출을 방지, `"ask"`는 사용자에게 확인을 요청                                   |
| `permissionDecisionReason` | `"allow"` 및 `"ask"`의 경우 사용자에게 표시되지만 Claude에게는 표시되지 않음. `"deny"`의 경우 Claude에게 표시됨                                                       |
| `updatedInput`             | 실행 전에 도구의 입력 매개변수를 수정한다. `"allow"`와 결합하여 자동 승인하거나 `"ask"`와 결합하여 수정된 입력을 사용자에게 표시 |
| `additionalContext`        | 도구가 실행되기 전에 Claude의 컨텍스트에 추가되는 문자열                                                                                        |

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "My reason here",
    "updatedInput": {
      "field_to_modify": "new value"
    },
    "additionalContext": "Current environment: production. Proceed with caution."
  }
}
```

<Note>
  PreToolUse는 이전에 최상위 `decision` 및 `reason` 필드를 사용했지만 이 이벤트에서는 더 이상 사용되지 않는다. 대신 `hookSpecificOutput.permissionDecision` 및 `hookSpecificOutput.permissionDecisionReason`을 사용할 수 있다. 더 이상 사용되지 않는 값 `"approve"` 및 `"block"`은 각각 `"allow"` 및 `"deny"`에 매핑된다. PostToolUse 및 Stop과 같은 다른 이벤트는 현재 형식으로 최상위 `decision` 및 `reason`을 계속 사용한다.
</Note>

### PermissionRequest

사용자에게 권한 대화 상자가 표시될 때 실행된다.
PermissionRequest 결정 제어를 사용하여 사용자를 대신하여 허용하거나 거부한다.

PreToolUse 훅과 동일한 값인 도구 이름에서 매칭한다.

#### PermissionRequest 입력

PermissionRequest 훅은 PreToolUse 훅과 같은 `tool_name` 및 `tool_input` 필드를 수신하지만 `tool_use_id`는 없다. 선택적 `permission_suggestions` 배열에는 사용자가 권한 대화 상자에서 일반적으로 볼 수 있는 "항상 허용" 옵션이 포함된다.
차이점은 훅이 발동되는 시점이다. PermissionRequest 훅은 사용자에게 권한 대화 상자가 표시되려고 할 때 실행되는 반면, PreToolUse 훅은 권한 상태에 관계없이 도구 실행 전에 실행된다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "PermissionRequest",
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf node_modules",
    "description": "Remove node_modules directory"
  },
  "permission_suggestions": [
    { "type": "toolAlwaysAllow", "tool": "Bash" }
  ]
}
```

#### PermissionRequest 결정 제어

`PermissionRequest` 훅은 권한 요청을 허용하거나 거부할 수 있다. 모든 훅에서 사용 가능한 JSON 출력 필드 외에도 훅 스크립트는 다음 이벤트별 필드가 있는 `decision` 객체를 반환할 수 있다.

| 필드                | 설명                                                                                                    |
| :------------------- | :------------------------------------------------------------------------------------------------------------- |
| `behavior`           | `"allow"`는 권한을 부여, `"deny"`는 거부                                                            |
| `updatedInput`       | `"allow"`에만 해당: 실행 전에 도구의 입력 매개변수를 수정                                      |
| `updatedPermissions` | `"allow"`에만 해당: 권한 규칙 업데이트를 적용, 사용자가 "항상 허용" 옵션을 선택하는 것과 동일 |
| `message`            | `"deny"`에만 해당: Claude에게 권한이 거부된 이유를 알려줌                                                  |
| `interrupt`          | `"deny"`에만 해당: `true`이면 Claude를 중지                                                     |

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow",
      "updatedInput": {
        "command": "npm run lint"
      }
    }
  }
}
```

### PostToolUse

도구가 성공적으로 완료된 직후에 실행된다.

PreToolUse와 동일한 값인 도구 이름에서 매칭한다.

#### PostToolUse 입력

`PostToolUse` 훅은 도구가 이미 성공적으로 실행된 후 발동된다. 입력에는 도구에 전송된 인수인 `tool_input`과 도구가 반환한 결과인 `tool_response`가 모두 포함된다. 두 가지의 정확한 스키마는 도구에 따라 다르다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "PostToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.txt",
    "content": "file content"
  },
  "tool_response": {
    "filePath": "/path/to/file.txt",
    "success": true
  },
  "tool_use_id": "toolu_01ABC123..."
}
```

#### PostToolUse 결정 제어

`PostToolUse` 훅은 도구 실행 후 Claude에게 피드백을 제공할 수 있다. 모든 훅에서 사용 가능한 JSON 출력 필드 외에도 훅 스크립트는 다음 이벤트별 필드를 반환할 수 있다.

| 필드                  | 설명                                                                                |
| :--------------------- | :----------------------------------------------------------------------------------------- |
| `decision`             | `"block"`은 `reason`으로 Claude에게 프롬프트를 표시한다. 작업을 진행하려면 생략            |
| `reason`               | `decision`이 `"block"`일 때 Claude에게 표시되는 설명                                   |
| `additionalContext`    | Claude가 고려할 추가 컨텍스트                                                  |
| `updatedMCPToolOutput` | MCP 도구에만 해당: 도구의 출력을 제공된 값으로 대체 |

```json
{
  "decision": "block",
  "reason": "Explanation for decision",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Additional information for Claude"
  }
}
```

### PostToolUseFailure

도구 실행이 실패할 때 실행된다. 이 이벤트는 오류를 던지거나 실패 결과를 반환하는 도구 호출에 대해 발동된다. 이를 사용하여 실패를 로깅하거나, 경고를 보내거나, Claude에게 수정 피드백을 보낼 수 있다.

PreToolUse와 동일한 값인 도구 이름에서 매칭한다.

#### PostToolUseFailure 입력

PostToolUseFailure 훅은 PostToolUse와 동일한 `tool_name` 및 `tool_input` 필드를 수신하며, 최상위 필드로 오류 정보를 함께 수신한다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "PostToolUseFailure",
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm test",
    "description": "Run test suite"
  },
  "tool_use_id": "toolu_01ABC123...",
  "error": "Command exited with non-zero status code 1",
  "is_interrupt": false
}
```

| 필드          | 설명                                                                     |
| :------------- | :------------------------------------------------------------------------------ |
| `error`        | 무엇이 잘못되었는지 설명하는 문자열                                               |
| `is_interrupt` | 실패가 사용자 중단으로 인한 것인지 여부를 나타내는 선택적 불리언 |

#### PostToolUseFailure 결정 제어

`PostToolUseFailure` 훅은 도구 실패 후 Claude에게 컨텍스트를 제공할 수 있다. 모든 훅에서 사용 가능한 JSON 출력 필드 외에도 훅 스크립트는 다음 이벤트별 필드를 반환할 수 있다.

| 필드               | 설명                                                   |
| :------------------ | :------------------------------------------------------------ |
| `additionalContext` | 오류와 함께 Claude가 고려할 추가 컨텍스트 |

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUseFailure",
    "additionalContext": "Additional information about the failure for Claude"
  }
}
```

### Notification

Claude Code가 알림을 보낼 때 실행된다. 알림 유형에서 매칭한다. (`permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`).
모든 알림 유형에 대해 훅을 실행하려면 매처를 생략하면 된다.

알림 유형에 따라 다른 핸들러를 실행하려면 별도의 매처를 사용하면 된다. 이 구성은 Claude가 권한 승인이 필요할 때 권한 관련 경고 스크립트를 트리거하고 Claude가 유휴 상태일 때 다른 알림을 트리거한다.

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/permission-alert.sh"
          }
        ]
      },
      {
        "matcher": "idle_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/idle-notification.sh"
          }
        ]
      }
    ]
  }
}
```

#### Notification 입력

공통 입력 필드 외에도 Notification 훅은 알림 텍스트가 있는 `message`, 선택적 `title` 및 어떤 유형이 발동되었는지 나타내는 `notification_type`을 수신한다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "Notification",
  "message": "Claude needs your permission to use Bash",
  "title": "Permission needed",
  "notification_type": "permission_prompt"
}
```

Notification 훅은 알림을 차단하거나 수정할 수 없다. 모든 훅에서 사용 가능한 JSON 출력 필드 외에도 대화에 컨텍스트를 추가하기 위해 `additionalContext`를 반환할 수 있다.

| 필드               | 설명                      |
| :------------------ | :------------------------------- |
| `additionalContext` | Claude의 컨텍스트에 추가되는 문자열 |

### SubagentStart

Task 도구를 통해 Claude Code 서브에이전트가 생성될 때 실행된다. 에이전트 유형 이름(내장 에이전트인 `Bash`, `Explore`, `Plan` 또는 `.claude/agents/`의 커스텀 에이전트 이름)으로 필터링하는 매처를 지원한다.

#### SubagentStart 입력

공통 입력 필드 외에도 SubagentStart 훅은 서브에이전트의 고유 식별자가 있는 `agent_id`와 에이전트 이름이 있는 `agent_type`(내장 에이전트인 `"Bash"`, `"Explore"`, `"Plan"` 또는 커스텀 에이전트 이름)을 수신한다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "SubagentStart",
  "agent_id": "agent-abc123",
  "agent_type": "Explore"
}
```

SubagentStart 훅은 서브에이전트 생성을 차단할 수 없지만 서브에이전트에 컨텍스트를 주입할 수 있다. 모든 훅에서 사용 가능한 JSON 출력 필드 외에도 다음을 반환할 수 있다.

| 필드               | 설명                            |
| :------------------ | :------------------------------------- |
| `additionalContext` | 서브에이전트의 컨텍스트에 추가되는 문자열 |

```json
{
  "hookSpecificOutput": {
    "hookEventName": "SubagentStart",
    "additionalContext": "Follow security guidelines for this task"
  }
}
```

### SubagentStop

Claude Code 서브에이전트가 응답을 완료했을 때 실행된다. SubagentStart와 동일한 값인 에이전트 유형에서 매칭한다.

#### SubagentStop 입력

공통 입력 필드 외에도 SubagentStop 훅은 `stop_hook_active`, `agent_id`, `agent_type` 및 `agent_transcript_path`를 수신한다. `agent_type` 필드는 매처 필터링에 사용되는 값이다. `transcript_path`는 메인 세션의 트랜스크립트이고, `agent_transcript_path`는 중첩된 `subagents/` 폴더에 저장된 서브에이전트 자체의 트랜스크립트다.

```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../abc123.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "SubagentStop",
  "stop_hook_active": false,
  "agent_id": "def456",
  "agent_type": "Explore",
  "agent_transcript_path": "~/.claude/projects/.../abc123/subagents/agent-def456.jsonl"
}
```

SubagentStop 훅은 Stop 훅과 동일한 결정 제어 형식을 사용한다.

### Stop

메인 Claude Code 에이전트가 응답을 완료했을 때 실행된다. 사용자 중단으로 인해 중지된 경우 실행되지 않는다.

#### Stop 입력

공통 입력 필드 외에도 Stop 훅은 `stop_hook_active`를 수신한다. 이 필드는 Claude Code가 이미 stop 훅의 결과로 계속되고 있을 때 `true`다. Claude Code가 무한히 실행되는 것을 방지하려면 이 값을 확인하거나 트랜스크립트를 처리해야한다.

```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "Stop",
  "stop_hook_active": true
}
```

#### Stop 결정 제어

`Stop` 및 `SubagentStop` 훅은 Claude가 계속되는지 여부를 제어할 수 있다. 모든 훅에서 사용 가능한 JSON 출력 필드 외에도 훅 스크립트는 다음 이벤트별 필드를 반환할 수 있다.

| 필드      | 설명                                                                |
| :--------- | :------------------------------------------------------------------------- |
| `decision` | `"block"`은 Claude가 중지하는 것을 방지한다. Claude가 중지하도록 허용하려면 생략      |
| `reason`   | `decision`이 `"block"`일 때 필수다. Claude에게 계속해야 하는 이유를 알려줌 |

```json
{
  "decision": "block",
  "reason": "Must be provided when Claude is blocked from stopping"
}
```

### TeammateIdle

[에이전트 팀](https://maeng-dev.tistory.com/226) 팀원이 턴을 완료한 후 유휴 상태가 되려고 할 때 실행된다. 팀원이 작업을 중지하기 전에 품질 게이트를 적용하는 데 사용할 수 있다. 예를 들어 통과하는 린트 검사가 필요하거나 출력 파일이 존재하는지 확인하는 것처럼.

`TeammateIdle` 훅이 코드 2로 종료되면 팀원은 stderr 메시지를 피드백으로 받고 유휴 상태가 되는 대신 계속 작업한다. TeammateIdle 훅은 매처를 지원하지 않으며 모든 발생에서 발동된다.

#### TeammateIdle 입력

공통 입력 필드 외에도 TeammateIdle 훅은 `teammate_name`과 `team_name`을 수신한다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "TeammateIdle",
  "teammate_name": "researcher",
  "team_name": "my-project"
}
```

| 필드           | 설명                                   |
| :-------------- | :-------------------------------------------- |
| `teammate_name` | 유휴 상태가 되려는 팀원의 이름 |
| `team_name`     | 팀의 이름                              |

#### TeammateIdle 결정 제어

TeammateIdle 훅은 JSON 결정 제어가 아닌 종료 코드만 사용한다. 이 예제는 팀원이 유휴 상태가 되기 전에 빌드 아티팩트가 존재하는지 확인한다.

```bash
#!/bin/bash

if [ ! -f "./dist/output.js" ]; then
  echo "Build artifact missing. Run the build before stopping." >&2
  exit 2
fi

exit 0
```

### TaskCompleted

작업이 완료로 표시되려고 할 때 실행된다. 이는 에이전트가 TaskUpdate 도구를 통해 작업을 명시적으로 완료로 표시할 때, 또는 [에이전트 팀](https://maeng-dev.tistory.com/226) 팀원이 진행 중인 작업과 함께 턴을 완료할 때 발동된다.
작업이 닫히기 전에 테스트 통과 또는 린트 검사와 같은 완료 기준을 적용하는 데 사용할 수 있다.

`TaskCompleted` 훅이 코드 2로 종료되면 작업이 완료로 표시되지 않고 stderr 메시지가 모델에 피드백으로 전달된다. TaskCompleted 훅은 매처를 지원하지 않으며 모든 발생에서 발동된다.

#### TaskCompleted 입력

공통 입력 필드 외에도 TaskCompleted 훅은 `task_id`, `task_subject` 및 선택적으로 `task_description`, `teammate_name`, `team_name`을 수신한다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "TaskCompleted",
  "task_id": "task-001",
  "task_subject": "Implement user authentication",
  "task_description": "Add login and signup endpoints",
  "teammate_name": "implementer",
  "team_name": "my-project"
}
```

| 필드              | 설명                                             |
| :----------------- | :------------------------------------------------------ |
| `task_id`          | 완료되는 작업의 식별자                  |
| `task_subject`     | 작업의 제목                                       |
| `task_description` | 작업의 상세 설명. 없을 수 있음         |
| `teammate_name`    | 작업을 완료하는 팀원의 이름. 없을 수 있음 |
| `team_name`        | 팀의 이름. 없을 수 있음                         |

#### TaskCompleted 결정 제어

TaskCompleted 훅은 JSON 결정 제어가 아닌 종료 코드만 사용한다. 이 예제는 테스트를 실행하고 실패하면 작업 완료를 차단한다.

```bash
#!/bin/bash
INPUT=$(cat)
TASK_SUBJECT=$(echo "$INPUT" | jq -r '.task_subject')

# 테스트 스위트 실행
if ! npm test 2>&1; then
  echo "Tests not passing. Fix failing tests before completing: $TASK_SUBJECT" >&2
  exit 2
fi

exit 0
```

### PreCompact

Claude Code가 압축 작업을 실행하려고 할 때 실행된다.

매처 값은 압축이 수동으로 트리거되었는지 자동으로 트리거되었는지를 나타낸다.

| 매처  | 발생 시점                                |
| :------- | :------------------------------------------- |
| `manual` | `/compact`                                   |
| `auto`   | 컨텍스트 창이 가득 찰 때 자동 압축 |

#### PreCompact 입력

공통 입력 필드 외에도 PreCompact 훅은 `trigger`와 `custom_instructions`를 수신한다. `manual`의 경우 `custom_instructions`에는 사용자가 `/compact`에 전달하는 내용이 포함된다. `auto`의 경우 `custom_instructions`는 비어 있다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "PreCompact",
  "trigger": "manual",
  "custom_instructions": ""
}
```

### SessionEnd

Claude Code 세션이 종료될 때 실행된다. 정리 작업, 세션 통계 로깅 또는 세션 상태 저장에 유용하다. 종료 이유로 필터링하는 매처를 지원한다.

훅 입력의 `reason` 필드는 세션이 종료된 이유를 나타낸다.

| 이유                       | 설명                                |
| :---------------------------- | :----------------------------------------- |
| `clear`                       | `/clear` 명령어로 세션 지워짐      |
| `logout`                      | 사용자 로그아웃                            |
| `prompt_input_exit`           | 프롬프트 입력이 표시된 상태에서 사용자 종료 |
| `bypass_permissions_disabled` | 권한 우회 모드 비활성화        |
| `other`                       | 기타 종료 이유                         |

#### SessionEnd 입력

공통 입력 필드 외에도 SessionEnd 훅은 세션이 종료된 이유를 나타내는 `reason` 필드를 수신한다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "SessionEnd",
  "reason": "other"
}
```

SessionEnd 훅은 결정 제어가 없다. 세션 종료를 차단할 수 없지만 정리 작업을 수행할 수 있다.

## 프롬프트 기반 훅

Bash 명령어 훅(`type: "command"`) 외에도 Claude Code는 LLM을 사용하여 작업을 허용하거나 차단할지 평가하는 프롬프트 기반 훅(`type: "prompt"`)을 지원한다.
프롬프트 기반 훅은 다음 이벤트와 함께 작동한다.
- `PreToolUse`,
- `PostToolUse`,
- `PostToolUseFailure`,
- `PermissionRequest`,
- `UserPromptSubmit`,
- `Stop`,
- `SubagentStop`,
- `TaskCompleted`.
`TeammateIdle`은 프롬프트 기반 또는 에이전트 기반 훅을 지원하지 않는다.

### 프롬프트 기반 훅 작동 방식

Bash 명령어를 실행하는 대신 프롬프트 기반 훅은 아래와 같이 처리한다.

1. 훅 입력과 프롬프트를 Claude 모델(기본적으로 Haiku)에 전송
2. LLM이 결정이 포함된 구조화된 JSON으로 응답
3. Claude Code가 결정을 자동으로 처리

### 프롬프트 훅 설정

`type`을 `"prompt"`로 설정하고 `command` 대신 `prompt` 문자열을 제공한다. `$ARGUMENTS` 플레이스홀더를 사용하여 훅의 JSON 입력 데이터를 프롬프트 텍스트에 주입한다. Claude Code는 결합된 프롬프트와 입력을 빠른 Claude 모델에 전송하고, 모델은 JSON 결정을 반환한다.

이 `Stop` 훅은 LLM에게 Claude가 완료하기 전에 모든 작업이 완료되었는지 평가하도록 요청한다.

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Evaluate if Claude should stop: $ARGUMENTS. Check if all tasks are complete."
          }
        ]
      }
    ]
  }
}
```

| 필드     | 필수 | 설명                                                                                                                                                         |
| :-------- | :------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `type`    | 예      | `"prompt"`여야 함                                                                                                                                                  |
| `prompt`  | 예      | LLM에 전송할 프롬프트 텍스트. 훅 입력 JSON의 플레이스홀더로 `$ARGUMENTS` 사용. `$ARGUMENTS`가 없으면 입력 JSON이 프롬프트에 추가됨 |
| `model`   | 아니오       | 평가에 사용할 모델. 기본값은 빠른 모델                                                                                                               |
| `timeout` | 아니오       | 타임아웃(초). 기본값: 30                                                                                                                                     |

### 응답 스키마

LLM은 다음을 포함하는 JSON으로 응답해야 한다.

```json
{
  "ok": true | false,
  "reason": "Explanation for the decision"
}
```

| 필드    | 설명                                                |
| :------- | :--------------------------------------------------------- |
| `ok`     | `true`는 작업을 허용, `false`는 방지              |
| `reason` | `ok`가 `false`일 때 필수. Claude에게 표시되는 설명 |

### 예제: 다중 기준 Stop 훅

이 `Stop` 훅은 상세한 프롬프트를 사용하여 Claude가 중지하도록 허용하기 전에 세 가지 조건을 확인한다. `"ok"`가 `false`이면 Claude는 제공된 이유를 다음 지시사항으로 사용하여 계속 작업한다. `SubagentStop` 훅은 동일한 형식을 사용하여 [서브에이전트](https://maeng-dev.tistory.com/225)가 중지해야 하는지 평가한다.

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "You are evaluating whether Claude should stop working. Context: $ARGUMENTS\n\nAnalyze the conversation and determine if:\n1. All user-requested tasks are complete\n2. Any errors need to be addressed\n3. Follow-up work is needed\n\nRespond with JSON: {\"ok\": true} to allow stopping, or {\"ok\": false, \"reason\": \"your explanation\"} to continue working.",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

## 에이전트 기반 훅

에이전트 기반 훅(`type: "agent"`)은 프롬프트 기반 훅과 비슷하지만 멀티턴 도구 액세스가 가능하다. 단일 LLM 호출 대신 에이전트 훅은 파일을 읽고, 코드를 검색하고, 코드베이스를 검사하여 조건을 확인할 수 있는 서브에이전트를 생성한다. 에이전트 훅은 프롬프트 기반 훅과 동일한 이벤트를 지원한다.

### 에이전트 훅 작동 방식

에이전트 훅이 발동되면:

1. Claude Code는 프롬프트와 훅의 JSON 입력으로 서브에이전트를 생성
2. 서브에이전트는 Read, Grep, Glob와 같은 도구를 사용하여 조사할 수 있음
3. 최대 50턴 후 서브에이전트는 구조화된 `{ "ok": true/false }` 결정을 반환
4. Claude Code는 프롬프트 훅과 동일한 방식으로 결정을 처리

에이전트 훅은 검증에 훅 입력 데이터만 평가하는 것이 아니라 실제 파일이나 테스트 출력을 검사해야 할 때 유용하다.

### 에이전트 훅 설정

`type`을 `"agent"`로 설정하고 `prompt` 문자열을 제공한다. 설정 필드는 프롬프트 훅과 동일하며, 기본 타임아웃이 더 길다.

| 필드     | 필수 | 설명                                                                                 |
| :-------- | :------- | :------------------------------------------------------------------------------------------ |
| `type`    | 예      | `"agent"`여야 함                                                                           |
| `prompt`  | 예      | 확인할 내용을 설명하는 프롬프트. 훅 입력 JSON의 플레이스홀더로 `$ARGUMENTS` 사용 |
| `model`   | 아니오       | 사용할 모델. 기본값은 빠른 모델                                                      |
| `timeout` | 아니오       | 타임아웃(초). 기본값: 60                                                             |

응답 스키마는 프롬프트 훅과 동일하다: 허용하려면 `{ "ok": true }`, 차단하려면 `{ "ok": false, "reason": "..." }`.

이 `Stop` 훅은 Claude가 완료하기 전에 모든 단위 테스트가 통과하는지 확인한다.

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "agent",
            "prompt": "Verify that all unit tests pass. Run the test suite and check the results. $ARGUMENTS",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

## 백그라운드에서 훅 실행

기본적으로 훅은 완료될 때까지 Claude의 실행을 차단한다. 배포, 테스트 스위트 또는 외부 API 호출과 같은 장기 실행 작업의 경우 `"async": true`로 설정하여 Claude가 계속 작업하는 동안 훅을 백그라운드에서 실행할 수 있다. 비동기 훅은 Claude의 동작을 차단하거나 제어할 수 없다. `decision`, `permissionDecision`, `continue`와 같은 응답 필드는 제어하려던 작업이 이미 완료되었기 때문에 효과가 없다.

### 비동기 훅 설정

명령어 훅의 설정에 `"async": true`를 추가하여 Claude를 차단하지 않고 백그라운드에서 실행한다. 이 필드는 `type: "command"` 훅에서만 사용할 수 있다.

이 훅은 모든 `Write` 도구 호출 후 테스트 스크립트를 실행한다. `run-tests.sh`가 최대 120초 동안 실행되는 동안 Claude는 즉시 계속 작업한다. 스크립트가 완료되면 다음 대화 턴에서 출력이 전달된다.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/run-tests.sh",
            "async": true,
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

`timeout` 필드는 백그라운드 프로세스의 최대 시간(초)을 설정한다. 지정하지 않으면 비동기 훅은 동기 훅과 동일한 10분 기본값을 사용한다.

### 비동기 훅 실행 방법

비동기 훅이 발동되면 Claude Code는 훅 프로세스를 시작하고 완료를 기다리지 않고 즉시 계속한다. 훅은 동기 훅과 동일한 JSON 입력을 stdin을 통해 수신한다.

백그라운드 프로세스가 종료된 후 훅이 `systemMessage` 또는 `additionalContext` 필드가 있는 JSON 응답을 생성한 경우 해당 콘텐츠는 다음 대화 턴에서 Claude에게 컨텍스트로 전달된다.

### 예제: 파일 변경 후 테스트 실행

이 훅은 Claude가 파일을 작성할 때마다 백그라운드에서 테스트 스위트를 시작한 다음 테스트가 완료되면 결과를 Claude에게 보고한다. 이 스크립트를 프로젝트의 `.claude/hooks/run-tests-async.sh`에 저장하고 `chmod +x`로 실행 가능하게 만들어야한다.

```bash
#!/bin/bash
# run-tests-async.sh

# stdin에서 훅 입력 읽기
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# 소스 파일에 대해서만 테스트 실행
if [[ "$FILE_PATH" != *.ts && "$FILE_PATH" != *.js ]]; then
  exit 0
fi

# 테스트 실행 및 systemMessage를 통해 결과 보고
RESULT=$(npm test 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  echo "{\"systemMessage\": \"Tests passed after editing $FILE_PATH\"}"
else
  echo "{\"systemMessage\": \"Tests failed after editing $FILE_PATH: $RESULT\"}"
fi
```

그런 다음 프로젝트 루트의 `.claude/settings.json`에 이 설정을 추가한다. `async: true` 플래그는 테스트가 실행되는 동안 Claude가 계속 작업할 수 있게 한다.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/run-tests-async.sh",
            "async": true,
            "timeout": 300
          }
        ]
      }
    ]
  }
}
```

### 제한 사항

비동기 훅은 동기 훅에 비해 여러 제약이 있다.

* `type: "command"` 훅만 `async`를 지원한다. 프롬프트 기반 훅은 비동기로 실행할 수 없다.
* 비동기 훅은 도구 호출을 차단하거나 결정을 반환할 수 없다. 훅이 완료될 때쯤 트리거 작업은 이미 진행되었기 때문이다.
* 훅 출력은 다음 대화 턴에서 전달된다. 세션이 유휴 상태인 경우 응답은 다음 사용자 상호 작용까지 대기한다.
* 각 실행은 별도의 백그라운드 프로세스를 생성한다.

## 보안 고려 사항

### 면책 조항

훅은 시스템 사용자의 전체 권한으로 실행된다.

<Warning>
  훅은 전체 사용자 권한으로 셸 명령어를 실행한다. 사용자 계정이 액세스할 수 있는 모든 파일을 수정, 삭제 또는 액세스할 수 있다. 설정에 추가하기 전에 모든 훅 명령어를 검토하고 테스트하자.
</Warning>

### 보안 모범 사례

훅을 작성할 때 이러한 관행을 고려하자!!!

* **입력 검증 및 정리**: 입력 데이터를 맹목적으로 신뢰하지 말자
* **항상 셸 변수를 따옴표로 감싸기**: `$VAR`가 아닌 `"$VAR"` 사용하자
* **경로 순회 차단**: 파일 경로에서 `..` 확인하자
* **절대 경로 사용**: 프로젝트 루트에 대해 `"$CLAUDE_PROJECT_DIR"`을 사용하여 스크립트의 전체 경로 지정하자
* **민감한 파일 건너뛰기**: `.env`, `.git/` 등

## 훅 디버그

`claude --debug`를 실행하여 어떤 훅이 일치했는지, 종료 코드 및 출력을 포함한 훅 실행 세부 정보를 확인할 수 있다. `Ctrl+O`로 상세 모드를 토글하여 트랜스크립트에서 훅 진행 상황을 확인할 수도 있다.

```
[DEBUG] Executing hooks for PostToolUse:Write
[DEBUG] Getting matching hook commands for PostToolUse with query: Write
[DEBUG] Found 1 hook matchers in settings
[DEBUG] Matched 1 hooks for query "Write"
[DEBUG] Found 1 hook commands to execute
[DEBUG] Executing hook command: <Your command> with timeout 600000ms
[DEBUG] Hook command completed with status 0: <Your stdout>
```

훅이 발동되지 않음, 무한 Stop 훅 루프 또는 설정 오류와 같은 일반적인 문제 해결은 가이드의 [제한 사항 및 문제 해결](https://code.claude.com/docs/en/hooks-guide#limitations-and-troubleshooting)을 참조하면 좋다. 특히 무한루프....ㅋㅋㅋ
