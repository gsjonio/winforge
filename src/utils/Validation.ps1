# Program installation validation and detection

<#
.SYNOPSIS
    Tests whether a program is already installed.
.DESCRIPTION
    Detects an installed program using four methods in order: executable on PATH,
    Get-Package, 'winget list', and the uninstall registry keys. Returns on the
    first positive match, so a re-run of the installer is a no-op.
.PARAMETER ProgramName
    Display name to match (used for Get-Package and registry lookups).
.PARAMETER Executable
    Optional command name to probe on PATH.
.PARAMETER WingetId
    Optional winget package id to probe via 'winget list'.
.OUTPUTS
    System.Boolean. $true if detected by any method, otherwise $false.
.EXAMPLE
    Test-ProgramInstalled -ProgramName 'Git' -Executable 'git' -WingetId 'Git.Git'
#>
function Test-ProgramInstalled {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProgramName,

        [Parameter(Mandatory = $false)]
        [string]$Executable = $null,

        [Parameter(Mandatory = $false)]
        [string]$WingetId = $null
    )

    # Method 1: Check by executable command
    if ($Executable) {
        $cmdTest = Get-Command -Name $Executable -ErrorAction SilentlyContinue
        if ($null -ne $cmdTest) {
            Write-Log "$ProgramName found via executable: $Executable" -Level Skip
            return $true
        }
    }

    # Method 2: Check via Get-Package (Windows registry/AppX)
    $packageTest = @(
        Get-Package -Name "*$ProgramName*" -ErrorAction SilentlyContinue |
        Select-Object -First 1
    )

    if ($packageTest.Count -gt 0) {
        Write-Log "$ProgramName found in installed packages" -Level Skip
        return $true
    }

    # Method 3: Check via winget list
    if ($WingetId) {
        try {
            $wingetList = winget list --id $WingetId --exact 2>&1
            if ($LASTEXITCODE -eq 0 -and $wingetList -match [regex]::Escape($WingetId)) {
                Write-Log "$ProgramName found via winget: $WingetId" -Level Skip
                return $true
            }
        }
        catch {
            Write-Verbose "winget check failed for '$WingetId': $_"
        }
    }

    # Method 4: Check via registry (common installation path)
    $regPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    foreach ($regPath in $regPaths) {
        if (Test-Path -Path $regPath) {
            $regTest = Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue |
                Get-ItemProperty -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName -like "*$ProgramName*" } |
                Select-Object -First 1

            if ($regTest) {
                Write-Log "$ProgramName found in registry: $($regTest.DisplayName)" -Level Skip
                return $true
            }
        }
    }

    return $false
}

<#
.SYNOPSIS
    Returns detailed installation status for a program.
.DESCRIPTION
    Like Test-ProgramInstalled but returns a status object describing how the
    program was detected (executable, package, winget, or registry) plus details,
    for reporting rather than a boolean guard.
.PARAMETER ProgramName
    Display name to match.
.PARAMETER Executable
    Optional command name to probe on PATH.
.PARAMETER WingetId
    Optional winget package id to probe via 'winget list'.
.OUTPUTS
    System.Collections.Hashtable with Name, IsInstalled, DetectionMethod, Details.
.EXAMPLE
    Get-InstallationStatus -ProgramName 'Git' -Executable 'git' -WingetId 'Git.Git'
#>
function Get-InstallationStatus {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProgramName,

        [Parameter(Mandatory = $false)]
        [string]$Executable = $null,

        [Parameter(Mandatory = $false)]
        [string]$WingetId = $null
    )

    $status = @{
        Name            = $ProgramName
        IsInstalled     = $false
        DetectionMethod = "Not found"
        Details         = @()
    }

    # Check executable
    if ($Executable) {
        $cmdTest = Get-Command -Name $Executable -ErrorAction SilentlyContinue
        if ($cmdTest) {
            $status.IsInstalled = $true
            $status.DetectionMethod = "Executable"
            $status.Details += "Found: $($cmdTest.Source)"
            return $status
        }
    }

    # Check Get-Package
    $packageTest = @(Get-Package -Name "*$ProgramName*" -ErrorAction SilentlyContinue | Select-Object -First 1)
    if ($packageTest.Count -gt 0) {
        $status.IsInstalled = $true
        $status.DetectionMethod = "Package"
        $status.Details += "Version: $($packageTest[0].Version)"
        return $status
    }

    # Check winget list
    if ($WingetId) {
        try {
            $wingetList = winget list --id $WingetId --exact 2>&1
            if ($LASTEXITCODE -eq 0 -and $wingetList -match [regex]::Escape($WingetId)) {
                $status.IsInstalled = $true
                $status.DetectionMethod = "Winget"
                $status.Details += "ID: $WingetId"
                return $status
            }
        }
        catch {
            Write-Verbose "winget check failed for '$WingetId': $_"
        }
    }

    # Check registry
    $regPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    foreach ($regPath in $regPaths) {
        if (Test-Path -Path $regPath) {
            $regTest = Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue |
                Get-ItemProperty -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName -like "*$ProgramName*" } |
                Select-Object -First 1

            if ($regTest) {
                $status.IsInstalled = $true
                $status.DetectionMethod = "Registry"
                $status.Details += "DisplayName: $($regTest.DisplayName)"
                $status.Details += "Version: $($regTest.DisplayVersion)"
                return $status
            }
        }
    }

    return $status
}

function Show-InstallationReport {
    param(
        [Parameter(Mandatory = $true)]
        [array]$Programs,

        [Parameter(Mandatory = $false)]
        [switch]$ShowDetails
    )

    Write-Host ""
    Write-Host "=======================================================================" -ForegroundColor Cyan
    Write-Host "  INSTALLATION VALIDATION REPORT" -ForegroundColor Cyan
    Write-Host "=======================================================================" -ForegroundColor Cyan
    Write-Host ""

    $installed = 0
    $notInstalled = 0

    foreach ($program in $Programs) {
        $status = Get-InstallationStatus -ProgramName $program.Name -Executable $program.Executable -WingetId $program.WingetId

        if ($status.IsInstalled) {
            Write-Host "[+] $($status.Name)" -ForegroundColor Green
            if ($ShowDetails) {
                Write-Host "    Method: $($status.DetectionMethod)" -ForegroundColor Gray
                foreach ($detail in $status.Details) {
                    Write-Host "    $detail" -ForegroundColor Gray
                }
            }
            $installed++
        }
        else {
            Write-Host "[x] $($status.Name)" -ForegroundColor Red
            if ($ShowDetails) {
                Write-Host "    Not found" -ForegroundColor Gray
            }
            $notInstalled++
        }
    }

    Write-Host ""
    Write-Host "=======================================================================" -ForegroundColor Cyan
    Write-Host "  Total: $($installed + $notInstalled) | Installed: $installed | Not Installed: $notInstalled" -ForegroundColor Cyan
    Write-Host "=======================================================================" -ForegroundColor Cyan
    Write-Host ""

    return @{
        Total        = $installed + $notInstalled
        Installed    = $installed
        NotInstalled = $notInstalled
    }
}
