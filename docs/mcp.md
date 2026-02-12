# MCP 커넥터

---

Claude의 Model Context Protocol (MCP) 커넥터 기능을 사용하면 별도의 MCP 클라이언트 없이 Messages API에서 직접 원격 MCP 서버에 연결할 수 있다.

<Note>
  **현재 버전**: 이 기능을 사용하려면 베타 헤더가 필요하다: `"anthropic-beta": "mcp-client-2025-11-20"`

  이전 버전(`mcp-client-2025-04-04`)은 더 이상 사용되지 않는다. 아래의 [더 이상 사용되지 않는 버전 문서](#deprecated-version-mcp-client-2025-04-04)를 참조하자.
</Note>

## 주요 기능

- **직접 API 통합**: MCP 클라이언트 구현 없이 MCP 서버에 연결한다
- **도구 호출 지원**: Messages API를 통해 MCP 도구에 액세스한다
- **유연한 도구 구성**: 모든 도구를 활성화하거나, 특정 도구를 허용 목록에 추가하거나, 원하지 않는 도구를 거부 목록에 추가할 수 있다
- **도구별 구성**: 개별 도구를 사용자 정의 설정으로 구성할 수 있다
- **OAuth 인증**: 인증된 서버에 대한 OAuth Bearer 토큰을 지원한다
- **다중 서버**: 단일 요청에서 여러 MCP 서버에 연결할 수 있다

## 제한 사항

- [MCP 사양](https://modelcontextprotocol.io/introduction#explore-mcp)의 기능 세트 중 현재는 [도구 호출](https://modelcontextprotocol.io/docs/concepts/tools)만 지원된다.
- 서버는 HTTP를 통해 공개적으로 노출되어야 한다(Streamable HTTP 및 SSE 전송 모두 지원). 로컬 STDIO 서버는 직접 연결할 수 없다.
- MCP 커넥터는 현재 Amazon Bedrock 및 Google Vertex에서 지원되지 않는다.

## Messages API에서 MCP 커넥터 사용하기

MCP 커넥터는 두 가지 구성 요소를 사용한다:

1. **MCP 서버 정의** (`mcp_servers` 배열): 서버 연결 세부 정보(URL, 인증)를 정의한다
2. **MCP 도구 세트** (`tools` 배열): 활성화할 도구와 구성 방법을 설정한다

### 기본 예제

이 예제는 기본 구성으로 MCP 서버의 모든 도구를 활성화한다:

<CodeGroup>
```bash Shell
curl https://api.anthropic.com/v1/messages \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "anthropic-beta: mcp-client-2025-11-20" \
  -d '{
    "model": "claude-opus-4-6",
    "max_tokens": 1000,
    "messages": [{"role": "user", "content": "What tools do you have available?"}],
    "mcp_servers": [
      {
        "type": "url",
        "url": "https://example-server.modelcontextprotocol.io/sse",
        "name": "example-mcp",
        "authorization_token": "YOUR_TOKEN"
      }
    ],
    "tools": [
      {
        "type": "mcp_toolset",
        "mcp_server_name": "example-mcp"
      }
    ]
  }'
```

```typescript TypeScript
import { Anthropic } from '@anthropic-ai/sdk';

const anthropic = new Anthropic();

const response = await anthropic.beta.messages.create({
  model: "claude-opus-4-6",
  max_tokens: 1000,
  messages: [
    {
      role: "user",
      content: "What tools do you have available?",
    },
  ],
  mcp_servers: [
    {
      type: "url",
      url: "https://example-server.modelcontextprotocol.io/sse",
      name: "example-mcp",
      authorization_token: "YOUR_TOKEN",
    },
  ],
  tools: [
    {
      type: "mcp_toolset",
      mcp_server_name: "example-mcp",
    },
  ],
  betas: ["mcp-client-2025-11-20"],
});
```

```python Python
import anthropic

client = anthropic.Anthropic()

response = client.beta.messages.create(
    model="claude-opus-4-6",
    max_tokens=1000,
    messages=[{
        "role": "user",
        "content": "What tools do you have available?"
    }],
    mcp_servers=[{
        "type": "url",
        "url": "https://mcp.example.com/sse",
        "name": "example-mcp",
        "authorization_token": "YOUR_TOKEN"
    }],
    tools=[{
        "type": "mcp_toolset",
        "mcp_server_name": "example-mcp"
    }],
    betas=["mcp-client-2025-11-20"]
)
```
</CodeGroup>

## MCP 서버 구성

`mcp_servers` 배열의 각 MCP 서버는 연결 세부 정보를 정의한다:

```json
{
  "type": "url",
  "url": "https://example-server.modelcontextprotocol.io/sse",
  "name": "example-mcp",
  "authorization_token": "YOUR_TOKEN"
}
```

### 필드 설명

| 속성 | 타입 | 필수 | 설명 |
|----------|------|----------|-------------|
| `type` | string | 예 | 현재는 "url"만 지원된다 |
| `url` | string | 예 | MCP 서버의 URL. https://로 시작해야 한다 |
| `name` | string | 예 | 이 MCP 서버의 고유 식별자. `tools` 배열의 정확히 하나의 MCPToolset에서 참조되어야 한다. |
| `authorization_token` | string | 아니오 | MCP 서버에서 요구하는 경우 OAuth 인증 토큰. [MCP 사양](https://modelcontextprotocol.io/specification/2025-11-25/basic/authorization)을 참조하자. |

## MCP 도구 세트 구성

MCPToolset은 `tools` 배열에 위치하며 MCP 서버의 어떤 도구가 활성화되고 어떻게 구성되어야 하는지 설정한다.

### 기본 구조

```json
{
  "type": "mcp_toolset",
  "mcp_server_name": "example-mcp",
  "default_config": {
    "enabled": true,
    "defer_loading": false
  },
  "configs": {
    "specific_tool_name": {
      "enabled": true,
      "defer_loading": true
    }
  }
}
```

### 필드 설명

| 속성 | 타입 | 필수 | 설명 |
|----------|------|----------|-------------|
| `type` | string | 예 | "mcp_toolset"이어야 한다 |
| `mcp_server_name` | string | 예 | `mcp_servers` 배열에 정의된 서버 이름과 일치해야 한다 |
| `default_config` | object | 아니오 | 이 세트의 모든 도구에 적용되는 기본 구성. `configs`의 개별 도구 구성이 이러한 기본값을 재정의한다. |
| `configs` | object | 아니오 | 도구별 구성 재정의. 키는 도구 이름이고 값은 구성 객체이다. |
| `cache_control` | object | 아니오 | 이 도구 세트에 대한 캐시 중단점 구성 |

### 도구 구성 옵션

각 도구(`default_config` 또는 `configs`에서 구성)는 다음 필드를 지원한다:

| 속성 | 타입 | 기본값 | 설명 |
|----------|------|---------|-------------|
| `enabled` | boolean | `true` | 이 도구가 활성화되었는지 여부 |
| `defer_loading` | boolean | `false` | true인 경우 도구 설명이 처음에는 모델로 전송되지 않는다. [도구 검색 도구](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool)와 함께 사용된다. |

### 구성 병합

구성 값은 다음 우선 순위로 병합된다(높음에서 낮음):

1. `configs`의 도구별 설정
2. 세트 수준 `default_config`
3. 시스템 기본값

예제:

```json
{
  "type": "mcp_toolset",
  "mcp_server_name": "google-calendar-mcp",
  "default_config": {
    "defer_loading": true
  },
  "configs": {
    "search_events": {
      "enabled": false
    }
  }
}
```

결과:
- `search_events`: `enabled: false` (configs에서), `defer_loading: true` (default_config에서)
- 다른 모든 도구: `enabled: true` (시스템 기본값), `defer_loading: true` (default_config에서)

## 일반적인 구성 패턴

### 기본 구성으로 모든 도구 활성화

가장 간단한 패턴 - 서버의 모든 도구를 활성화한다:

```json
{
  "type": "mcp_toolset",
  "mcp_server_name": "google-calendar-mcp",
}
```

### 허용 목록 - 특정 도구만 활성화

`enabled: false`를 기본값으로 설정한 다음 특정 도구를 명시적으로 활성화한다:

```json
{
  "type": "mcp_toolset",
  "mcp_server_name": "google-calendar-mcp",
  "default_config": {
    "enabled": false
  },
  "configs": {
    "search_events": {
      "enabled": true
    },
    "create_event": {
      "enabled": true
    }
  }
}
```

### 거부 목록 - 특정 도구 비활성화

기본적으로 모든 도구를 활성화한 다음 원하지 않는 도구를 명시적으로 비활성화한다:

```json
{
  "type": "mcp_toolset",
  "mcp_server_name": "google-calendar-mcp",
  "configs": {
    "delete_all_events": {
      "enabled": false
    },
    "share_calendar_publicly": {
      "enabled": false
    }
  }
}
```

### 혼합 - 도구별 구성이 있는 허용 목록

허용 목록을 각 도구에 대한 사용자 정의 구성과 결합한다:

```json
{
  "type": "mcp_toolset",
  "mcp_server_name": "google-calendar-mcp",
  "default_config": {
    "enabled": false,
    "defer_loading": true
  },
  "configs": {
    "search_events": {
      "enabled": true,
      "defer_loading": false
    },
    "list_events": {
      "enabled": true
    }
  }
}
```

이 예제에서:
- `search_events`는 `defer_loading: false`로 활성화된다
- `list_events`는 `defer_loading: true`로 활성화된다 (default_config에서 상속)
- 다른 모든 도구는 비활성화된다

## 검증 규칙

API는 다음 검증 규칙을 적용한다:

- **서버가 존재해야 함**: MCPToolset의 `mcp_server_name`은 `mcp_servers` 배열에 정의된 서버와 일치해야 한다
- **서버가 사용되어야 함**: `mcp_servers`에 정의된 모든 MCP 서버는 정확히 하나의 MCPToolset에서 참조되어야 한다
- **서버당 고유한 도구 세트**: 각 MCP 서버는 하나의 MCPToolset에서만 참조될 수 있다
- **알 수 없는 도구 이름**: `configs`의 도구 이름이 MCP 서버에 존재하지 않는 경우 백엔드 경고가 기록되지만 오류는 반환되지 않는다 (MCP 서버는 동적 도구 가용성을 가질 수 있음)

## 응답 콘텐츠 타입

Claude가 MCP 도구를 사용하면 응답에 두 가지 새로운 콘텐츠 블록 타입이 포함된다:

### MCP 도구 사용 블록

```json
{
  "type": "mcp_tool_use",
  "id": "mcptoolu_014Q35RayjACSWkSj4X2yov1",
  "name": "echo",
  "server_name": "example-mcp",
  "input": { "param1": "value1", "param2": "value2" }
}
```

### MCP 도구 결과 블록

```json
{
  "type": "mcp_tool_result",
  "tool_use_id": "mcptoolu_014Q35RayjACSWkSj4X2yov1",
  "is_error": false,
  "content": [
    {
      "type": "text",
      "text": "Hello"
    }
  ]
}
```

## 다중 MCP 서버

`mcp_servers`에 여러 서버 정의를 포함하고 `tools` 배열에 각각에 대한 해당 MCPToolset을 포함하여 여러 MCP 서버에 연결할 수 있다:

```json
{
  "model": "claude-opus-4-6",
  "max_tokens": 1000,
  "messages": [
    {
      "role": "user",
      "content": "Use tools from both mcp-server-1 and mcp-server-2 to complete this task"
    }
  ],
  "mcp_servers": [
    {
      "type": "url",
      "url": "https://mcp.example1.com/sse",
      "name": "mcp-server-1",
      "authorization_token": "TOKEN1"
    },
    {
      "type": "url",
      "url": "https://mcp.example2.com/sse",
      "name": "mcp-server-2",
      "authorization_token": "TOKEN2"
    }
  ],
  "tools": [
    {
      "type": "mcp_toolset",
      "mcp_server_name": "mcp-server-1"
    },
    {
      "type": "mcp_toolset",
      "mcp_server_name": "mcp-server-2",
      "default_config": {
        "defer_loading": true
      }
    }
  ]
}
```

## 인증

OAuth 인증이 필요한 MCP 서버의 경우 액세스 토큰을 얻어야 한다. MCP 커넥터 베타는 MCP 서버 정의에서 `authorization_token` 매개변수를 전달하는 것을 지원한다.
API 소비자는 API 호출을 하기 전에 OAuth 플로우를 처리하고 액세스 토큰을 얻고 필요에 따라 토큰을 새로 고쳐야 한다.

### 테스트용 액세스 토큰 얻기

MCP inspector는 테스트 목적으로 액세스 토큰을 얻는 프로세스를 안내할 수 있다.

1. 다음 명령으로 inspector를 실행한다. 머신에 Node.js가 설치되어 있어야 한다.

   ```bash
   npx @modelcontextprotocol/inspector
   ```

2. 왼쪽 사이드바에서 "Transport type"에 대해 "SSE" 또는 "Streamable HTTP"를 선택한다.
3. MCP 서버의 URL을 입력한다.
4. 오른쪽 영역에서 "Need to configure authentication?" 뒤의 "Open Auth Settings" 버튼을 클릭한다.
5. "Quick OAuth Flow"를 클릭하고 OAuth 화면에서 권한을 부여한다.
6. inspector의 "OAuth Flow Progress" 섹션에서 단계를 따르고 "Authentication complete"에 도달할 때까지 "Continue"를 클릭한다.
7. `access_token` 값을 복사한다.
8. MCP 서버 구성의 `authorization_token` 필드에 붙여넣는다.

### 액세스 토큰 사용

위의 OAuth 플로우 중 하나를 사용하여 액세스 토큰을 얻은 후 MCP 서버 구성에서 사용할 수 있다:

```json
{
  "mcp_servers": [
    {
      "type": "url",
      "url": "https://example-server.modelcontextprotocol.io/sse",
      "name": "authenticated-server",
      "authorization_token": "YOUR_ACCESS_TOKEN_HERE"
    }
  ]
}
```

OAuth 플로우에 대한 자세한 설명은 MCP 사양의 [Authorization 섹션](https://modelcontextprotocol.io/specification/2025-11-25/basic/authorization)을 참조하자.

## 클라이언트 측 MCP 헬퍼 (TypeScript)

자체 MCP 클라이언트 연결을 관리하는 경우(예: 로컬 stdio 서버, MCP 프롬프트 또는 MCP 리소스 사용) TypeScript SDK는 MCP 타입과 Claude API 타입 간에 변환하는 헬퍼 함수를 제공한다. 이를 통해 [MCP SDK](https://github.com/modelcontextprotocol/typescript-sdk)를 Anthropic SDK와 함께 사용할 때 수동 변환 코드가 필요 없다.

<Note>
  이러한 헬퍼는 현재 TypeScript SDK에서만 사용할 수 있다.
</Note>
<Note>
  URL을 통해 액세스할 수 있는 원격 서버가 있고 도구 지원만 필요한 경우 [`mcp_servers` API 매개변수](#using-the-mcp-connector-in-the-messages-api)를 사용한다. [Agent SDK](https://platform.claude.com/docs/en/agent-sdk/mcp)를 사용하는 경우 MCP 연결이 자동으로 관리된다. 로컬 서버, 프롬프트, 리소스가 필요하거나 기본 SDK로 연결을 더 많이 제어해야 하는 경우 클라이언트 측 헬퍼를 사용한다.
</Note>

### 설치

Anthropic SDK와 MCP SDK를 모두 설치한다:

```bash
npm install @anthropic-ai/sdk @modelcontextprotocol/sdk
```

### 사용 가능한 헬퍼

베타 네임스페이스에서 헬퍼를 가져온다:

```typescript
import {
  mcpTools,
  mcpMessages,
  mcpResourceToContent,
  mcpResourceToFile,
} from '@anthropic-ai/sdk/helpers/beta/mcp';
```

| 헬퍼 | 설명 |
|--------|-------------|
| `mcpTools(tools, mcpClient)` | MCP 도구를 `client.beta.messages.toolRunner()`와 함께 사용할 Claude API 도구로 변환한다 |
| `mcpMessages(messages)` | MCP 프롬프트 메시지를 Claude API 메시지 형식으로 변환한다 |
| `mcpResourceToContent(resource)` | MCP 리소스를 Claude API 콘텐츠 블록으로 변환한다 |
| `mcpResourceToFile(resource)` | MCP 리소스를 업로드할 파일 객체로 변환한다 |

### MCP 도구 사용

도구 실행을 자동으로 처리하는 SDK의 [도구 러너](https://platform.claude.com/docs/en/agents-and-tools/tool-use/implement-tool-use#tool-runner-beta)와 함께 사용하기 위해 MCP 도구를 변환한다:

```typescript
import Anthropic from '@anthropic-ai/sdk';
import { mcpTools } from '@anthropic-ai/sdk/helpers/beta/mcp';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';

const anthropic = new Anthropic();

// MCP 서버에 연결
const transport = new StdioClientTransport({ command: 'mcp-server', args: [] });
const mcpClient = new Client({ name: 'my-client', version: '1.0.0' });
await mcpClient.connect(transport);

// 도구 목록을 나열하고 Claude API용으로 변환
const { tools } = await mcpClient.listTools();
const runner = await anthropic.beta.messages.toolRunner({
  model: 'claude-sonnet-4-5',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'What tools do you have available?' }],
  tools: mcpTools(tools, mcpClient),
});
```

### MCP 프롬프트 사용

MCP 프롬프트 메시지를 Claude API 메시지 형식으로 변환한다:

```typescript
import { mcpMessages } from '@anthropic-ai/sdk/helpers/beta/mcp';

const { messages } = await mcpClient.getPrompt({ name: 'my-prompt' });
const response = await anthropic.beta.messages.create({
  model: 'claude-sonnet-4-5',
  max_tokens: 1024,
  messages: mcpMessages(messages),
});
```

### MCP 리소스 사용

MCP 리소스를 메시지에 포함할 콘텐츠 블록 또는 업로드할 파일 객체로 변환한다:

```typescript
import { mcpResourceToContent, mcpResourceToFile } from '@anthropic-ai/sdk/helpers/beta/mcp';

// 메시지의 콘텐츠 블록으로
const resource = await mcpClient.readResource({ uri: 'file:///path/to/doc.txt' });
await anthropic.beta.messages.create({
  model: 'claude-sonnet-4-5',
  max_tokens: 1024,
  messages: [
    {
      role: 'user',
      content: [
        mcpResourceToContent(resource),
        { type: 'text', text: 'Summarize this document' },
      ],
    },
  ],
});

// 파일 업로드로
const fileResource = await mcpClient.readResource({ uri: 'file:///path/to/data.json' });
await anthropic.beta.files.upload({ file: mcpResourceToFile(fileResource) });
```

### 오류 처리

변환 함수는 MCP 값이 Claude API에서 지원되지 않는 경우 `UnsupportedMCPValueError`를 발생시킨다. 이는 지원되지 않는 콘텐츠 타입, MIME 타입 또는 비HTTP 리소스 링크에서 발생할 수 있다.

## 마이그레이션 가이드

더 이상 사용되지 않는 `mcp-client-2025-04-04` 베타 헤더를 사용하는 경우 이 가이드에 따라 새 버전으로 마이그레이션한다.

### 주요 변경 사항

1. **새 베타 헤더**: `mcp-client-2025-04-04`에서 `mcp-client-2025-11-20`으로 변경한다
2. **도구 구성 이동**: 도구 구성은 이제 MCP 서버 정의가 아닌 `tools` 배열에 MCPToolset 객체로 위치한다
3. **더 유연한 구성**: 새 패턴은 허용 목록, 거부 목록 및 도구별 구성을 지원한다

### 마이그레이션 단계

**이전 (더 이상 사용되지 않음):**

```json
{
  "model": "claude-opus-4-6",
  "max_tokens": 1000,
  "messages": [...],
  "mcp_servers": [
    {
      "type": "url",
      "url": "https://mcp.example.com/sse",
      "name": "example-mcp",
      "authorization_token": "YOUR_TOKEN",
      "tool_configuration": {
        "enabled": true,
        "allowed_tools": ["tool1", "tool2"]
      }
    }
  ]
}
```

**이후 (현재):**

```json
{
  "model": "claude-opus-4-6",
  "max_tokens": 1000,
  "messages": [...],
  "mcp_servers": [
    {
      "type": "url",
      "url": "https://mcp.example.com/sse",
      "name": "example-mcp",
      "authorization_token": "YOUR_TOKEN"
    }
  ],
  "tools": [
    {
      "type": "mcp_toolset",
      "mcp_server_name": "example-mcp",
      "default_config": {
        "enabled": false
      },
      "configs": {
        "tool1": {
          "enabled": true
        },
        "tool2": {
          "enabled": true
        }
      }
    }
  ]
}
```

### 일반적인 마이그레이션 패턴

| 이전 패턴 | 새 패턴 |
|-------------|-------------|
| `tool_configuration` 없음 (모든 도구 활성화) | `default_config` 또는 `configs`가 없는 MCPToolset |
| `tool_configuration.enabled: false` | `default_config.enabled: false`가 있는 MCPToolset |
| `tool_configuration.allowed_tools: [...]` | `default_config.enabled: false`이고 `configs`에서 특정 도구가 활성화된 MCPToolset |

## 더 이상 사용되지 않는 버전: mcp-client-2025-04-04

<Note type="warning">
  이 버전은 더 이상 사용되지 않는다. 위의 [마이그레이션 가이드](#migration-guide)를 사용하여 `mcp-client-2025-11-20`으로 마이그레이션한다.
</Note>

이전 버전의 MCP 커넥터는 MCP 서버 정의에 직접 도구 구성을 포함했다:

```json
{
  "mcp_servers": [
    {
      "type": "url",
      "url": "https://example-server.modelcontextprotocol.io/sse",
      "name": "example-mcp",
      "authorization_token": "YOUR_TOKEN",
      "tool_configuration": {
        "enabled": true,
        "allowed_tools": ["example_tool_1", "example_tool_2"]
      }
    }
  ]
}
```

### 더 이상 사용되지 않는 필드 설명

| 속성 | 타입 | 설명 |
|----------|------|-------------|
| `tool_configuration` | object | **더 이상 사용되지 않음**: 대신 `tools` 배열의 MCPToolset을 사용한다 |
| `tool_configuration.enabled` | boolean | **더 이상 사용되지 않음**: MCPToolset의 `default_config.enabled`를 사용한다 |
| `tool_configuration.allowed_tools` | array | **더 이상 사용되지 않음**: MCPToolset의 `configs`와 함께 허용 목록 패턴을 사용한다 |
