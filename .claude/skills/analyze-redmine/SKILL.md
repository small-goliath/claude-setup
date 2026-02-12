---
name: analyze-redmine
description: Redmine 이슈를 분석하고 요구사항을 추출합니다
context: fork
agent: redmine-analyzer
disable-model-invocation: true
argument-hint: [issue-number]
allowed-tools: Skill(redmine-my-issues), Read, Grep, Glob
---

# Redmine 이슈 분석

## 목차

- [Redmine 이슈 분석](#redmine-이슈-분석)
  - [사용법](#사용법)
  - [분석 단계](#분석-단계)
  - [출력 형식](#출력-형식)

Redmine API를 사용하여 이슈 정보를 조회하고 분석합니다.

## 사용법

```bash
/analyze-redmine [issue-number]
```

## 분석 단계

1. **이슈 조회**:
   - redmine-my-issues 스킬 활용
   - 이슈 번호로 상세 정보 가져오기

2. **내용 분석**:
   - 제목, 설명, 코멘트 분석
   - 첨부파일 확인
   - 관련 이슈 파악

3. **요구사항 추출**:
   - 기능 요구사항
   - 비기능 요구사항
   - 제약사항
   - 우선순위

4. **결과 반환**:
   - 구조화된 요구사항 문서
   - 예상 영향 범위
   - 관련 파일 목록

## 출력 형식

```markdown
# Redmine 이슈 #$ARGUMENTS 분석 결과

## 이슈 정보
- 제목: [이슈 제목]
- 우선순위: [우선순위]
- 담당자: [담당자]
- 상태: [상태]

## 요구사항
### 기능 요구사항
- [요구사항 1]
- [요구사항 2]

### 비기능 요구사항
- [요구사항 1]

### 제약사항
- [제약사항 1]

## 예상 영향 범위
- [파일/모듈 1]
- [파일/모듈 2]

## 관련 이슈
- [이슈 번호] [이슈 제목]
```