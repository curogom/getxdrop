# 06. Report Schema

## 1) 출력 파일

- `inventory.json`
- `migration_report.md`
- `migration_report.json`

## 2) `inventory.json`

`inventory.json`은 `AuditResult` wire shape를 사용한다.

```json
{
  "schemaVersion": 1,
  "inventory": {
    "project": {
      "rootPath": ".",
      "generatedAt": "2026-04-16T00:00:00Z"
    },
    "summary": {
      "totalDartFiles": 128,
      "analyzedFiles": 121,
      "parseFailures": 7,
      "totalFindings": 243
    },
    "riskSummary": {
      "low": 98,
      "medium": 91,
      "high": 54
    },
    "categories": {
      "state": [],
      "di": [],
      "routing": [],
      "uiHelper": [],
      "network": []
    },
    "routeInventory": {
      "declarations": [],
      "invocations": [],
      "argumentAccesses": []
    },
    "networkInventory": {
      "clients": []
    },
    "controllerInventory": {
      "controllers": []
    },
    "findingDrillDowns": [],
    "recommendedOrder": [],
    "findings": []
  },
  "parseFailures": []
}
```

top-level:
- `schemaVersion`
- `inventory`
- `parseFailures`

## 3) `migration_report.json`

`migration_report.json`은 `ProjectInventory` wire shape를 사용한다.

```json
{
  "schemaVersion": 1,
  "project": {
    "rootPath": ".",
    "generatedAt": "2026-04-16T00:00:00Z"
  },
  "summary": {
    "totalDartFiles": 128,
    "analyzedFiles": 121,
    "parseFailures": 7,
    "totalFindings": 243
  },
  "riskSummary": {
    "low": 98,
    "medium": 91,
    "high": 54
  },
  "categories": {
    "state": [],
    "di": [],
    "routing": [],
    "uiHelper": [],
    "network": []
  },
  "routeInventory": {
    "declarations": [],
    "invocations": [],
    "argumentAccesses": []
  },
  "networkInventory": {
    "clients": []
  },
  "controllerInventory": {
    "controllers": []
  },
  "findingDrillDowns": [],
  "recommendedOrder": [],
  "findings": []
}
```

top-level:
- `schemaVersion`
- `project`
- `summary`
- `riskSummary`
- `categories`
- `routeInventory`
- `networkInventory`
- `controllerInventory`
- `findingDrillDowns`
- `recommendedOrder`
- `findings`

## 4) `migration_report.md`

```md
# GetXDrop Migration Report

## Summary
- total dart files: 128
- analyzed files: 121
- parse failures: 7
- findings: 243

## Risk Summary
- low: 98
- medium: 91
- high: 54

## Categories
### State
...
### DI
...
### Routing
...
### UI Helper
...
### Network
...

## Route Inventory
...

## Network Inventory
...

## Controller Inventory
...

## Explainable Findings
...

## Recommended Order
1. App router migration
2. Network abstraction migration
3. Large controller decomposition
4. DI cleanup
5. Widget-level reactive cleanup

## Parse Failures
...

## Findings
### Finding GXD-ROUTE-001
...
```

## 5) 공통 필드 상세

## 5-1) Schema Versioning Policy

- `inventory.json` top-level `schemaVersion` 현재 값: `1`
- `migration_report.json` top-level `schemaVersion` 현재 값: `1`
- additive field 추가는 가능한 한 forward-compatible 하게 진행한다.
- incompatible wire-shape 변경은 release note, `README.md`, `docs/internal/04_cli_spec.md`, `docs/internal/06_report_schema.md`에 함께 반영한다.

### project
- `rootPath`
- `generatedAt`
- `flutterVersion?`
- `dartVersion?`

### summary
- `totalDartFiles`
- `analyzedFiles`
- `parseFailures`
- `totalFindings`

### riskSummary
- `low`
- `medium`
- `high`

### findings[]
- `id`
- `category`
- `subcategory`
- `filePath`
- `lineStart`
- `lineEnd`
- `snippet`
- `riskLevel`
- `confidence`
- `description`
- `migrationHint`
- `recommendedTarget`
- `requiresManualReview`

### recommendedOrder[]
- `title`
- `reason`
- `relatedFindingIds[]`

### routeInventory
- `declarations[]`
- `invocations[]`
- `argumentAccesses[]`

### routeInventory.declarations[]
- `routeName`
- `filePath`
- `lineStart`
- `pageBuilder`
- `binding?`
- `middlewares[]`

### routeInventory.invocations[]
- `methodName`
- `routeName`
- `filePath`
- `lineStart`
- `passesArguments`

### routeInventory.argumentAccesses[]
- `filePath`
- `lineStart`

### networkInventory
- `clients[]`

### networkInventory.clients[]
- `clientName`
- `filePath`
- `lineStart`
- `hasRequestModifier`
- `hasAuthenticator`
- `hasDecoder`
- `publicMethods[]`

### controllerInventory
- `controllers[]`

### controllerInventory.controllers[]
- `controllerName`
- `filePath`
- `lineStart`
- `lineCount`
- `dependencyCount`
- `reactiveFieldCount`
- `lifecycleMethodCount`
- `navigationCallCount`
- `apiCallCount`
- `globalLookupCount`
- `uiHelperCallCount`
- `totalScore`
- `riskLevel`
- `hotspots[]`

### findingDrillDowns[]
- `findingId`
- `whyRisky`
- `nextAction`
- `relatedSteps[]`
- `evidence[]`

## 6) Finding ID 규칙

형식:
`GXD-<CATEGORY>-<NNN>`

예시:
- `GXD-STATE-001`
- `GXD-DI-014`
- `GXD-ROUTE-007`
- `GXD-NET-003`

## 7) Snippet 정책

- 1개 finding당 짧은 snippet만 담는다.
- 원문 전체를 JSON에 우겨 넣지 않는다.
- line range로 원본 위치를 추적 가능하게 한다.

## 8) Report 생성 원칙

- 숫자 요약
- 위험도 요약
- 카테고리별 묶음
- route/network/controller inventory
- explainable finding drill-down
- 우선 처리 순서
- 개별 finding 상세

즉, 사람이 보고 바로 작업 순서를 결정할 수 있어야 한다.
