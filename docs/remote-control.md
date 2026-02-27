# 원격 제어를 통해 모든 기기에서 로컬 세션 이어하기

> 원격 제어(Remote Control)를 사용하여 휴 대폰, 태블릿 또는 모든 브라우저에서 로컬 Claude Code 세션을 이어갈 수 있습니다. claude.ai/code 및 Claude 모바일 앱에서 작동합니다.

<Note>
  원격 제어는 Max 요금제에서 연구 미리보기로 제공되며, 곧 Pro 요금제로 롤아웃될 예정입니다. Team 또는 Enterprise 요금제에서는 사용할 수 없습니다.
</Note>

원격 제어는 [claude.ai/code](https://claude.ai/code) 또는 [iOS](https://apps.apple.com/us/app/claude-by-anthropic/id6473753684)와 [Android](https://play.google.com/store/apps/details?id=com.anthropic.claude)용 Claude 앱을 사용자의 머신에서 실행 중인 Claude Code 세션에 연결합니다. 책상에서 작업을 시작한 후, 소파에서 휴 대폰으로 또는 다른 컴퓨터의 브라우저에서 작업을 이어갈 수 있습니다.

머신에서 원격 제어 세션을 시작하면 Claude는 계속 로컬에서 실행되므로 클라우드로 이동하지 않습니다. 원격 제어를 통해 다음을 수행할 수 있습니다:

* **전체 로컬 환경을 원격으로 사용**: 파일 시스템, [MCP 서버](https://code.claude.com/docs/en/mcp), 도구, 프로젝트 구성이 모두 그대로 유지됩니다
* **두 화면에서 동시에 작업**: 대화는 연결된 모든 기기에서 동기화되므로 터미널, 브라우저, 휴 대폰에서 번갈아가며 메시지를 별낼 수 있습니다
* **중단 없이 지속**: 노트북이 절전 모드에 들어가거나 네트워크가 끊겨도 머신이 다시 온라인 상태가 되면 세션이 자동으로 재연결됩니다

원격 제어 세션은 클라우드 인프라에서 실행되는 [웹의 Claude Code](https://code.claude.com/docs/en/claude-code-on-the-web)와 달리 사용자의 머신에서 직접 실행되며 로컬 파일 시스템과 상호작용합니다. 웹 및 모바일 인터페이스는 해당 로컬 세션을 위한 창에 불과합니다.

이 페이지에서는 설정, 세션 시작 및 연결 방법, 그리고 원격 제어와 웹의 Claude Code 비교에 대해 다룹니다.

## 요구사항

원격 제어를 사용하기 전에 환경이 다음 조건을 충족하는지 확인하세요:

* **구독**: Max 요금제가 필요합니다. Pro 요금제 지원은 곧 제공될 예정입니다. API 키는 지원되지 않습니다.
* **인증**: 아직 로그인하지 않았다면 `claude`를 실행하고 `/login`을 사용하여 claude.ai를 통해 로그인하세요.
* **작업 공간 신뢰**: 작업 공간 신뢰 다이얼로그를 수락하려면 프로젝트 디렉토리에서 `claude`를 최소 한 번 실행하세요.

## 원격 제어 세션 시작

원격 제어에서 직접 새 세션을 시작하거나, 이미 실행 중인 세션에 연결할 수 있습니다.

<Tabs>
  <Tab title="새 세션">
    프로젝트 디렉토리로 이동하여 다음을 실행하세요:

    ```bash  theme={null}
    claude remote-control
    ```

    프로세스는 터미널에서 계속 실행되며 원격 연결을 대기합니다. [다른 기기에서 연결](#다른-기기에서-연결)하는 데 사용할 수 있는 세션 URL을 표시하며, 스페이스바를 눌러 휴 대폰에서 빠르게 접근할 수 있는 QR 코드를 표시할 수 있습니다. 원격 세션이 활성 상태인 동안 터미널은 연결 상태와 도구 활동을 표시합니다.

    이 명령은 다음 플래그를 지원합니다:

    * **`--verbose`**: 상세한 연결 및 세션 로그 표시
    * **`--sandbox`** / **`--no-sandbox`**: 세션 중 파일 시스템 및 네트워크 격리를 위한 [샌드박싱](https://code.claude.com/docs/en/sandboxing) 활성화 또는 비활성화. 샌드박싱은 기본적으로 꺼져 있습니다.
  </Tab>

  <Tab title="기존 세션에서">
    이미 Claude Code 세션에 있는 상태에서 원격으로 계속하려면 `/remote-control`(또는 `/rc`) 명령을 사용하세요:

    ```
    /remote-control
    ```

    이렇게 하면 현재 대화 기록을 이어가는 원격 제어 세션이 시작되며, [다른 기기에서 연결](#다른-기기에서-연결)하는 데 사용할 수 있는 세션 URL과 QR 코드를 표시합니다. `--verbose`, `--sandbox`, `--no-sandbox` 플래그는 이 명령에서 사용할 수 없습니다.

    <Tip>
      세션에 설명적인 이름을 지정하려면 `/remote-control`을 실행하기 전에 `/rename`을 사용하세요. 이렇게 하면 여러 기기의 세션 목록에서 찾기가 쉬워집니다.
    </Tip>
  </Tab>
</Tabs>

### 다른 기기에서 연결

원격 제어 세션이 활성화되면 다른 기기에서 연결하는 방법이 몇 가지 있습니다:

* [claude.ai/code](https://claude.ai/code)에서 세션으로 바로 이동하려면 **브라우저에서 세션 URL을 열어**보세요. `claude remote-control`와 `/remote-control` 모두 터미널에 이 URL을 표시합니다.
* 세션 URL과 함께 표시된 **QR 코드를 스캔**하면 Claude 앱에서 직접 열립니다. `claude remote-control`에서는 스페이스바를 눌러 QR 코드 표시를 전환할 수 있습니다.
* **클로드 앱에서 [claude.ai/code](https://claude.ai/code)를 열고** 세션 목록에서 이름으로 세션을 찾으세요. 원격 제어 세션은 온라인 상태일 때 녹색 상태 점이 있는 컴퓨터 아이콘으로 표시됩니다.

원격 세션은 마지막 메시지, `/rename` 값 또는 대화 기록이 없는 경우 "Remote Control session"에서 이름을 가져옵니다. 환경에 이미 활성 세션이 있는 경우, 계속할지 또는 새 세션을 시작할지 묻습니다.

Claude 앱이 아직 없다면 Claude Code 낶에서 `/mobile` 명령을 사용하여 [iOS](https://apps.apple.com/us/app/claude-by-anthropic/id6473753684) 또는 [Android](https://play.google.com/store/apps/details?id=com.anthropic.claude)용 다운로드 QR 코드를 표시하세요.

### 모든 세션에 대해 원격 제어 활성화

기본적으로 원격 제어는 `claude remote-control` 또는 `/remote-control`을 명시적으로 실행할 때만 활성화됩니다. 모든 세션에 대해 자동으로 활성화하려면 Claude Code 내에서 `/config`를 실행하고 **모든 세션에 대해 원격 제어 활성화**를 `true`로 설정하세요. 다시 비활성화하려면 `false`로 설정하세요.

각 Claude Code 인스턴스는 한 번에 하나의 원격 세션만 지원합니다. 여러 인스턴스를 실행하면 각 인스턴스마다 자체 환경과 세션이 생깁니다.

## 연결 및 보안

로컬 Claude Code 세션은 아웃바운드 HTTPS 요청만 하며 머신에서 인바운드 포트를 열지 않습니다. 원격 제어를 시작하면 Anthropic API에 등록하고 작업을 폴링합니다. 다른 기기에서 연결하면 서버가 웹 또는 모바일 클라이언트와 로컬 세션 간에 스트리밍 연결을 통해 메시지를 라우팅합니다.

모든 트래픽은 다른 Claude Code 세션과 동일한 전송 보안인 TLS를 통해 Anthropic API를 통해 전송됩니다. 연결은 단일 목적으로 범위가 지정되고 독립적으로 만료되는 여러 단기 자격 증명을 사용합니다.

## 원격 제어와 웹의 Claude Code 비교

원격 제어와 [웹의 Claude Code](https://code.claude.com/docs/en/claude-code-on-the-web)는 모두 claude.ai/code 인터페이스를 사용합니다. 핵심 차이점은 세션이 실행되는 위치입니다: 원격 제어는 사용자의 머신에서 실행되므로 로컬 MCP 서버, 도구, 프로젝트 구성이 그대로 유지됩니다. 웹의 Claude Code는 Anthropic에서 관리하는 클라우드 인프라에서 실행됩니다.

로컬 작업 중에 다른 기기에서 계속 진행하려면 원격 제어를 사용하세요. 로컬 설정 없이 작업을 시작하거나, 클론하지 않은 저장소에서 작업하거나, 여러 작업을 병렬로 실행하려면 웹의 Claude Code를 사용하세요.

## 제한사항

* **한 번에 하나의 원격 세션**: 각 Claude Code 세션은 하나의 원격 연결만 지원합니다.
* **터미널을 열어 두어야 함**: 원격 제어는 로컬 프로세스로 실행됩니다. 터미널을 닫거나 `claude` 프로세스를 중지하면 세션이 종료됩니다. 새 세션을 시작하려면 `claude remote-control`를 다시 실행하세요.
* **장기 네트워크 중단**: 머신은 깨어 있지만 약 10분 이상 네트워크에 연결할 수 없는 경우 세션이 시간 초과되고 프로세스가 종료됩니다. 새 세션을 시작하려면 `claude remote-control`를 다시 실행하세요.

## 관련 리소스

* [웹의 Claude Code](https://code.claude.com/docs/en/claude-code-on-the-web): 사용자의 머신 대신 Anthropic이 관리하는 클라우드 환경에서 세션 실행
* [인증](https://code.claude.com/docs/en/authentication): claude.ai에 대한 `/login` 설정 및 자격 증명 관리
* [CLI 참조](https://code.claude.com/docs/en/cli-reference): `claude remote-control`를 포함한 플래그 및 명령의 전체 목록
* [보안](https://code.claude.com/docs/en/security): 원격 제어 세션이 Claude Code 보안 모델에 어떻게 적합한지
* [데이터 사용](https://code.claude.com/docs/en/data-usage): 로컬 및 원격 세션 중 Anthropic API를 통해 흐르는 데이터
