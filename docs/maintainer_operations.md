# Maintainer Operations

This document defines the minimum GitHub operating standard for keeping
GetXDrop above the `9/10` public-project quality bar.

## Branch Policy

- default branch: `main`
- merge strategy: squash merge
- direct pushes to `main`: disabled except for emergency maintainer action
- required status check before merge: `CI`

## Pull Request Policy

- prefer one behavior change per PR
- require a concise summary and validation notes
- call out schema or CLI contract changes explicitly
- block merges that add unsafe automation without reviewable scope

## Label Taxonomy

- `bug`: incorrect behavior, missing detection, or regression
- `enhancement`: user-visible improvement within current product direction
- `docs`: documentation or site-only change
- `ci`: workflow, automation, or release pipeline change
- `dependencies`: dependency maintenance only
- `breaking-change`: output contract or CLI semantics changed
- `needs-repro`: issue needs a minimal reproduction before action
- `good first issue`: entry-level scoped contribution

## Release Policy

- release branch model: tag from `main`
- release tag format: `v*`
- release gate:
  - `fvm dart run melos run analyze`
  - `fvm dart run melos run test`
  - docs updated if the public contract changed
  - `CHANGELOG.md` entry present for the release line

## Pages Policy

- public site source: `site/`
- deployment target: GitHub Pages
- every `main` change touching `site/**` should deploy automatically

## Security Intake

- preferred channel: GitHub Security Advisories
- fallback contact: `i_am@curogom.dev`
- do not route security-sensitive issues through public bug reports
