# Restore group: reverse the changes made by the optimize (and related) modules
# back to Windows factory defaults. This is the escape hatch — it is NOT part of
# the default run and executes only on an explicit `-Group restore`.

function Install-RestorePrograms {
    Write-GroupHeader "RESTORE - Skipped (configuration only)"
    Write-Log "This group restores defaults, no programs to install" -Level Info
}

<#
.SYNOPSIS
    Restores services and policy keys changed by winforge back to Windows defaults.
.DESCRIPTION
    Reverses the destructive/aggressive changes the optimize module can make:
    re-enables services (StorSvc, VSS, DPS, SysMain, WinRM and the rest optimize
    can disable) to their documented Windows 11 StartType and starts the ones
    that should run; and reverts policy/registry keys (Game Bar capture,
    SmartScreen, the non-Store install lockdown, Shadow Copies) to default —
    preferring to remove a policy value so Windows falls back on its own default.

    Idempotent and safe to re-run. Supports -WhatIf to preview every action
    without changing anything. Requires administrator privileges (services and
    HKLM policies). Telemetry (DiagTrack) stays disabled unless -RestoreTelemetry
    is given, since re-enabling it is privacy-sensitive.
.PARAMETER RestoreTelemetry
    Also re-enable the DiagTrack telemetry service (default: left disabled).
.PARAMETER EnableSystemRestore
    After restoring VSS, turn System Restore protection back on for C:\.
.EXAMPLE
    Restore-SafeDefaults -WhatIf         # preview, change nothing
.EXAMPLE
    Restore-SafeDefaults -EnableSystemRestore
