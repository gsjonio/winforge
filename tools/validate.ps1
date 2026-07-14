#!/usr/bin/env pwsh

<#
    .SYNOPSIS
    Validate installation status of programs before running setup

    .DESCRIPTION
    Checks if the programs declared in each module are already installed,
    using multiple detection methods (executable, Get-Package, winget, registry).
    Program lists are read directly from the module files via AST parsing, so
    nothing is installed and the module functions are never executed.

    .PARAMETER Group
    Specific group to validate. Omit to validate all groups.

    .PARAMETER ShowDetails
    Show detailed detection information (method + version).

    .EXAMPLE
    .\validate.ps1 -Group dev -ShowDetails
#>

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("base", "dev", "gaming", "system", "optimize", "customize", "shell", "restore")]
    [string]$Group,

    [switch]$ShowDetails
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$utilsPath = Join-Path $repoRoot "src\utils"
$modulesPath = Join-Path $repoRoot "src\modules"

# Detection + reporting helpers live in the shared utils
. "$utilsPath\Logging.ps1"
. "$utilsPath\Validation.ps1"

# Extract the program hashtables (@{ Name=..; WingetId=..; Executable=.. }) from a
# module file without running it. Only literal string values are supported, which
# is all the modules use.
function Get-ModulePrograms {
    param([string]$ModuleFile)

    $ast = [System.Management.Automation.Language.Parser]::ParseFile($ModuleFile, [ref]$null, [ref]$null)
    $hashAsts = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.HashtableAst] }, $true)

    foreach ($hash in $hashAsts) {
        $entry = @{}
        foreach ($pair in $hash.KeyValuePairs) {
            $key = $pair.Item1.Value
            $valueAst = $pair.Item2.PipelineElements[0].Expression
            if ($valueAst -is [System.Management.Automation.Language.StringConstantExpressionAst]) {
                $entry[$key] = $valueAst.Value
            }
        }
        # A program entry is any hashtable that names a winget package
        if ($entry.ContainsKey("WingetId")) {
            [PSCustomObject]@{
                Name       = $entry["Name"]
                Executable = $entry["Executable"]
                WingetId   = $entry["WingetId"]
            }
        }
    }
}

# Safety assertions for the optimize module: the default 'safe' profile must
# never disable services that break core Windows (Store, System Restore,
# diagnostics, remote mgmt). Uses the pure Get-OptimizeTweaks selector, so it
# runs nothing and needs no elevation.
function Test-OptimizeSafety {
    $optimizeFile = Join-Path $modulesPath "optimize.ps1"
    if (-not (Test-Path -Path $optimizeFile)) {
        Write-Log "optimize.ps1 not found - skipping safety checks" -Level Warning
        return $true
    }
    . $optimizeFile

    $ok = $true
    $forbidden = @('VSS', 'StorSvc', 'DPS', 'WinRM', 'SysMain')

    Write-GroupHeader "OPTIMIZE - Safety Assertions"

    # 1. safe profile must not disable any critical service
    $safe = Get-OptimizeTweaks -Profile safe
    $hits = @($safe.Services | Where-Object { $_ -in $forbidden })
    if ($hits.Count -gt 0) {
        Write-Log "FAIL: safe profile disables: $($hits -join ', ')" -Level Error; $ok = $false
    }
    else {
        Write-Log "safe profile disables no critical service" -Level Success
    }

    # 2. VSS and StorSvc must never be disabled on any profile (removed entirely)
    $allSvc = (Get-OptimizeTweaks -Profile gaming).Services
    foreach ($svc in @('VSS', 'StorSvc')) {
        if ($svc -in $allSvc) {
            Write-Log "FAIL: $svc is disabled on some profile" -Level Error; $ok = $false
        }
    }

    # 3. the non-Store install lockdown must be opt-in (never in safe)
    if ($safe.Name -match 'non-Store') {
        Write-Log "FAIL: safe profile blocks non-Store installs" -Level Error; $ok = $false
    }

    # 4. SmartScreen must not be disabled (registry value absent from source)
    if ((Get-Content -Path $optimizeFile -Raw) -match 'SmartScreenEnabled') {
        Write-Log "FAIL: SmartScreenEnabled is still set by optimize" -Level Error; $ok = $false
    }

    if ($ok) { Write-Log "All optimize safety assertions passed" -Level Success }
    return $ok
}

# Runtime assertions for `-Group restore`: after a restore run, the critical
# services must not be Disabled and Game Bar capture must not be force-disabled.
# Queries live state, so it reflects this machine (run it after restore).
function Test-RestoreState {
    Write-GroupHeader "RESTORE - State Assertions"
    $ok = $true

    foreach ($name in @('StorSvc', 'VSS', 'DPS', 'SysMain')) {
        $svc = Get-Service -Name $name -ErrorAction SilentlyContinue
        if (-not $svc) {
            Write-Log "$name not present - skipped" -Level Skip
            continue
        }
        if ($svc.StartType -eq 'Disabled') {
            Write-Log "FAIL: $name is Disabled" -Level Error; $ok = $false
        }
        else {
            Write-Log "$name StartType=$($svc.StartType)" -Level Success
        }
    }

    $gdvr = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -ErrorAction SilentlyContinue
    if ($null -eq $gdvr) {
        Write-Log "AllowGameDVR absent (Windows default)" -Level Success
    }
    elseif ($gdvr.AllowGameDVR -eq 1) {
        Write-Log "AllowGameDVR = 1 (Game Bar capture enabled)" -Level Success
    }
    else {
        Write-Log "FAIL: AllowGameDVR = $($gdvr.AllowGameDVR) (capture disabled)" -Level Error; $ok = $false
    }

    if ($ok) { Write-Log "All restore state assertions passed" -Level Success }
    return $ok
}

Write-Host ""
Write-Host "Program Installation Validator" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

$groupsToValidate = if ($Group) { @($Group) } else {
    @("base", "dev", "gaming", "system", "optimize", "customize", "shell")
}

$grandTotal = @{ Total = 0; Installed = 0; NotInstalled = 0 }

foreach ($groupName in $groupsToValidate) {
    $moduleFile = Join-Path $modulesPath "$groupName.ps1"

    if (-not (Test-Path -Path $moduleFile)) {
        Write-Log "Module file not found: $moduleFile" -Level Error
        continue
    }

    Write-GroupHeader "$($groupName.ToUpper()) - Validation"

    $programs = @(Get-ModulePrograms -ModuleFile $moduleFile)

    if ($programs.Count -eq 0) {
        Write-Log "No installable programs in '$groupName' (configuration-only group)" -Level Skip
        continue
    }

    $result = Show-InstallationReport -Programs $programs -ShowDetails:$ShowDetails
    $grandTotal.Total += $result.Total
    $grandTotal.Installed += $result.Installed
    $grandTotal.NotInstalled += $result.NotInstalled
}

Write-Host ""
Write-Host "=======================================================================" -ForegroundColor Cyan
Write-Host "  OVERALL: $($grandTotal.Total) checked | $($grandTotal.Installed) installed | $($grandTotal.NotInstalled) missing" -ForegroundColor Cyan
Write-Host "=======================================================================" -ForegroundColor Cyan
Write-Host ""

# Run optimize safety assertions whenever optimize is in scope
if ($groupsToValidate -contains "optimize") {
    if (-not (Test-OptimizeSafety)) {
        Write-Host ""
        exit 1
    }
}

# Run restore state assertions when restore is requested explicitly
if ($groupsToValidate -contains "restore") {
    if (-not (Test-RestoreState)) {
        Write-Host ""
        exit 1
    }
}
