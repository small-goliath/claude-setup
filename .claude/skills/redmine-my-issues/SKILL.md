---
name: redmine-my-issues
description: Redmine에서 나에게 할당된 이슈를 확인하고 필터링합니다. 사용자가 할당된 이슈를 확인하거나, 작업해야 할 태스크를 보거나, 이슈 우선순위를 확인하거나, 작업량을 검토하려 할 때 사용합니다. "내 Redmine 이슈 보여줘", "내가 작업 중인 이슈는?", "내 태스크 확인", "할당된 이슈 목록" 등의 표현에 반응합니다.![alt text](image.png)
---

# Redmine 내 이슈

## 목차

- [Redmine 내 이슈](#redmine-내-이슈)
  - [개요](#개요)
  - [사전 요구사항](#사전-요구사항)
  - [빠른 사용법](#빠른-사용법)
    - [내 이슈 전체 목록](#내-이슈-전체-목록)
    - [진행 중인 이슈만 목록 조회](#진행-중인-이슈만-목록-조회)
    - [우선순위별 목록 조회](#우선순위별-목록-조회)
    - [프로젝트별로 그룹화](#프로젝트별로-그룹화)
  - [워크플로우](#워크플로우)
  - [일반적인 필터](#일반적인-필터)
    - [사용 가능한 상태 조회](#사용-가능한-상태-조회)
    - [사용 가능한 우선순위 조회](#사용-가능한-우선순위-조회)
    - [상태별 필터 (예시)](#상태별-필터-예시)
    - [우선순위별 필터 (예시)](#우선순위별-필터-예시)
    - [마감일별 필터](#마감일별-필터)
  - [출력 형식](#출력-형식)
  - [고급 기능](#고급-기능)
    - [관련 데이터 포함](#관련-데이터-포함)
    - [프로젝트별 필터링](#프로젝트별-필터링)
    - [결과 정렬](#결과-정렬)
  - [사용 가능한 스크립트](#사용-가능한-스크립트)
  - [팁](#팁)

Redmine에서 나에게 할당된 이슈를 확인하고 관리합니다.

## 개요

이 스킬은 개발 환경에서 직접 나에게 할당된 Redmine 이슈를 조회할 수 있게 합니다. 내가 처리해야 할 작업을 빠르게 확인하고, 우선순위를 체크하며, 상태별로 필터링할 수 있습니다.

## 사전 요구사항

다음 환경 변수를 설정하세요:

- `REDMINE_URL` - Redmine 서버 URL (예: `https://redmine.example.com`)
- `REDMINE_API_KEY` - API 키 (로그인 후 `/my/account`에서 확인 가능)

## 빠른 사용법

### 내 이슈 전체 목록

**스크립트**: @scripts/list-all-issues.sh

```bash
./scripts/list-all-issues.sh
```

### 진행 중인 이슈만 목록 조회

**스크립트**: @scripts/list-open-issues.sh

```bash
./scripts/list-open-issues.sh
```

### 우선순위별 목록 조회

**스크립트**: @scripts/list-high-priority.sh

높은 우선순위 이슈:
```bash
./scripts/list-high-priority.sh
```

### 프로젝트별로 그룹화

**스크립트**: @scripts/group-by-project.sh

```bash
./scripts/group-by-project.sh
```

## 워크플로우

1. **이슈 조회**: `assigned_to_id=me` 필터로 API 쿼리 실행
2. **응답 파싱**: 관련 필드 추출 (id, subject, status, priority, due_date)
3. **출력 포맷팅**: 주요 정보를 읽기 쉬운 형식으로 표시
4. **링크 제공**: 이슈로 이동하는 클릭 가능한 URL 포함: `${REDMINE_URL}/issues/{id}`

## 일반적인 필터

> ⚠️ **주의**: 상태 ID와 우선순위 ID는 Redmine 인스턴스마다 다를 수 있습니다. 아래 값들은 예시이며, 실제 값은 제공된 스크립트로 확인하세요.

### 사용 가능한 상태 조회

**스크립트**: @scripts/get-issue-statuses.sh

```bash
./scripts/get-issue-statuses.sh
```

### 사용 가능한 우선순위 조회

**스크립트**: @scripts/get-issue-priorities.sh

```bash
./scripts/get-issue-priorities.sh
```

### 상태별 필터 (예시)

- `status_id=open` - 모든 진행 중 이슈 (권장)
- `status_id=*` - 종료되지 않은 이슈 (`*`는 와일드카드, 실제 ID로 대체)

### 우선순위별 필터 (예시)

- `priority_id=3|4|5` - 높음/긴급/즉시 (OR 조건)
- `priority_id=*` - 특정 우선순위 (`*`는 실제 ID로 대체)

### 마감일별 필터

**스크립트**: @scripts/list-due-soon.sh

곧 마감 예정인 이슈:
```bash
./scripts/list-due-soon.sh
```

## 출력 형식

명확하고 실행 가능한 형식으로 이슈를 표시합니다:

```
내 Redmine 이슈 (진행 중 5개)

높은 우선순위:
#123 - 로그인 버그 수정 [높음] - 마감: 2026-02-01
  프로젝트: Website
  https://redmine.example.com/issues/123

#124 - 보안 패치 [긴급] - 마감: 2026-01-29
  프로젝트: API
  https://redmine.example.com/issues/124

보통 우선순위:
#125 - 문서 업데이트 [보통]
  프로젝트: Website
  https://redmine.example.com/issues/125
```

## 고급 기능

### 관련 데이터 포함

**스크립트**: @scripts/list-with-details.sh

상세 정보 조회:
```bash
./scripts/list-with-details.sh
```

### 프로젝트별 필터링

**스크립트**: @scripts/list-by-project.sh

```bash
./scripts/list-by-project.sh <project_id>
```

### 결과 정렬

**스크립트**: @scripts/list-sorted-priority.sh

우선순위별 정렬 (내림차순):
```bash
./scripts/list-sorted-priority.sh
```

## 사용 가능한 스크립트

모든 스크립트는 `scripts/` 디렉토리에 있습니다:

| 스크립트 | 설명 |
|---------|------|
| @scripts/get-issue-statuses.sh | 사용 가능한 이슈 상태 조회 |
| @scripts/get-issue-priorities.sh | 사용 가능한 이슈 우선순위 조회 |
| @scripts/list-all-issues.sh | 내 이슈 전체 목록 조회 |
| @scripts/list-open-issues.sh | 진행 중인 이슈만 조회 |
| @scripts/list-high-priority.sh | 높은 우선순위 이슈 조회 |
| @scripts/group-by-project.sh | 프로젝트별로 그룹화 |
| @scripts/list-due-soon.sh | 마감일 기준 정렬 |
| @scripts/list-with-details.sh | 첨부파일 및 히스토리 포함 |
| @scripts/list-by-project.sh | 특정 프로젝트 필터링 |
| @scripts/list-sorted-priority.sh | 우선순위별 정렬 |

## 팁

- 기본 제한은 25개이며, 더 많은 이슈를 보려면 `&limit=100` 사용
- 페이지네이션을 위해 `&offset=N` 사용
- AND 논리를 위해 필터를 `&`로 결합
- OR 논리를 위해 값에 `|` 사용 (예: `priority_id=3|4|5`)
- 종료된 이슈를 제외하려면 항상 `status_id=open`으로 필터링
- 긴급 작업을 우선순위화하려면 `due_date` 필드 확인
