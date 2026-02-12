# Agent Skills

Agent Skills는 Claude의 기능을 확장하는 모듈식 기능이다. 각 Skill은 Claude가 관련 상황에서 자동으로 사용하는 지침, 메타데이터, 선택적 리소스(스크립트, 템플릿)를 패키징한다.

---

## Skills를 사용하는 이유

Skills는 Claude에게 도메인별 전문 지식(워크플로우, 컨텍스트, 베스트 프랙티스)을 제공하여 범용 에이전트를 전문가로 변환하는 재사용 가능한 파일시스템 기반 리소스이다. 일회성 작업을 위한 대화 수준의 지침인 프롬프트와 달리, Skills는 필요에 따라 로드되며 여러 대화에서 동일한 가이드를 반복적으로 제공할 필요를 없앤다.

**주요 이점**:
- **Claude 전문화**: 도메인별 작업에 맞게 기능 조정
- **반복 감소**: 한 번 생성하면 자동으로 사용
- **기능 조합**: Skills를 결합하여 복잡한 워크플로우 구축

## Skills 사용하기

Anthropic은 일반적인 문서 작업(PowerPoint, Excel, Word, PDF)을 위한 사전 구축된 Agent Skills를 제공하며, 자체 커스텀 Skills를 생성할 수도 있다. 두 가지 모두 동일한 방식으로 작동한다. Claude는 요청과 관련이 있을 때 자동으로 사용한다.

**사전 구축된 Agent Skills**는 https://claude.ai 및 Claude API를 통해 모든 사용자에게 제공된다.

**커스텀 Skills**를 사용하면 도메인 전문 지식과 조직 지식을 패키징할 수 있다. Claude의 모든 제품에서 사용할 수 있다. Claude Code에서 생성하거나, API를 통해 업로드하거나, https://claude.ai 설정에서 추가할 수 있다.

