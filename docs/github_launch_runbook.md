# GitHub Launch Runbook

This runbook covers the remaining public-release steps that cannot be fully
completed from the repository contents alone.

## 1. Change Repository Visibility

Target repository:

- `https://github.com/curogom/getxdrop`

Steps:

1. Open repository `Settings`.
2. Go to `General`.
3. Scroll to `Danger Zone`.
4. Change visibility from `Private` to `Public`.
5. Re-check README badges and public links after the change.

## 2. Enable Branch Protection

Recommended rule for `main`:

- require pull request before merging
- require `CI` status check
- require branch to be up to date before merging
- require conversation resolution before merging
- disallow force pushes
- disallow direct deletion

Recommended merge policy:

- enable `Squash merge`
- disable merge commits if a linear history is preferred

## 3. Enable GitHub Pages

Site source is already prepared in:

- `site/`
- `.github/workflows/pages.yml`

Steps:

1. Open `Settings -> Pages`.
2. Set source to `GitHub Actions`.
3. Push to `main` or manually run the `Pages` workflow.
4. Verify:
   - `https://curogom.github.io/getxdrop/`
   - asset path `https://curogom.github.io/getxdrop/assets/og-preview.svg`

## 4. Enable Security Advisories

Steps:

1. Open `Security`.
2. Enable `Private vulnerability reporting` or GitHub Security Advisories.
3. Verify `SECURITY.md` matches the enabled path:
   - `https://github.com/curogom/getxdrop/security`

## 5. Review Repository Metadata

Recommended repository metadata:

- description:
  - `CLI-first migration workbench for legacy GetX Flutter apps`
- homepage:
  - `https://curogom.github.io/getxdrop/`
- topics:
  - `flutter`
  - `dart`
  - `getx`
  - `migration`
  - `cli`
  - `riverpod`
  - `go-router`
  - `dio`

## 6. Release `v0.1.0`

Before tagging:

1. Confirm `CHANGELOG.md` is final.
2. Confirm README quickstart still works.
3. Confirm `fvm dart run melos run analyze`.
4. Confirm `fvm dart run melos run test`.

Then:

1. Create tag `v0.1.0`.
2. Push tag.
3. Verify `.github/workflows/release.yml` succeeds.
4. Review the generated GitHub Release notes.
