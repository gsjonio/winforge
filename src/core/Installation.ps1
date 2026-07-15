# Program installation core logic

function Test-ChocoInstalled {
    return $null -ne (Get-Command -Name choco -ErrorAction SilentlyContinue)
}

function Install-Chocolatey {
    if (Test-ChocoInstalled) {
        Write-Log "Chocolatey is already installed" -Level Skip
        return $true
    }

    Write-Log "Installing Chocolatey..." -Level Info

    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        $chocoScript = (New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')
        & ([scriptblock]::Create($chocoScript))

        if (Test-ChocoInstalled) {
            Write-Log "Chocolatey installed successfully" -Level Success
            return $true
        }
        throw "Chocolatey installation verification failed"
    }
    catch {
        Write-Log "Chocolatey installation failed: $_" -Level Error
        return $false
    }
}

function Install-Program {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$WingetId,

        [Parameter(Mandatory = $false)]
        [string]$Executable = $null,

        [Parameter(Mandatory = $false)]
        [string]$ChocoId = $null,

        [Parameter(Mandatory = $false)]
        [string]$InstallerUrl = $null
    )

    if (Test-ProgramInstalled -ProgramName $Name -Executable $Executable -WingetId $WingetId) {
        return $true
    }

    Write-Log "Installing $Name..." -Level Info

    try {
        # Method 1: Try Winget
        Write-Log "Attempting: winget" -Level Info
        winget install --id $WingetId --source winget --accept-source-agreements --accept-package-agreements --silent 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Log "$Name installed successfully (winget)" -Level Success
            return $true
        }

        # Method 2: Try Chocolatey (if ChocoId provided)
        if ($ChocoId) {
            Write-Log "Attempting: chocolatey ($ChocoId)" -Level Info

            # Install Chocolatey if not present
            if (-not (Test-ChocoInstalled)) {
                if (-not (Install-Chocolatey)) {
                    Write-Log "Chocolatey installation failed, skipping choco fallback" -Level Warning
                }
            }

            if (Test-ChocoInstalled) {
                choco install $ChocoId -y --no-progress 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Log "$Name installed successfully (chocolatey)" -Level Success
                    return $true
                }
            }
        }

        # Method 3: Try custom installer URL
        if ($InstallerUrl) {
            Write-Log "Attempting: custom installer URL" -Level Warning
            Install-FromUrl -Name $Name -Url $InstallerUrl
            return $true
        }

        throw "Installation failed (no valid method)"
    }
    catch {
        Write-Log "$Name installation failed: $_" -Level Error
        return $false
    }
}

function Install-FromUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    try {
        $tempFile = Join-Path $env:TEMP "install.exe"

        Write-Log "Downloading installer for $Name..." -Level Info
        Invoke-WebRequest -Uri $Url -OutFile $tempFile -UseBasicParsing -ProgressAction SilentlyContinue

        Write-Log "Executing installer..." -Level Info
        Start-Process -FilePath $tempFile -Wait -ArgumentList "/S"

        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
        Write-Log "$Name installed from URL" -Level Success
    }
    catch {
        Write-Log "Custom installation failed: $_" -Level Error
        throw
    }
}

function Invoke-SystemConfig {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Description,

        [Parameter(Mandatory = $true)]
        [scriptblock]$ConfigBlock
    )

    Write-Log "Applying: $Description" -Level Info

    try {
        & $ConfigBlock
        Write-Log "$Description applied" -Level Success
    }
    catch {
        Write-Log "Failed to apply $Description`: $_" -Level Error
    }
}
