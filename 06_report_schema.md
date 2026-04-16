# 06. Report Schema

## 1) 출력 파일

- `migration_report.md`
- `migration_report.json`

## 2) Markdown 구조 예시

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

## Recommended Order
1. App router migration
2. Network abstraction migration
3. Large controller decomposition
4. DI cleanup
5. Widget-level reactive cleanup

## Findings
### Finding GXD-ROUTE-001
...
```

## 3) JSON 스키마 예시

```json
{
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
  "recommendedOrder": [],
  "findings": []
}
```

## 4) JSON 필드 상세

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

## 5) Finding ID 규칙 제안

형식:
`GXD-<CATEGORY>-<NNN>`

예시:
- `GXD-STATE-001`
- `GXD-DI-014`
- `GXD-ROUTE-007`
- `GXD-NET-003`

## 6) Snippet 정책

- 1개 finding당 짧은 snippet만 담는다.
- 원문 전체를 JSON에 우겨 넣지 않는다.
- line range로 원본 위치를 추적 가능하게 한다.

## 7) Recommended target 예시

- `riverpod_notifier`
- `riverpod_async_notifier`
- `go_router_route_tree`
- `dio_client_repository`
- `manual_ui_context_refactor`
- `legacy_di_bridge_optional`

## 8) Report 생성 원칙

- 숫자 요약
- 위험도 요약
- 카테고리별 묶음
- 우선 처리 순서
- 개별 finding 상세

즉, 사람이 보고 바로 작업 순서를 결정할 수 있어야 한다.
