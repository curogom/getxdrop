# 01. Project Overview

## 1) 프로젝트명

- Public name: **GetXDrop**
- Short name: **GXD**
- Suggested repo/package/CLI: **`getxdrop`**

## 2) 한 줄 정의

GetXDrop는 레거시 GetX Flutter 앱을 분석하고, 위험도를 분류하고, 안전한 범위만 자동 처리하며, 목표 아키텍처로 이관하기 위한 마이그레이션 워크벤치다.

## 3) 왜 필요한가

GetX는 단순 상태관리 라이브러리가 아니라 아래 역할을 광범위하게 맡아왔다.

- 상태관리
- 의존성 주입
- 라우팅
- contextless UI helper
- HTTP / WebSocket helper
- lifecycle orchestration

이 구조에서는 단순 치환이 불가능하다.
문자열 replace나 단일 codemod로 처리하려 하면 의미 보존 실패 확률이 높다.

따라서 GetXDrop의 역할은 “무조건 바꾼다”가 아니라 다음 4가지다.

1. 어디에 GetX가 얼마나 깊게 박혀 있는지 보여준다.
2. 상태 / DI / 라우팅 / 네트워크 / UI helper를 분리해서 분류한다.
3. 목표 스택으로 옮길 수 있는 뼈대를 자동 생성한다.
4. 안전한 변경만 적용하고 위험한 구간은 TODO와 리포트로 남긴다.

## 4) 제품 철학

### 해야 할 것
- 먼저 분석하고 나중에 수정한다.
- 확실한 패턴만 자동화한다.
- 바꾸지 못한 부분은 숨기지 않고 드러낸다.
- 사람이 마지막 결정을 할 수 있게 만든다.

### 하지 말아야 할 것
- “완전 자동 마이그레이션”이라는 식으로 과장하지 않는다.
- 복잡한 controller, route, API 로직을 조용히 깨뜨리지 않는다.
- 상태관리 도구를 DI 전용 대체재처럼만 사용하게 유도하지 않는다.

## 5) 목표 결과 구조

GetXDrop가 지향하는 타깃 구조는 다음과 같다.

- Routing: GoRouter
- HTTP/REST: Dio
- State + reactive graph: Riverpod 3
- Optional compatibility bridge: GetIt (기본 비활성)

## 6) 첫 성공 기준

첫 성공 기준은 코드 변환율이 아니다.

첫 성공 기준은 아래 둘이다.

- 프로젝트 안의 GetX 사용 구조가 명확하게 리포트된다.
- 개발자가 “어디부터 손대야 하는지” 바로 판단할 수 있다.

즉, v0.1의 본질은 코드 편집기가 아니라 **진단 도구**다.
