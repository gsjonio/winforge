# Setup GitHub Branch Protection Rules
# Run this script after pushing to GitHub to configure branch protection

param(
    [Parameter(Mandatory = $false)]
    [string]$Owner,

    [Parameter(Mandatory = $false)]
    [string]$Repo,

    [switch]$SkipValidation
)

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "GitHub Branch Protection Setup" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Check GitHub CLI
Write-Host "Checking GitHub CLI..." -ForegroundColor Yellow
$ghVersion = gh --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ GitHub CLI not found" -ForegroundColor Red
    Write-Host "  Install from: https://cli.github.com/" -ForegroundColor Gray
    exit 1
}
Write-Host "✓ GitHub CLI installed: $ghVersion" -ForegroundColor Green
Write-Host ""

# Check authentication
Write-Host "Checking GitHub authentication..." -ForegroundColor Yellow
gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Not authenticated with GitHub" -ForegroundColor Red
    Write-Host "  Run: gh auth login" -ForegroundColor Gray
    exit 1
}
Write-Host "✓ Authenticated" -ForegroundColor Green
Write-Host ""

# Get repo info if not provided
if (-not $Owner -or -not $Repo) {
    Write-Host "Getting repository information..." -ForegroundColor Yellow
    $repoUrl = git remote get-url origin
    if ($repoUrl -match "github.com[:/](.+)/(.+?)(.git)?$") {
        $Owner = $matches[1]
        $Repo = $matches[2] -replace "\.git$"
    } else {
        Write-Host "✗ Could not determine repository" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Repository: $Owner/$Repo" -ForegroundColor Green
Write-Host ""

if (-not $SkipValidation) {
    Write-Host "About to configure branch protection for:" -ForegroundColor Yellow
    Write-Host "  Owner: $Owner" -ForegroundColor Cyan
    Write-Host "  Repo: $Repo" -ForegroundColor Cyan
    Write-Host "  Branch: main" -ForegroundColor Cyan
    Write-Host ""

    $confirm = Read-Host "Continue? (y/n)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Host "Cancelled" -ForegroundColor Red
        exit 0
    }
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Configuring Branch Protection..." -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Documentation
Write-Host "📖 For detailed configuration, see: docs/BRANCH-PROTECTION.md" -ForegroundColor Cyan
Write-Host ""

Write-Host "Manual Configuration (via GitHub UI):" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Go to: https://github.com/$Owner/$Repo/settings/branches" -ForegroundColor White
Write-Host ""
Write-Host "2. Under 'Branch protection rules' → 'Add rule'" -ForegroundColor White
Write-Host ""
Write-Host "3. Configure for branch: main" -ForegroundColor White
Write-Host "   ✓ Require a pull request before merging" -ForegroundColor Cyan
Write-Host "   ✓ Require 1 approval" -ForegroundColor Cyan
Write-Host "   ✓ Require status checks:" -ForegroundColor Cyan
Write-Host "     - Lint" -ForegroundColor Gray
Write-Host "     - Validate" -ForegroundColor Gray
Write-Host "     - Security" -ForegroundColor Gray
Write-Host "     - Documentation" -ForegroundColor Gray
Write-Host "   ✓ Require linear history" -ForegroundColor Cyan
Write-Host "   ✓ Dismiss stale pull request approvals" -ForegroundColor Cyan
Write-Host "   ✓ Require approval of most recent push" -ForegroundColor Cyan
Write-Host "   ✓ Restrict who can push (optional)" -ForegroundColor Cyan
Write-Host "   ✓ Allow force pushes: Disabled" -ForegroundColor Cyan
Write-Host "   ✓ Allow deletions: Disabled" -ForegroundColor Cyan
Write-Host "   ✓ Automatically delete head branches" -ForegroundColor Cyan
Write-Host ""

Write-Host "Merge Settings (Settings → General):" -ForegroundColor Yellow
Write-Host "   ✓ Allow squash merging (recommended)" -ForegroundColor Cyan
Write-Host "   ✓ Disable merge commits" -ForegroundColor Cyan
Write-Host "   ✓ Disable rebase merging" -ForegroundColor Cyan
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "Setup Instructions Complete!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host ""

Write-Host "✓ Configure the rules above in GitHub UI" -ForegroundColor Green
Write-Host "✓ All GitHub Actions will run automatically on PRs" -ForegroundColor Green
Write-Host "✓ Commits must follow conventional format" -ForegroundColor Green
Write-Host "✓ All status checks must pass before merging" -ForegroundColor Green
Write-Host ""

Write-Host "Need help? See docs/BRANCH-PROTECTION.md" -ForegroundColor Cyan
Write-Host ""
