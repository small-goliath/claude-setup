# Claude Code 개인 설정 저장소

이 저장소는 개인화된 Claude Code 개발 환경을 구성하기 위한 commands, skills, agents, plugins 및 설정 파일을 관리합니다.

## 프로젝트 구조

```
claude-setup/
├── agents/              # 전문화된 에이전트
├── commands/            # 커스텀 명령어
├── skills/              # 재사용 가능한 스킬
├── plugins/             # 설치된 플러그인
├── settings.json        # Claude Code 전역 설정
└── .claude.json         # MCP 서버 설정
```

## 설정 파일

### settings.json

전역 Claude Code 설정을 관리합니다.

**주요 설정:**
- `permissions.defaultMode`: "bypassPermissions" - 기본 권한 모드
- `statusLine`: claude-hud 플러그인을 사용한 상태 라인 표시
- `language`: "korean" - 기본 언어 설정

**허용된 작업:**
- Bash 명령어: ls, find, grep, echo, tree, curl, wget
- MCP 서버: context7, playwright
- WebSearch, WebFetch 기능

### .claude.json

MCP (Model Context Protocol) 서버 설정을 관리합니다.

**설정된 MCP 서버:**

1. **playwright** - 브라우저 자동화
   - Chrome 브라우저 사용
   - Isolated 모드로 실행

2. **context7** - Sequential thinking 지원
   - 단계별 사고 프로세스 제공

3. **serena** - 프로젝트 관리 도구
   - Web dashboard 비활성화

4. **taskmaster-ai** - 태스크 관리 AI
   - ANTHROPIC_API_KEY 필요

## Commands

### 개발 워크플로우

- **`/brainstorm`** - 기능 구현 전 요구사항 및 설계 탐색 (필수)
- **`/write-plan`** - 상세한 구현 계획 작성
- **`/execute-plan`** - 배치 단위로 계획 실행
- **`/understand`** - 전체 애플리케이션 아키텍처 분석
- **`/test`** - 컨텍스트 인식 스마트 테스트 실행

### 코드 품질

- **`/refactor`** - 체계적인 코드 리팩토링 (세션 지속성 지원)
- **`/security-scan`** - 보안 취약점 스캔 및 수정 (세션 지속성 지원)
- **`/docs`** - 프로젝트 문서 자동 업데이트

### 설명 및 분석

- **`/explain-like-senior`** - 시니어 개발자 관점의 상세 설명

## Agents

### code-reviewer

주요 프로젝트 단계 완료 후 계획 대비 검토 및 코딩 표준 확인을 수행하는 시니어 코드 리뷰어 에이전트입니다.

**사용 시점:**
- 주요 프로젝트 단계 완료 시
- 계획된 기능 구현 완료 시
- 코드 품질 검증이 필요한 시점

**검토 항목:**
1. Plan Alignment - 계획 대비 구현 일치도
2. Code Quality - 코드 품질 및 패턴 준수
3. Architecture & Design - 아키텍처 및 설계 원칙
4. Documentation - 문서화 적절성

## Skills

### 개발 가이드

- **ai-development-guide** - AI 개발 가이드라인
- **coding-principles** - 코딩 원칙 및 베스트 프랙티스
- **documentation-criteria** - PRD, ADR, Design Doc, Plan 문서 작성 기준
- **skill-creator** - 새로운 스킬 생성 가이드

### 프로젝트 관리 (Redmine)

- **redmine-issue-create** - Redmine 이슈 생성 (Textile 포맷 지원)
- **redmine-issue-update** - Redmine 이슈 업데이트
- **redmine-my-issues** - 내 이슈 조회
- **redmine-log-time** - 작업 시간 기록

**필수 환경 변수:**
```bash
export REDMINE_URL="https://redmine.example.com"
export REDMINE_API_KEY="your_api_key_here"
export REDMINE_PROJECT_ID="1"  # 선택사항
```

### 코드 리뷰 (Upsource)

- **upsource-add-comment** - Upsource 리뷰에 코멘트 추가
- **upsource-review-status** - 리뷰 상태 조회
- **requesting-code-review** - 코드 리뷰 요청 프로세스
- **receiving-code-review** - 코드 리뷰 수신 및 대응

