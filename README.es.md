# GetXDrop

Idiomas:
[English](README.md) |
[한국어](README.ko.md) |
[日本語](README.ja.md) |
[简体中文](README.zh-Hans.md) |
[Español](README.es.md) |
[Português (BR)](README.pt-BR.md)

El README público canónico es el inglés. Este archivo es una versión resumida en español.

GetXDrop es un migration workbench centrado en CLI para apps Flutter heredadas con GetX.

No promete una reescritura de un clic. Primero ayuda a responder dos preguntas:

- qué parte del código es riesgosa
- qué debería migrarse primero

Hoy GetXDrop se enfoca en `doctor`, `audit` y `report`. Analiza el uso de GetX, genera artifacts legibles por máquina y produce un migration report con contexto de planificación a nivel de route, network, controller y finding.

- Repositorio: [github.com/curogom/getxdrop](https://github.com/curogom/getxdrop)
- Issues: [github.com/curogom/getxdrop/issues](https://github.com/curogom/getxdrop/issues)
- Discussions: [github.com/curogom/getxdrop/discussions](https://github.com/curogom/getxdrop/discussions)
- Sitio: [curogom.github.io/getxdrop](https://curogom.github.io/getxdrop/)

## Disponible ahora (`v0.1`)

- `doctor`
- `audit`
- `report`
- route inventory
- network inventory
- controller complexity scoring
- explainable finding drill-down
- sample app regression coverage
- analyze / test CI baseline

Todavía no incluido:

- `getxdrop scaffold`
- `getxdrop apply-safe`
- one-click full migration

## Probar en 60 segundos

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

Luego abre:

- `build/getxdrop/inventory.json`
- `build/getxdrop/migration_report.json`
- `build/getxdrop/migration_report.md`

## Comandos públicos

```bash
getxdrop doctor
getxdrop audit
getxdrop report
```

Helpers del workspace:

```bash
fvm dart run melos run analyze
fvm dart run melos run test
fvm dart run melos run audit:sample
```

## Contratos de salida

Directorio por defecto: `build/getxdrop`

- `inventory.json`
  top-level `schemaVersion`, `inventory`, `parseFailures`
- `migration_report.md`
  report legible por personas
- `migration_report.json`
  top-level `schemaVersion`, `project`, `summary`, `riskSummary`, `categories`, `routeInventory`, `networkInventory`, `controllerInventory`, `findingDrillDowns`, `recommendedOrder`, `findings`

Schema version actual:

- `inventory.json`: `1`
- `migration_report.json`: `1`

## Política de distribución

`v0.1.x` sigue una estrategia GitHub-first.

- hogar público: GitHub repository
- canal de release: GitHub Releases
- sitio: GitHub Pages
- pub.dev: todavía no

El CLI depende hoy de `getxdrop_analyzer_core` y `getxdrop_report_core`, así que una publicación futura en pub.dev necesita una estrategia para todo el conjunto de paquetes, no solo para el ejecutable.

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

## Documentación

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
