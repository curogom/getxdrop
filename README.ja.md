# GetXDrop

Languages:
[English](README.md) |
[한국어](README.ko.md) |
[日本語](README.ja.md) |
[简体中文](README.zh-Hans.md) |
[Español](README.es.md) |
[Português (BR)](README.pt-BR.md)

公開用の基準 README は英語版です。この文書は日本語向けの概要です。

GetXDrop は、レガシーな GetX ベース Flutter アプリのための CLI ファーストな移行ワークベンチです。

ワンクリック変換を約束するものではありません。まず、次の 2 つの問いに答えられるようにします。

- どこが危険か
- 何から移行すべきか

現在の GetXDrop は `doctor`、`audit`、`report` に集中しています。GetX の利用箇所を分析し、machine-readable artifact を生成し、route / network / controller / finding 単位の planning context を持つ migration report を作ります。

- Repository: [github.com/curogom/getxdrop](https://github.com/curogom/getxdrop)
- Issues: [github.com/curogom/getxdrop/issues](https://github.com/curogom/getxdrop/issues)
- Discussions: [github.com/curogom/getxdrop/discussions](https://github.com/curogom/getxdrop/discussions)
- Site: [curogom.github.io/getxdrop](https://curogom.github.io/getxdrop/)

## 現在利用可能なもの (`v0.1`)

- `doctor`
- `audit`
- `report`
- route inventory
- network inventory
- controller complexity scoring
- explainable finding drill-down
- sample app regression coverage
- analyze / test CI baseline

未提供:

- `getxdrop scaffold`
- `getxdrop apply-safe`
- one-click full migration

## 60 秒で試す

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

確認するファイル:

- `build/getxdrop/inventory.json`
- `build/getxdrop/migration_report.json`
- `build/getxdrop/migration_report.md`

## 公開コマンド

```bash
getxdrop doctor
getxdrop audit
getxdrop report
```

ワークスペース helper:

```bash
fvm dart run melos run analyze
fvm dart run melos run test
fvm dart run melos run audit:sample
```

## 出力契約

デフォルト出力先は `build/getxdrop` です。

- `inventory.json`
  top-level `schemaVersion`, `inventory`, `parseFailures`
- `migration_report.md`
  human-readable report
- `migration_report.json`
  top-level `schemaVersion`, `project`, `summary`, `riskSummary`, `categories`, `routeInventory`, `networkInventory`, `controllerInventory`, `findingDrillDowns`, `recommendedOrder`, `findings`

現在の schema version:

- `inventory.json`: `1`
- `migration_report.json`: `1`

## 配布方針

`v0.1.x` は GitHub-first の公開ラインです。

- 公開ホーム: GitHub repository
- リリースチャネル: GitHub Releases
- サイト: GitHub Pages
- pub.dev: 現時点では未公開

CLI は `getxdrop_analyzer_core` と `getxdrop_report_core` に依存しているため、pub.dev 公開は実行パッケージ単体ではなく依存セット全体の戦略が必要です。

## ロードマップ

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

## 文書

公開文書:

- [docs/README.md](docs/README.md)
- [docs/roadmap.md](docs/roadmap.md)
- [docs/master_plan.md](docs/master_plan.md)
- [docs/public_release_checklist.md](docs/public_release_checklist.md)
- [docs/distribution_strategy.md](docs/distribution_strategy.md)
- [docs/github_launch_runbook.md](docs/github_launch_runbook.md)

内部設計文書:

- [docs/internal/README.md](docs/internal/README.md)

## コントリビュート

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- [SECURITY.md](SECURITY.md)
- [CHANGELOG.md](CHANGELOG.md)
