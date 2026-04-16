# Release And Support Policy

## Release Track

GetXDrop `0.1.x` is a GitHub-first public preview line.

- primary distribution: GitHub repository and GitHub Releases
- current CLI distribution stance: not published to pub.dev yet
- reason: CLI UX, report schema, and project configuration behavior should stay
  stable across early adopter feedback before wider package distribution

See also: [distribution_strategy.md](distribution_strategy.md)

## Supported Line

Current supported public line:

- `0.1.x`

## Support Expectations

- critical breakage or blocking regression:
  - initial triage target: within 3 business days
- high-signal bug report with reproduction:
  - initial triage target: within 5 business days
- feature request or roadmap request:
  - best effort, no guaranteed response time

## What "Supported" Means In `0.1.x`

- the repository should build and test on the pinned toolchain
- `doctor`, `audit`, and `report` should keep their documented behavior
- machine-readable outputs should avoid unnecessary breaking changes
- known gaps may still exist in migration coverage and edge-case detection

## Breaking Change Policy

While `0.1.x` is still a preview line:

- breaking changes should be rare and called out explicitly
- output contract changes must be documented in `README.md`,
  `docs/internal/04_cli_spec.md`, and `docs/internal/06_report_schema.md`
- changes that would invalidate sample-app expectations must ship with updated
  tests in the same change
