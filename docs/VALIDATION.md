# Installation Validation Guide

## Overview

The setup script includes comprehensive validation to prevent redundant installations. Before installing any program, it checks multiple sources to determine if the program is already installed.

## Detection Methods

The script uses **4 progressive detection methods** (checked in order):

### 1. Executable Command Check
**Fastest** - Searches system PATH for the program's command

```powershell
Get-Command -Name "git"  # Returns path if found
```

✓ Works for: All CLI tools, IDEs with command-line wrappers  
✗ May miss: GUI-only applications without PATH entry

### 2. Windows Package Manager (Get-Package)
**Windows Registry** - Checks installed packages via PackageManagement

```powershell
Get-Package -Name "*Git*"
```

✓ Works for: MSI/EXE installers that register with Windows  
✗ May miss: Portable/ZIP distributions, Winget-only packages

### 3. Winget List
**Package Manager** - Queries Windows Package Manager directly

```powershell
winget list --id Git.Git --exact
```

✓ Works for: Winget-managed installations  
✗ May miss: Older manual installations

### 4. Registry Uninstall Keys
**Most Thorough** - Searches Windows uninstall registry paths

Checks:
- `HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall`
- `HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall`
- `HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall`

✓ Works for: Almost all installers  
✗ May include: Old/incomplete entries

## Function Reference

### Test-ProgramInstalled

Quick boolean check if program is installed.

```powershell
. .\lib\helpers.ps1

# Returns: $true or $false
Test-ProgramInstalled -ProgramName "Git" `
    -Executable "git" `
    -WingetId "Git.Git"
```

**Parameters:**
- `ProgramName` (required) - Display name of program
- `Executable` (optional) - Command to check in PATH
- `WingetId` (optional) - Winget package identifier

### Get-InstallationStatus

Detailed status information with detection method.

```powershell
$status = Get-InstallationStatus -ProgramName "Git" `
    -Executable "git" `
    -WingetId "Git.Git"

$status.IsInstalled         # true/false
$status.DetectionMethod     # "Executable", "Package", etc.
$status.Details             # Array of additional info
```

### Show-InstallationReport

Visual report for multiple programs.

```powershell
$programs = @(
    @{ Name = "Git"; Executable = "git"; WingetId = "Git.Git" },
    @{ Name = "Node.js"; Executable = "node"; WingetId = "OpenJS.NodeJS" }
)

Show-InstallationReport -Programs $programs -ShowDetails
```

**Parameters:**
- `Programs` (required) - Array of program objects
- `ShowDetails` (optional switch) - Show detection details

**Output:**
```text
=======================================================================
  INSTALLATION VALIDATION REPORT
=======================================================================

[+] Git
    Method: Executable
    Found: C:\Program Files\Git\cmd\git.exe
[+] Node.js
    Method: Executable
    Found: C:\Users\User\AppData\Local\Programs\nodejs\node.exe
[x] Python
    Not found

=======================================================================
  Total: 3 | Installed: 2 | Not Installed: 1
=======================================================================
```

## Installation Behavior

### When Program IS Detected

```
[~] Git is already installed
    ↓
SKIPPED - No action taken
```

The script logs the detection method and skips installation:
- Saves time
- Preserves existing configuration
- Prevents version conflicts

### When Program IS NOT Detected

```
[i] Installing Git...
    ↓
    Try Winget
    ├─ Success → [+] Installed successfully
    ├─ Fail → Try custom installer URL (if provided)
    │         ├─ Success → [+] Installed from URL
    │         └─ Fail → [x] Installation failed
    └─ Fail (no URL) → [x] Installation failed
```

## Common Scenarios

### Scenario 1: Program from Winget

```powershell
@{
    Name       = "Git"
    WingetId   = "Git.Git"
    Executable = "git"
}
```

**Detection:** Executable check → finds `git.exe` in PATH → **SKIPPED**

### Scenario 2: Program Not in Winget

```powershell
@{
    Name         = "Custom App"
    WingetId     = "Custom.App"
    Executable   = "customapp.exe"
    InstallerUrl = "https://example.com/custom-installer.exe"
}
```

**Detection Flow:**
1. Check executable → Not found
2. Check Package → Not found
3. Check Winget → Not found
4. Check Registry → Not found
5. Try Winget install → Fails
6. Fall back to custom URL → Downloads and installs
7. Result: **INSTALLED**

### Scenario 3: Portable/ZIP Application

```powershell
@{
    Name         = "Portable Tool"
    WingetId     = "Tool.Portable"
    Executable   = "tool.exe"
    InstallerUrl = "https://example.com/tool-portable.zip"
}
```

**Note:** For ZIP files, you'll need custom installation logic in a pre-installation script.

## Best Practices

### 1. Always Provide Executable
Ensures fastest detection:

```powershell
@{
    Name       = "Git"
    WingetId   = "Git.Git"
    Executable = "git"              # ← Important!
}
```

### 2. Provide Custom Installer URL
Handles cases where Winget fails:

```powershell
@{
    Name         = "Git"
    WingetId     = "Git.Git"
    Executable   = "git"
    InstallerUrl = "https://github.com/git-for-windows/git/releases/download/.../Git-2.42.exe"
}
```

### 3. Test Before Running
Validate programs before full setup:

```powershell
. .\lib\helpers.ps1

$myPrograms = @(
    @{ Name = "Git"; Executable = "git"; WingetId = "Git.Git" },
    @{ Name = "Node.js"; Executable = "node"; WingetId = "OpenJS.NodeJS" }
)

Show-InstallationReport -Programs $myPrograms -ShowDetails
```

### 4. Keep Logs
The script logs all operations for troubleshooting:

```
[11:50:10] [i] Installing Git...
[11:50:10] [~] Git is already installed
[11:50:11] [+] Installation completed
```

## Troubleshooting

### Program Not Detected

1. **Verify executable name:**
   ```powershell
   Get-Command -Name "git"
   ```

2. **Check registry manually:**
   ```powershell
   Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" |
       Get-ItemProperty | Where DisplayName -Match "Git"
   ```

3. **List via Winget:**
   ```powershell
   winget list --id Git.Git
   ```

### Installation Failed

1. **Check Winget first:**
   ```powershell
   winget install --id Git.Git
   ```

2. **Verify installer URL:**
   ```powershell
   Invoke-WebRequest -Uri "https://..." -Method Head
   ```

3. **Try manual installation:**
   Download and run installer directly to identify issues

### Performance Issues

- Script checks 4 detection methods per program
- Total time: ~1-2 seconds per program
- For 100+ programs: Consider pre-filtering to reduce checks
