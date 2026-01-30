# Claude Code 개인 설정 저장소

이 저장소는 어느 디바이스에서든 일관된 Claude Code 개발 환경을 사용할 수 있도록 commands, skills, agents, plugins 그리고 설정 파일들을 관리하기 위한 공간입니다.

## 목차

- [빠른 시작](#빠른-시작)
- [프로젝트 구조](#프로젝트-구조)
- [Commands 상세](#commands-상세)
- [Skills 상세](#skills-상세)
- [Agents 상세](#agents-상세)
- [Plugins 상세](#plugins-상세)
- [MCP 서버 상세](#mcp-서버-상세)
- [설정 파일 상세](#설정-파일-상세)
- [환경 변수 설정](#환경-변수-설정)
- [새 디바이스 설정](#새-디바이스-설정)
- [문제 해결](#문제-해결)

## 빠른 시작

### 1. 저장소 클론

```bash
git clone <repository-url> ~/Documents/private/claude-setup
cd ~/Documents/private/claude-setup
```

### 2. 설정 파일 배포

```bash
# 옵션 1: 심볼릭 링크 (권장)
ln -s ~/Documents/private/claude-setup/commands ~/.claude/commands
ln -s ~/Documents/private/claude-setup/skills ~/.claude/skills
ln -s ~/Documents/private/claude-setup/agents ~/.claude/agents
cp ~/Documents/private/claude-setup/settings.json ~/.claude/settings.json
cp ~/Documents/private/claude-setup/.claude.json ~/.claude/.claude.json

# 옵션 2: 복사
cp -r ~/Documents/private/claude-setup/commands ~/.claude/
cp -r ~/Documents/private/claude-setup/skills ~/.claude/
cp -r ~/Documents/private/claude-setup/agents ~/.claude/
cp ~/Documents/private/claude-setup/settings.json ~/.claude/settings.json
cp ~/Documents/private/claude-setup/.claude.json ~/.claude/.claude.json
```

### 3. 환경 변수 설정

```bash
# ~/.zshrc 또는 ~/.bashrc에 추가
export REDMINE_URL="https://redmine.example.com"
export REDMINE_API_KEY="your_api_key_here"
export REDMINE_PROJECT_ID="1"  # 선택사항
export UPSOURCE_URL="https://upsource.example.com"
export UPSOURCE_TOKEN="your_token_here"
export ANTHROPIC_API_KEY="your_anthropic_key"  # taskmaster-ai 사용 시

# 적용
source ~/.zshrc  # 또는 source ~/.bashrc
```

### 4. MCP 서버 종속성 확인

```bash
# npx가 설치되어 있는지 확인 (Node.js 패키지)
npx --version

# uvx가 설치되어 있는지 확인 (Python 패키지)
uvx --version  # 또는 pip install uvx
```

### 5. Claude Code 재시작

설정이 완료되면 Claude Code를 재시작하여 변경사항을 적용합니다.

## 프로젝트 구조

```
claude-setup/
├── commands/                          # 사용자 호출 명령어 (10개)
│   ├── brainstorm.md                  # 요구사항 및 설계 탐색
│   ├── write-plan.md                  # 구현 계획 작성
│   ├── execute-plan.md                # 계획 실행
│   ├── understand.md                  # 코드베이스 분석
│   ├── test.md                        # 스마트 테스트 러너
│   ├── refactor.md                    # 리팩토링 엔진
│   ├── security-scan.md               # 보안 스캔
│   ├── docs.md                        # 문서 업데이트
│   ├── explain-like-senior.md         # 시니어 관점 설명
│   └── dev-env-setup.md               # 개발 환경 설정
│
├── skills/                            # 자동 트리거 전문 지식 (13개 + 6개 .skill)
│   ├── coding-principles/             # 코딩 원칙
│   ├── skill-creator/                 # 스킬 생성 도구
│   ├── documentation-criteria/        # 문서화 기준
│   ├── ai-development-guide/          # AI 개발 가이드
│   ├── brainstorming/                 # 브레인스토밍
│   ├── requesting-code-review/        # 코드 리뷰 요청
│   ├── receiving-code-review/         # 코드 리뷰 수신
│   ├── keybindings-help/              # 키바인딩 도움말
│   ├── redmine-issue-create.skill     # Redmine 이슈 생성 (압축)
│   ├── redmine-issue-update.skill     # Redmine 이슈 업데이트 (압축)
│   ├── redmine-my-issues.skill        # Redmine 내 이슈 (압축)
│   ├── redmine-log-time.skill         # Redmine 시간 로깅 (압축)
│   ├── upsource-add-comment.skill     # Upsource 댓글 (압축)
│   └── upsource-review-status.skill   # Upsource 상태 (압축)
│
├── agents/                            # 전문 에이전트 (1개)
│   └── code-reviewer.md               # 코드 리뷰어
│
├── plugins/                           # 설치된 플러그인
│   ├── config.json
│   ├── installed_plugins.json
│   └── marketplaces/
│       ├── claude-hud/                # 상태 표시 플러그인
│       └── team-attention-plugins/    # 팀 협업 플러그인
│           ├── session-wrap/          # 세션 마무리
│           ├── clarify/               # 요구사항 명확화
│           ├── agent-council/         # 멀티 에이전트
│           └── ...
│
├── settings.json                      # Claude Code 전역 설정
├── .claude.json                       # MCP 서버 설정
├── CLAUDE.md                          # Claude용 프로젝트 문서
└── README.md                          # 사용자용 가이드 (이 파일)
```

## Commands 상세

Commands는 사용자가 명시적으로 `/command-name` 형태로 호출하는 작업 단위입니다.

### 개발 워크플로우

#### `/brainstorm`

**목적:** 기능 구현 전 요구사항과 설계를 탐색합니다.

**사용 시점:**
- 새로운 기능을 추가하기 전
- 복잡한 문제를 해결하기 전
- 아키텍처 결정이 필요할 때

**동작:**
- `brainstorming` 스킬을 호출하여 체계적인 탐색 프로세스 시작
- 요구사항 명확화
- 다양한 접근 방식 탐색
- 장단점 분석
- 최적 솔루션 제안

**예시:**
```
사용자: /brainstorm
사용자: 사용자 인증 시스템을 추가하려고 합니다.

Claude: 인증 시스템 설계를 위해 몇 가지 질문드리겠습니다:
1. 인증 방식은? (JWT, Session, OAuth)
2. 사용자 정보 저장 방식은?
3. 비밀번호 재설정 기능이 필요한가요?
...
```

**관련 스킬:** `brainstorming`

---

#### `/write-plan`

**목적:** 구현 작업에 대한 상세한 계획을 작성합니다.

**사용 시점:**
- 브레인스토밍 후 구현 전
- 복잡한 기능 개발 시
- 팀 협업이 필요한 작업

**동작:**
- 작업 범위 정의
- 파일 변경 목록 작성
- 단계별 구현 순서 정의
- 예상 위험 요소 식별
- 테스트 계획 수립

**출력:**
- `plan.md` 파일 생성 (프로젝트 루트)
- 단계별 체크리스트
- 파일별 변경 사항 요약

**예시:**
```
사용자: /write-plan 사용자 인증 시스템 구현

출력:
# 구현 계획: 사용자 인증 시스템

## 1. 개요
...

## 2. 변경 파일
- src/auth/jwt.js (신규)
- src/middleware/auth.js (신규)
- src/routes/user.js (수정)
...

## 3. 구현 단계
1. [ ] JWT 토큰 생성/검증 로직
2. [ ] 미들웨어 구현
...
```

**관련 스킬:** `documentation-criteria`

---

#### `/execute-plan`

**목적:** 작성된 계획을 배치 단위로 실행합니다.

**사용 시점:**
- `/write-plan` 완료 후
- 계획서가 준비된 경우

**동작:**
- `plan.md` 파일을 읽어 단계별 실행
- 각 단계 완료 후 검증
- 진행 상황 업데이트
- 문제 발생 시 중단 및 보고

**옵션:**
- `/execute-plan --batch 1` : 첫 번째 배치만 실행
- `/execute-plan --all` : 전체 계획 실행
- `/execute-plan --resume` : 중단된 지점부터 재개

**예시:**
```
사용자: /execute-plan --batch 1

Claude:
배치 1 실행 중...
✓ src/auth/jwt.js 생성 완료
✓ 단위 테스트 통과
✓ ESLint 검사 통과

다음 배치를 실행하시겠습니까?
```

---

#### `/understand`

**목적:** 전체 애플리케이션의 아키텍처와 코드베이스를 분석합니다.

**사용 시점:**
- 새로운 프로젝트에 참여할 때
- 레거시 코드 분석 시
- 리팩토링 전 구조 파악

**동작:**
- 프로젝트 구조 분석
- 주요 모듈 및 의존성 파악
- 데이터 흐름 추적
- 아키텍처 패턴 식별
- 개선 사항 제안

**출력:**
- 프로젝트 구조도
- 주요 컴포넌트 설명
- 의존성 그래프
- 개선 권장사항

**예시:**
```
사용자: /understand

Claude:
# 프로젝트 구조 분석

## 아키텍처 패턴
- MVC 패턴 사용
- Express.js 기반 REST API

## 주요 모듈
1. src/controllers/ - 비즈니스 로직
2. src/models/ - 데이터 모델 (Mongoose)
3. src/routes/ - API 엔드포인트
...

## 개선 사항
- 인증 미들웨어 부재
- 에러 처리 표준화 필요
...
```

---

#### `/test`

**목적:** 컨텍스트 인식 스마트 테스트를 실행합니다.

**사용 시점:**
- 코드 변경 후 검증
- CI/CD 파이프라인 실행 전
- 버그 수정 후 확인

**동작:**
- 변경된 파일 감지
- 관련 테스트 자동 선택
- 테스트 실행 및 결과 분석
- 실패 시 원인 파악 및 수정 제안

**옵션:**
- `/test --all` : 전체 테스트 실행
- `/test --changed` : 변경된 파일 관련 테스트만
- `/test --watch` : 파일 변경 감지 모드

**예시:**
```
사용자: /test --changed

Claude:
변경 파일 감지:
- src/auth/jwt.js

관련 테스트 실행:
✓ test/auth/jwt.test.js (12개 테스트)
✗ test/integration/auth.test.js (1개 실패)

실패 원인: 토큰 만료 시간 검증 누락
수정 제안을 보여드릴까요?
```

---

### 코드 품질

#### `/refactor`

**목적:** 체계적인 코드 리팩토링을 수행합니다. 세션 지속성을 지원합니다.

**사용 시점:**
- 코드 품질 개선 필요 시
- 기술 부채 해소
- 아키텍처 변경

**동작:**
1. **Setup** : `refactor/` 디렉토리 생성
2. **Analysis** : 코드 분석 및 개선 영역 식별
3. **Planning** : `refactor/plan.md` 작성
4. **Execution** : 단계별 리팩토링 수행
5. **Validation** : 각 단계마다 테스트 실행 및 동작 검증
6. **De-Para Mapping** : 변경 전후 매핑 생성

**세션 파일:**
- `<project>/refactor/plan.md` : 리팩토링 계획
- `<project>/refactor/state.json` : 진행 상태

**옵션:**
- `/refactor` : 새 리팩토링 시작
- `/refactor resume` : 중단된 리팩토링 재개
- `/refactor validate` : 최종 검증

**예시:**
```
사용자: /refactor

Claude:
리팩토링 영역을 분석 중입니다...

발견된 개선 사항:
1. 중복 코드 3곳
2. 순환 의존성 2개
3. 과도한 복잡도 함수 5개

계획을 작성하시겠습니까? (y/n)

---

사용자: /refactor resume

Claude:
이전 세션 복원 중...
진행률: 60% (3/5 단계 완료)
다음 단계: 순환 의존성 해결
계속 진행하시겠습니까?
```

**관련 스킬:** `coding-principles`

---

#### `/security-scan`

**목적:** 보안 취약점을 스캔하고 수정합니다. 세션 지속성을 지원합니다.

**사용 시점:**
- 배포 전 보안 검사
- 정기적인 보안 감사
- 신규 종속성 추가 후

**동작:**
1. **Scan** : 보안 취약점 스캔
2. **Analysis** : 위험도 평가
3. **Planning** : 수정 계획 작성
4. **Fix** : 취약점 수정
5. **Validation** : 수정 검증

**검사 항목:**
- SQL Injection
- XSS (Cross-Site Scripting)
- CSRF (Cross-Site Request Forgery)
- 인증/인가 누락
- 민감 정보 노출
- 의존성 취약점

**세션 파일:**
- `<project>/security-scan/plan.md` : 취약점 목록 및 수정 계획
- `<project>/security-scan/state.json` : 진행 상태

**예시:**
```
사용자: /security-scan

Claude:
보안 스캔 시작...

발견된 취약점:
[HIGH] SQL Injection - src/db/query.js:45
[MEDIUM] XSS - src/views/user.ejs:12
[LOW] 민감 정보 로깅 - src/logger.js:89

수정을 시작하시겠습니까?
```

---

#### `/docs`

**목적:** 프로젝트 문서를 자동으로 업데이트합니다.

**사용 시점:**
- 코드 변경 후
- API 변경 시
- 릴리즈 전

**동작:**
- 코드 변경 사항 감지
- API 문서 자동 생성
- CHANGELOG 업데이트
- README 동기화

**대상 문서:**
- README.md
- CHANGELOG.md
- API.md
- JSDoc / TSDoc 주석

**예시:**
```
사용자: /docs

Claude:
문서 업데이트 중...

✓ README.md - API 섹션 업데이트
✓ CHANGELOG.md - v1.2.0 항목 추가
✓ API.md - 신규 엔드포인트 3개 추가

변경사항을 확인하시겠습니까?
```

**관련 스킬:** `documentation-criteria`

---

### 설명 및 분석

#### `/explain-like-senior`

**목적:** 시니어 개발자 관점에서 코드나 개념을 상세히 설명합니다.

**사용 시점:**
- 복잡한 코드 이해 필요 시
- 아키텍처 결정 배경 파악
- 학습 목적

**동작:**
- 코드의 의도와 배경 설명
- 설계 패턴 식별
- 장단점 분석
- 개선 방향 제시
- 실무 팁 제공

**예시:**
```
사용자: /explain-like-senior
이 코드가 왜 이렇게 작성되었나요?

[코드 블록]

Claude:
시니어 개발자 관점에서 설명드리겠습니다.

## 설계 의도
이 코드는 Factory 패턴을 사용하고 있습니다...

## 장점
1. 객체 생성 로직 캡슐화
2. 의존성 주입 용이
...

## 단점
1. 보일러플레이트 증가
2. 초기 학습 곡선
...

## 실무 팁
프로덕션 환경에서는 다음을 추가로 고려하세요:
- 에러 처리
- 로깅
...
```

---

#### `/dev-env-setup`

**목적:** 개발 환경을 설정합니다.

**사용 시점:**
- 새 프로젝트 시작
- 새 팀원 온보딩
- 개발 환경 표준화

**동작:**
- 필수 도구 설치 확인
- 설정 파일 생성
- 환경 변수 설정
- Git hooks 설정

**예시:**
```
사용자: /dev-env-setup

Claude:
개발 환경 설정을 시작합니다...

✓ Node.js v18.x 설치 확인
✓ .editorconfig 생성
✓ .eslintrc.js 생성
✓ .prettierrc 생성
✓ Git hooks 설정

설정이 완료되었습니다!
```

---

## Skills 상세

Skills는 특정 컨텍스트에서 자동으로 활성화되는 전문 지식입니다.

### 개발 가이드 Skills

#### `coding-principles`

**자동 트리거 조건:**
- 코드 작성 또는 수정 시
- 리팩토링 수행 시
- 코드 리뷰 시

**제공 지식:**
- 언어 중립적 코딩 원칙
- SOLID 원칙
- DRY, KISS, YAGNI
- 네이밍 규칙
- 함수 크기 및 복잡도 기준

**예시 원칙:**
```
- 함수는 한 가지 일만 수행
- 변수명은 의도를 명확히 표현
- 매직 넘버 사용 금지
- 조기 반환 (early return) 선호
- null 체크보다 Optional 사용
```

---

#### `documentation-criteria`

**자동 트리거 조건:**
- 문서 작성 요청 시
- 새 기능 추가 시
- 아키텍처 변경 시

**제공 지식:**
- PRD (Product Requirements Document) 작성 기준
- ADR (Architecture Decision Record) 작성 기준
- Design Doc 작성 기준
- Work Plan 작성 기준
- Task 정의 방법

**문서 생성 매트릭스:**

| 조건 | 필수 문서 | 생성 순서 |
|------|----------|----------|
| 신규 기능 | PRD → [ADR] → Design → Plan | PRD 승인 후 |
| 6개 이상 파일 변경 | ADR → Design → Plan (필수) | 즉시 시작 |
| 3-5개 파일 변경 | Design → Plan (권장) | 즉시 시작 |
| 1-2개 파일 변경 | 없음 | 직접 구현 |

**템플릿 제공:**
- `references/prd-template.md`
- `references/adr-template.md`
- `references/design-template.md`
- `references/plan-template.md`
- `references/task-template.md`

---

#### `ai-development-guide`

**자동 트리거 조건:**
- AI 기능 개발 시
- 기술적 의사결정 필요 시
- 코드 품질 검토 시

**제공 지식:**
- 기술 결정 기준
- 안티 패턴 감지
- 디버깅 기법
- 품질 체크 워크플로우

---

#### `skill-creator`

**자동 트리거 조건:**
- "새 스킬 만들기" 요청 시
- "스킬 생성" 관련 질문 시

**제공 도구:**
- `scripts/init_skill.py` : 스킬 디렉토리 초기화
- `scripts/package_skill.py` : 스킬 패키징 (.skill 파일 생성)
- `scripts/quick_validate.py` : 스킬 검증

**스킬 생성 워크플로우:**
1. **이해** : 구체적 사용 예시 수집
2. **계획** : scripts/references/assets 식별
3. **초기화** : `init_skill.py <skill-name>` 실행
4. **편집** : SKILL.md 및 리소스 작성
5. **패키징** : `package_skill.py <path>` 실행
6. **반복** : 실제 사용 후 개선

**스킬 디렉토리 구조:**
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

---

### 프로젝트 관리 Skills

#### `redmine-issue-create`

**자동 트리거 조건:**
- "Redmine 이슈 생성" 요청
- "버그 리포트 작성" 요청
- "작업 티켓 만들기" 요청

**필수 환경 변수:**
```bash
export REDMINE_URL="https://redmine.example.com"
export REDMINE_API_KEY="your_api_key_here"
export REDMINE_PROJECT_ID="1"  # 선택사항
```

**기능:**
- Redmine REST API를 통한 이슈 생성
- Textile 마크업 자동 변환
- 이슈 타입 선택 (Bug, Feature, Task 등)
- 우선순위 및 담당자 설정

**Textile 마크업 예시:**
```textile
h2. 버그 설명

패스워드에 @#$@ 같은 특수문자 사용 시 로그인 실패

h3. 재현 단계

# 로그인 페이지 이동
# 유효한 사용자명 입력
# 특수문자 포함 패스워드 입력
# 로그인 버튼 클릭

h3. 예상 vs 실제

*예상:* 로그인 성공
*실제:* 에러 메시지

@validatePassword()@ 함수 참조: "auth 모듈":https://example.com/auth.js
```

---

#### `redmine-issue-update`

**자동 트리거 조건:**
- "Redmine 이슈 업데이트" 요청
- "이슈 상태 변경" 요청
- "진행 상황 업데이트" 요청

**기능:**
- 이슈 상태 변경 (New → In Progress → Resolved)
- 진행률 업데이트
- 코멘트 추가 (Textile 형식)
- 담당자 변경

---

#### `redmine-my-issues`

**자동 트리거 조건:**
- "내 이슈 보기" 요청
- "할당된 작업 확인" 요청

**기능:**
- 현재 사용자에게 할당된 이슈 목록 조회
- 우선순위별 필터링
- 상태별 그룹화
- 마감일 기준 정렬

---

#### `redmine-log-time`

**자동 트리거 조건:**
- "시간 기록" 요청
- "작업 시간 로깅" 요청

**기능:**
- 특정 이슈에 작업 시간 기록
- 활동 타입 선택 (Development, Testing, Documentation 등)
- Textile 형식 코멘트 추가
- 날짜 지정 가능

---

### 코드 리뷰 Skills

#### `upsource-add-comment`

**주의:** Upsource는 2023년 1월 EOL되었습니다. 레거시 시스템 전용입니다.

**자동 트리거 조건:**
- "Upsource 코멘트 추가" 요청
- "리뷰 코멘트 작성" 요청

**필수 환경 변수:**
```bash
export UPSOURCE_URL="https://upsource.example.com"
export UPSOURCE_TOKEN="your_token_here"
```

**기능:**
- 특정 리뷰에 코멘트 추가
- 파일의 특정 라인에 코멘트
- 일반 코멘트 또는 이슈 제기

---

#### `upsource-review-status`

**자동 트리거 조건:**
- "리뷰 상태 확인" 요청
- "리뷰 진행 상황" 요청

**기능:**
- 리뷰 상태 조회 (Open, In Progress, Closed)
- 참여자 및 승인 상태
- 미해결 코멘트 수
- 변경 파일 목록

---

#### `requesting-code-review`

**자동 트리거 조건:**
- 작업 완료 후
- PR 생성 전
- "코드 리뷰 요청" 멘션

**제공 지식:**
- 리뷰 요청 전 체크리스트
- PR 설명 작성 가이드
- Self-review 방법
- 리뷰어 선택 기준

---

#### `receiving-code-review`

**자동 트리거 조건:**
- 코드 리뷰 피드백 수신 시
- "리뷰 코멘트 대응" 요청

**제공 지식:**
- 피드백 해석 방법
- 기술적 검증 프로세스
- 불명확한 피드백 처리
- 의견 불일치 시 대응

**핵심 원칙:**
- 모든 피드백을 기술적으로 검증
- 불명확한 제안은 명확히 요청
- 맹목적 수용보다 이해 우선

---

### 기타 Skills

#### `brainstorming`

**자동 트리거 조건:**
- 창의적 작업 시작 전
- 문제 해결 접근 방식 탐색
- 아키텍처 설계

**제공 프로세스:**
1. 문제 정의
2. 요구사항 명확화
3. 제약 조건 파악
4. 다양한 접근 방식 탐색
5. 장단점 비교
6. 최적 솔루션 선택

---

#### `keybindings-help`

**자동 트리거 조건:**
- "키 바인딩 변경" 요청
- "단축키 설정" 요청
- "chord 바인딩 추가" 요청

**제공 지식:**
- `~/.claude/keybindings.json` 구조
- 단일 키 바인딩 설정
- Chord 바인딩 (연속 키 입력)
- 기본 바인딩 목록
- 충돌 해결 방법

---

## Agents 상세

Agents는 복잡한 작업을 처리하기 위해 별도 Claude 인스턴스로 위임되는 전문 에이전트입니다.

### code-reviewer

**목적:** 주요 프로젝트 단계 완료 후 코드를 검토하고 계획 대비 일치도를 확인합니다.

**사용 시점:**
- 주요 프로젝트 단계 완료 시
- `/execute-plan` 배치 완료 시
- PR 생성 전
- 릴리즈 전

**호출 방법:**
```
사용자: code-reviewer 에이전트를 실행해주세요.
```

**검토 항목:**

1. **Plan Alignment (계획 일치도)**
   - 계획서와 실제 구현 비교
   - 누락된 요구사항 확인
   - 범위 초과 코드 식별

2. **Code Quality (코드 품질)**
   - 코딩 표준 준수
   - 명명 규칙
   - 함수 크기 및 복잡도
   - 중복 코드
   - 주석 품질

3. **Architecture & Design (아키텍처)**
   - 설계 패턴 적용
   - SOLID 원칙 준수
   - 의존성 방향
   - 계층 분리
   - 결합도/응집도

4. **Documentation (문서화)**
   - API 문서 완성도
   - 인라인 주석 적절성
   - README 업데이트
   - CHANGELOG 기록

**출력 형식:**
```markdown
# Code Review Report

## Summary
- Overall Score: 8.5/10
- Critical Issues: 0
- Major Issues: 2
- Minor Issues: 5

## Plan Alignment ✓
모든 요구사항이 구현되었습니다.

## Code Quality ⚠
### Major Issues
1. [src/auth/jwt.js:45] 함수 복잡도 과다 (CC: 15)
2. [src/db/query.js:23] SQL Injection 위험

### Minor Issues
...

## Architecture ✓
설계 패턴이 일관되게 적용되었습니다.

## Documentation ⚠
API 문서 업데이트가 필요합니다.

## Recommendations
1. jwt.js의 복잡한 함수를 분리하세요
2. 파라미터 검증 로직을 추가하세요
...
```

**설정:**
- **Model:** `inherit` (부모 세션의 모델 사용)
- **컨텍스트:** 전체 대화 히스토리 포함

---

## Plugins 상세

Plugins는 기능을 확장하는 번들입니다. Commands, Skills, Agents를 포함할 수 있습니다.

### claude-hud

**목적:** 터미널 상태 라인에 실시간 정보를 표시합니다.

**표시 정보:**
- 현재 프로젝트 이름
- Git 브랜치 및 상태
- 활성 에이전트
- 토큰 사용량
- 세션 시간

**설정 위치:** `settings.json`의 `statusLine` 섹션

**예시 출력:**
```
[claude-setup:main✓] Agent:code-reviewer | Tokens: 12.5k/200k | 00:15:32
```

**커스터마이징:**
- 색상 변경 가능
- 표시 항목 선택 가능
- 업데이트 주기 설정 가능

---

### team-attention-plugins

팀 협업 및 생산성 향상을 위한 플러그인 모음입니다.

#### session-wrap

**목적:** 세션 종료 시 작업 내용을 자동으로 정리하고 분석합니다.

**호출 방법:**
```
/wrap
```

**수행 작업:**

1. **Phase 1: 병렬 분석 (4개 에이전트)**
   - `doc-updater`: 문서 업데이트 필요 사항 식별
   - `automation-scout`: 자동화 기회 발견
   - `learning-extractor`: 학습 내용 추출
   - `followup-suggester`: 후속 작업 제안

2. **Phase 2: 검증**
   - `duplicate-checker`: 중복 제안 검증 및 통합

3. **결과 통합 및 제시**
   - 문서화 제안
   - 자동화 기회
   - 학습 요약
   - 다음 작업 목록

**출력 파일:**
- `session-summary.md`: 세션 요약
- `learnings.md`: 학습 내용
- `next-tasks.md`: 후속 작업

---

#### clarify

**목적:** 불명확한 요구사항을 명확히 합니다.

**자동 트리거 조건:**
- 요구사항이 모호할 때
- "명확히 해주세요" 요청
- "무엇을 원하시나요?" 질문

**제공 프로세스:**
- 반복적 질문을 통한 요구사항 정제
- 구체적 예시 요청
- 제약 조건 파악
- 우선순위 설정

---

#### agent-council

**목적:** 여러 에이전트가 협업하여 복잡한 문제를 해결합니다.

**사용 시점:**
- 다양한 관점이 필요한 결정
- 복잡한 아키텍처 설계
- 리스크 평가

**동작:**
- 여러 전문 에이전트 동시 실행
- 각 에이전트의 의견 수집
- 합의 도출 또는 투표
- 최종 권장 사항 제시

---

#### youtube-digest

**목적:** YouTube 영상을 분석하고 요약합니다.

**기능:**
- 자막 추출 및 분석
- 핵심 내용 요약
- 타임스탬프 기반 섹션 분리
- 코드 예제 추출 (기술 영상)

---

#### interactive-review

**목적:** 대화형 코드 리뷰를 제공합니다.

**기능:**
- 단계별 코드 리뷰
- 실시간 질의응답
- 개선 사항 즉시 적용
- 리뷰 진행 상황 추적

---

## MCP 서버 상세

MCP (Model Context Protocol) 서버는 외부 도구를 Claude와 통합합니다.

### playwright

**목적:** 브라우저 자동화 및 테스트

**설정:**
```json
{
  "playwright": {
    "command": "npx",
    "args": [
      "-y",
      "@executeautomation/playwright-mcp-server",
      "--browser", "chrome",
      "--isolated"
    ]
  }
}
```

**제공 기능:**
- 웹 페이지 자동화
- E2E 테스트 실행
- 스크린샷 캡처
- 요소 상호작용

**사용 예시:**
```
사용자: playwright를 사용해서 로그인 페이지를 테스트해주세요.

Claude:
1. chrome 브라우저를 시작합니다
2. https://example.com/login 이동
3. 사용자명 입력
4. 비밀번호 입력
5. 로그인 버튼 클릭
6. 대시보드 페이지 확인
```

---

### context7

**목적:** 단계별 사고 프로세스 (Sequential Thinking) 지원

**설정:**
```json
{
  "context7": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
  }
}
```

**제공 기능:**
- 복잡한 문제를 단계별로 분해
- 각 단계의 사고 과정 기록
- 논리적 추론 체인 생성
- 의사결정 과정 추적

**사용 예시:**
```
사용자: 최적의 캐싱 전략을 선택해주세요.

Claude (Sequential Thinking 사용):
[Step 1] 캐싱 요구사항 분석
- 읽기 빈도: 높음
- 쓰기 빈도: 낮음
- 데이터 크기: 중간

[Step 2] 캐싱 전략 옵션 평가
- In-Memory: 빠르지만 재시작 시 손실
- Redis: 영속성 보장, 분산 가능
- CDN: 정적 리소스 최적

[Step 3] 제약 조건 고려
- 예산: 제한적
- 인프라: 기존 Redis 있음

[Step 4] 최종 권장사항
Redis 사용을 권장합니다. 이유: ...
```

---

### serena

**목적:** 프로젝트 관리 및 코드 탐색 도구

**설정:**
```json
{
  "serena": {
    "type": "stdio",
    "command": "uvx",
    "args": [
      "--from", "git+https://github.com/oraios/serena",
      "serena-mcp-server",
      "start-mcp-server",
      "--args", "{\"web_dashboard\": false}"
    ]
  }
}
```

**제공 기능:**
- 코드베이스 탐색
- 심볼 검색 및 분석
- 파일 구조 시각화
- 의존성 그래프

**사용 예시:**
```
사용자: UserService 클래스를 찾아주세요.

Claude (Serena 사용):
UserService 클래스를 찾았습니다:

위치: src/services/UserService.js:12
메서드:
- constructor(db)
- getUser(id)
- createUser(data)
- updateUser(id, data)
- deleteUser(id)

이 클래스를 참조하는 파일:
- src/controllers/UserController.js:5
- src/routes/user.js:3
```

---

### taskmaster-ai

**목적:** AI 기반 작업 관리 및 자동화

**설정:**
```json
{
  "taskmaster-ai": {
    "command": "uvx",
    "args": ["taskmaster-mcp-server"],
    "env": {
      "ANTHROPIC_API_KEY": "your_api_key_here"
    }
  }
}
```

**필수 환경 변수:**
```bash
export ANTHROPIC_API_KEY="your_anthropic_api_key"
```

**제공 기능:**
- 작업 자동 생성 및 분해
- 우선순위 자동 설정
- 의존성 자동 분석
- 작업 진행 상황 추적
- PRD 파싱 및 작업 생성

**사용 예시:**
```
사용자: PRD를 기반으로 작업을 생성해주세요.

Claude (Taskmaster 사용):
PRD 분석 중...

생성된 작업 (10개):
1. [P0] 데이터베이스 스키마 설계
2. [P1] API 엔드포인트 구현
   - 2.1. POST /users
   - 2.2. GET /users/:id
3. [P1] 프론트엔드 통합
...

의존성:
- Task 2는 Task 1 완료 후 시작 가능
- Task 3는 Task 2 완료 후 시작 가능
```

---

## 설정 파일 상세

### settings.json

전역 Claude Code 설정 파일입니다.

**위치:** `~/.claude/settings.json`

**전체 구조:**
```json
{
  "permissions": {
    "defaultMode": "bypassPermissions",
    "allow": [
      "Bash(ls:*)",
      "Bash(find:*)",
      "Bash(grep:*)",
      "Bash(echo:*)",
      "Bash(cat:*)",
      "Bash(tree:*)",
      "Bash(curl:*)",
      "Bash(wget:*)",
      "WebSearch",
      "WebFetch",
      "mcp__context7__*",
      "mcp__playwright__*"
    ],
    "deny": [],
    "ask": []
  },
  "statusLine": {
    "type": "command",
    "command": "bash -c '\"/opt/homebrew/bin/node\" \"$(ls -td ~/.claude/plugins/cache/claude-hud/claude-hud/*/ 2>/dev/null | head -1)dist/index.js\"'"
  },
  "language": "korean"
}
```

#### permissions 섹션

**defaultMode**

Claude가 도구를 사용할 때 기본 권한 모드를 설정합니다.

옵션:
- `"bypassPermissions"`: 모든 작업 자동 허용 (개발 편의성)
- `"ask"`: 매번 사용자에게 확인 요청 (보안 우선)

권장:
- 개인 프로젝트: `"bypassPermissions"`
- 팀 프로젝트: `"ask"`
- 프로덕션 환경: `"ask"` + 명시적 `allow` 리스트

**allow 리스트**

명시적으로 허용할 작업을 정의합니다.

형식:
```json
"allow": [
  "ToolName(parameter:pattern)",
  "ToolName",
  "mcp__server-name__*"
]
```

예시:
```json
"allow": [
  "Bash(ls:*)",              // ls 명령어 모두 허용
  "Bash(git:status)",        // git status만 허용
  "WebSearch",               // 웹 검색 허용
  "mcp__playwright__*"       // Playwright MCP 모든 기능 허용
]
```

**deny 리스트**

명시적으로 거부할 작업을 정의합니다. `allow`보다 우선합니다.

예시:
```json
"deny": [
  "Bash(rm:*)",              // rm 명령어 금지
  "Bash(sudo:*)",            // sudo 명령어 금지
  "Write(/etc/*)"            // 시스템 디렉토리 쓰기 금지
]
```

**ask 리스트**

항상 사용자 확인을 요청할 작업을 정의합니다.

예시:
```json
"ask": [
  "Bash(npm:install)",       // npm install 시 확인
  "Bash(git:push)",          // git push 시 확인
  "Write(package.json)"      // package.json 수정 시 확인
]
```

#### statusLine 섹션

터미널 상태 라인 설정입니다.

**type**

상태 라인 유형:
- `"command"`: 외부 명령 실행 결과 표시
- `"static"`: 고정 텍스트 표시

**command**

상태 라인 정보를 생성하는 명령어입니다.

현재 설정은 claude-hud 플러그인을 동적으로 찾아 실행합니다:
```bash
bash -c '
  "/opt/homebrew/bin/node" \
  "$(ls -td ~/.claude/plugins/cache/claude-hud/claude-hud/*/ 2>/dev/null | head -1)dist/index.js"
'
```

커스터마이징:
```json
{
  "statusLine": {
    "type": "command",
    "command": "bash -c 'echo \"[$(basename $(pwd))] $(git branch --show-current 2>/dev/null)\"'"
  }
}
```

결과: `[claude-setup] main`

#### language 섹션

Claude의 기본 응답 언어를 설정합니다.

옵션:
- `"korean"`: 한국어
- `"english"`: 영어
- `"japanese"`: 일본어
- 기타 지원 언어

---

### .claude.json

MCP 서버 설정 파일입니다.

**위치:** `~/.claude/.claude.json` 또는 프로젝트 루트

**전체 구조:**
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "-y",
        "@executeautomation/playwright-mcp-server",
        "--browser", "chrome",
        "--isolated"
      ]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    },
    "serena": {
      "type": "stdio",
      "command": "uvx",
      "args": [
        "--from", "git+https://github.com/oraios/serena",
        "serena-mcp-server",
        "start-mcp-server",
        "--args", "{\"web_dashboard\": false}"
      ]
    },
    "taskmaster-ai": {
      "command": "uvx",
      "args": ["taskmaster-mcp-server"],
      "env": {
        "ANTHROPIC_API_KEY": "${ANTHROPIC_API_KEY}"
      }
    }
  }
}
```

#### MCP 서버 공통 필드

**command**

MCP 서버를 실행할 명령어입니다.

일반적인 값:
- `"npx"`: Node.js 패키지 실행
- `"uvx"`: Python 패키지 실행 (pipx 후계)
- `"python"`: Python 스크립트 실행
- 기타 실행 가능한 명령어

**args**

명령어에 전달할 인자 배열입니다.

예시:
```json
"args": [
  "-y",                    // npx: 자동 yes
  "package-name",          // 패키지 이름
  "--option", "value"      // 패키지 옵션
]
```

**env** (선택사항)

MCP 서버에 전달할 환경 변수입니다.

예시:
```json
"env": {
  "API_KEY": "${YOUR_API_KEY}",
  "DEBUG": "true"
}
```

환경 변수 참조:
- `"${VAR_NAME}"`: 시스템 환경 변수 참조
- `"literal value"`: 리터럴 값

**type** (선택사항)

MCP 서버 통신 방식입니다.

옵션:
- `"stdio"`: 표준 입출력 (기본값)
- `"http"`: HTTP 서버

---

## 환경 변수 설정

### Redmine 통합

Redmine API를 사용하는 스킬에 필요합니다.

```bash
# ~/.zshrc 또는 ~/.bashrc에 추가

# Redmine 서버 URL
export REDMINE_URL="https://redmine.example.com"

# Redmine API 키 (My account > API access key에서 생성)
export REDMINE_API_KEY="your_api_key_here"

# 기본 프로젝트 ID (선택사항)
export REDMINE_PROJECT_ID="1"
```

**API 키 생성 방법:**
1. Redmine 로그인
2. My account 메뉴
3. API access key 섹션
4. "Show" 클릭 또는 "Reset" 클릭하여 생성

---

### Upsource 통합

Upsource API를 사용하는 스킬에 필요합니다.

```bash
# Upsource 서버 URL
export UPSOURCE_URL="https://upsource.example.com"

# Upsource 액세스 토큰
export UPSOURCE_TOKEN="your_token_here"
```

**토큰 생성 방법:**
1. Upsource 로그인
2. Settings > Access Tokens
3. "Generate Token" 클릭
4. 권한 선택 (reviews:read, reviews:write)

**참고:** Upsource는 EOL되었으므로 GitLab 또는 GitHub로 마이그레이션을 권장합니다.

---

### Taskmaster AI

Taskmaster AI MCP 서버에 필요합니다.

```bash
# Anthropic API 키
export ANTHROPIC_API_KEY="sk-ant-..."
```

**API 키 생성 방법:**
1. https://console.anthropic.com 접속
2. API Keys 메뉴
3. "Create Key" 클릭
4. 키 이름 지정 및 생성

---

### 환경 변수 적용

```bash
# 설정 파일 편집
vim ~/.zshrc  # 또는 ~/.bashrc

# 환경 변수 추가
export REDMINE_URL="..."
export REDMINE_API_KEY="..."

# 저장 후 적용
source ~/.zshrc
```

**영구 적용 확인:**
```bash
echo $REDMINE_URL
# 출력: https://redmine.example.com
```

---

## 새 디바이스 설정

다른 컴퓨터에서 동일한 Claude Code 환경을 구성하는 방법입니다.

### 1. Git 저장소 클론

```bash
git clone <repository-url> ~/Documents/private/claude-setup
cd ~/Documents/private/claude-setup
```

### 2. Claude Code 설치 확인

```bash
claude --version
# Claude Code v1.x.x
```

설치되지 않은 경우:
```bash
# macOS
brew install claude-code

# 기타 OS
# https://github.com/anthropics/claude-code 참조
```

### 3. 설정 파일 배포

#### 옵션 A: 심볼릭 링크 (권장)

장점: 저장소 변경 시 자동 반영

```bash
ln -s ~/Documents/private/claude-setup/commands ~/.claude/commands
ln -s ~/Documents/private/claude-setup/skills ~/.claude/skills
ln -s ~/Documents/private/claude-setup/agents ~/.claude/agents
```

#### 옵션 B: 복사

장점: 독립적인 환경

```bash
cp -r ~/Documents/private/claude-setup/commands ~/.claude/
cp -r ~/Documents/private/claude-setup/skills ~/.claude/
cp -r ~/Documents/private/claude-setup/agents ~/.claude/
```

#### 설정 파일 복사

**중요:** 심볼릭 링크가 아닌 복사 권장 (민감 정보 포함)

```bash
cp ~/Documents/private/claude-setup/settings.json ~/.claude/settings.json
cp ~/Documents/private/claude-setup/.claude.json ~/.claude/.claude.json
```

### 4. 환경 변수 설정

```bash
# 쉘 설정 파일 편집
vim ~/.zshrc  # 또는 ~/.bashrc

# 다음 내용 추가
export REDMINE_URL="https://redmine.example.com"
export REDMINE_API_KEY="your_api_key"
export UPSOURCE_URL="https://upsource.example.com"
export UPSOURCE_TOKEN="your_token"
export ANTHROPIC_API_KEY="your_anthropic_key"

# 적용
source ~/.zshrc
```

### 5. MCP 서버 종속성 설치

```bash
# Node.js 설치 확인
node --version
npm --version

# Python 설치 확인
python3 --version

# uvx 설치
pip3 install pipx
pipx ensurepath
pipx install uvx

# 또는 brew (macOS)
brew install pipx
pipx install uvx
```

### 6. Claude Code 재시작

```bash
# 터미널을 종료하고 다시 시작
# 또는
exec $SHELL
```

### 7. 설정 확인

```bash
# Commands 확인
ls ~/.claude/commands/

# Skills 확인
ls ~/.claude/skills/

# Agents 확인
ls ~/.claude/agents/

# 환경 변수 확인
echo $REDMINE_URL
```

### 8. 테스트

Claude Code를 실행하고 간단한 명령어를 테스트합니다:

```
/brainstorm
테스트 기능을 추가하려고 합니다.
```

---

## 문제 해결

### MCP 서버 연결 실패

**증상:**
```
Error: Failed to connect to MCP server 'playwright'
```

**원인 및 해결:**

1. **npx/uvx가 설치되지 않음**
   ```bash
   # npx 확인 (Node.js)
   npx --version
   # 설치
   npm install -g npx

   # uvx 확인 (Python)
   uvx --version
   # 설치
   pip3 install uvx
   ```

2. **네트워크 문제**
   ```bash
   # 패키지 수동 설치 시도
   npx -y @executeautomation/playwright-mcp-server --version
   ```

3. **API 키 미설정**
   ```bash
   # 환경 변수 확인
   echo $ANTHROPIC_API_KEY

   # 없으면 설정
   export ANTHROPIC_API_KEY="your_key"
   ```

---

### Skills 인식 안 됨

**증상:**
- Skills가 자동으로 트리거되지 않음
- "Skill not found" 에러

**원인 및 해결:**

1. **파일 위치 확인**
   ```bash
   ls ~/.claude/skills/
   # 스킬이 보여야 함
   ```

2. **.skill 압축 파일 문제**
   ```bash
   # .skill 파일은 압축 해제 필요
   cd ~/.claude/skills/
   unzip redmine-issue-create.skill
   ```

3. **SKILL.md 형식 확인**
   - YAML frontmatter가 있는지 확인
   - `name`과 `description` 필드 필수

   ```markdown
   ---
   name: skill-name
   description: Detailed description that triggers the skill
   ---

   # Skill content
   ...
   ```

4. **Claude Code 재시작**
   ```bash
   # 터미널 재시작
   exec $SHELL
   ```

---

### Permissions 오류

**증상:**
```
Permission denied: Bash(git:push)
```

**원인 및 해결:**

1. **settings.json 확인**
   ```bash
   cat ~/.claude/settings.json | grep -A 10 permissions
   ```

2. **allow 리스트에 추가**
   ```json
   {
     "permissions": {
       "allow": [
         "Bash(git:*)"  // git 모든 명령어 허용
       ]
     }
   }
   ```

3. **defaultMode 변경 (주의)**
   ```json
   {
     "permissions": {
       "defaultMode": "bypassPermissions"
     }
   }
   ```

---

### Redmine API 연결 실패

**증상:**
```
Error: Failed to create Redmine issue
Unauthorized (401)
```

**원인 및 해결:**

1. **환경 변수 확인**
   ```bash
   echo $REDMINE_URL
   echo $REDMINE_API_KEY
   ```

2. **API 키 유효성 테스트**
   ```bash
   curl -H "X-Redmine-API-Key: $REDMINE_API_KEY" \
        "$REDMINE_URL/projects.json"
   ```

3. **Redmine 서버 URL 확인**
   - 프로토콜 확인 (https://)
   - 경로에 /api 포함 여부 확인

4. **API 액세스 활성화 확인**
   - Redmine 관리자 설정 > API > "Enable REST web service" 체크

---

### Plugin 로드 실패

**증상:**
- 플러그인이 표시되지 않음
- 플러그인 기능이 동작하지 않음

**원인 및 해결:**

1. **플러그인 디렉토리 확인**
   ```bash
   ls -la ~/.claude/plugins/
   ls -la ~/.claude/plugins/marketplaces/
   ```

2. **plugin.json 존재 확인**
   ```bash
   cat ~/.claude/plugins/marketplaces/claude-hud/.claude-plugin/plugin.json
   ```

3. **플러그인 재설치**
   ```bash
   # 플러그인 삭제
   rm -rf ~/.claude/plugins/marketplaces/claude-hud

   # Claude Code 재시작 후 자동 재설치
   ```

---

### statusLine 표시 안 됨

**증상:**
- 터미널 상단에 상태 라인이 표시되지 않음

**원인 및 해결:**

1. **claude-hud 설치 확인**
   ```bash
   ls ~/.claude/plugins/cache/claude-hud/
   ```

2. **명령어 수동 실행 테스트**
   ```bash
   bash -c '"/opt/homebrew/bin/node" "$(ls -td ~/.claude/plugins/cache/claude-hud/claude-hud/*/ 2>/dev/null | head -1)dist/index.js"'
   ```

3. **Node.js 경로 확인**
   ```bash
   which node
   # /opt/homebrew/bin/node (macOS ARM)
   # /usr/local/bin/node (macOS Intel)
   # /usr/bin/node (Linux)
   ```

4. **settings.json 수정**
   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "bash -c '\"$(which node)\" \"$(ls -td ~/.claude/plugins/cache/claude-hud/claude-hud/*/ 2>/dev/null | head -1)dist/index.js\"'"
     }
   }
   ```

---

## 고급 사용법

### 커스텀 Command 생성

```markdown
# ~/.claude/commands/my-command.md
---
description: 내 커스텀 명령어 설명
disable-model-invocation: true
---

Invoke the custom-skill skill
```

### 커스텀 Skill 생성

```bash
# Skill Creator 사용
cd ~/.claude/skills/
python ~/Documents/private/claude-setup/skills/skill-creator/scripts/init_skill.py my-skill

# SKILL.md 편집
vim my-skill/SKILL.md

# 패키징
python ~/Documents/private/claude-setup/skills/skill-creator/scripts/package_skill.py my-skill
```

### 커스텀 Agent 생성

```markdown
# ~/.claude/agents/my-agent.md
---
name: my-agent
description: 내 커스텀 에이전트
model: inherit
---

# Agent Instructions

당신은 [특정 역할] 전문가입니다.

## 주요 책임
1. ...
2. ...

## 작업 방식
...
```

---

## 참고 자료

- [Claude Code 공식 문서](https://docs.anthropic.com/claude/docs)
- [MCP 프로토콜](https://modelcontextprotocol.io)
- [프로젝트 상세 문서](./CLAUDE.md)
- [Skill Creator 가이드](./skills/skill-creator/SKILL.md)
- [문서화 기준](./skills/documentation-criteria/SKILL.md)

---

**마지막 업데이트:** 2026-01-30
