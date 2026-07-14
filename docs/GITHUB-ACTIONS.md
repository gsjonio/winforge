# GitHub Actions CI/CD

Automated workflows for code quality, security, testing, and release management.

## Overview

This project uses **5 GitHub Actions workflows** for:

- **Code Quality**: PSScriptAnalyzer linting
- **Validation**: Project structure and documentation
- **Security**: Credential scanning and vulnerability checks
- **Documentation**: Markdown validation and statistics
- **Release**: Automated release creation from tags
- **Pull Requests**: Automated checks for incoming PRs

## Workflows

### 1. Code Quality (Lint)

**File**: `.github/workflows/lint.yml`

**Trigger**: Commits or PRs that modify PowerShell files

**What it does**:

- Installs PSScriptAnalyzer
- Runs linting against all `.ps1` files
- Reports errors (fails if found)
- Reports warnings (non-blocking)

**Status**: ✅ Enabled

**Command to run locally**:

```powershell
.\tools\lint.ps1
```

**Configuration**: `.pslintrc`

### 2. Validation

**File**: `.github/workflows/validate.yml`

**Trigger**: Every push and weekly schedule

**Checks**:

- ✓ All required files exist
- ✓ Project structure is correct
- ✓ CHANGELOG format is valid
- ✓ Git history follows conventions
- ✓ Version tags exist (v*.*.*)

**Status**: ✅ Enabled

**Useful for**: Ensuring project integrity

### 3. Release

**File**: `.github/workflows/release.yml`

**Trigger**: When a version tag is pushed (v*.*.*)

**What it does**:

1. Extracts version from tag
2. Reads CHANGELOG for release notes
3. Creates GitHub Release
4. Attaches release artifacts
5. Notifies project

**Status**: ✅ Enabled

**How to trigger**:

```bash
git tag -a v0.2.0 -m "Release 0.2.0"
git push origin v0.2.0
```

**Result**: Automatic GitHub Release created with CHANGELOG notes

### 4. Documentation

**File**: `.github/workflows/documentation.yml`

**Trigger**: Changes to markdown or docs

**Checks**:

- ✓ Markdown syntax validation
- ✓ Broken link detection
- ✓ README.md completeness
- ✓ Code statistics generation

**Status**: ✅ Enabled

**Useful for**: Maintaining documentation quality

### 5. Security Checks

**File**: `.github/workflows/security.yml`

**Trigger**: PowerShell changes + weekly schedule

**Checks**:

- ✓ PowerShell security rules (PSScriptAnalyzer)
- ✓ Dangerous patterns detection
- ✓ External dependency scanning
- ✓ Credential/secret scanning (TruffleHog)
- ✓ Credential validation in code

**Status**: ✅ Enabled

**Security rules checked**:

- PSAvoidUsingPlainTextForPassword
- PSAvoidUsingConvertToSecureStringWithPlainText
- PSAvoidUsingUsernameAndPasswordParams
- PSAvoidUsingInvokeExpression
- PSAvoidUsingComputerNameHardcoded

### 6. Pull Request Checks

**File**: `.github/workflows/pr-checks.yml`

**Trigger**: PR opened, updated, or reopened

**Checks**:

- ✓ PR title follows conventional commit format
- ✓ PR has description
- ✓ PR links to issues
- ✓ File changes are appropriate
- ✓ Commit messages are valid
- ✓ PR size is reasonable
- ✓ Auto-comment with summary

**Status**: ✅ Enabled

**PR Requirements**:

```text
Title format: type(scope): description

Allowed types:
  - feat: New feature
  - fix: Bug fix
  - docs: Documentation
  - style: Code style
  - refactor: Refactoring
  - perf: Performance
  - chore: Maintenance
  - test: Tests

Example: feat(installation): add Chocolatey fallback
```

## Workflow Status Badges

Add to README.md:

```markdown
[![Lint](https://github.com/Gustavo496/winforge/actions/workflows/lint.yml/badge.svg)](https://github.com/Gustavo496/winforge/actions/workflows/lint.yml)
[![Validation](https://github.com/Gustavo496/winforge/actions/workflows/validate.yml/badge.svg)](https://github.com/Gustavo496/winforge/actions/workflows/validate.yml)
[![Security](https://github.com/Gustavo496/winforge/actions/workflows/security.yml/badge.svg)](https://github.com/Gustavo496/winforge/actions/workflows/security.yml)
```

## Workflow Triggers

| Workflow | Push | PR | Schedule |
| ---------- | ------ | ----- | ---------- |
| Lint | ✓ | ✓ | - |
| Validate | ✓ | - | Weekly |
| Release | Tag (v*) | - | - |
| Documentation | ✓ | ✓ | - |
| Security | ✓ | ✓ | Weekly |
| PR Checks | - | ✓ | - |

## Setting Up Workflows

### Prerequisites

1. **GitHub Repository** with Actions enabled
2. **Default Branch**: `main`
3. **Secondary Branch** (optional): `develop`

### Enable Workflows

Workflows are enabled automatically when you push `.github/workflows/*.yml` files.

### Verify Activation

1. Go to repository **Actions** tab
2. Should see all 6 workflows listed
3. Click workflow to see runs

## Secrets & Configuration

### Required Secrets

None! All workflows use built-in GitHub tokens.

### Optional: Custom Configuration

Create `.markdownlint.json` for markdown linting:

```json
{
  "extends": "default",
  "MD003": { "style": "consistent" },
  "MD025": false,
  "MD033": false
}
```

## Advanced Usage

### Manual Workflow Trigger

Go to **Actions** → Select workflow → **Run workflow** button

### View Workflow Logs

1. Click workflow name
2. Click recent run
3. Click job name
4. View detailed logs

### Troubleshooting

**Workflow fails but should pass?**

Check:

1. Branch configuration (push to main/develop)
2. File changes match trigger conditions
3. Dependencies installed correctly
4. View workflow logs for details

## Future Enhancements

### Potential Additions

- [ ] **Testing**: Unit tests for PowerShell scripts
- [ ] **Coverage**: Code coverage reports
- [ ] **Build**: Artifact generation and storage
- [ ] **Deploy**: Automated deployment workflows
- [ ] **Scheduled Runs**: Daily security scans
- [ ] **Notifications**: Slack/Email alerts
- [ ] **Performance**: Speed benchmarking

### Example: Add Testing Workflow

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        shell: pwsh
        run: |
          # Implement Pester tests
          Invoke-Pester -Path tests/ -PassThru
```

## CI/CD Best Practices

1. ✅ **Keep workflows simple** - One job per workflow
2. ✅ **Fast feedback** - Quick execution (< 5 min)
3. ✅ **Clear messaging** - Informative job names
4. ✅ **Fail fast** - Stop on first error
5. ✅ **Parallel jobs** - Run independent checks in parallel
6. ✅ **Cache dependencies** - Reduce install time
7. ✅ **Document changes** - Update workflows with code changes

## External Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [PSScriptAnalyzer GitHub](https://github.com/PowerShell/PSScriptAnalyzer)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)

---

## Quick Reference

**View all workflows**: Go to **Actions** tab → Left sidebar

**View specific workflow runs**: Click workflow name

**View job details**: Click job in workflow run

**View step logs**: Click step in job

**Rerun workflow**: Click **Re-run jobs** button

---

For questions or issues, see [ARCHITECTURE.md](ARCHITECTURE.md) or [README.md](../README.md)
