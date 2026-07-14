# Optimize group: Windows system optimization and privacy tweaks
#
# Tweaks are declared as a data-driven table, each tagged with a risk tier.
# Profiles are cumulative:  safe  ⊂  desktop  ⊂  gaming.
#   safe    - privacy/telemetry, visual perf, storage, harmless service disables.
#   desktop - safe + power/24-7 tweaks (no sleep/hibernate, high performance).
#   gaming  - desktop + network/latency tweaks + aggressive service disables.
# Destructive tweaks were removed entirely (VSS #8, StorSvc #9, SmartScreen #11).

function Install-OptimizePrograms {
    Write-GroupHeader "OPTIMIZE - Skipped (configuration only)"
    Write-Log "This group contains system optimizations, no programs to install" -Level Info
}

<#
.SYNOPSIS
    Returns the optimize tweak descriptors that apply to a profile.
.DESCRIPTION
    Pure/read-only: builds the tweak table and filters it by the profile's tiers.
    The Action scriptblocks are returned, not executed, so this is safe to call
    for inspection or validation without elevation or side effects. Tiers are
    cumulative (safe ⊂ desktop ⊂ gaming). Service-disabling tweaks carry a
    'Services' key so callers can reason about what they touch.
.PARAMETER Profile
    safe (default), desktop, or gaming.
.EXAMPLE
    Get-OptimizeTweaks -Profile safe | Select-Object Name, Tier
.EXAMPLE
    # Assert the safe profile never disables a critical service
    (Get-OptimizeTweaks -Profile safe).Services -notcontains 'StorSvc'
