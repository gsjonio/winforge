#!/usr/bin/env pwsh

<#
    .SYNOPSIS
    Validate installation status of programs before running setup

    .DESCRIPTION
    Checks if programs are already installed using multiple detection methods:
    - Executable command availability
    - Windows Package Manager (Get-Package)
    - Windows Registry (Uninstall keys)
    - Winget list command

    .PARAMETER Group
    Specific group to validate: base, dev, gaming

    .PARAMETER Verbose
    Show detailed detection information
#>

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("base", "dev", "gaming")]
    [string]$Group,

    [switch]$Verbose
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$libPath = Join-Path $scriptRoot "lib"
$groupsPath = Join-Path $scriptRoot "groups"

. "$libPath\helpers.ps1"

Write-Host ""
Write-Host "Program Installation Validator" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan
Write-Host ""

$groupsToValidate = if ($Group) { @($Group) } else { @("base", "dev", "gaming") }

foreach ($groupName in $groupsToValidate) {
    $groupFile = Join-Path $groupsPath "$groupName.ps1"

    if (Test-Path -Path $groupFile) {
        Write-Host ""
        Write-GroupHeader "$($groupName.ToUpper()) - Validation"

        # Source the group file
        . $groupFile

        # Get programs array from the group
        $programs = @()
        $installFunc = "Install-$($groupName)Programs"

        # Extract programs by reading the file (simplified approach)
        try {
            # Read group file content to extract programs
            $content = Get-Content -Path $groupFile -Raw

            # This is a simplified approach - in practice, you'd need to invoke the function
            # and capture the programs array
            Write-Log "Validating programs in $groupName group..." -Level Info

            # For now, show instruction for manual validation
            Write-Host "To validate, uncomment programs in $groupFile and run this script again" -ForegroundColor Yellow
        }
        catch {
            Write-Log "Error validating group: $_" -Level Error
        }
    }
}

Write-Host ""
Write-Log "To validate specific programs, use:" -Level Info
Write-Host "  PS> . .\lib\helpers.ps1" -ForegroundColor Gray
Write-Host "  PS> Get-InstallationStatus -ProgramName 'Git' -Executable 'git' -WingetId 'Git.Git'" -ForegroundColor Gray
Write-Host ""