#>
function Restore-SafeDefaults {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$RestoreTelemetry,
        [switch]$EnableSystemRestore
    )

    Write-GroupHeader "RESTORE - Reverting to Windows defaults"

    # Service -> documented Windows 11 clean-install default. 'Manual' covers
    # trigger-started services (they start on demand); the ones marked Start are
    # started immediately. Kept in sync with optimize.ps1 via the drift check below.
    $serviceDefaults = [ordered]@{
        StorSvc            = @{ StartType = 'Manual'; Start = $true }   # Microsoft Store / licensing (#9)
        VSS                = @{ StartType = 'Manual'; Start = $false }  # System Restore / shadow copies (#8)
        DPS                = @{ StartType = 'Automatic'; Start = $true }
        SysMain            = @{ StartType = 'Automatic'; Start = $true }
        WinRM              = @{ StartType = 'Manual'; Start = $false }
        dmwappushservice   = @{ StartType = 'Manual'; Start = $false }
        OneSyncSvc         = @{ StartType = 'Manual'; Start = $false }
        HvHost             = @{ StartType = 'Manual'; Start = $false }
        SharedAccess       = @{ StartType = 'Manual'; Start = $false }
        CscService         = @{ StartType = 'Manual'; Start = $false }
        TabletInputService = @{ StartType = 'Manual'; Start = $false }
        TrkWks             = @{ StartType = 'Automatic'; Start = $true }
        stisvc             = @{ StartType = 'Manual'; Start = $false }
        WMPNetworkSvc      = @{ StartType = 'Manual'; Start = $false }
        lfsvc              = @{ StartType = 'Manual'; Start = $false }
    }

    foreach ($name in $serviceDefaults.Keys) {
        $def = $serviceDefaults[$name]
        if ($PSCmdlet.ShouldProcess($name, "Restore service (StartType=$($def.StartType), Start=$($def.Start))")) {
            $action = {
                $svc = Get-Service -Name $name -ErrorAction SilentlyContinue
                if ($svc) {
                    Set-Service -Name $name -StartupType $def.StartType -ErrorAction SilentlyContinue
                    if ($def.Start) { Start-Service -Name $name -ErrorAction SilentlyContinue }
                }
                else {
                    Write-Log "Service '$name' not present - skipped" -Level Skip
                }
            }.GetNewClosure()
            Invoke-SystemConfig "Restore service $name -> $($def.StartType)" $action
        }
    }

    # DiagTrack (telemetry) is opt-in — re-enabling it is privacy-sensitive.
    if ($RestoreTelemetry) {
        if ($PSCmdlet.ShouldProcess('DiagTrack', 'Restore telemetry service (Automatic)')) {
            Invoke-SystemConfig "Restore DiagTrack (telemetry) -> Automatic" {
                Get-Service -Name 'DiagTrack' -ErrorAction SilentlyContinue | Set-Service -StartupType Automatic -ErrorAction SilentlyContinue
            }
        }
    }
    else {
        Write-Log "DiagTrack (telemetry) left disabled - pass -RestoreTelemetry to re-enable" -Level Skip
    }

    # Policy / registry reverts. Prefer removing a policy value so Windows uses
    # its own default rather than hardcoding one.
    $registryReverts = @(
        @{ Desc = 'Re-enable Game Bar capture (remove AllowGameDVR policy)'; Op = {
                # Defensive: winforge does not set AllowGameDVR, but AllowGameDVR=0
                # is a common breakage that greys out Game Bar capture.
                Remove-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR"
            } }
        @{ Desc = 'Re-enable Game Bar app capture toggles'; Op = {
                Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" "AppCaptureEnabled" 1 "DWORD"
                Set-RegistryValue "HKCU:\System\GameConfigStore" "GameDVR_Enabled" 1 "DWORD"
            } }
        @{ Desc = 'Restore SmartScreen (remove disable keys)'; Op = {
                Remove-RegistryValue "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer" "SmartScreenEnabled"
                Remove-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost" "EnableWebContentEvaluation"
            } }
        @{ Desc = 'Allow non-Store app installation (remove lockdown)'; Op = {
                Remove-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\AppInstaller" "EnableAppsInstallationFromNonStoreLocation"
            } }
        @{ Desc = 'Re-enable Shadow Copies (remove DisableShadowCopy)'; Op = {
                Remove-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\System" "DisableShadowCopy"
            } }
    )

    foreach ($revert in $registryReverts) {
        if ($PSCmdlet.ShouldProcess($revert.Desc, 'Revert registry')) {
            Invoke-SystemConfig $revert.Desc $revert.Op
        }
    }

    # System Restore recommendation (never forced silently).
    Write-Log "VSS restored, but System Restore protection may still be OFF." -Level Warning
    if ($EnableSystemRestore) {
        if ($PSCmdlet.ShouldProcess('C:\', 'Enable System Restore')) {
            Invoke-SystemConfig "Enable System Restore on C:\" {
                Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
            }
        }
    }
    else {
        Write-Log "Run 'Enable-ComputerRestore -Drive C:\' (or pass -EnableSystemRestore) to turn it back on" -Level Info
    }

    # Drift check: every service optimize can disable must have a restore default.
    $optimizeFile = Join-Path $PSScriptRoot "optimize.ps1"
    if (Test-Path -Path $optimizeFile) {
        . $optimizeFile
        $optimizeServices = @((Get-OptimizeTweaks -Profile gaming).Services | Where-Object { $_ })
        # DiagTrack is handled separately (opt-in via -RestoreTelemetry).
        $handled = @($serviceDefaults.Keys) + 'DiagTrack'
        $missing = @($optimizeServices | Where-Object { $_ -notin $handled })
        if ($missing.Count -gt 0) {
            Write-Log "DRIFT: optimize disables services with no restore default: $($missing -join ', ')" -Level Warning
        }
    }

    Write-Log "Restore completed" -Level Success
}

<#
.SYNOPSIS
    Entry point for `-Group restore`; restores Windows defaults.
.DESCRIPTION
    Thin wrapper matching the setup.ps1 dispatch convention. Forwards to
    Restore-SafeDefaults and supports -WhatIf. Never runs in the default
    all-groups execution — only on an explicit `-Group restore`.
.PARAMETER RestoreTelemetry
    Also re-enable the DiagTrack telemetry service.
.PARAMETER EnableSystemRestore
    Turn System Restore protection back on for C:\ after restoring VSS.
.EXAMPLE
    Set-RestoreConfiguration -WhatIf
#>
function Set-RestoreConfiguration {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$RestoreTelemetry,
        [switch]$EnableSystemRestore
    )

    Restore-SafeDefaults @PSBoundParameters
}
