#!/usr/bin/env pwsh

<#
    .SYNOPSIS
    Update installed applications via winget and/or Chocolatey.

    .DESCRIPTION
    Upgrades installed apps using the package managers winforge already relies
    on. This works even when the Microsoft Store app is broken, because winget's
    community source is independent of the Store.

    .PARAMETER Source
    Which package manager to use: winget, choco, or all (default).

    .PARAMETER DryRun
    List available updates without installing anything.

    .PARAMETER IncludeUnknown
    Also upgrade packages whose installed version winget cannot determine
    (often Store-registered apps). Ignored in -DryRun.

    .EXAMPLE
    .\tools\update.ps1                 # upgrade everything (winget + choco)
    .\tools\update.ps1 -DryRun         # just show what would be updated
    .\tools\update.ps1 -Source winget -IncludeUnknown
#>

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("all", "winget", "choco")]
    [string]$Source = "all",

    [switch]$DryRun,

    [switch]$IncludeUnknown
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot

. "$repoRoot\src\utils\Logging.ps1"
. "$repoRoot\src\utils\System.ps1"

function Test-CommandExists {
    param([string]$Name)
    return $null -ne (Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

Write-GroupHeader "APP UPDATE$(if ($DryRun) { ' (dry run)' })"

if (-not (Test-IsElevated)) {
    Write-Log "Not running as administrator - machine-wide apps may be skipped" -Level Warning
}

$ranAny = $false

# ---------- winget ----------
if ($Source -eq "all" -or $Source -eq "winget") {
    if (Test-CommandExists "winget") {
        $ranAny = $true
        if ($DryRun) {
            Write-Log "winget: available updates" -Level Info
            winget upgrade --accept-source-agreements
        }
        else {
            Write-Log "winget: upgrading all packages..." -Level Info
            $wingetArgs = @(
                "upgrade", "--all",
                "--accept-source-agreements", "--accept-package-agreements",
                "--silent"
            )
            if ($IncludeUnknown) { $wingetArgs += "--include-unknown" }
            winget @wingetArgs
            if ($LASTEXITCODE -eq 0) { Write-Log "winget upgrade completed" -Level Success }
            else { Write-Log "winget upgrade exited with code $LASTEXITCODE" -Level Warning }
        }
    }
    else {
        Write-Log "winget not found - skipping" -Level Skip
    }
}

# ---------- chocolatey ----------
if ($Source -eq "all" -or $Source -eq "choco") {
    if (Test-CommandExists "choco") {
        $ranAny = $true
        if ($DryRun) {
            Write-Log "chocolatey: outdated packages" -Level Info
            choco outdated
        }
        else {
            Write-Log "chocolatey: upgrading all packages..." -Level Info
            choco upgrade all -y --no-progress
            if ($LASTEXITCODE -eq 0) { Write-Log "chocolatey upgrade completed" -Level Success }
            else { Write-Log "chocolatey upgrade exited with code $LASTEXITCODE" -Level Warning }
        }
    }
    else {
        Write-Log "chocolatey not found - skipping" -Level Skip
    }
}

if (-not $ranAny) {
    Write-Log "No supported package manager found (winget or chocolatey)" -Level Error
    exit 1
}

Write-Host ""
Write-Log "Update run finished" -Level Success
