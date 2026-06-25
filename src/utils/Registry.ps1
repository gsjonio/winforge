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
        # Handle both formats: "HKCU:\path" and "HKCU:\path"
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
        $regPath = $Path -replace '^HKEY_', ''
        $hive = $regPath.Split('\')[0]

        $hiveName = @{
            "HKEY_LOCAL_MACHINE" = "HKLM"
            "HKEY_CURRENT_USER"  = "HKCU"
            "HKEY_CLASSES_ROOT"  = "HKCR"
            "HKEY_CURRENT_CONFIG" = "HKCC"
            "HKEY_USERS"         = "HKU"
            "HKLM"               = "HKLM"
            "HKCU"               = "HKCU"
            "HKCR"               = "HKCR"
            "HKCC"               = "HKCC"
            "HKU"                = "HKU"
        }[$hive]

        $subPath = ($regPath -split '\\', 2)[1]
        $fullPath = "$($hiveName):\$subPath"

        $value = Get-ItemProperty -Path $fullPath -Name $Name -ErrorAction SilentlyContinue
        return if ($value) { $value.$Name } else { $DefaultValue }
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
