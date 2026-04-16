# Contributing

Thanks for considering a contribution to GetXDrop.

> 한국어
>
> GetXDrop에 기여를 고려해주셔서 감사합니다.
> 이 문서는 영어를 기준으로 하며, 아래 한국어 설명은 빠른 이해를 돕기 위한 보조 설명입니다.

## What We Need Most

- real-world GetX edge cases
- small, focused bug reports with reproductions
- report output accuracy improvements
- tests that lock down migration-risk interpretation

> 한국어
>
> 가장 필요한 기여는 실제 GetX edge case, 재현 가능한 작은 bug report, report 정확도 개선, migration-risk 해석을 고정하는 테스트입니다.

## Development Setup

```bash
fvm install
fvm use
fvm dart pub get
fvm dart run melos run analyze
fvm dart run melos run test
```

> 한국어
>
> 개발 환경은 `fvm` 기준으로 맞추고, 기본 검증은 `melos run analyze`와 `melos run test`로 진행합니다.

## Workflow

- Start with a narrowly scoped issue or bug.
- Prefer one behavior change per pull request.
- Follow `Red -> Green -> Refactor`.
- Add or update tests before changing behavior.
- Update docs when the public contract changes.

> 한국어
>
> 작은 범위의 이슈부터 시작하고, PR 하나에는 하나의 behavior change만 넣는 편이 좋습니다.
> 작업 방식은 `Red -> Green -> Refactor`이며, public contract가 바뀌면 문서도 같이 갱신해야 합니다.

## Pull Request Guidelines

- Keep PRs small enough to review in one sitting.
- Describe user-visible behavior changes clearly.
- Call out schema or CLI contract changes explicitly.
- Do not mix unrelated refactors with bug fixes.
- Do not add unsafe migration automation under the guise of a small improvement.

Labels and maintainer operating rules are documented in [docs/maintainer_operations.md](docs/maintainer_operations.md).

> 한국어
>
> PR은 한 번에 리뷰 가능한 크기로 유지하고, schema/CLI contract 변경은 반드시 명시해야 합니다.
> 작은 개선처럼 보이도록 unsafe automation을 끼워 넣는 방식은 받지 않습니다.

## Testing Expectations

At minimum, run:

```bash
fvm dart run melos run analyze
fvm dart run melos run test
```

If your change only touches docs or GitHub templates, say so in the PR.

> 한국어
>
> 코드 변경이 있다면 최소한 analyze/test 전체를 돌리는 것을 기대합니다.
> 문서나 GitHub 템플릿만 수정한 경우에는 PR에 그 사실을 적어주세요.

## Design Principles

- Be conservative with automation claims.
- Favor explainability over cleverness.
- Preserve machine-readable stability where possible.
- Treat false negatives and false confidence as product bugs.

> 한국어
>
> 이 프로젝트는 자동화 과장보다 설명 가능성과 보수성을 우선합니다.
> false negative와 과도한 confidence는 제품 버그로 취급합니다.

## Communication

For larger changes, open an issue first so scope and compatibility can be aligned before implementation.

> 한국어
>
> 큰 변경은 구현 전에 issue를 열어 범위와 호환성부터 맞추는 것이 좋습니다.
