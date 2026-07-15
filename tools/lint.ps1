#!/usr/bin/env pwsh

<#
    .SYNOPSIS
    Lint PowerShell scripts using PSScriptAnalyzer

    .DESCRIPTION
    Checks all PowerShell scripts for style issues, security problems,
    and performance concerns.

    .PARAMETER Path
    Path to analyze (default: parent directory)

    .PARAMETER Severity
    Minimum severity level (Error, Warning, Information, default: Warning)

    .EXAMPLE
    .\tools\lint.ps1
    .\tools\lint.ps1 -Path .\src
    .\tools\lint.ps1 -Severity Error
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$Path = "..",

    [Parameter(Mandatory = $false)]
    [ValidateSet("Error", "Warning", "Information")]
    [string]$Severity = "Warning"
)

# Check if PSScriptAnalyzer is available
$analyzer = Get-Module -ListAvailable -Name PSScriptAnalyzer
if (-not $analyzer) {
    Write-Host "PSScriptAnalyzer is not installed." -ForegroundColor Red
    Write-Host ""
    Write-Host "Install with:" -ForegroundColor Yellow
    Write-Host "  Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  PowerShell Script Analysis" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Path: $Path" -ForegroundColor Gray
Write-Host "Severity: $Severity" -ForegroundColor Gray
Write-Host ""

# Import and run analyzer
Import-Module PSScriptAnalyzer -ErrorAction SilentlyContinue

$settingsPath = Join-Path $PSScriptRoot "..\.pslintrc"

$params = @{
    Path        = $Path
    Recurse     = $true
    Severity    = @($Severity, "Error") | Select-Object -Unique
    ErrorAction = "SilentlyContinue"
}
if (Test-Path -Path $settingsPath) { $params.Settings = $settingsPath }

$results = Invoke-ScriptAnalyzer @params

if ($results) {
    Write-Host "Found $($results.Count) issue(s):" -ForegroundColor Red
    Write-Host ""

    $results | Group-Object -Property Severity | ForEach-Object {
        Write-Host "$($_.Name):" -ForegroundColor $(
            if ($_.Name -eq "Error") { "Red" }
            elseif ($_.Name -eq "Warning") { "Yellow" }
            else { "Cyan" }
        )

        $_.Group | ForEach-Object {
            Write-Host "  [$($_.RuleName)] $($_.Message)" -ForegroundColor Gray
            Write-Host "    → $($_.ScriptPath):$($_.Line)" -ForegroundColor DarkGray
        }
        Write-Host ""
    }

    exit 1
}
else {
    Write-Host "✓ No issues found!" -ForegroundColor Green
    Write-Host ""
    exit 0
}
