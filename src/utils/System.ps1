# System-level utilities and helpers

function Test-IsElevated {
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

function Request-Elevation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,

        # Original script params to forward to the elevated instance (e.g. -Group).
        [System.Collections.IDictionary]$BoundParameters = @{}
    )

    if (Test-IsElevated) {
        return
    }

    Write-Log "Requesting administrator privileges..." -Level Warning

    $psPath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
    $argList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$ScriptPath`"")

    foreach ($key in $BoundParameters.Keys) {
        $value = $BoundParameters[$key]
        if ($value -is [switch] -or $value -is [bool]) {
            if ($value) { $argList += "-$key" }
        }
        else {
            $argList += "-$key"
            $argList += "`"$value`""
        }
    }

    Start-Process -FilePath $psPath -ArgumentList $argList -Verb RunAs -Wait
    exit $LASTEXITCODE
}