> **참고**
> **시작하기:**
> - 사전 구축된 Agent Skills의 경우: [빠른 시작 튜토리얼](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/quickstart)을 참고하여 API에서 PowerPoint, Excel, Word, PDF skills 사용 시작
> - 커스텀 Skills의 경우: [Agent Skills Cookbook](https://platform.claude.com/cookbook/skills-notebooks-01-skills-introduction)을 참고하여 자체 Skills 생성 방법 학습

## Skills 작동 방식

Skills는 Claude의 VM 환경을 활용하여 프롬프트만으로는 불가능한 기능을 제공한다. Claude는 파일시스템 액세스가 있는 가상 머신에서 작동하므로 Skills는 지침, 실행 가능 코드, 참고 자료가 포함된 디렉토리로 존재할 수 있으며, 새 팀원을 위해 생성하는 온보딩 가이드처럼 구성된다.

이 파일시스템 기반 아키텍처는 **점진적 공개**를 가능하게 한다. Claude는 미리 컨텍스트를 소비하는 것이 아니라 필요에 따라 정보를 단계적으로 로드한다.

### 세 가지 유형의 Skill 콘텐츠, 세 가지 로딩 레벨

Skills는 세 가지 유형의 콘텐츠를 포함할 수 있으며, 각각 다른 시점에 로드된다.

### 레벨 1: 메타데이터 (항상 로드됨)

**콘텐츠 유형: 지침**. Skill의 YAML frontmatter는 발견 정보를 제공한다.

```yaml
---
name: pdf-processing
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---
```

Claude는 시작 시 이 메타데이터를 로드하고 시스템 프롬프트에 포함한다. 이 경량 접근 방식은 컨텍스트 패널티 없이 많은 Skills를 설치할 수 있음을 의미한다. Claude는 각 Skill이 존재한다는 것과 언제 사용할지만 알고 있다.

### 레벨 2: 지침 (트리거될 때 로드됨)

**콘텐츠 유형: 지침**. SKILL.md의 본문에는 절차적 지식(워크플로우, 베스트 프랙티스, 가이드)이 포함된다.

````markdown
# PDF Processing

## Quick start

Use pdfplumber to extract text from PDFs:

```python
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

For advanced form filling, see [FORMS.md](FORMS.md).
````

Skill의 설명과 일치하는 요청을 하면 Claude는 bash를 통해 파일시스템에서 SKILL.md를 읽는다. 그때서야 이 콘텐츠가 컨텍스트 윈도우에 들어간다.

### 레벨 3: 리소스 및 코드 (필요에 따라 로드됨)

**콘텐츠 유형: 지침, 코드, 리소스**. Skills는 추가 자료를 번들로 제공할 수 있다.

```
pdf-skill/
├── SKILL.md (주요 지침)
├── FORMS.md (양식 작성 가이드)
├── REFERENCE.md (상세 API 참조)
└── scripts/
    └── fill_form.py (유틸리티 스크립트)
```

**지침**: 전문화된 가이드와 워크플로우가 포함된 추가 마크다운 파일(FORMS.md, REFERENCE.md)

**코드**: Claude가 bash를 통해 실행하는 실행 가능 스크립트(fill_form.py, validate.py). 스크립트는 컨텍스트를 소비하지 않고 결정적 작업을 제공한다

**리소스**: 데이터베이스 스키마, API 문서, 템플릿, 예제와 같은 참고 자료

Claude는 참조될 때만 이러한 파일에 액세스한다. 파일시스템 모델은 각 콘텐츠 유형이 서로 다른 장점을 갖는다는 것을 의미한다. 지침은 유연한 가이드용, 코드는 신뢰성용, 리소스는 사실 조회용이다.

| 레벨 | 로드 시점 | 토큰 비용 | 콘텐츠 |
|-------|------------|------------|---------|
| **레벨 1: 메타데이터** | 항상 (시작 시) | Skill당 ~100 토큰 | YAML frontmatter의 `name`과 `description` |
| **레벨 2: 지침** | Skill이 트리거될 때 | 5k 토큰 미만 | 지침과 가이드가 포함된 SKILL.md 본문 |
| **레벨 3+: 리소스** | 필요에 따라 | 사실상 무제한 | 콘텐츠를 컨텍스트에 로드하지 않고 bash를 통해 실행되는 번들 파일 |

점진적 공개는 주어진 시점에 관련 콘텐츠만 컨텍스트 윈도우를 차지하도록 보장한다.

### Skills 아키텍처

Skills는 Claude가 파일시스템 액세스, bash 명령, 코드 실행 기능을 갖춘 코드 실행 환경에서 실행된다. 다음과 같이 생각할 수 있다. Skills는 가상 머신의 디렉토리로 존재하며, Claude는 컴퓨터에서 파일을 탐색하는 데 사용하는 것과 동일한 bash 명령을 사용하여 상호 작용한다.

![Agent Skills Architecture - Skills가 에이전트의 구성 및 가상 머신과 통합되는 방식을 보여줌](https://platform.claude.com/docs/images/agent-skills-architecture.png)

**Claude가 Skill 콘텐츠에 액세스하는 방법:**

Skill이 트리거되면 Claude는 bash를 사용하여 파일시스템에서 SKILL.md를 읽어 지침을 컨텍스트 윈도우로 가져온다. 해당 지침이 다른 파일(FORMS.md 또는 데이터베이스 스키마 등)을 참조하는 경우 Claude는 추가 bash 명령을 사용하여 해당 파일도 읽는다. 지침이 실행 가능 스크립트를 언급하면 Claude는 bash를 통해 실행하고 출력만 받는다(스크립트 코드 자체는 컨텍스트에 들어가지 않음).

**이 아키텍처가 가능하게 하는 것:**

**주문형 파일 액세스**: Claude는 각 특정 작업에 필요한 파일만 읽는다. Skill에 수십 개의 참조 파일이 포함될 수 있지만 작업에 영업 스키마만 필요한 경우 Claude는 해당 파일 하나만 로드한다. 나머지는 파일시스템에 남아 토큰을 소비하지 않는다.

**효율적인 스크립트 실행**: Claude가 `validate_form.py`를 실행할 때 스크립트 코드는 컨텍스트 윈도우에 로드되지 않는다. 스크립트의 출력("검증 통과" 또는 특정 오류 메시지 등)만 토큰을 소비한다. 이는 Claude가 즉석에서 동등한 코드를 생성하는 것보다 훨씬 효율적이다.

**번들 콘텐츠에 사실상 제한 없음**: 파일이 액세스될 때까지 컨텍스트를 소비하지 않기 때문에 Skills는 포괄적인 API 문서, 대용량 데이터세트, 광범위한 예제 또는 필요한 모든 참고 자료를 포함할 수 있다. 사용되지 않는 번들 콘텐츠에 대한 컨텍스트 패널티가 없다.

이 파일시스템 기반 모델은 점진적 공개를 작동하게 만든다. Claude는 온보딩 가이드의 특정 섹션을 참조하는 것처럼 Skill을 탐색하여 각 작업에 필요한 것만 정확히 액세스한다.

### 예시: PDF 처리 skill 로딩

Claude가 PDF 처리 skill을 로드하고 사용하는 방법은 다음과 같다.

1. **시작**: 시스템 프롬프트에 포함: `PDF Processing - Extract text and tables from PDF files, fill forms, merge documents`
2. **사용자 요청**: "이 PDF에서 텍스트를 추출하고 요약해줘"
3. **Claude 호출**: `bash: read pdf-skill/SKILL.md` → 지침이 컨텍스트에 로드됨
4. **Claude 판단**: 양식 작성이 필요하지 않으므로 FORMS.md는 읽지 않음
5. **Claude 실행**: SKILL.md의 지침을 사용하여 작업 완료

![Skills loading into context window - skill 메타데이터와 콘텐츠의 점진적 로딩을 보여줌](https://platform.claude.com/docs/images/agent-skills-context-window.png)

다이어그램은 다음을 보여준다.
1. 시스템 프롬프트와 skill 메타데이터가 미리 로드된 기본 상태
2. Claude가 bash를 통해 SKILL.md를 읽어 skill을 트리거함
3. Claude가 필요에 따라 FORMS.md와 같은 추가 번들 파일을 선택적으로 읽음
4. Claude가 작업을 진행함

이 동적 로딩은 관련 skill 콘텐츠만 컨텍스트 윈도우를 차지하도록 보장한다.

## Skills가 작동하는 곳

Skills는 Claude의 에이전트 제품 전반에서 사용할 수 있다.

### Claude API

Claude API는 사전 구축된 Agent Skills와 커스텀 Skills를 모두 지원한다. 두 가지 모두 동일하게 작동한다. 코드 실행 도구와 함께 `container` 매개변수에서 관련 `skill_id`를 지정한다.

**전제 조건**: API를 통해 Skills를 사용하려면 세 가지 베타 헤더가 필요하다.
- `code-execution-2025-08-25` - Skills가 코드 실행 컨테이너에서 실행됨
- `skills-2025-10-02` - Skills 기능을 활성화함
- `files-api-2025-04-14` - 컨테이너로/에서 파일을 업로드/다운로드하는 데 필요함

`skill_id`(예: `pptx`, `xlsx`)를 참조하여 사전 구축된 Agent Skills를 사용하거나, Skills API(`/v1/skills` 엔드포인트)를 통해 자체 Skills를 생성 및 업로드한다. 커스텀 Skills는 조직 전체에서 공유된다.

자세한 내용은 [Claude API로 Skills 사용](https://platform.claude.com/docs/en/build-with-claude/skills-guide)을 참고하자.

### Claude Code

[Claude Code](https://code.claude.com/docs/en/overview)는 커스텀 Skills만 지원한다.

**커스텀 Skills**: SKILL.md 파일이 포함된 디렉토리로 Skills를 생성한다. Claude가 자동으로 발견하고 사용한다.

Claude Code의 커스텀 Skills는 파일시스템 기반이며 API 업로드가 필요하지 않다.

자세한 내용은 [Claude Code에서 Skills 사용](https://code.claude.com/docs/en/skills)을 참고하자.

### Claude Agent SDK

[Claude Agent SDK](https://platform.claude.com/docs/en/agent-sdk/overview)는 파일시스템 기반 구성을 통해 커스텀 Skills를 지원한다.

**커스텀 Skills**: `.claude/skills/`에 SKILL.md 파일이 포함된 디렉토리로 Skills를 생성한다. `allowed_tools` 구성에 `"Skill"`을 포함하여 Skills를 활성화한다.

그러면 SDK가 실행될 때 Agent SDK의 Skills가 자동으로 발견된다.

자세한 내용은 [SDK의 Agent Skills](https://platform.claude.com/docs/en/agent-sdk/skills)를 참고하자.

### Claude.ai

[Claude.ai](https://claude.ai)는 사전 구축된 Agent Skills와 커스텀 Skills를 모두 지원한다.

**사전 구축된 Agent Skills**: 이러한 Skills는 문서를 생성할 때 이미 백그라운드에서 작동하고 있다. Claude는 설정 없이 사용한다.

**커스텀 Skills**: Settings > Features를 통해 zip 파일로 자체 Skills를 업로드한다. 코드 실행이 활성화된 Pro, Max, Team, Enterprise 플랜에서 사용할 수 있다. 커스텀 Skills는 각 사용자에게 개별적이다. 조직 전체에서 공유되지 않으며 관리자가 중앙에서 관리할 수 없다.

https://claude.ai에서 Skills 사용에 대한 자세한 내용은 Claude Help Center의 다음 리소스를 참고하자.
- [What are Skills?](https://support.claude.com/en/articles/12512176-what-are-skills)
- [Using Skills in Claude](https://support.claude.com/en/articles/12512180-using-skills-in-claude)
- [How to create custom Skills](https://support.claude.com/en/articles/12512198-creating-custom-skills)
- [Teach Claude your way of working using Skills](https://support.claude.com/en/articles/12580051-teach-claude-your-way-of-working-using-skills)

## Skill 구조

모든 Skill은 YAML frontmatter가 포함된 `SKILL.md` 파일이 필요하다.

```yaml
---
name: your-skill-name
description: Brief description of what this Skill does and when to use it
---

# Your Skill Name

## Instructions
[Clear, step-by-step guidance for Claude to follow]

## Examples
[Concrete examples of using this Skill]
```

**필수 필드**: `name`과 `description`

**필드 요구사항**:

`name`:
- 최대 64자
- 소문자, 숫자, 하이픈만 포함해야 함
- XML 태그를 포함할 수 없음
- 예약어를 포함할 수 없음: "anthropic", "claude"

`description`:
- 비어 있지 않아야 함
- 최대 1024자
- XML 태그를 포함할 수 없음

`description`에는 Skill이 무엇을 하는지와 Claude가 언제 사용해야 하는지를 모두 포함해야 한다. 완전한 작성 가이드는 [베스트 프랙티스 가이드](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)를 참고하자.

## 보안 고려사항

신뢰할 수 있는 출처(직접 생성했거나 Anthropic에서 얻은 것)의 Skills만 사용할 것을 강력히 권장한다. Skills는 지침과 코드를 통해 Claude에게 새로운 기능을 제공하며, 이것이 강력하게 만들지만 악의적인 Skill이 Skill의 명시된 목적과 일치하지 않는 방식으로 도구를 호출하거나 코드를 실행하도록 Claude를 유도할 수 있음을 의미한다.

> **경고**
> 신뢰할 수 없거나 알 수 없는 출처의 Skill을 사용해야 하는 경우 극도로 주의하고 사용하기 전에 철저히 감사한다. Claude가 Skill을 실행할 때 어떤 액세스 권한을 갖는지에 따라 악의적인 Skills는 데이터 유출, 무단 시스템 액세스 또는 기타 보안 위험을 초래할 수 있다.

**주요 보안 고려사항**:
- **철저한 감사**: Skill에 번들로 제공되는 모든 파일(SKILL.md, 스크립트, 이미지, 기타 리소스)을 검토한다. 예상치 못한 네트워크 호출, 파일 액세스 패턴 또는 Skill의 명시된 목적과 일치하지 않는 작업과 같은 비정상적인 패턴을 찾는다
- **외부 소스는 위험함**: 외부 URL에서 데이터를 가져오는 Skills는 특히 위험하다. 가져온 콘텐츠에 악의적인 지침이 포함될 수 있기 때문이다. 신뢰할 수 있는 Skills도 시간이 지남에 따라 외부 종속성이 변경되면 손상될 수 있다
- **도구 오용**: 악의적인 Skills는 도구(파일 작업, bash 명령, 코드 실행)를 해로운 방식으로 호출할 수 있다
- **데이터 노출**: 민감한 데이터에 액세스할 수 있는 Skills는 정보를 외부 시스템으로 유출하도록 설계될 수 있다
- **소프트웨어 설치처럼 취급**: 신뢰할 수 있는 출처의 Skills만 사용한다. 민감한 데이터 또는 중요한 작업에 액세스할 수 있는 프로덕션 시스템에 Skills를 통합할 때는 특히 주의한다

## 사용 가능한 Skills

### 사전 구축된 Agent Skills

다음 사전 구축된 Agent Skills를 즉시 사용할 수 있다.

- **PowerPoint (pptx)**: 프레젠테이션 생성, 슬라이드 편집, 프레젠테이션 콘텐츠 분석
- **Excel (xlsx)**: 스프레드시트 생성, 데이터 분석, 차트가 포함된 보고서 생성
- **Word (docx)**: 문서 생성, 콘텐츠 편집, 텍스트 서식 지정
- **PDF (pdf)**: 서식이 지정된 PDF 문서 및 보고서 생성

이러한 Skills는 Claude API와 https://claude.ai에서 사용할 수 있다. API에서 사용을 시작하려면 [빠른 시작 튜토리얼](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/quickstart)을 참고하자.

### 커스텀 Skills 예제

커스텀 Skills의 완전한 예제는 [Skills cookbook](https://platform.claude.com/cookbook/skills-notebooks-01-skills-introduction)을 참고하자.

## 제한사항 및 제약

이러한 제한사항을 이해하면 Skills 배포를 효과적으로 계획하는 데 도움이 된다.

### 교차 표면 가용성

**커스텀 Skills는 표면 간에 동기화되지 않는다**. 한 표면에 업로드된 Skills는 다른 표면에서 자동으로 사용할 수 없다.

- https://claude.ai에 업로드된 Skills는 API에 별도로 업로드해야 함
- API를 통해 업로드된 Skills는 https://claude.ai에서 사용할 수 없음
- Claude Code Skills는 파일시스템 기반이며 https://claude.ai와 API 모두와 별개임

사용하려는 각 표면에 대해 Skills를 별도로 관리하고 업로드해야 한다.

### 공유 범위

Skills는 사용하는 위치에 따라 다른 공유 모델을 갖는다.
- **Claude.ai**: 개별 사용자만. 각 팀원이 별도로 업로드해야 함
- **Claude API**: 워크스페이스 전체. 모든 워크스페이스 구성원이 업로드된 Skills에 액세스할 수 있음
- **Claude Code**: 개인용(`~/.claude/skills/`) 또는 프로젝트 기반(`.claude/skills/`). Claude Code 플러그인을 통해 공유할 수도 있음

https://claude.ai는 현재 중앙 집중식 관리자 관리 또는 조직 전체 커스텀 Skills 배포를 지원하지 않는다.

### 런타임 환경 제약

skill에서 사용할 수 있는 정확한 런타임 환경은 사용하는 제품 표면에 따라 다르다.

- **Claude.ai**:
   - **다양한 네트워크 액세스**: 사용자/관리자 설정에 따라 Skills는 전체, 부분 또는 네트워크 액세스가 없을 수 있다. 자세한 내용은 [Create and Edit Files](https://support.claude.com/en/articles/12111783-create-and-edit-files-with-claude#h_6b7e833898) 지원 문서를 참고하자.
- **Claude API**:
   - **네트워크 액세스 없음**: Skills는 외부 API 호출을 하거나 인터넷에 액세스할 수 없음
   - **런타임 패키지 설치 없음**: 사전 설치된 패키지만 사용할 수 있음. 실행 중에 새 패키지를 설치할 수 없음
   - **사전 구성된 종속성만**: 사용 가능한 패키지 목록은 [코드 실행 도구 문서](https://platform.claude.com/docs/en/agents-and-tools/tool-use/code-execution-tool)를 확인한다
- **Claude Code**:
   - **전체 네트워크 액세스**: Skills는 사용자 컴퓨터의 다른 프로그램과 동일한 네트워크 액세스 권한을 가짐
   - **전역 패키지 설치 권장하지 않음**: Skills는 사용자 컴퓨터를 방해하지 않도록 로컬에서만 패키지를 설치해야 함

이러한 제약 내에서 작동하도록 Skills를 계획한다.