#>
function Get-OptimizeTweaks {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidAssignmentToAutomaticVariable', 'Profile',
        Justification = 'Public -Profile selector; the automatic $PROFILE variable is not used here.')]
    [CmdletBinding()]
    param(
        [ValidateSet('safe', 'desktop', 'gaming')]
        [string]$Profile = 'safe'
    )

    # Cumulative tiers: desktop includes safe; gaming includes safe + desktop.
    $tiersFor = @{
        safe    = @('safe')
        desktop = @('safe', 'desktop')
        gaming  = @('safe', 'desktop', 'gaming')
    }

    $tweaks = @(
        # ==================== SAFE: privacy & telemetry ====================
        @{ Name = 'Disable diagnostic data collection'; Tier = 'safe'; Action = {
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" "Enabled" 0 "DWORD"
                Set-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowDiagnosticData" 0 "DWORD"
            } }
        @{ Name = 'Disable background application activity'; Tier = 'safe'; Action = {
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserExperienceSettings_IsMigratedToNewSettingsModel" 1 "DWORD"
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Settings\Privacy\General" "AllowTailoredExperiences" 0 "DWORD"
            } }
        @{ Name = 'Disable Find My Device'; Tier = 'safe'; Action = {
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\FindMyDevice" "LocationSyncEnabled" 0 "DWORD"
            } }
        @{ Name = 'Disable activity history sync'; Tier = 'safe'; Action = {
                Set-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\System" "EnableActivityFeed" 0 "DWORD"
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\ActivityHistory" "EnableActivityFeed" 0 "DWORD"
            } }
        @{ Name = 'Disable Problem Steps Recorder'; Tier = 'safe'; Action = {
                Set-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\AppCompat" "DisablePCA" 1 "DWORD"
            } }
        @{ Name = 'Disable update notifications'; Tier = 'safe'; Action = {
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.UpdateNotification" "Enabled" 0 "DWORD"
            } }
        @{ Name = 'Disable File Explorer insights'; Tier = 'safe'; Action = {
                Set-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\Explorer" "DisableQuickAccess" 1 "DWORD"
            } }
        @{ Name = 'Disable recent documents history in Start menu'; Tier = 'safe'; Action = {
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowRecent" 0 "DWORD"
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowFrequent" 0 "DWORD"
            } }
        @{ Name = 'Disable settings sync'; Tier = 'safe'; Action = {
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync" "SyncPolicy" 0 "DWORD"
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" "Enabled" 0 "DWORD"
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\AppSync" "Enabled" 0 "DWORD"
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" "Enabled" 0 "DWORD"
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\StartLayout" "Enabled" 0 "DWORD"
            } }
        @{ Name = 'Disable Cortana'; Tier = 'safe'; Action = {
                Set-RegistryValue "HKCU:\Software\Microsoft\Personalization\Settings" "AcceptedPrivacyPolicy" 0 "DWORD"
                Set-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0 "DWORD"
            } }
        @{ Name = 'Disable consumer experiences'; Tier = 'safe'; Action = {
                Set-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" "DisableTailoredExperiencesNotification" 1 "DWORD"
                Set-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" "DisableWindowsSpotlightFeatures" 1 "DWORD"
            } }
        @{ Name = 'Disable automatic driver installation'; Tier = 'safe'; Action = {
                Set-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\Device Metadata" "PreventDeviceMetadataFromNetwork" 1 "DWORD"
            } }

        # ==================== SAFE: harmless service disables ====================
        # NOTE: StorSvc (#9) and VSS (#8) are intentionally absent — disabling them
        # breaks the Microsoft Store and System Restore respectively.
        @{ Name = 'Disable diagnostic tracking service'; Tier = 'safe'; Services = @('DiagTrack'); Action = {
                Get-Service -Name "DiagTrack" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
            } }
        @{ Name = 'Disable device metadata sync'; Tier = 'safe'; Services = @('dmwappushservice'); Action = {
                Get-Service -Name "dmwappushservice" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
            } }
        @{ Name = 'Disable OneDrive sync service'; Tier = 'safe'; Services = @('OneSyncSvc'); Action = {
                Get-Service -Name "OneSyncSvc" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
            } }
        @{ Name = 'Disable Hyper-V Host service'; Tier = 'safe'; Services = @('HvHost'); Action = {
                Get-Service -Name "HvHost" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
            } }
        @{ Name = 'Disable Internet Connection Sharing'; Tier = 'safe'; Services = @('SharedAccess'); Action = {
                Get-Service -Name "SharedAccess" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
            } }
        @{ Name = 'Disable offline files'; Tier = 'safe'; Services = @('CscService'); Action = {
                Get-Service -Name "CscService" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
            } }
        @{ Name = 'Disable tablet input service'; Tier = 'safe'; Services = @('TabletInputService'); Action = {
                Get-Service -Name "TabletInputService" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
            } }
        @{ Name = 'Disable distributed link tracking client'; Tier = 'safe'; Services = @('TrkWks'); Action = {
                Get-Service -Name "TrkWks" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
            } }
        @{ Name = 'Disable still image events service'; Tier = 'safe'; Services = @('stisvc'); Action = {
                Get-Service -Name "stisvc" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
            } }
        @{ Name = 'Disable Windows Media Player network sharing'; Tier = 'safe'; Services = @('WMPNetworkSvc'); Action = {
                Get-Service -Name "WMPNetworkSvc" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
            } }
        @{ Name = 'Disable location framework service'; Tier = 'safe'; Services = @('lfsvc'); Action = {
                Get-Service -Name "lfsvc" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
            } }

        # ==================== SAFE: visual performance ====================
        @{ Name = 'Disable animations and transitions'; Tier = 'safe'; Action = {
                Set-RegistryValue "HKCU:\Control Panel\Desktop" "UserPreferencesMask" "9012038010000000" "String"
            } }
        @{ Name = 'Disable visual effects for performance'; Tier = 'safe'; Action = {
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ListviewAlphaEnabled" 0 "DWORD"
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAnimations" 0 "DWORD"
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\Dwm.Exe" "UseDeferredScheduling" 0 "DWORD"
            } }
        @{ Name = 'Disable window transparency and blur'; Tier = 'safe'; Action = {
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 0 "DWORD"
                Set-RegistryValue "HKLM:\Software\Microsoft\Windows\DWM" "ForceEffectMode" 0 "DWORD"
            } }
        @{ Name = 'Disable tooltip animations'; Tier = 'safe'; Action = {
                Set-RegistryValue "HKCU:\Control Panel\Desktop" "MenuShowDelay" "0" "String"
            } }

        # ==================== SAFE: storage ====================
        @{ Name = 'Configure automatic temp files cleanup'; Tier = 'safe'; Action = {
                # Enable Storage Sense (automatic cleanup)
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" "01" 1 "DWORD"
                # Cleanup temp files older than 1 day
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" "04" 1 "DWORD"
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" "08" 0 "DWORD"
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" "32" 0 "DWORD"
                # Cleanup recycle bin older than 30 days
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" "256" 30 "DWORD"
                Write-Log "Storage Sense configured for automatic cleanup" -Level Info
            } }
        @{ Name = 'Enable automatic TRIM for SSD'; Tier = 'safe'; Action = {
                # NOTE: VSS / System Restore is intentionally NOT disabled (issue #8).
                fsutil behavior set DisableDeleteNotify 0 2>&1 | Out-Null
                Write-Log "Automatic TRIM enabled - SSD performance optimized" -Level Info
            } }

        # ==================== DESKTOP: power / 24-7 ====================
        @{ Name = 'Disable Multimedia Class Scheduler (RAM >= 8GB)'; Tier = 'desktop'; Action = {
                $ramGB = [math]::Round((Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 0)
                if ($ramGB -ge 8 -and (Get-Command Disable-MMAgent -ErrorAction SilentlyContinue)) {
                    Disable-MMAgent -mc
                }
            } }
        @{ Name = 'Force High Performance power plan'; Tier = 'desktop'; Action = {
                try {
                    powercfg /setactive 8c5e7fda-e8bf-45a6-a6cc-4b3c2b40b294 2>&1 | Out-Null
                    Write-Log "High Performance power plan activated" -Level Info
                }
                catch {
                    Write-Log "Could not set power plan: $_" -Level Warning
                }
            } }
        @{ Name = 'Disable USB Selective Suspend'; Tier = 'desktop'; Action = {
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\PowerShell" "DisableUSBSelectiveSuspend" 1 "DWORD"
                Set-RegistryValue "HKLM:\System\CurrentControlSet\Services\usbhub\Parameters" "DisableSelectiveSuspend" 1 "DWORD"
                Write-Log "USB Selective Suspend disabled - instant peripherals response" -Level Info
            } }
        @{ Name = 'Disable Sleep/Hibernate (PC 24/7)'; Tier = 'desktop'; Action = {
                powercfg /change monitor-timeout-ac 0 2>&1 | Out-Null
                powercfg /change disk-timeout-ac 0 2>&1 | Out-Null
                powercfg /change standby-timeout-ac 0 2>&1 | Out-Null
                powercfg /h off 2>&1 | Out-Null
                Write-Log "Sleep/Hibernate disabled - PC stays fully active" -Level Info
            } }
        @{ Name = 'Disable Fast Startup'; Tier = 'desktop'; Action = {
                Set-RegistryValue "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" "HibernationFile" 0 "DWORD"
                Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_PowerButtonAction" 0 "DWORD"
                powercfg /change hybrid-sleep off 2>&1 | Out-Null
                Write-Log "Fast Startup disabled (prevents potential conflicts)" -Level Info
            } }

        # ==================== GAMING: network + aggressive services ====================
        @{ Name = 'Disable QoS Throttling (network bandwidth)'; Tier = 'gaming'; Action = {
                Set-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\Psched" "NonBestEffortLimit" 0 "DWORD"
                Write-Log "QoS Throttling disabled - full bandwidth available" -Level Info
            } }
        @{ Name = 'Remove network throttling limit'; Tier = 'gaming'; Action = {
                $throttlePath = "HKLM:\SYSTEM\CurrentControlSet\Services\Psched\Parameters"
                # -1 is written as the unsigned DWORD 0xFFFFFFFF; passing 0xFFFFFFFF (a
                # UInt32) overflows Int32 DWORD coercion and can write the wrong value.
                $maxDword = -1
                Set-RegistryValue $throttlePath "NetworkThrottlingIndex" $maxDword "DWORD"
                # Read-back validation: a DWORD of 0xFFFFFFFF reads back as -1.
                $written = (Get-ItemProperty -Path $throttlePath -Name "NetworkThrottlingIndex" -ErrorAction SilentlyContinue).NetworkThrottlingIndex
                if ($written -ne -1) {
                    Write-Log "NetworkThrottlingIndex expected 0xFFFFFFFF but read back '$written'" -Level Warning
                }
                else {
                    Write-Log "Network throttling removed - faster updates and downloads" -Level Info
                }
            } }
        @{ Name = 'Disable SysMain (Prefetch)'; Tier = 'gaming'; Services = @('SysMain'); Action = {
                Get-Service -Name "SysMain" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
            } }
        @{ Name = 'Disable performance diagnostics (DPS)'; Tier = 'gaming'; Services = @('DPS'); Action = {
                Get-Service -Name "DPS" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
            } }
        @{ Name = 'Disable Windows Remote Management (WinRM)'; Tier = 'gaming'; Services = @('WinRM'); Action = {
                Get-Service -Name "WinRM" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
            } }
        @{ Name = 'Block installation of apps from non-Store locations'; Tier = 'gaming'; Action = {
                # Blocks sideloading / installs from non-Store locations. This is a
                # lockdown (NOT "push installation") — kept opt-in so it never blocks
                # legitimate developer sideloading in the default safe profile (#10).
                Set-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\AppInstaller" "EnableAppsInstallationFromNonStoreLocation" 0 "DWORD"
            } }
    )

    $tweaks | Where-Object { $_.Tier -in $tiersFor[$Profile] }
}

