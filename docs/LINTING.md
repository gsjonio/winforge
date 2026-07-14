# PowerShell Code Quality - PSScriptAnalyzer

## Overview

This project uses **PSScriptAnalyzer** - the official Microsoft PowerShell static code analyzer to maintain code quality, security, and consistency.

## Installation

### One-Time Setup

```powershell
# Install PSScriptAnalyzer
Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force
```

### Verify Installation

```powershell
# Check if installed
Get-Module -ListAvailable -Name PSScriptAnalyzer

# Should show: PSScriptAnalyzer v1.20+
```

## Usage

### Run All Scripts

```powershell
.\tools\lint.ps1
```

### Lint Specific Directory

```powershell
# Check src directory
.\tools\lint.ps1 -Path .\src

# Check specific file
.\tools\lint.ps1 -Path .\src\core\Installation.ps1
```

### Filter by Severity

```powershell
# Only show errors (not warnings)
.\tools\lint.ps1 -Severity Error

# Show all issues (errors + warnings)
.\tools\lint.ps1 -Severity Warning
```

## Configuration

Configuration file: `.pslintrc`

### Enabled Rules

Standard PowerShell best practices:

| Category | Rules |
| ---------- | ------- |
| **Style** | Indentation, whitespace, assignment alignment |
| **Best Practices** | Approved verbs, variable usage, implicit conversion |
| **Performance** | Avoid Invoke-Expression, optimize patterns |
| **Security** | Password handling, code injection prevention |
| **Readability** | Line length (120 chars), hardcoded values |

### Excluded Rules

- `PSAvoidDoubleQuotedStrings` - Allow for readability
- `PSAvoidWriteHost` - Needed for logging output
- `PSProvideCommentHelp` - Documented in ARCHITECTURE.md

## Common Issues

### Issue: "PSScriptAnalyzer not installed"

**Solution:**

```powershell
Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force
```

### Issue: "NuGet provider is required"

**Solution:**

```powershell
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force
```

### Issue: "Access denied"

**Solution:** Use `-Scope CurrentUser` instead of system-wide installation

## Example Output

```text
═══════════════════════════════════════════════════════════
  PowerShell Script Analysis
═══════════════════════════════════════════════════════════
Path: .
Severity: Warning

Found 2 issue(s):

Warning:
  [PSAvoidUsingCmdletAliases] Cmdlet alias used
    → .\src\utils\Logging.ps1:10
  
  [PSUseDeclaredVarsMoreThanAssignments] Variable assigned but not used
    → .\src\core\Installation.ps1:25

✓ No issues found!
```

## Rule Severity Levels

| Level | Impact |
| ------- | -------- |
| **Error** | Code won't work / security issue / high impact |
| **Warning** | Style issue / minor problem / best practice |
| **Information** | Suggestion / alternative approach |

## Pre-commit Hook (Optional)

To automatically check code before committing:

```powershell
# Create .git/hooks/pre-commit
#!/bin/pwsh
.\tools\lint.ps1 -Severity Error
exit $LASTEXITCODE
```

## IDE Integration

### Visual Studio Code

Install extension: **PowerShell**

The extension uses PSScriptAnalyzer automatically.

### VS Code Settings

```json
{
  "powershell.linting.enabled": true,
  "powershell.linting.level": "Warning"
}
```

## Continuous Integration

Run linting in CI/CD pipeline:

```yaml
# GitHub Actions example
- name: Lint PowerShell Scripts
  run: |
    Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force
    .\tools\lint.ps1 -Severity Error
```

## References

- **PSScriptAnalyzer Rules**: <https://github.com/PowerShell/PSScriptAnalyzer>
- **PowerShell Best Practices**: <https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-development-guidelines>
- **Configuration Reference**: See `.pslintrc` in project root

## Questions?

See `docs/ARCHITECTURE.md` for project design or `docs/EXAMPLES.md` for usage.
