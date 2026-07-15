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
    [CmdletBinding(SupportsShouldProcess)]
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
        [string]$InstallerUrl = $null,

        [Parameter(Mandatory = $false)]
        [string]$InstallerSha256 = $null
    )

    if (Test-ProgramInstalled -ProgramName $Name -Executable $Executable -WingetId $WingetId) {
        return $true
    }

    if (-not $PSCmdlet.ShouldProcess($Name, "Install program")) {
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
            Install-FromUrl -Name $Name -Url $InstallerUrl -Sha256 $InstallerSha256
            return $true
        }

        throw "Installation failed (no valid method)"
    }
    catch {
        Write-Log "$Name installation failed: $_" -Level Error
        return $false
    }
}

<#
.SYNOPSIS
    Downloads and runs a silent installer from a URL, optionally verifying its hash.
.DESCRIPTION
    Last-resort install method. Downloads the installer to a temp file and runs it
    with '/S'. If -Sha256 is supplied, the downloaded file's SHA256 is verified
    before execution and a mismatch aborts (the file is deleted). Without -Sha256
    the download is unverified and a warning is logged.
.PARAMETER Name
    Display name, used for logging.
.PARAMETER Url
    Direct installer URL.
.PARAMETER Sha256
    Optional expected SHA256 hash; if given, the installer is verified before it runs.
.EXAMPLE
    Install-FromUrl -Name 'Foo' -Url 'https://example.com/foo.exe' -Sha256 'ABC123...'
#>
function Install-FromUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Url,

        [Parameter(Mandatory = $false)]
        [string]$Sha256
    )

    try {
        $tempFile = Join-Path $env:TEMP "install.exe"

        Write-Log "Downloading installer for $Name..." -Level Info
        Invoke-WebRequest -Uri $Url -OutFile $tempFile -UseBasicParsing -ProgressAction SilentlyContinue

        if ($Sha256) {
            $actual = (Get-FileHash -Path $tempFile -Algorithm SHA256).Hash
            if ($actual -ne $Sha256) {
                Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
                throw "SHA256 mismatch for $Name (expected $Sha256, got $actual)"
            }
            Write-Log "Installer verified (SHA256)" -Level Success
        }
        else {
            Write-Log "No SHA256 provided - installer for $Name is unverified" -Level Warning
        }

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
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Description,

        [Parameter(Mandatory = $true)]
        [scriptblock]$ConfigBlock
    )

    if (-not $PSCmdlet.ShouldProcess($Description, "Apply configuration")) {
        return
    }

    Write-Log "Applying: $Description" -Level Info

    try {
        & $ConfigBlock
        Write-Log "$Description applied" -Level Success
    }
    catch {
        Write-Log "Failed to apply $Description`: $_" -Level Error
    }
}
