# GetXDrop

Idiomas:
[English](README.md) |
[한국어](README.ko.md) |
[日本語](README.ja.md) |
[简体中文](README.zh-Hans.md) |
[Español](README.es.md) |
[Português (BR)](README.pt-BR.md)

O README público canônico é o inglês. Este arquivo é uma versão resumida em português do Brasil.

GetXDrop é uma migration workbench centrada em CLI para apps Flutter legados com GetX.

Ele não promete uma reescrita em um clique. Primeiro ajuda a responder duas perguntas:

- onde está o risco
- o que deve migrar primeiro

Hoje o GetXDrop se concentra em `doctor`, `audit` e `report`. Ele analisa o uso de GetX, gera artifacts legíveis por máquina e produz um migration report com contexto de planejamento em nível de route, network, controller e finding.

- Repositório: [github.com/curogom/getxdrop](https://github.com/curogom/getxdrop)
- Issues: [github.com/curogom/getxdrop/issues](https://github.com/curogom/getxdrop/issues)
- Discussions: [github.com/curogom/getxdrop/discussions](https://github.com/curogom/getxdrop/discussions)
- Site: [curogom.github.io/getxdrop](https://curogom.github.io/getxdrop/)

## Disponível agora (`v0.1`)

- `doctor`
- `audit`
- `report`
- route inventory
- network inventory
- controller complexity scoring
- explainable finding drill-down
- sample app regression coverage
- analyze / test CI baseline

Ainda não incluído:

- `getxdrop scaffold`
- `getxdrop apply-safe`
- one-click full migration

## Teste em 60 segundos

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

Depois abra:

- `build/getxdrop/inventory.json`
- `build/getxdrop/migration_report.json`
- `build/getxdrop/migration_report.md`

## Comandos públicos

```bash
getxdrop doctor
getxdrop audit
getxdrop report
```

Helpers do workspace:

```bash
fvm dart run melos run analyze
fvm dart run melos run test
fvm dart run melos run audit:sample
```

## Contratos de saída

Diretório padrão: `build/getxdrop`

- `inventory.json`
  top-level `schemaVersion`, `inventory`, `parseFailures`
- `migration_report.md`
  report legível por pessoas
- `migration_report.json`
  top-level `schemaVersion`, `project`, `summary`, `riskSummary`, `categories`, `routeInventory`, `networkInventory`, `controllerInventory`, `findingDrillDowns`, `recommendedOrder`, `findings`

Schema version atual:

- `inventory.json`: `1`
- `migration_report.json`: `1`

## Política de distribuição

`v0.1.x` segue uma estratégia GitHub-first.

- casa pública: GitHub repository
- canal de release: GitHub Releases
- site: GitHub Pages
- pub.dev: ainda não

Hoje o CLI depende de `getxdrop_analyzer_core` e `getxdrop_report_core`, então uma publicação futura no pub.dev exige uma estratégia para todo o conjunto de pacotes, não apenas para o executável.

## Roadmap

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

## Documentação

Documentos públicos:

- [docs/README.md](docs/README.md)
- [docs/roadmap.md](docs/roadmap.md)
- [docs/master_plan.md](docs/master_plan.md)
- [docs/public_release_checklist.md](docs/public_release_checklist.md)
- [docs/distribution_strategy.md](docs/distribution_strategy.md)
- [docs/github_launch_runbook.md](docs/github_launch_runbook.md)

Documentos internos:

- [docs/internal/README.md](docs/internal/README.md)

## Contribuir

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- [SECURITY.md](SECURITY.md)
- [CHANGELOG.md](CHANGELOG.md)