**필수 환경 변수:**
```bash
export UPSOURCE_URL="https://upsource.example.com"
export UPSOURCE_TOKEN="your_token_here"
```

**참고:** Upsource는 2023년 1월 EOL되었습니다. GitLab 또는 GitHub로 마이그레이션을 권장합니다.

### 기타

- **brainstorming** - 체계적인 브레인스토밍 프로세스

## Plugins

### claude-hud
프로젝트 상태를 실시간으로 표시하는 HUD (Heads-Up Display) 플러그인입니다.
상태 라인에 세션 정보, 에이전트, 도구 사용 현황을 표시합니다.

### team-attention-plugins
팀 협업 및 생산성 향상을 위한 플러그인 모음입니다.

**포함된 플러그인:**
- **session-wrap** - 세션 종료 시 작업 내용 요약
- **youtube-digest** - YouTube 영상 분석 및 요약
- **interactive-review** - 대화형 코드 리뷰
- **clarify** - 요구사항 명확화
- **kakaotalk** - 카카오톡 통합
- **google-calendar** - Google Calendar 통합
- **agent-council** - 다중 에이전트 협업
- **dev** - 개발 관련 도구

## 환경 설정 가이드

### 초기 설정

1. 저장소 클론
   ```bash
   git clone <repository-url> ~/Documents/private/claude-setup
   ```

2. 심볼릭 링크 생성 (선택사항)
   ```bash
   # commands
   ln -s ~/Documents/private/claude-setup/commands ~/.claude/commands

   # skills
   ln -s ~/Documents/private/claude-setup/skills ~/.claude/skills

   # agents
   ln -s ~/Documents/private/claude-setup/agents ~/.claude/agents
   ```

3. 설정 파일 복사
   ```bash
   cp ~/Documents/private/claude-setup/settings.json ~/.claude/settings.json
   cp ~/Documents/private/claude-setup/.claude.json ~/.claude/.claude.json
   ```

4. 환경 변수 설정
   ```bash
   # ~/.zshrc 또는 ~/.bashrc에 추가
   export REDMINE_URL="https://redmine.example.com"
   export REDMINE_API_KEY="your_api_key"
   export UPSOURCE_URL="https://upsource.example.com"
   export UPSOURCE_TOKEN="your_token"
   export ANTHROPIC_API_KEY="your_anthropic_key"  # taskmaster-ai 사용 시
   ```

### 새 디바이스에서 설정

1. 저장소를 새 디바이스에 클론
2. 위의 초기 설정 단계 반복
3. MCP 서버 종속성 확인 (npx, uvx 설치 필요)

## 세션 지속성 기능

일부 명령어는 세션 파일을 통해 작업 상태를 유지합니다:

### /refactor
- 위치: `<project>/refactor/`
- 파일: `plan.md`, `state.json`
- 재개: `/refactor resume`

### /security-scan
- 위치: `<project>/security-scan/`
- 파일: `plan.md`, `state.json`
- 재개: `/security-scan resume`

**중요:** 세션 파일은 항상 현재 프로젝트 디렉토리에 생성됩니다.

## 개발 워크플로우 예시

### 새 기능 개발
```
/brainstorm           # 요구사항 및 설계 탐색
/write-plan          # 구현 계획 작성
/execute-plan        # 계획 실행
/test                # 테스트 실행
code-reviewer agent  # 코드 리뷰
/docs                # 문서 업데이트
```

### 코드 품질 개선
```
/understand          # 코드베이스 분석
/security-scan       # 보안 취약점 확인 및 수정
/refactor            # 리팩토링 수행
/test                # 테스트 검증
/docs                # 문서 동기화
```

### 버그 수정
```
/understand          # 문제 영역 분석
/test                # 실패하는 테스트 확인
[수정 작업]
/test                # 수정 검증
/docs                # CHANGELOG 업데이트
```

## 베스트 프랙티스

1. **창의적 작업 전 브레인스토밍** - `/brainstorm` 명령어를 통해 설계 먼저 수행
2. **세션 지속성 활용** - 중단된 작업은 `resume` 명령으로 이어서 진행
3. **문서 동기화** - 코드 변경 후 `/docs`로 문서 자동 업데이트
4. **정기적 보안 점검** - `/security-scan`으로 주기적 보안 검사
5. **코드 리뷰 활용** - 주요 단계마다 code-reviewer 에이전트 활용
6. **세션 마무리** - 작업 완료 후 `/wrap`으로 학습 내용 정리

