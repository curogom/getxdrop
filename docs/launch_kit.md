# Launch Kit

This document collects the public launch copy for GetXDrop `v0.1.0`.

English is the primary publishing language. Korean is included as a short
supporting summary where it helps.

## One-Line Positioning

GetXDrop is a CLI-first migration workbench that helps teams inspect legacy
GetX Flutter apps and plan what to migrate first.

## Short Description

GetXDrop is not a one-click rewrite tool. It helps teams find where GetX risk
lives, generate machine-readable migration artifacts, and plan a staged move to
`GoRouter + Dio + Riverpod 3`.

## GitHub Repo Description

CLI-first migration workbench for legacy GetX Flutter apps

## GitHub Discussion Announcement

### Title

GetXDrop v0.1.0 is live

### Body

GetXDrop `v0.1.0` is now public.

GetXDrop is a CLI-first migration workbench for legacy GetX-based Flutter apps.
It is not a one-click rewrite tool. The goal of `v0.1.0` is to help teams
answer the two questions that matter first:

- what in this codebase is risky
- what should we migrate first

What is included in `v0.1.0`:

- `doctor`, `audit`, and `report`
- machine-readable `inventory.json`
- `migration_report.json` and `migration_report.md`
- route inventory
- network inventory
- controller complexity scoring
- explainable finding drill-down
- sample app regression coverage
- GitHub Actions CI baseline

Project links:

- Repository: <https://github.com/curogom/getxdrop>
- Release: <https://github.com/curogom/getxdrop/releases/tag/v0.1.0>
- Docs: <https://github.com/curogom/getxdrop/blob/main/README.md>
- Site: <https://curogom.github.io/getxdrop/>

Quick start:

```bash
git clone https://github.com/curogom/getxdrop
cd getxdrop
fvm install && fvm use && fvm dart pub get
cd packages/cli
fvm dart run bin/getxdrop.dart audit \
  --project ../../examples/sample_getx_app \
  --out ../../build/getxdrop \
  --format both
```

Korean summary:

GetXDrop `v0.1.0`은 레거시 GetX Flutter 앱을 위한 첫 공개 릴리즈입니다.
핵심은 `doctor`, `audit`, `report`로 현재 위험 구간과 우선 이관 대상을
빠르게 보여주는 것입니다.

## Social Post

### Short Post

GetXDrop `v0.1.0` is live.

It is a CLI-first migration workbench for legacy GetX Flutter apps.

Not a one-click rewrite tool.
Built for the first question teams have when a legacy package becomes uncertain:

- what is risky
- what should move first

Includes `doctor`, `audit`, `report`, route/network/controller planning output,
and explainable findings.

<https://github.com/curogom/getxdrop>

### Long Post

GetXDrop `v0.1.0` is now public.

This project started from a simple need: when a widely used package becomes
uncertain, teams need a response path immediately.

GetXDrop is a CLI-first migration workbench for legacy GetX Flutter apps. It
does not pretend migration is trivial and it does not claim to replace
engineering judgment. Instead, it helps teams inspect a real codebase, generate
machine-readable artifacts, and plan a staged migration with route, network,
controller, and finding-level visibility.

The first public release includes:

- `doctor`, `audit`, and `report`
- `inventory.json`, `migration_report.json`, and `migration_report.md`
- route inventory
- network inventory
- controller complexity scoring
- explainable finding drill-down
- sample app regression coverage and CI

Repository:
<https://github.com/curogom/getxdrop>

Release:
<https://github.com/curogom/getxdrop/releases/tag/v0.1.0>

Site:
<https://curogom.github.io/getxdrop/>

## Community Post

### English

Sharing a new open-source tool: GetXDrop `v0.1.0`.

It is a CLI-first migration workbench for legacy GetX Flutter apps. The focus
is not automatic rewriting. The focus is helping teams inspect risk and decide
what should be migrated first.

Current release:

- `doctor`, `audit`, `report`
- route / network / controller planning output
- explainable findings
- JSON + markdown artifacts

If you are dealing with a legacy GetX codebase and need a migration planning
starting point, feedback is welcome.

- Repo: <https://github.com/curogom/getxdrop>
- Release: <https://github.com/curogom/getxdrop/releases/tag/v0.1.0>

### Korean

새 오픈소스 프로젝트 `GetXDrop v0.1.0`을 공개했습니다.

레거시 GetX Flutter 앱을 대상으로, 무엇이 위험한지와 무엇부터 옮겨야
하는지를 먼저 보여주는 CLI 중심 migration workbench입니다.

현재 제공 범위:

- `doctor`, `audit`, `report`
- route / network / controller planning output
- explainable findings
- JSON / markdown artifacts

레거시 GetX 코드베이스를 다루고 있다면 피드백 부탁드립니다.

- Repo: <https://github.com/curogom/getxdrop>
- Release: <https://github.com/curogom/getxdrop/releases/tag/v0.1.0>
