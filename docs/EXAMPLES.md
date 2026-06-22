# Program Configuration Examples

Once you have the list of programs to install, add them to the appropriate group file using this format:

## Adding Programs to a Group

Edit the `$programs` array in the relevant group file (e.g., `src/modules/dev.ps1`):

```powershell
$programs = @(
    @{
        Name        = "Visual Studio Code"
        WingetId    = "Microsoft.VisualStudioCode"
        Executable  = "code"
    },
    @{
        Name        = "Git"
        WingetId    = "Git.Git"
        Executable  = "git"
    },
    @{
        Name        = "Node.js"
        WingetId    = "OpenJS.NodeJS"
        Executable  = "node"
    }
)
```

## Installation Methods (Fallback Chain)

The script tries to install in this order:

1. **Winget** - Primary installer
2. **Chocolatey** - Fallback (if `ChocoId` provided)
3. **Custom URL** - Last resort (if `InstallerUrl` provided)

### Using Chocolatey as Fallback

Add a `ChocoId` parameter for Chocolatey fallback:

```powershell
@{
    Name        = "Python"
    WingetId    = "Python.Python.3.11"
    ChocoId     = "python311"          # ← Chocolatey fallback
    Executable  = "python"
}
```

**Find Chocolatey IDs:**
```powershell
# Search on https://community.chocolatey.org/packages
# Or search command line (requires choco installed):
choco search "python"
```

### Using Custom Installer URL

For programs not in Winget or Chocolatey:

```powershell
@{
    Name         = "Custom App"
    WingetId     = "Custom.App"
    ChocoId      = "customapp"         # Optional
    Executable   = "customapp.exe"
    InstallerUrl = "https://example.com/installer.exe"
}
```

### Installation Priority Example

```powershell
# Try Winget first
@{
    Name     = "Tool"
    WingetId = "Publisher.Tool"
}

# Try Winget, then Chocolatey
@{
    Name     = "Tool"
    WingetId = "Publisher.Tool"
    ChocoId  = "tool"
}

# Try Winget, Chocolatey, then custom URL
@{
    Name         = "Tool"
    WingetId     = "Publisher.Tool"
    ChocoId      = "tool"
    InstallerUrl = "https://example.com/tool.exe"
}

# Only Chocolatey and custom URL (if Winget not available)
@{
    Name         = "Old Tool"
    WingetId     = "Old.Tool"
    ChocoId      = "old-tool"
    InstallerUrl = "https://example.com/oldtool.exe"
}
```

## Finding WingetId for Programs

Use the command below to search for a program's winget ID:

```powershell
winget search "Program Name"
```

Example:
```powershell
PS> winget search "Visual Studio Code"
Name             Id                           Version Source
Visual Studio... Microsoft.VisualStudioCode   1.95.0  winget
```

## Adding System Configurations

In the `Set-*Configuration` functions, use `Apply-SystemConfig` with `Set-RegistryValue`:

```powershell
function Set-DevConfiguration {
    Write-GroupHeader "DEV - Development Configuration"

    Apply-SystemConfig "Enable Windows Developer Mode" {
        Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock" `
            -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord
    }

    Apply-SystemConfig "Configure Git" {
        git config --global user.name "Your Name"
        git config --global user.email "your.email@example.com"
    }
}
```

## Available Registry Types

When setting registry values, use one of these types:

- `String` - Text value (default)
- `DWord` - 32-bit number
- `QWord` - 64-bit number
- `Binary` - Binary data
- `ExpandString` - Expandable string
- `MultiString` - Multiple strings

Example:
```powershell
Set-RegistryValue -Path "HKCU:\Software\MyApp" `
    -Name "DebugMode" -Value 1 -Type DWord
```

## Testing Your Configuration

Before running the full script, test a specific group:

```powershell
.\setup.ps1 -Group dev
.\setup.ps1 -Group gaming
```

## Handling Installation Failures

If `winget` fails to install a program, you can provide a custom installer URL:

```powershell
@{
    Name         = "Custom Program"
    WingetId     = "Publisher.Program"
    Executable   = "program.exe"
    InstallerUrl = "https://example.com/installer.exe"
}
```

The script will automatically fall back to downloading and executing the custom installer.

## Validating Installation Status

The setup script automatically skips programs that are already installed. It uses multiple detection methods:

1. **Executable Check** - Searches system PATH for the program's command
2. **Get-Package** - Checks Windows Package Manager registry
3. **Winget List** - Queries Windows Package Manager directly
4. **Registry Uninstall Keys** - Searches standard Windows uninstall registry paths

### Check Individual Program Status

```powershell
. .\src\utils\Validation.ps1

# Simple check (returns true/false)
Test-ProgramInstalled -ProgramName "Git" -Executable "git" -WingetId "Git.Git"

# Detailed status report
$status = Get-InstallationStatus -ProgramName "Git" -Executable "git" -WingetId "Git.Git"
$status.IsInstalled        # true/false
$status.DetectionMethod    # "Executable", "Package", "Registry", etc.
$status.Details            # Additional information
```

### Validate All Programs in a Group

```powershell
. .\src\utils\Validation.ps1

$programs = @(
    @{ Name = "Git"; Executable = "git"; WingetId = "Git.Git" },
    @{ Name = "Node.js"; Executable = "node"; WingetId = "OpenJS.NodeJS" },
    @{ Name = "VS Code"; Executable = "code"; WingetId = "Microsoft.VisualStudioCode" }
)

# Show summary report
Show-InstallationReport -Programs $programs

# Show detailed report with detection information
Show-InstallationReport -Programs $programs -ShowDetails
```

### Output Example

```text
=======================================================================
  INSTALLATION VALIDATION REPORT
=======================================================================

[+] Git
    Method: Executable
    Found: C:\Program Files\Git\cmd\git.exe
[+] VS Code
    Method: Executable
    Found: C:\Users\User\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd
[x] Node.js
    Not found

=======================================================================
  Total: 3 | Installed: 2 | Not Installed: 1
=======================================================================
```

The setup script will automatically skip programs marked as `[+]` (already installed) and only install programs marked as `[x]`.
