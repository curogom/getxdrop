# GetXDrop

语言:
[English](README.md) |
[한국어](README.ko.md) |
[日本語](README.ja.md) |
[简体中文](README.zh-Hans.md) |
[Español](README.es.md) |
[Português (BR)](README.pt-BR.md)

对外公开的主 README 以英文版为准。本文件是简体中文摘要版。

GetXDrop 是一款面向遗留 GetX Flutter 应用、以 CLI 为中心的迁移工作台。

它并不承诺一键重写。它首先帮助团队回答两个最重要的问题：

- 哪里有风险
- 应该先迁移什么

当前 GetXDrop 聚焦于 `doctor`、`audit`、`report`。它会分析 GetX 使用情况，生成 machine-readable artifact，并输出带有 route / network / controller / finding 级 planning context 的 migration report。

- 仓库: [github.com/curogom/getxdrop](https://github.com/curogom/getxdrop)
- Issues: [github.com/curogom/getxdrop/issues](https://github.com/curogom/getxdrop/issues)
- Discussions: [github.com/curogom/getxdrop/discussions](https://github.com/curogom/getxdrop/discussions)
- 站点: [curogom.github.io/getxdrop](https://curogom.github.io/getxdrop/)

## 当前可用功能 (`v0.1`)

- `doctor`
- `audit`
- `report`
- route inventory
- network inventory
- controller complexity scoring
- explainable finding drill-down
- sample app regression coverage
- analyze / test CI baseline

尚未提供:

- `getxdrop scaffold`
- `getxdrop apply-safe`
- one-click full migration

## 60 秒体验

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

然后查看:

- `build/getxdrop/inventory.json`
- `build/getxdrop/migration_report.json`
- `build/getxdrop/migration_report.md`

## 公开命令

```bash
getxdrop doctor
getxdrop audit
getxdrop report
```

工作区 helper:

```bash
fvm dart run melos run analyze
fvm dart run melos run test
fvm dart run melos run audit:sample
```

## 输出契约

默认输出目录是 `build/getxdrop`。

- `inventory.json`
  top-level `schemaVersion`, `inventory`, `parseFailures`
- `migration_report.md`
  人类可读 report
- `migration_report.json`
  top-level `schemaVersion`, `project`, `summary`, `riskSummary`, `categories`, `routeInventory`, `networkInventory`, `controllerInventory`, `findingDrillDowns`, `recommendedOrder`, `findings`

当前 schema version:

- `inventory.json`: `1`
- `migration_report.json`: `1`

## 分发策略

`v0.1.x` 采用 GitHub-first 策略。

- 公开主页: GitHub repository
- 发布渠道: GitHub Releases
- 网站: GitHub Pages
- pub.dev: 暂不发布

CLI 当前依赖 `getxdrop_analyzer_core` 和 `getxdrop_report_core`，因此未来如果要上 pub.dev，需要为整套依赖包制定公开策略，而不是只发布可执行包装层。

## 路线图

### Now

- `doctor`, `audit`, `report`
- stable report artifacts
- route / network / controller planning slices
- explainable finding drill-down

### Next

- `getxdrop.yaml`
- schema versioning / validation
- CI / PR-friendly summaries

### Later

- `scaffold`
- `apply-safe`
- richer `explain`, `diff`, `stats`

## 文档

公开文档:

- [docs/README.md](docs/README.md)
- [docs/roadmap.md](docs/roadmap.md)
- [docs/master_plan.md](docs/master_plan.md)
- [docs/public_release_checklist.md](docs/public_release_checklist.md)
- [docs/distribution_strategy.md](docs/distribution_strategy.md)
- [docs/github_launch_runbook.md](docs/github_launch_runbook.md)

内部设计文档:

- [docs/internal/README.md](docs/internal/README.md)

## 贡献

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- [SECURITY.md](SECURITY.md)
- [CHANGELOG.md](CHANGELOG.md)
