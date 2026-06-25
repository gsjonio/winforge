# Customize group: Windows UI and shell customizations

function Install-CustomizePrograms {
    Write-GroupHeader "CUSTOMIZE - Skipped (configuration only)"
    Write-Log "This group contains UI customizations, no programs to install" -Level Info
}

function Set-CustomizeConfiguration {
    Write-GroupHeader "CUSTOMIZE - Windows Shell & UI Customization"

    # Context Menu: Remove unnecessary items
    Apply-SystemConfig "Remove 'Share' from context menu" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowSuperHidden" 0 "DWORD"
        Remove-Item "HKCU:\Software\Classes\*\shellex\ContextMenuHandlers\ModernSharing" -ErrorAction SilentlyContinue
    }

    # Context Menu: Remove 'Print' for non-document files
    Apply-SystemConfig "Customize context menu for files" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DisableContextMenuItems" 1 "DWORD"
    }

    # Context Menu: Add 'Edit with Notepad++' if available
    Apply-SystemConfig "Add useful context menu items" {
        $notepadPath = "C:\Program Files\Notepad++\notepad++.exe"
        if (Test-Path $notepadPath) {
            Set-RegistryValue "HKCU:\Software\Classes\*\shell\Edit with Notepad++" "Icon" $notepadPath "String"
            Set-RegistryValue "HKCU:\Software\Classes\*\shell\Edit with Notepad++\command" "(Default)" "`"$notepadPath`" `"%1`"" "String"
        }
    }

    # File Explorer: Show hidden files
    Apply-SystemConfig "Show hidden files in File Explorer" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1 "DWORD"
    }

    # File Explorer: Show file extensions
    Apply-SystemConfig "Show file extensions in File Explorer" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0 "DWORD"
    }

    # File Explorer: Show full path in address bar
    Apply-SystemConfig "Show full path in File Explorer address bar" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" "FullPath" 1 "DWORD"
    }

    # File Explorer: Use List view by default
    Apply-SystemConfig "Set File Explorer default view to List" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "FolderContentsMode" 3 "DWORD"
    }

    # Taskbar: Show all system tray icons
    Apply-SystemConfig "Show all system tray icons" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" "EnableAutoTray" 0 "DWORD"
    }

    # Taskbar: Disable news and interests widget
    Apply-SystemConfig "Disable news and interests in taskbar" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" "ShellFeedsTaskbarViewMode" 2 "DWORD"
    }

    # Taskbar: Disable Cortana button
    Apply-SystemConfig "Disable Cortana search icon in taskbar" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" 0 "DWORD"
    }

    # Start Menu: Remove recommendations
    Apply-SystemConfig "Remove recommendations from Start menu" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_TrackProgs" 0 "DWORD"
    }

    # Start Menu: Remove suggested apps
    Apply-SystemConfig "Remove suggested apps from Start menu" {
        Set-RegistryValue "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" "DisableWindowsSpotlightFeatures" 1 "DWORD"
    }

    # Desktop: Remove shortcut arrow overlay
    Apply-SystemConfig "Remove shortcut arrow overlay on desktop icons" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" "29" "%SystemRoot%\System32\shell32.dll,-50" "String"
    }

    # System: Dark mode for apps
    Apply-SystemConfig "Enable dark mode for applications" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme" 0 "DWORD"
    }

    # System: Dark mode for Windows
    Apply-SystemConfig "Enable dark mode for Windows" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "SystemUsesLightTheme" 0 "DWORD"
    }

    # Keyboard: Disable Sticky Keys warning
    Apply-SystemConfig "Disable sticky keys confirmation dialog" {
        Set-RegistryValue "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "506" "String"
    }

    # Mouse: Enable pointer shadow
    Apply-SystemConfig "Enable mouse pointer shadow" {
        Set-RegistryValue "HKCU:\Control Panel\Cursors" "CursorShadow" "1" "String"
    }

    # Mouse: Disable mouse acceleration
    Apply-SystemConfig "Disable mouse acceleration" {
        Set-RegistryValue "HKCU:\Control Panel\Mouse" "MouseSpeed" "0" "String"
        Set-RegistryValue "HKCU:\Control Panel\Mouse" "MouseThreshold1" "0" "String"
        Set-RegistryValue "HKCU:\Control Panel\Mouse" "MouseThreshold2" "0" "String"
    }

    # Keyboard: Show key press visually (on-screen keyboard indicator)
    Apply-SystemConfig "Configure keyboard settings" {
        Set-RegistryValue "HKCU:\Control Panel\Keyboard" "InitialKeyboardIndicators" "2" "String"
    }

    Write-Log "All UI customizations completed" -Level Success
}