## Skill 구조 이해하기

### Progressive Disclosure 패턴

Skill은 3단계 로딩 시스템을 사용합니다:

1. **Metadata** (항상 로드): `name` + `description`
2. **SKILL.md body** (트리거 시): 핵심 워크플로우
3. **Bundled resources** (필요 시): `scripts/`, `references/`, `assets/`

### Skill 디렉토리 구조

```
skill-name/
├── SKILL.md          # 필수 - YAML frontmatter + 가이드
├── scripts/          # 선택 - 실행 가능 코드
│   └── helper.py
├── references/       # 선택 - 문서, 컨텍스트에 로드
│   └── api_docs.md
└── assets/           # 선택 - 출력에 사용, 로드 안 함
    └── template.html
```

### Skill vs Command vs Agent

| 구분 | 트리거 | 용도 | 예시 |
|-----|--------|------|------|
| **Command** | 사용자 명시 호출 (`/cmd`) | 자주 쓰는 작업 단축 | `/brainstorm`, `/test` |
| **Skill** | 자동 (description 매칭) | 도메인 특화 지식 | Redmine API, 문서화 기준 |
| **Agent** | 위임된 서브태스크 | 복잡한 분석/검토 | code-reviewer |

## Textile 마크업 (Redmine)

Redmine API 사용 시 Markdown이 아닌 Textile 문법을 사용해야 합니다:

| Feature | Textile | Markdown |
|---------|---------|----------|
| 헤더 | `h2. Title` | `## Title` |
| Bold | `*text*` | `**text**` |
| Italic | `_text_` | `*text*` |
| Code | `@code@` | `` `code` `` |
| Link | `"text":url` | `[text](url)` |
| List | `* item` | `- item` |

## 문제 해결

### MCP 서버 연결 실패
- npx, uvx 명령어가 설치되어 있는지 확인
- API 키가 올바르게 설정되어 있는지 확인
- 네트워크 연결 상태 확인

### 플러그인 로드 실패
- 플러그인 디렉토리 경로 확인
- `.claude-plugin/plugin.json` 파일 존재 여부 확인
- Claude Code 재시작

### 권한 오류
- `settings.json`의 permissions 설정 확인
- 필요한 작업이 `allow` 목록에 있는지 확인

### Skill이 트리거되지 않음
- Skill의 `description`이 충분히 상세한지 확인
- SKILL.md 파일이 올바른 YAML frontmatter를 가지는지 확인
- Skill 디렉토리가 `~/.claude/skills`에 있는지 확인

## 알려진 이슈

### Skills 파일 형식
현재 일부 스킬이 `.skill` 압축 파일로 존재합니다. 이들은 디렉토리 형태로 압축 해제되어야 Claude가 인식할 수 있습니다:
- redmine-issue-create.skill
- redmine-issue-update.skill
- redmine-my-issues.skill
- redmine-log-time.skill
- upsource-add-comment.skill
- upsource-review-status.skill

### 보안 설정
- `settings.json`의 `defaultMode: "bypassPermissions"`는 개발 편의성을 위한 설정입니다
- 프로덕션 환경이나 민감한 프로젝트에서는 명시적 권한 관리를 권장합니다

### Git 추적
- `.DS_Store` 같은 시스템 파일이 현재 추적되고 있습니다
- `.gitignore` 추가가 필요합니다

## 참고 자료

- [Claude Code 공식 문서](https://docs.anthropic.com/claude/docs)
- [MCP 프로토콜 스펙](https://modelcontextprotocol.io)
- [Skills 작성 가이드](./skills/skill-creator/SKILL.md)
- [문서 작성 기준](./skills/documentation-criteria/SKILL.md)
- [Claude Code GitHub](https://github.com/anthropics/claude-code)

## 버전 히스토리

- **2026-01-30**: 초기 설정 및 문서 작성
  - 10개 commands, 13개 skills, 1개 agent 설정
  - MCP 서버 통합 (playwright, context7, serena, taskmaster-ai)
  - claude-hud 및 team-attention-plugins 설치
