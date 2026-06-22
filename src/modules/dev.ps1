# Dev group: Development tools and programming environments

function Install-DevPrograms {
    Write-GroupHeader "DEV - Development Programs"

    $programs = @(
        # @{
        #     Name        = "Visual Studio Code"
        #     WingetId    = "Microsoft.VisualStudioCode"
        #     Executable  = "code"
        # }
        # @{
        #     Name        = "Git"
        #     WingetId    = "Git.Git"
        #     Executable  = "git"
        # }
        # @{
        #     Name        = "Node.js"
        #     WingetId    = "OpenJS.NodeJS"
        #     Executable  = "node"
        # }
        # Add more development tools here...
    )

    foreach ($program in $programs) {
        Install-Program @program
    }
}

function Set-DevConfiguration {
    Write-GroupHeader "DEV - Development Configuration"

    # Example: Enable Developer Mode
    # Apply-SystemConfig "Enable Windows Developer Mode" {
    #     Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock" `
    #         -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord
    # }

    # Example: Configure Git
    # Apply-SystemConfig "Configure Git global settings" {
    #     git config --global user.name "Your Name"
    #     git config --global user.email "your.email@example.com"
    # }
}

