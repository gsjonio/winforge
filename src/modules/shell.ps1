# Shell group: PowerShell customization and terminal enhancement

function Install-ShellPrograms {
    Write-GroupHeader "SHELL - PowerShell Enhancement"

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

    # Create or update PowerShell profile
    Apply-SystemConfig "Configure PowerShell profile with Oh My Posh" {
        $profilePath = $PROFILE
        $profileDir = Split-Path -Parent $profilePath

        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }

        $profileContent = @'
# ========== Oh My Posh Configuration ==========
# Initialize Oh My Posh with dracula theme (PowerShell 7+ only)
# Requires: winget install JanDeDobbeleer.OhMyPosh -s winget
if ($PSVersionTable.PSVersion.Major -ge 7) {
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        oh-my-posh init pwsh | Out-String | Invoke-Expression
    }
}

# ========== PSReadLine Configuration ==========
# Check PowerShell version for parameter compatibility
if ($PSVersionTable.PSVersion.Major -ge 7) {
    # PowerShell 7+ parameters
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
} else {
    # PowerShell 5.1 compatible - use basic setup
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
}

# Enable Tab completion menu (works on both versions)
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete -ErrorAction SilentlyContinue

# Advanced history search (Ctrl+R and Ctrl+S) - works on both versions
Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory -ErrorAction SilentlyContinue
Set-PSReadLineKeyHandler -Key Ctrl+s -Function ForwardSearchHistory -ErrorAction SilentlyContinue

# Keyboard shortcuts (works on both versions)
Set-PSReadLineKeyHandler -Key Ctrl+a -Function BeginningOfLine -ErrorAction SilentlyContinue
Set-PSReadLineKeyHandler -Key Ctrl+e -Function EndOfLine -ErrorAction SilentlyContinue
Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord -ErrorAction SilentlyContinue
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord -ErrorAction SilentlyContinue

# ========== Aliases ==========
# Useful aliases for bash-like experience
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
