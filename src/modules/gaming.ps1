# Gaming group: Gaming-related programs and configurations

function Install-GamingPrograms {
    Write-GroupHeader "GAMING - Gaming Programs"

    $programs = @(
        # @{
        #     Name        = "Steam"
        #     WingetId    = "Valve.Steam"
        #     Executable  = "steam"
        # }
        # @{
        #     Name        = "Discord"
        #     WingetId    = "Discord.Discord"
        #     Executable  = "discord"
        # }
        # @{
        #     Name        = "OBS Studio"
        #     WingetId    = "OBSProject.OBStudio"
        #     Executable  = "obs32"
        # }
        # Add more gaming tools here...
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

