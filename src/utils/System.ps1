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

function Wait-ProcessExit {
    param(
        [Parameter(Mandatory = $true)]
        [int]$ProcessId,

        [Parameter(Mandatory = $false)]
        [int]$TimeoutSeconds = 300
    )

    try {
        $process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
        if ($process) {
            $process.WaitForExit($TimeoutSeconds * 1000)
        }
    }
    catch {
        Write-Log "Error waiting for process: $_" -Level Warning
    }
}

function Get-InstalledPrograms {
    return @(Get-Package -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name)
}
