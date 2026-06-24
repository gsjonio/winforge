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

    Write-Log "All system optimizations completed" -Level Success
}
