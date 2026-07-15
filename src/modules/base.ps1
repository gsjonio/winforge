# Base group: Essential programs (always executed)

function Install-BasePrograms {
    Write-GroupHeader "BASE - Essential Programs"

    $programs = @(
        @{
            Name     = "Firefox"
            WingetId = "Mozilla.Firefox"
            ChocoId  = "firefox"
            Executable = "firefox"
        },
        @{
            Name     = "Git"
            WingetId = "Git.Git"
            ChocoId  = "git"
            Executable = "git"
        },
        @{
            Name     = "VLC Media Player"
            WingetId = "VideoLAN.VLC"
            ChocoId  = "vlc"
            Executable = "vlc"
        },
        @{
            Name     = "WinRAR"
            WingetId = "RARLab.WinRAR"
            ChocoId  = "winrar"
            Executable = "rar"
        },
        @{
            Name     = "LibreOffice"
            WingetId = "TheDocumentFoundation.LibreOffice"
            ChocoId  = "libreoffice"
            Executable = "soffice"
        }
    )

    foreach ($program in $programs) {
        Install-Program @program
    }
}

function Set-BaseConfiguration {
    Write-GroupHeader "BASE - System Configuration"

    # Example system configurations
    # Uncomment and adapt as needed:

    # Enable dark mode
    # Invoke-SystemConfig "Enable Dark Mode" {
    #     Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
    #         -Name "AppsUseLightTheme" -Value 0 -Type DWord
    # }

    # Disable unnecessary services
    # Invoke-SystemConfig "Disable unnecessary services" {
    #     @("DiagTrack", "dmwappushservice") | ForEach-Object {
    #         Get-Service -Name $_ -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
    #     }
    # }
}

