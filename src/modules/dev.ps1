# Dev group: Development tools and programming environments

function Install-DevPrograms {
    Write-GroupHeader "DEV - Development Programs"

    $programs = @(
        @{
            Name     = "Visual Studio Code"
            WingetId = "Microsoft.VisualStudioCode"
            ChocoId  = "vscode"
            Executable = "code"
        },
        @{
            Name     = "GitHub Desktop"
            WingetId = "GitHub.GitHubDesktop"
            ChocoId  = "github-desktop"
            Executable = "github"
        },
        @{
            Name     = "Claude"
            WingetId = "Anthropic.Claude"
            Executable = "claude"
        },
        @{
            Name     = "Python"
            WingetId = "Python.Python.3.12"
            ChocoId  = "python"
            Executable = "python"
        }
    )

    foreach ($program in $programs) {
        Install-Program @program
    }
}

function Set-DevConfiguration {
    Write-GroupHeader "DEV - Development Configuration"

    # Example: Enable Developer Mode
    # Invoke-SystemConfig "Enable Windows Developer Mode" {
    #     Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock" `
    #         -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord
    # }

    # Example: Configure Git
    # Invoke-SystemConfig "Configure Git global settings" {
    #     git config --global user.name "Your Name"
    #     git config --global user.email "your.email@example.com"
    # }
}

