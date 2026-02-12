---
name: generate-commit-messages
description: Git commit message를 규칙에 맞게 3가지 생성합니다
context: fork
agent: commit-message-generator
disable-model-invocation: true
allowed-tools: Read, Bash(git *), AskUserQuestion
---

# Git Commit Message 생성

## 목차

- [Git Commit Message 생성](#git-commit-message-생성)
  - [Commit Message 규칙](#commit-message-규칙)
  - [생성 단계](#생성-단계)
    - [1. 변경사항 확인](#1-변경사항-확인)
    - [2. 변경 분석](#2-변경-분석)
    - [3. 메시지 생성](#3-메시지-생성)
  - [출력 형식](#출력-형식)

프로젝트 커밋 메시지 규칙에 맞는 메시지 2가지를 생성합니다.

## Commit Message 규칙

```
!`cat $COMMIT_MESSAGE_CONVENTIONS_PATH`
```

## 생성 단계

### 1. 변경사항 확인
```bash
git diff --cached
git status
```

### 2. 변경 분석
- 변경된 파일 목록
- 변경 내용 요약
- 변경 목적 파악

### 3. 메시지 생성
규칙에 따라 2가지 스타일로 메시지 생성:
- **간결한 버전**: 핵심만 포함
- **상세한 버전**: 변경 내용 상세 설명

## 출력 형식

```markdown
# Commit Message 후보

## 옵션 1: 간결한 버전
```
[타입](#이슈번호): 간결한 설명
```

## 옵션 2: 상세한 버전
```
[타입](#이슈번호): 제목 (필수사항)

본문 (선택사항)

바닥글 (선택사항)
```

AskUserQuestion을 사용하여 사용자가 커밋메시지를 선택하도록 합니다.