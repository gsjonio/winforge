# Gaming & Social group: Gaming, social, and multimedia applications

function Install-GamingPrograms {
    Write-GroupHeader "GAMING - Gaming & Social Programs"

    $programs = @(
        @{
            Name     = "Steam"
            WingetId = "Valve.Steam"
            ChocoId  = "steam"
            Executable = "steam"
        },
        @{
            Name     = "Discord"
            WingetId = "Discord.Discord"
            ChocoId  = "discord"
            Executable = "discord"
        },
        @{
            Name     = "Spotify"
            WingetId = "Spotify.Spotify"
            ChocoId  = "spotify"
            Executable = "spotify"
        },
        @{
            Name     = "WhatsApp"
            WingetId = "WhatsApp.WhatsApp"
            Executable = "whatsapp"
        }
    )

    foreach ($program in $programs) {
        Install-Program @program
    }
}

function Set-GamingConfiguration {
    Write-GroupHeader "GAMING - Gaming Configuration"

    # Example: Enable Game Mode
    # Apply-SystemConfig "Enable Game Mode" {
    #     Set-RegistryValue -Path "HKCU:\Software\Microsoft\GameBar" `
    #         -Name "GamePanelStartupTipIndex" -Value 3 -Type DWord
    # }

    # Example: Optimize for gaming performance
    # Apply-SystemConfig "Optimize power settings for gaming" {
    #     powercfg /setactive 8c5e7fda-e8bf-45a6-a6cc-4b3c9be882a4  # High Performance
    # }
}