<#
.SYNOPSIS
    Applies the Windows optimization tweaks for the chosen profile.
.DESCRIPTION
    Runs every tweak whose tier is included by the profile (safe ⊂ desktop ⊂
    gaming). The default 'safe' profile applies only reversible privacy, visual,
    storage and harmless-service tweaks; it never disables VSS, StorSvc,
    SmartScreen, DPS, WinRM or SysMain. Each tweak is executed through
    Apply-SystemConfig so failures are logged and non-fatal.
.PARAMETER Profile
    safe (default), desktop, or gaming.
.EXAMPLE
    Set-OptimizeConfiguration                 # safe defaults
.EXAMPLE
    Set-OptimizeConfiguration -Profile gaming  # everything, incl. aggressive tweaks
#>
function Set-OptimizeConfiguration {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidAssignmentToAutomaticVariable', 'Profile',
        Justification = 'Public -Profile parameter; the automatic $PROFILE variable is not used here.')]
    [CmdletBinding()]
    param(
        [ValidateSet('safe', 'desktop', 'gaming')]
        [string]$Profile = 'safe'
    )

    Write-GroupHeader "OPTIMIZE - System Optimization ($Profile profile)"

    foreach ($tweak in (Get-OptimizeTweaks -Profile $Profile)) {
        Apply-SystemConfig $tweak.Name $tweak.Action
    }

    Write-Log "All optimizations for the '$Profile' profile completed" -Level Success
}
