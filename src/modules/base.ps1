# Base group: Essential programs (always executed)

function Install-BasePrograms {
    Write-GroupHeader "BASE - Essential Programs"

    $programs = @(
        # @{
        #     Name        = "Program Name"
        #     WingetId    = "Publisher.Program"
        #     Executable  = "program.exe"  # Optional: command to check installation
        #     InstallerUrl = "https://..."  # Optional: custom installer URL
        # }
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
    # Apply-SystemConfig "Enable Dark Mode" {
    #     Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
    #         -Name "AppsUseLightTheme" -Value 0 -Type DWord
    # }

    # Disable unnecessary services
    # Apply-SystemConfig "Disable unnecessary services" {
    #     @("DiagTrack", "dmwappushservice") | ForEach-Object {
    #         Get-Service -Name $_ -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
    #     }
    # }
}

