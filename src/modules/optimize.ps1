# Optimize group: Windows system optimization and privacy tweaks

function Install-OptimizePrograms {
    Write-GroupHeader "OPTIMIZE - Skipped (configuration only)"
    Write-Log "This group contains system optimizations, no programs to install" -Level Info
}

function Set-OptimizeConfiguration {
    Write-GroupHeader "OPTIMIZE - System Optimization & Privacy"

    # Check system RAM and disable Multimedia Class Scheduler if >= 8GB
    $ramGB = [math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 0)
    if ($ramGB -ge 8) {
        Apply-SystemConfig "Disable Multimedia Class Scheduler (RAM >= 8GB)" {
            if (Get-Command Disable-MMAgent -ErrorAction SilentlyContinue) {
                Disable-MMAgent -mc
            }
        }
    }

    # Disable telemetry and data collection
    Apply-SystemConfig "Disable diagnostic data collection" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" "Enabled" 0 "DWORD"
        Set-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowDiagnosticData" 0 "DWORD"
    }

    # Disable background app activity
    Apply-SystemConfig "Disable background application activity" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserExperienceSettings_IsMigratedToNewSettingsModel" 1 "DWORD"
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Settings\Privacy\General" "AllowTailoredExperiences" 0 "DWORD"
    }

    # Disable App Installer (Push Installation)
    Apply-SystemConfig "Disable push installation service" {
        Set-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\AppInstaller" "EnableAppsInstallationFromNonStoreLocation" 0 "DWORD"
    }

    # Disable Find My Device
    Apply-SystemConfig "Disable Find My Device" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\FindMyDevice" "LocationSyncEnabled" 0 "DWORD"
    }

    # Disable Activity History
    Apply-SystemConfig "Disable activity history sync" {
        Set-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\System" "EnableActivityFeed" 0 "DWORD"
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\ActivityHistory" "EnableActivityFeed" 0 "DWORD"
    }

    # Disable Problem Steps Recorder (PSR)
    Apply-SystemConfig "Disable Problem Steps Recorder" {
        Set-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\AppCompat" "DisablePCA" 1 "DWORD"
    }

    # Disable automatic update notifications
    Apply-SystemConfig "Disable update notifications" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.UpdateNotification" "Enabled" 0 "DWORD"
    }

    # Disable File Explorer insights (downloads, recent items)
    Apply-SystemConfig "Disable File Explorer insights" {
        Set-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\Explorer" "DisableQuickAccess" 1 "DWORD"
    }

    # Disable Start menu recent documents history
    Apply-SystemConfig "Disable recent documents history in Start menu" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowRecent" 0 "DWORD"
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowFrequent" 0 "DWORD"
    }

    # Disable Windows Defender SmartScreen
    Apply-SystemConfig "Configure Windows Defender SmartScreen" {
        Set-RegistryValue "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer" "SmartScreenEnabled" "Off" "String"
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost" "EnableWebContentEvaluation" 0 "DWORD"
    }

    # Disable sync settings
    Apply-SystemConfig "Disable settings sync" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync" "SyncPolicy" 0 "DWORD"
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" "Enabled" 0 "DWORD"
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\AppSync" "Enabled" 0 "DWORD"
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" "Enabled" 0 "DWORD"
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\StartLayout" "Enabled" 0 "DWORD"
    }

    # Disable Cortana
    Apply-SystemConfig "Disable Cortana" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Personalization\Settings" "AcceptedPrivacyPolicy" 0 "DWORD"
        Set-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0 "DWORD"
    }

    # Disable web content evaluation in Microsoft Edge
    Apply-SystemConfig "Disable web content evaluation in browsers" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost" "EnableWebContentEvaluation" 0 "DWORD"
    }

    # Disable Microsoft Consumer Experiences
    Apply-SystemConfig "Disable consumer experiences" {
        Set-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" "DisableTailoredExperiencesNotification" 1 "DWORD"
        Set-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" "DisableWindowsSpotlightFeatures" 1 "DWORD"
    }

    # Disable automatic driver installation
    Apply-SystemConfig "Disable automatic driver installation" {
        Set-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\Device Metadata" "PreventDeviceMetadataFromNetwork" 1 "DWORD"
    }

    # Desktop service optimizations (disable unnecessary services)
    Apply-SystemConfig "Disable diagnostic tracking service" {
        Get-Service -Name "DiagTrack" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
    }

    Apply-SystemConfig "Disable device metadata sync" {
        Get-Service -Name "dmwappushservice" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
    }

    Apply-SystemConfig "Disable OneDrive sync service" {
        Get-Service -Name "OneSyncSvc" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
    }

    Apply-SystemConfig "Disable Hyper-V Host service" {
        Get-Service -Name "HvHost" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
    }

    Apply-SystemConfig "Disable Internet Connection Sharing" {
        Get-Service -Name "SharedAccess" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
    }

    Apply-SystemConfig "Disable SysMain (Prefetch)" {
        Get-Service -Name "SysMain" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
    }

    Apply-SystemConfig "Disable Storage service" {
        Get-Service -Name "StorSvc" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
    }

    Apply-SystemConfig "Disable offline files" {
        Get-Service -Name "CscService" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
    }

    Apply-SystemConfig "Disable performance diagnostics" {
        Get-Service -Name "DPS" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
    }

    Apply-SystemConfig "Disable tablet input service" {
        Get-Service -Name "TabletInputService" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
    }

    Apply-SystemConfig "Disable distributed link tracking client" {
        Get-Service -Name "TrkWks" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
    }

    Apply-SystemConfig "Disable still image events service" {
        Get-Service -Name "stisvc" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
    }

    Apply-SystemConfig "Disable Windows Media Player network sharing" {
        Get-Service -Name "WMPNetworkSvc" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
    }

    Apply-SystemConfig "Disable Windows Remote Management" {
        Get-Service -Name "WinRM" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
    }

    Apply-SystemConfig "Disable location framework service" {
        Get-Service -Name "lfsvc" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
    }

    # Performance Visual Optimizations
    Apply-SystemConfig "Disable animations and transitions" {
        Set-RegistryValue "HKCU:\Control Panel\Desktop" "UserPreferencesMask" "9012038010000000" "String"
    }

    Apply-SystemConfig "Disable visual effects for performance" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ListviewAlphaEnabled" 0 "DWORD"
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAnimations" 0 "DWORD"
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\Dwm.Exe" "UseDeferredScheduling" 0 "DWORD"
    }

    Apply-SystemConfig "Disable window transparency and blur" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 0 "DWORD"
        Set-RegistryValue "HKLM:\Software\Microsoft\Windows\DWM" "ForceEffectMode" 0 "DWORD"
    }

    Apply-SystemConfig "Disable tooltip animations" {
        Set-RegistryValue "HKCU:\Control Panel\Desktop" "MenuShowDelay" "0" "String"
    }

    # Automatic Temp Files Cleanup
    Apply-SystemConfig "Configure automatic temp files cleanup" {
        # Enable Storage Sense (automatic cleanup)
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" "01" 1 "DWORD"

        # Cleanup temp files older than 1 day
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" "04" 1 "DWORD"
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" "08" 0 "DWORD"
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" "32" 0 "DWORD"

        # Cleanup recycle bin older than 30 days
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" "256" 30 "DWORD"

        Write-Log "Storage Sense configured for automatic cleanup" -Level Info
    }

    # Network Performance Optimizations (Gaming)
    Apply-SystemConfig "Disable QoS Throttling (network bandwidth)" {
        Set-RegistryValue "HKLM:\Software\Policies\Microsoft\Windows\Psched" "NonBestEffortLimit" 0 "DWORD"
        Write-Log "QoS Throttling disabled - full bandwidth available" -Level Info
    }

    Apply-SystemConfig "Remove network throttling limit" {
        Set-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Services\Psched\Parameters" "NetworkThrottlingIndex" 0xFFFFFFFF "DWORD"
        Write-Log "Network throttling removed - faster updates and downloads" -Level Info
    }

    # Power/Energy Optimizations (Desktop 24/7)
    Apply-SystemConfig "Force High Performance power plan" {
        try {
            powercfg /setactive 8c5e7fda-e8bf-45a6-a6cc-4b3c2b40b294 2>&1 | Out-Null
            Write-Log "High Performance power plan activated" -Level Info
        }
        catch {
            Write-Log "Could not set power plan: $_" -Level Warning
        }
    }

    Apply-SystemConfig "Disable USB Selective Suspend" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\PowerShell" "DisableUSBSelectiveSuspend" 1 "DWORD"
        Set-RegistryValue "HKLM:\System\CurrentControlSet\Services\usbhub\Parameters" "DisableSelectiveSuspend" 1 "DWORD"
        Write-Log "USB Selective Suspend disabled - instant peripherals response" -Level Info
    }

    Apply-SystemConfig "Disable Sleep/Hibernate (PC 24/7)" {
        # Disable sleep timeout
        powercfg /change monitor-timeout-ac 0 2>&1 | Out-Null
        powercfg /change disk-timeout-ac 0 2>&1 | Out-Null
        powercfg /change standby-timeout-ac 0 2>&1 | Out-Null

        # Disable hibernation completely
        powercfg /h off 2>&1 | Out-Null

        Write-Log "Sleep/Hibernate disabled - PC stays fully active" -Level Info
    }

    Write-Log "All system optimizations completed" -Level Success
}
