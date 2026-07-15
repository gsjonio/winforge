# Logging and output formatting functions

$script:LogLevel = @{
    Info    = @{ Symbol = "[i]"; Color = "Cyan" }
    Success = @{ Symbol = "[+]"; Color = "Green" }
    Warning = @{ Symbol = "[!]"; Color = "Yellow" }
    Error   = @{ Symbol = "[x]"; Color = "Red" }
    Skip    = @{ Symbol = "[~]"; Color = "Gray" }
}

function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Success", "Warning", "Error", "Skip")]
        [string]$Level = "Info"
    )

    $log = $LogLevel[$Level]
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] $($log.Symbol) " -NoNewline -ForegroundColor $log.Color
    Write-Host $Message
}

function Write-GroupHeader {
    param([string]$GroupName)
    Write-Host ""
    Write-Host "=======================================================================" -ForegroundColor Cyan
    Write-Host "  GROUP: $GroupName" -ForegroundColor Cyan
    Write-Host "=======================================================================" -ForegroundColor Cyan
}
