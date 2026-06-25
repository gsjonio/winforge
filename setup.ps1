#!/usr/bin/env pwsh

<#
    .SYNOPSIS
    Windows Post-Format Automation Setup Script

    .DESCRIPTION
    Automates installation and configuration of Windows after a clean format.
    Runs selectively by group or executes all groups.

    .PARAMETER Group
    Specific group to execute: base, dev, gaming, or omit for all.
    Examples:
      .\setup.ps1 -Group dev
      .\setup.ps1  # executes all groups

    .PARAMETER SkipElevation
    Skip elevation check (for testing in current context).
#>

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("base", "dev", "gaming", "system", "optimize", "customize", "shell")]
    [string]$Group,

    [switch]$SkipElevation
)

# ========== Initialization ==========

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$srcPath = Join-Path $scriptRoot "src"
$corePath = Join-Path $srcPath "core"
$utilsPath = Join-Path $srcPath "utils"
$modulesPath = Join-Path $srcPath "modules"

# ========== Load Libraries (in order) ==========

# 1. Logging (needed by everything else)
. "$utilsPath\Logging.ps1"

# 2. System utilities (elevation, admin checks)
. "$utilsPath\System.ps1"

if (-not $SkipElevation) {
    Request-Elevation
}

# 3. Validation (installation detection)
. "$utilsPath\Validation.ps1"

# 4. Registry utilities (system configuration)
. "$utilsPath\Registry.ps1"

# 5. Core installation logic
. "$corePath\Installation.ps1"

Write-Host ""
Write-Host "Windows Post-Format Automation Setup" -ForegroundColor Cyan
Write-Host "PowerShell 7+" -ForegroundColor Cyan
Write-Host ""

if (Test-IsElevated) {
    Write-Log "Running with administrator privileges" -Level Success
}
else {
    Write-Log "WARNING: Not running as administrator" -Level Warning
    Write-Host ""
    Write-Host "Some features require administrator privileges (fonts, registry, services)." -ForegroundColor Yellow
    Write-Host "Run as admin with: powershell -NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -ForegroundColor Gray
    Write-Host ""

    # Try to ask for confirmation, but continue if in NonInteractive mode
    try {
        $continueAnyway = Read-Host "Continue without admin? (y/n)" -ErrorAction Stop
        if ($continueAnyway -ne "y" -and $continueAnyway -ne "Y") {
            Write-Log "Cancelled by user" -Level Info
            exit 0
        }
    }
    catch {
        Write-Log "NonInteractive mode detected, continuing without admin..." -Level Info
    }
}

# ========== Execute Groups ==========

$groupsToRun = @()

if ($Group) {
    $groupsToRun = @($Group)
    Write-Log "Running group: $Group" -Level Info
}
else {
    $groupsToRun = @("base", "dev", "gaming", "system", "optimize", "customize", "shell")
    Write-Log "Running all groups" -Level Info
}

foreach ($groupName in $groupsToRun) {
    $moduleFile = Join-Path $modulesPath "$groupName.ps1"

    if (Test-Path -Path $moduleFile) {
        try {
            . $moduleFile

            # Install programs
            if (Get-Command -Name "Install-$groupName`Programs" -ErrorAction SilentlyContinue) {
                & "Install-$groupName`Programs"
            }

            # Apply configuration
            if (Get-Command -Name "Set-$groupName`Configuration" -ErrorAction SilentlyContinue) {
                & "Set-$groupName`Configuration"
            }
        }
        catch {
            Write-Log "Error executing group '$groupName': $_" -Level Error
        }
    }
    else {
        Write-Log "Module file not found: $moduleFile" -Level Error
    }
}

# ========== Summary ==========

Write-Host ""
Write-Log "Setup completed" -Level Success
Write-Host ""
