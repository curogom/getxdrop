# Public Release Checklist

This checklist tracks what GetXDrop needs in order to score at least `9/10`
across product, project, and open-source operations for the first public
release.

Status legend:

- `[x]` complete in repo
- `[~]` in progress or partially complete
- `[ ]` not started
- `[!]` blocked by a repo URL, maintainer handle, or GitHub server-side setting

## Target Scorecard

- Product core: `9.1 / 10`
- Code quality and test confidence: `9.0 / 10`
- Documentation and onboarding: `8.0 / 10`
- PR workflow and review operations: `7.4 / 10`
- OSS metadata and distribution: `5.8 / 10`
- Public-facing presentation: `8.2 / 10`
- Security and maintenance operations: `7.3 / 10`

## Product And Contract

- [x] `doctor`, `audit`, and `report` are stable public commands.
- [x] Route, network, controller, and explainable planning output are shipped.
- [x] JSON outputs include a top-level `schemaVersion`.
- [x] Schema compatibility policy is documented beyond `v0.1`.
- [x] `getxdrop.yaml` config support.

## Documentation And Onboarding

- [x] Public `README.md` explains current scope and non-goals.
- [x] `CHANGELOG.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, and `SECURITY.md` exist.
- [x] Public roadmap is visible in `README.md`.
- [~] Static landing page exists with multilingual copy.
- [x] Replace `git clone <your-public-repo-url>` with the actual repository URL.
- [x] Add badges, screenshot, and short demo asset to `README.md`.
- [x] Add one copy-paste quickstart that does not require reading internal docs.

## PR And Review Operations

- [x] Pull request template exists.
- [x] Bug report and feature request templates exist.
- [x] Label taxonomy is documented and consistently applied.
- [x] Add `CODEOWNERS` with actual maintainer handles.
- [!] Enable branch protection and require the `CI` workflow before merge.
- [!] Decide merge policy (`squash` recommended) and apply it in GitHub settings.

## OSS Metadata And Distribution

- [x] MIT license is present.
- [x] Versions are pinned for the current shipped package set.
- [x] Add `homepage`, `repository`, and `issue_tracker` to publishable package metadata.
- [x] Decide whether `getxdrop_cli` will stay GitHub-only or later publish to pub.dev.
- [x] Document package-by-package distribution strategy.
- [x] GitHub Pages deployment workflow exists for the landing page.
- [x] Release workflow exists for `v*` tags.

## Security And Maintenance

- [x] Security policy exists.
- [x] Dependabot is configured for Dart workspace packages and GitHub Actions.
- [x] Add an actual private security contact path or GitHub Security Advisory entry.
- [x] Document supported maintenance windows and response expectations after public release.

## Manual GitHub Repository Setup

- [!] Configure repository description, topics, social preview, and homepage URL.
- [!] Enable GitHub Pages if the site will be publicly hosted.
- [!] Turn on GitHub Security Advisories.
- [!] Configure branch protection for `main`.
- [!] Add maintainer team or user handles to `CODEOWNERS`.

## Release Gate For `v0.2.0`

- [x] `fvm dart run melos run analyze`
- [x] `fvm dart run melos run test`
- [x] README points to the real public repository.
- [x] Landing page links point to deployed public URLs.
- [x] Release notes are finalized for the latest public release.
- [ ] Tag `v0.2.0` and verify the release workflow.
