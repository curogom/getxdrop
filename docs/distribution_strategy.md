# Distribution Strategy

This document defines where GetXDrop should be publicly distributed and what
should remain repository-only.

## Distribution Layers

### 1. Repository

Canonical home:

- `https://github.com/curogom/getxdrop`

Repository distribution is always required because it contains:

- product documentation
- roadmap and project docs
- sample app fixture
- static landing page
- issue tracker and discussions

### 2. GitHub Releases

Primary public delivery channel for `v0.1.x`.

Why:

- fastest path to public availability
- supports release notes and versioned tags
- lets the CLI contract settle before package-registry commitments
- keeps docs, site, code, and release artifact in one place

### 3. pub.dev

Not the primary channel for `v0.1.x`.

Reason:

- `getxdrop_cli` currently depends on `getxdrop_analyzer_core` and
  `getxdrop_report_core`
- publishing the CLI alone is not enough; the dependency graph must also be
  publishable
- once a package is published to pub.dev, versioning and public API stability
  expectations increase

## Package Publication Policy

### Keep Repository-Only For Now

- `getxdrop_workspace`
- `getxdrop_codemod_core`
- `getxdrop_templates`

These packages are either workspace-only or reserved for future slices and
should not be published in `v0.1.x`.

### Candidate Packages For Future pub.dev Publication

- `getxdrop_cli`
- `getxdrop_analyzer_core`
- `getxdrop_report_core`

These are the only packages that make sense to publish if the project later
chooses a pub.dev path.

## Recommended Public Strategy

### `v0.1.x`

- repository: public
- website: GitHub Pages
- release delivery: GitHub Releases
- pub.dev: do not publish yet

### `v0.2.x` decision gate

Consider pub.dev only if all of the following are true:

- `doctor`, `audit`, and `report` semantics are stable
- JSON schemas have a documented compatibility story
- install and upgrade UX is clear for external users
- the team is willing to support package-level semver expectations

## Why This Matters

If GetXDrop is positioned as a fast-response open-source answer, GitHub is the
best first channel because it optimizes for visibility, documentation, and
iteration speed.

If GetXDrop later becomes a stable developer tool with a strong CLI contract,
pub.dev becomes valuable for:

- Flutter/Dart discovery
- simpler install commands
- package-level trust signals
- ecosystem search visibility

## Current Decision

For the first public release:

- open the repository publicly
- ship `v0.1.0` through GitHub Releases
- keep package publication on pub.dev deferred until a later release line
