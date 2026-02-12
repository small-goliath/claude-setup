---
name: development-workflow
description: Redmine 이슈부터 배포까지 전체 개발 워크플로우를 자동화합니다
disable-model-invocation: true
argument-hint: [redmine-issue-number]
allowed-tools: Skill, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion, Bash
---

# 개발 워크플로우 자동화

## 목차

- [개발 워크플로우 자동화](#개발-워크플로우-자동화)
  - [사용법](#사용법)
  - [워크플로우 단계](#워크플로우-단계)
    - [1단계: Redmine 이슈 분석](#1단계-redmine-이슈-분석)
    - [2단계: 설계](#2단계-설계)
    - [3단계: PRD 생성 및 검증](#3단계-prd-생성-및-검증)
    - [4단계: 브랜치 생성](#4단계-브랜치-생성)
    - [5단계: Task 구성](#5단계-task-구성)
    - [6단계: Task 구현 루프](#6단계-task-구현-루프)
    - [7단계: 코드 리뷰](#7단계-코드-리뷰)
    - [8단계: 피드백 처리](#8단계-피드백-처리)
    - [9단계: 테스트 실행](#9단계-테스트-실행)
    - [10단계: 테스트 결과 처리](#10단계-테스트-결과-처리)
    - [11단계: CLAUDE.md 최종 업데이트](#11단계-claudemd-최종-업데이트)
    - [12단계: 완료](#12단계-완료)
  - [주의사항](#주의사항)
  - [참조 파일](#참조-파일)

Redmine 이슈를 분석하고, 설계부터 구현, 테스트, 코드 리뷰까지 전체 개발 프로세스를 자동화합니다.

## 사용법

```bash
/development-workflow [redmine-issue-number]
```

## 워크플로우 단계

### 1단계: Redmine 이슈 분석
```bash
/analyze-redmine $ARGUMENTS
```
- Redmine API로 이슈 상세 정보 조회
- 이슈 내용, 설명, 첨부파일 분석
- 요구사항 추출

### 2단계: 설계
```bash
/design-solution
```
- Plan agent와 ultrathink 모드로 상세 설계
- 영향받는 파일 파악
- 구현 방안 및 테스트 전략 수립
- **사용자 확인**: AskUserQuestion으로 설계 승인

### 3단계: PRD 생성 및 검증
병렬로 실행:
- Task(prd-generator): PRD.md 문서 생성
- Task(prd-validator): PRD.md 기술 검증

### 4단계: 브랜치 생성
- 기본 브랜치명: `feature/{이슈번호}`
- **사용자 확인**: AskUserQuestion으로 브랜치명 커스터마이즈 옵션 제공
- Git 브랜치 생성 및 체크아웃:
  ```bash
  git checkout -b feature/{이슈번호}
  ```

### 5단계: Task 구성
- TaskCreate로 구현 작업 세분화
- 의존성 관계 설정 (blocks, blockedBy)
- 각 Task에 명확한 목표 및 검증 기준 설정

### 6단계: Task 구현 루프
각 Task마다:

1. **TaskUpdate(status: in_progress)**
2. **파일 수정** (Hook이 자동으로 Google Chat 알림)
3. **Commit Message 생성**:
   ```bash
   /generate-commit-messages
   ```
4. **사용자 선택**: AskUserQuestion으로 commit message 선택
5. **Git Commit**:
   ```bash
   git commit -m "selected message"
   ```
6. **CLAUDE.md 업데이트**: 변경사항 문서화
7. **TaskUpdate(status: completed)** (Hook이 검증 후 Google Chat 알림)

### 7단계: 코드 리뷰
```bash
/code-review
```
- code-reviewer agent와 ultrathink 모드로 심층 리뷰
- 프로젝트 규칙, 로직, 보안, 의존성 검토
- 피드백을 레벨별로 분류 (CRITICAL/HIGH/MEDIUM/LOW)

### 8단계: 피드백 처리
- **CRITICAL/HIGH/MEDIUM**: 자동으로 TaskCreate 후 6단계로 이동
- **LOW**: AskUserQuestion으로 사용자 선택 후 6단계로 이동

### 9단계: 테스트 실행
프로젝트 타입에 따라:
```bash
# Gradle 프로젝트
gradle clean test

# Maven 프로젝트
mvn clean install
```

### 10단계: 테스트 결과 처리
- **실패**: 원인 분석 → 픽스 설계 → TaskCreate → 6단계로 이동
- **성공**: 11단계로 이동

### 11단계: CLAUDE.md 최종 업데이트
테스트 성공 시:
```bash
/finalize-documentation
```
- Task(documentation-finalizer) 에이전트 실행
- 전체 워크플로우 실행 내역 분석 (git log, git diff)
- 구현된 기능 및 변경사항 요약
- CLAUDE.md 파일에 최종 업데이트 반영

### 12단계: 완료
- Stop Hook이 Google Chat 완료 알림 발송

## 주의사항

1. 모든 단계에서 Google Chat으로 알림이 발송됩니다
2. 사용자 확인이 필요한 시점에는 AskUserQuestion을 사용합니다
3. Task 완료 시 반드시 커밋된 상태여야 합니다 (Hook이 자동 검증)
4. 프로젝트 컨벤션 파일들이 올바르게 설정되어 있어야 합니다

## 참조 파일

- Commit message 규칙: `$COMMIT_MESSAGE_CONVENTIONS_PATH`
- 프로젝트 포맷: `$PROJECT_FORMAT_PATH`
- Checkstyle 규칙: `$CHECKSTYLE_RULES_PATH`
- Formatter 규칙: `$FORMATTER_PATH`