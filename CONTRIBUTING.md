# Contributing to winforge

This is a small, personal project, but pull requests are welcome.
This project follows the [Code of Conduct](CODE_OF_CONDUCT.md).

## Setup

Requires PowerShell 7.0+.

```powershell
git clone https://github.com/gsjonio/winforge.git
cd winforge
.\tools\lint.ps1        # PSScriptAnalyzer (settings in .pslintrc)
.\tools\validate.ps1    # install detection + optimize safety assertions
Invoke-Pester .\tests   # unit tests (Pester 5+)
```

## Issues come first

One topic per issue, and every issue carries a milestone (`vX.Y.Z`). If you're
about to open a PR with no issue behind it, open the issue first — that's what
makes the release notes and the version bump derivable.

Issue titles use the same Conventional Commits prefix the work will use:
`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, `ci:`.

## Branching (gitflow)

The repo follows [gitflow](https://nvie.com/posts/a-successful-git-branching-model/).
Two long-lived branches, both protected (pull requests only, no direct pushes):

- **`develop`** is the default branch and the integration target. Day-to-day
  work branches off it and merges back into it.
- **`main`** holds released code only. It receives `release/*` and `hotfix/*`
  merges, and every commit on it is tagged.

Short-lived branches:

- **`feature/<name>`** / **`fix/<name>`** — branch off `develop`, PR back into
  `develop`.
- **`release/<version>`** — branch off `develop` to stabilize a release, then PR
  into `main`; tag `main` (`vX.Y.Z`), and merge back into `develop`.
- **`hotfix/<version>`** — branch off `main` for an urgent fix, PR into `main`,
  tag, then merge back into `develop`.

Pushing a `vX.Y.Z` tag triggers the release workflow, which publishes the GitHub
Release with notes from `CHANGELOG.md`. So a normal release is: merge the
`release/*` PR into `main`, then push the tag.

## Versioning (SemVer, driven by commits)

The commit type determines the bump:

| Prefix | Bump |
| --- | --- |
| `feat!:` or a `BREAKING CHANGE:` footer | major |
| `feat:` | minor |
| `fix:` / `perf:` | patch |
| `docs:` / `refactor:` / `test:` / `chore:` / `ci:` | none |

*Pre-1.0.0: `feat!` bumps minor, `feat` bumps patch.*

## Architecture

Dot-sourced PowerShell scripts (no module manifest). `setup.ps1` loads shared
utils/core, then dispatches per-group modules by name. `optimize` is a
data-driven tweak table selected by `-Profile` via the pure `Get-OptimizeTweaks`;
all state changes route through `Invoke-SystemConfig`, which supports `-WhatIf`.
See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and [docs/STRUCTURE.md](docs/STRUCTURE.md).

## Before opening a PR

- [ ] Lint (`.\tools\lint.ps1`), validation, and tests (`Invoke-Pester .\tests`) pass.
- [ ] New non-trivial logic (a branch, a parser, a heuristic) has a test.
- [ ] If you touched a documented behavior, update **both**
      [README.md](README.md) and [README.pt-BR.md](README.pt-BR.md) in the same
      PR — they must stay structurally identical (same sections, same content,
      one in English and one in Portuguese). If it's something a beginner would
      need explained (a new term, table column, or warning sign), update
      [docs/GUIDE.md](docs/GUIDE.md) and [docs/GUIDE.pt-BR.md](docs/GUIDE.pt-BR.md)
      too.
- [ ] Commit messages are short and imperative, prefixed by type, with no Claude
      co-author trailer.
- [ ] You noted any security or performance impact in the PR body.

## Scope

Keep changes focused: one logical change per PR. If you're not sure whether a
feature fits the project (e.g. it adds a new external dependency, or a large new
subsystem), open an issue to discuss it first rather than sending a large PR
speculatively.

Prefer the standard library. A new dependency is a decision, not a detail.
