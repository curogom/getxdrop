# Security Policy

This document is written in English first for public reporting. Korean notes are included as a secondary explanation.

> 한국어
>
> 이 문서는 공개 프로젝트 운영을 위해 영어를 기준으로 작성되며, 한국어 설명은 보조 안내입니다.

## Supported Version

Current supported preview line:

- `0.1.x`

> 한국어
>
> 현재는 `0.1.x` 프리뷰 라인만 지원 대상으로 봅니다.

## Reporting A Vulnerability

Please do not open public issues for security-sensitive vulnerabilities.

Preferred approach:

1. Use GitHub Security Advisories at `https://github.com/curogom/getxdrop/security` when possible.
2. If a private advisory cannot be used, contact `i_am@curogom.dev`.
3. Include a minimal impact summary, affected version, and reproduction details.
4. Allow reasonable time for triage before public disclosure.

> 한국어
>
> 보안 이슈는 public issue로 열지 말고, 가능하면 GitHub Security Advisory를 사용해 주세요.
> Advisory 사용이 어렵다면 `i_am@curogom.dev` 로 알려주세요.
> 영향 범위, 영향받는 버전, 재현 방법을 함께 보내는 것이 좋습니다.

## What Counts As Security-Sensitive Here

- arbitrary file write or command execution paths
- unsafe path handling in CLI output or config loading
- report generation issues that expose private source unexpectedly
- dependency or workflow issues that materially affect users of the tool

General accuracy bugs, false positives, and migration-planning quality issues should go through the normal issue tracker unless they expose sensitive data or execution risk.

> 한국어
>
> 임의 파일 쓰기, 명령 실행, 경로 처리 취약점, 민감한 소스 노출 가능성, 심각한 dependency/workflow 이슈는 보안 이슈로 취급합니다.
> 일반적인 정확도 문제나 false positive는 민감 정보 노출이 없는 한 일반 issue tracker로 보내면 됩니다.
