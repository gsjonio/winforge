# Registry manipulation helpers

function Set-RegistryValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        $Value,

        [Parameter(Mandatory = $false)]
        [ValidateSet("String", "DWORD", "QWORD", "Binary", "ExpandString", "MultiString")]
        [string]$Type = "String"
    )

    try {
        # Normalize both forms: "HKCU\path" and "HKCU:\path" to provider format
        $fullPath = if ($Path.Contains(':\')) {
            $Path  # Already has provider format
        } else {
            # Convert HKCU, HKLM format to HKCU:\, HKLM:\
            $Path -replace '^(HKCU|HKLM|HKCR|HKCC|HKU)([:\\])', '$1:\' -replace '\\\\', '\'
        }

        # Create all parent paths recursively if they don't exist
        $pathParts = $fullPath -split '\\'
        $currentPath = ""

        for ($i = 0; $i -lt $pathParts.Count; $i++) {
            $currentPath = if ($i -eq 0) { $pathParts[$i] } else { "$currentPath\$($pathParts[$i])" }

            if (-not (Test-Path -Path $currentPath -ErrorAction SilentlyContinue)) {
                New-Item -Path $currentPath -Force -ErrorAction SilentlyContinue | Out-Null
            }
        }

        # Set registry value
        Set-ItemProperty -Path $fullPath -Name $Name -Value $Value -Type $Type -Force -ErrorAction Stop

        return $true
    }
    catch {
        throw "Failed to set registry value: $_"
    }
}

<#
.SYNOPSIS
    Removes a registry value, letting Windows fall back to its default.
.DESCRIPTION
    Deletes a single value from a registry key. Preferred over writing a
    "default" value when the true Windows default is the value being absent
    (e.g. policy keys). Accepts both "HKLM\path" and "HKLM:\path" forms and is
    idempotent: a missing key or value is a no-op, not an error.
.PARAMETER Path
    Registry key path (HKLM:\..., HKCU:\..., or the colon-less form).
.PARAMETER Name
    Name of the value to remove.
.EXAMPLE
    Remove-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR"
#>
function Remove-RegistryValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    try {
        # Normalize to provider format, matching Set-RegistryValue
        $fullPath = if ($Path.Contains(':\')) {
            $Path
        } else {
            $Path -replace '^(HKCU|HKLM|HKCR|HKCC|HKU)([:\\])', '$1:\' -replace '\\\\', '\'
        }

        if (Test-Path -LiteralPath $fullPath) {
            Remove-ItemProperty -LiteralPath $fullPath -Name $Name -Force -ErrorAction SilentlyContinue
        }
        return $true
    }
    catch {
        Write-Log "Warning: could not remove '$Name' from '$Path': $_" -Level Warning
        return $false
    }
}

function Get-RegistryValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        $DefaultValue = $null
    )

    try {
        # Normalize to provider format, matching Set-RegistryValue
        $fullPath = if ($Path.Contains(':\')) {
            $Path
        } else {
            $Path -replace '^(HKCU|HKLM|HKCR|HKCC|HKU)([:\\])', '$1:\' -replace '\\\\', '\'
        }

        $value = Get-ItemProperty -Path $fullPath -Name $Name -ErrorAction SilentlyContinue
        if ($value) { return $value.$Name }
        return $DefaultValue
    }
    catch {
        return $DefaultValue
    }
}

function Enable-Feature {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FeatureName
    )

    try {
        Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart -ErrorAction Stop
        return $true
    }
    catch {
        throw "Failed to enable feature $FeatureName`: $_"
    }
}

function Disable-Feature {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FeatureName
    )

    try {
        Disable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart -ErrorAction Stop
        return $true
    }
    catch {
        throw "Failed to disable feature $FeatureName`: $_"
    }
}

function Set-FileAssociation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Extension,

        [Parameter(Mandatory = $true)]
        [string]$ProgId
    )

    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension\UserChoice"
        Set-ItemProperty -Path $regPath -Name "ProgId" -Value $ProgId -Force
        return $true
    }
    catch {
        Write-Log "Warning: Could not set file association for $Extension" -Level Warning
    }
}
