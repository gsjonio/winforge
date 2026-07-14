# Chocolatey Integration

## Overview

Chocolatey (choco) is integrated as a **fallback installer** when Winget fails. This dramatically increases installation success rates for programs not available through Winget.

## Installation Chain

The script attempts installation in this order:

```text
1. Winget (primary)
   ↓ (if fails)
2. Chocolatey (fallback)
   ↓ (if fails)
3. Custom URL (last resort)
```

## Setup

### Option 1: Auto-Installation (Recommended)

Chocolatey installs automatically when needed:

```powershell
@{
    Name    = "Python"
    WingetId = "Python.Python.3.11"
    ChocoId  = "python311"              # Enables Chocolatey fallback
    Executable = "python"
}
```

If Winget fails, the script will:

1. Detect Chocolatey is not installed
2. Install Chocolatey automatically
3. Use Chocolatey to install the program

### Option 2: Pre-Install Chocolatey

Manually install Chocolatey first:

```powershell
# In PowerShell (as admin)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

Then use it in your programs:

```powershell
@{
    Name    = "Python"
    WingetId = "Python.Python.3.11"
    ChocoId  = "python311"
}
```

## Finding Chocolatey Package IDs

### Search Online

Visit: <https://community.chocolatey.org/packages>

Example: Search for "python"

### Command Line

With Chocolatey installed:

```powershell
choco search python
choco search git
choco list | findstr /i "python"
```

## Examples

### Only Winget

```powershell
@{
    Name       = "Git"
    WingetId   = "Git.Git"
    Executable = "git"
}
```

Result: Tries Winget only (no fallback)

### Winget + Chocolatey

```powershell
@{
    Name       = "Python"
    WingetId   = "Python.Python.3.11"
    ChocoId    = "python311"
    Executable = "python"
}
```

Result: Tries Winget → if fails, tries Chocolatey → if fails, error

### All Three Methods

```powershell
@{
    Name         = "Custom App"
    WingetId     = "Vendor.CustomApp"
    ChocoId      = "customapp"
    Executable   = "customapp.exe"
    InstallerUrl = "https://example.com/customapp.exe"
}
```

Result: Tries Winget → Chocolatey → Custom URL

### Legacy Programs

For old software only available in Chocolatey:

```powershell
@{
    Name       = "Legacy Tool"
    WingetId   = "Legacy.Tool"
    ChocoId    = "legacytool"              # Chocolatey has it
    Executable = "legacytool.exe"
}
```

Result: Winget fails → Chocolatey succeeds

## Package Name vs ID

Important distinction:

| Field | Value | Source |
| ------- | ------- | -------- |
| `Name` | "Visual Studio Code" | Display name (human readable) |
| `WingetId` | "Microsoft.VisualStudioCode" | Winget package ID |
| `ChocoId` | "vscode" | Chocolatey package ID |

Example:

```powershell
@{
    Name       = "VS Code"                          # Display name
    WingetId   = "Microsoft.VisualStudioCode"       # Winget ID
    ChocoId    = "vscode"                           # Choco ID (different!)
    Executable = "code"
}
```

## Common Chocolatey Package IDs

| Program | ID |
| --------- | ----- |
| Python | `python311` |
| Node.js | `nodejs` |
| Git | `git` |
| VS Code | `vscode` |
| Docker | `docker-desktop` |
| 7-Zip | `7zip` |
| VLC | `vlc` |
| Firefox | `firefox` |
| Chrome | `googlechrome` |
| Java | `jdk` |

## Troubleshooting

### Chocolatey installation fails

```text
[x] Chocolatey installation failed
```

**Cause**: Network issue or missing admin rights

**Solution**:

1. Ensure you have admin privileges
2. Check internet connection
3. Try manual installation first
4. Skip Chocolatey fallback (don't include `ChocoId`)

### Program not found in Chocolatey

```text
[x] Program installation failed (no valid method)
```

**Cause**: Program not available in any source

**Solution**:

1. Provide `InstallerUrl` as fallback
2. Check if Winget ID is correct
3. Search Chocolatey: <https://community.chocolatey.org/packages>

### Chocolatey command not found

```text
choco : The term 'choco' is not recognized
```

**Cause**: Chocolatey not installed or PATH not updated

**Solution**:

- The script handles this automatically
- Or install manually and restart PowerShell

## Advanced Usage

### Conditional Installation

```powershell
function Install-DevPrograms {
    $programs = @(
        @{
            Name       = "Python (with Choco fallback)"
            WingetId   = "Python.Python.3.11"
            ChocoId    = "python311"
            Executable = "python"
        }
    )
    
    foreach ($program in $programs) {
        Install-Program @program
    }
}
```

### Check if Chocolatey is available

```powershell
if (Test-ChocoInstalled) {
    Write-Log "Chocolatey is available" -Level Success
} else {
    Write-Log "Chocolatey will be installed on demand" -Level Info
}
```

### Install Chocolatey explicitly

```powershell
if (-not (Test-ChocoInstalled)) {
    Install-Chocolatey
}
```

## Performance

- **Winget install**: ~10-30 seconds
- **Chocolatey install**: ~15-45 seconds
- **Chocolatey auto-install**: ~2-3 minutes (one-time)

For scripts with many Chocolatey packages, consider pre-installing Chocolatey.

## Security

Chocolatey installation downloads from official source:

```text
https://community.chocolatey.org/install.ps1
```

## References

- **Chocolatey Official**: <https://chocolatey.org>
- **Package Repository**: <https://community.chocolatey.org/packages>
- **Documentation**: <https://docs.chocolatey.org>

---

**See [EXAMPLES.md](EXAMPLES.md) for complete examples.**
