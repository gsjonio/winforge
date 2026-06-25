# Shell group: PowerShell customization and terminal enhancement

function Install-ShellPrograms {
    Write-GroupHeader "SHELL - PowerShell Enhancement"

    # Update PowerShell to latest version before installing Oh My Posh
    Apply-SystemConfig "Update PowerShell to latest version" {
        Write-Log "Checking for PowerShell updates..." -Level Info
        winget upgrade --id Microsoft.PowerShell -e -ErrorAction SilentlyContinue
        Write-Log "PowerShell update check completed" -Level Success
    }

    $programs = @(
        @{
            Name     = "Oh My Posh"
            WingetId = "JanDeDobbeleer.OhMyPosh"
            Executable = "oh-my-posh"
        }
    )

    foreach ($program in $programs) {
        Install-Program @program
    }
}

function Set-ShellConfiguration {
    Write-GroupHeader "SHELL - Terminal Configuration"

    # Install Fira Code font
    Apply-SystemConfig "Install Fira Code font" {
        $fontUrl = "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip"
        $tempDir = Join-Path $env:TEMP "FiraCode"

        try {
            if (-not (Test-Path $tempDir)) {
                New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            }

            $zipPath = Join-Path $tempDir "FiraCode.zip"
            Write-Log "Downloading Fira Code..." -Level Info
            (New-Object System.Net.WebClient).DownloadFile($fontUrl, $zipPath)

            $fontsPath = Join-Path $tempDir "fonts"
            if (Test-Path $fontsPath) {
                Remove-Item $fontsPath -Recurse -Force
            }

            Expand-Archive -Path $zipPath -DestinationPath $fontsPath -Force

            Write-Log "Installing Fira Code fonts..." -Level Info
            $ttfFiles = Get-ChildItem -Path $fontsPath -Filter "*.ttf" -Recurse

            foreach ($ttf in $ttfFiles) {
                Copy-Item -Path $ttf.FullName -Destination "$env:WINDIR\Fonts\" -Force -ErrorAction SilentlyContinue
            }

            Write-Log "Fira Code font installed successfully" -Level Success
        }
        catch {
            Write-Log "Failed to install Fira Code: $_" -Level Warning
        }
        finally {
            if (Test-Path $tempDir) {
                Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    # Download and configure Oh My Posh half-life theme
    Apply-SystemConfig "Download Oh My Posh half-life theme" {
        $appDataPath = $env:APPDATA
        $ohMyPoshDir = Join-Path $appDataPath "oh-my-posh"
        $configPath = Join-Path $ohMyPoshDir "config.json"

        if (-not (Test-Path $ohMyPoshDir)) {
            New-Item -ItemType Directory -Path $ohMyPoshDir -Force | Out-Null
        }

        try {
            $themeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/half-life.omp.json"
            Write-Log "Downloading half-life theme from GitHub..." -Level Info
            $themeContent = (New-Object System.Net.WebClient).DownloadString($themeUrl)
            $themeContent | Set-Content -Path $configPath -Encoding UTF8
            Write-Log "Oh My Posh half-life theme configured" -Level Success
        }
        catch {
            Write-Log "Failed to download theme, using default configuration: $_" -Level Warning
        }
    }

    # Create or update PowerShell profile
    Apply-SystemConfig "Configure PowerShell profile with Oh My Posh" {
        $profilePath = $PROFILE
        $profileDir = Split-Path -Parent $profilePath

        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }

        $profileContent = @'
# Clear screen before initializing Oh My Posh
Clear-Host

# ========== Oh My Posh Configuration ==========
# Initialize Oh My Posh with half-life theme (PowerShell 7+ only)
# Requires: winget install JanDeDobbeleer.OhMyPosh -s winget
#
# About Oh My Posh:
# - Modern, customizable terminal prompt similar to oh-my-zsh for Linux/macOS
# - Supports 100+ themes (half-life, dracula, nord, powerlevel10k, tokyo, catppuccin, etc)
# - Git repository status displayed automatically
# - Cross-platform compatible (Windows, macOS, Linux)
#
# Current Theme: half-life (game-inspired prompt with custom segments)
# - runner name (user)
# - path (directory)
# - git branch status
# - lambda prompt (λ)
#
# To change theme, download from GitHub:
# https://github.com/JanDeDobbeleer/oh-my-posh/tree/main/themes

if ($PSVersionTable.PSVersion.Major -ge 7) {
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        # Initialize Oh My Posh with config from AppData
        $configPath = "$env:APPDATA\oh-my-posh\config.json"
        if (Test-Path $configPath) {
            oh-my-posh init pwsh --config $configPath 2>$null | Out-String | Invoke-Expression
        } else {
            # Fallback if config doesn't exist
            oh-my-posh init pwsh | Out-String | Invoke-Expression
        }
    }
}

# ========== PSReadLine Configuration ==========
# PSReadLine provides intelligent command line editing, history search, and autocomplete
# Version compatibility: Works on PowerShell 5.1 and 7+, with enhanced features on 7+
#
# Features enabled:
# - History prediction from previous commands
# - Tab menu for autocomplete (like bash)
# - Ctrl+R for reverse history search (like Linux)
# - Command history saved between sessions

if ($PSVersionTable.PSVersion.Major -ge 7) {
    # PowerShell 7+ parameters - better prediction
    Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
    Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
} else {
    # PowerShell 5.1 compatible - use basic history features
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd -ErrorAction SilentlyContinue
}

# Enable Tab completion menu (works on both versions) - like bash
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete -ErrorAction SilentlyContinue

# Advanced history search (Ctrl+R and Ctrl+S) - familiar from Linux shells
Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory -ErrorAction SilentlyContinue
Set-PSReadLineKeyHandler -Key Ctrl+s -Function ForwardSearchHistory -ErrorAction SilentlyContinue

# Keyboard shortcuts - familiar Linux/macOS keybindings
Set-PSReadLineKeyHandler -Key Ctrl+a -Function BeginningOfLine -ErrorAction SilentlyContinue
Set-PSReadLineKeyHandler -Key Ctrl+e -Function EndOfLine -ErrorAction SilentlyContinue
Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord -ErrorAction SilentlyContinue
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord -ErrorAction SilentlyContinue

# ========== Aliases ==========
# Bash-compatible aliases for familiar command names
# Helps users transitioning from Linux/macOS feel at home in PowerShell
#
# Usage:
# - ll       : List files in long format (like ls -lh)
# - la       : List all files including hidden (like ls -la)
# - grep     : Search text patterns (like Linux grep)
# - touch    : Create empty files

Set-Alias -Name ll -Value Get-ChildItemLong -Force -ErrorAction SilentlyContinue
Set-Alias -Name la -Value Get-ChildItemAll -Force -ErrorAction SilentlyContinue
Set-Alias -Name grep -Value Select-String -Force -ErrorAction SilentlyContinue

# ========== Custom Functions ==========
# List files in long format
function Get-ChildItemLong {
    Get-ChildItem -File | Format-Table -AutoSize
}

# List all files including hidden
function Get-ChildItemAll {
    Get-ChildItem -Force -File | Format-Table -AutoSize
}

# ========== Terminal Title ==========
# Set terminal title
$host.ui.RawUI.WindowTitle = "PowerShell - $(Split-Path -Leaf $pwd)"
'@

        if (Test-Path $profilePath) {
            $currentContent = Get-Content -Path $profilePath -Raw
            if ($currentContent -notlike "*Oh My Posh Configuration*") {
                Add-Content -Path $profilePath -Value "`n`n$profileContent"
                Write-Log "PowerShell profile updated with shell configuration" -Level Success
            }
            else {
                Write-Log "PowerShell profile already configured" -Level Skip
            }
        }
        else {
            Set-Content -Path $profilePath -Value $profileContent
            Write-Log "PowerShell profile created with shell configuration" -Level Success
        }
    }

    # Set terminal font to Fira Code in Windows Terminal config
    Apply-SystemConfig "Configure Windows Terminal to use Fira Code" {
        $wtConfigPath = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

        if (Test-Path $wtConfigPath) {
            try {
                $wtConfig = Get-Content -Path $wtConfigPath -Raw | ConvertFrom-Json

                if (-not $wtConfig.profiles.defaults) {
                    $wtConfig.profiles | Add-Member -Name "defaults" -Value @{} -MemberType NoteProperty
                }

                $wtConfig.profiles.defaults.font = @{ face = "FiraCode NF" }
                $wtConfig.profiles.defaults.fontSize = 10

                $wtConfig | ConvertTo-Json -Depth 32 | Set-Content -Path $wtConfigPath
                Write-Log "Windows Terminal configured with Fira Code font" -Level Success
            }
            catch {
                Write-Log "Could not configure Windows Terminal (it may not be installed): $_" -Level Warning
            }
        }
        else {
            Write-Log "Windows Terminal config not found (optional)" -Level Skip
        }
    }

    Write-Log "All shell customizations completed" -Level Success
}
