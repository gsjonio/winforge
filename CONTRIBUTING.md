# Contributing

winforge uses a **git-flow** branching model, and `main` is protected: it only
accepts changes through pull requests.

## Branch model

| Branch | Purpose |
| --- | --- |
| `main` | Production. Protected, PR-only, tagged releases. Never pushed to directly. |
| `develop` | Integration branch for day-to-day work. |
| `feature/*` | New features and non-urgent changes. Branch off `develop`. |
| `fix/*` | Bug fixes. Branch off `develop`. |
| `release/*` | Release preparation. Branch off `develop`, merge to `main` + tag. |
| `hotfix/*` | Urgent production fixes. Branch off `main`. |

## Workflow

1. **Open an issue** describing the change before starting.
2. **Branch** off `develop` (or `main` for a hotfix):

   ```bash
   git checkout develop && git pull
   git checkout -b feature/my-change
   ```

3. **Commit** using [Conventional Commits](https://www.conventionalcommits.org/)
   prefixes: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `ci:`.
4. **Push** the branch and **open a pull request**:

   ```bash
   git push -u origin feature/my-change
   gh pr create --base develop --fill
   ```

   Reference the issue in the PR body (`Closes #N`).
5. **Merge** with **squash** or **rebase** — `main` and `develop` keep a linear
   history.

## `main` branch protection

The `Main Branch Protection` ruleset enforces:

- **Pull request required** — no direct pushes to `main`.
- **Linear history** — merge via squash or rebase, no merge commits.
- **No force-push, no deletion.**

It is solo-friendly (0 required approvals), so the maintainer can self-merge.
There are no bypass actors; even admins go through a PR.

## Releases

Cut a release from `main`, then tag it:

```bash
git tag -a vX.Y.Z -m "vX.Y.Z"
git push origin vX.Y.Z
```

Pushing the tag triggers the Release workflow, which publishes the GitHub
release from `CHANGELOG.md`. Follow [Semantic Versioning](https://semver.org):
`MAJOR.MINOR.PATCH`.

## Before opening a PR

```powershell
.\tools\lint.ps1        # PSScriptAnalyzer
.\tools\validate.ps1    # installation detection sanity
Invoke-Pester .\tests   # unit tests (requires Pester 5+)
```

CI also runs lint, validation, security, and documentation checks on every PR.
