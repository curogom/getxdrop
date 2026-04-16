# 04. CLI Specification

## 1) 기본 명령

```bash
getxdrop audit
getxdrop report --format markdown
getxdrop scaffold
getxdrop apply-safe
getxdrop doctor
```

## 2) 커맨드 정의

### `getxdrop audit`
프로젝트를 분석하고 normalized inventory를 생성한다.

예시:
```bash
getxdrop audit --project . --out build/getxdrop
```

출력:
- in-memory inventory
- optional cached analysis
- report generation input

옵션:
- `--project <path>`
- `--out <path>`
- `--format markdown|json|both`
- `--include-test`
- `--ignore <glob>`
- `--dry-run`

### `getxdrop report`
이전에 생성된 inventory 또는 즉시 분석 결과를 바탕으로 리포트를 생성한다.

예시:
```bash
getxdrop report --project . --format both
```

옵션:
- `--project <path>`
- `--format markdown|json|both`
- `--out <path>`

### `getxdrop scaffold`
타깃 구조의 기본 파일을 생성한다.

예시:
```bash
getxdrop scaffold --project . --target riverpod
```

옵션:
- `--project <path>`
- `--out <path>`
- `--routing go_router`
- `--network dio`
- `--state riverpod`
- `--legacy-di none|get_it`
- `--dry-run`

### `getxdrop apply-safe`
낮은 위험도의 패턴에 대해서만 자동 수정안을 적용한다.

예시:
```bash
getxdrop apply-safe --project . --dry-run
```

옵션:
- `--project <path>`
- `--out <path>`
- `--dry-run`
- `--write`
- `--insert-todos`
- `--max-risk low`

### `getxdrop doctor`
환경을 진단한다.

검사 대상:
- Dart SDK version
- Flutter SDK version
- parser compatibility
- project root validity
- pubspec presence
- lib directory presence

## 3) 출력 정책

### 성공
- summary lines
- generated file list
- report paths

### 실패
- partial findings라도 출력
- parse failure file list 출력
- unsupported pattern 목록 출력

## 4) exit code 제안

- `0`: success
- `1`: generic failure
- `2`: project invalid
- `3`: analysis partial with recoverable issues
- `4`: write blocked because of safety policy

## 5) 향후 커맨드 후보

- `getxdrop init`
- `getxdrop explain <finding-id>`
- `getxdrop diff`
- `getxdrop stats`
- `getxdrop config validate`

## 6) CLI UX 규칙

- 기본은 보수적으로 동작
- write는 opt-in
- 사람이 검토할 수 있는 diff 우선
- 조용히 고치지 말고 이유를 같이 출력
