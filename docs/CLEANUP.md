# Cleanup Guide - Reorganization Complete

The project has been reorganized from a flat structure to a **responsibility-based architecture**.

## What Changed

### New Structure (Current)
```
src/
├── core/        # Installation logic
├── utils/       # Reusable functions
└── modules/     # Installation groups

docs/            # Documentation
tools/           # Utilities
```

### Old Structure (Deprecated)
```
lib/             # ← MOVE to src/utils/
groups/          # ← MOVE to src/modules/
```

## Files to Delete

The following files in the **project root** can be safely deleted:

```bash
# Old documentation (now in docs/)
rm EXAMPLES.md
rm VALIDATION.md

# Old source code directories
rm -r lib/          # → Moved to src/utils/
rm -r groups/       # → Moved to src/modules/

# Old validate utility (now in tools/)
rm validate.ps1     # → Moved to tools/validate.ps1
```

## Files to Keep

| File | Purpose |
|------|---------|
| `setup.ps1` | Main entry point - **DO NOT DELETE** |
| `README.md` | Main documentation |
| `CLEANUP.md` | This file (can be deleted after cleanup) |
| `src/` | New source structure - **DO NOT DELETE** |
| `docs/` | Documentation - **DO NOT DELETE** |
| `tools/` | Utilities like validate.ps1 |

## How to Clean Up

### Option 1: Manual Cleanup

```powershell
cd c:\Users\Gustavo\Documents\Projetos\windows_scripting_automation

# Delete old files
Remove-Item -Path "lib" -Recurse -Force
Remove-Item -Path "groups" -Recurse -Force
Remove-Item -Path "EXAMPLES.md" -Force
Remove-Item -Path "VALIDATION.md" -Force
Remove-Item -Path "validate.ps1" -Force  # Only if you copied to tools/

Write-Host "✓ Cleanup complete!"
```

### Option 2: PowerShell Script

```powershell
$oldFiles = @("lib", "groups", "EXAMPLES.md", "VALIDATION.md", "validate.ps1")
$oldFiles | ForEach-Object {
    $path = Join-Path (Get-Location) $_
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force
        Write-Host "✓ Deleted: $_"
    }
}
```

## After Cleanup

Your project will be clean and organized:

```
win-setup/
├── setup.ps1
├── README.md
├── src/
│   ├── core/
│   ├── utils/
│   └── modules/
├── docs/
├── tools/
├── config/
└── tests/
```

## References

- **Architecture**: See `docs/ARCHITECTURE.md` for project design
- **Examples**: See `docs/EXAMPLES.md` for how to add programs
- **Validation**: See `docs/VALIDATION.md` for validation details

## No Breaking Changes

- All functionality remains the same
- No changes to setup.ps1 usage
- All scripts are fully backward compatible
- Just better organized for maintainability

**Setup.ps1 command:**
```powershell
.\setup.ps1                    # Run all groups
.\setup.ps1 -Group dev         # Run specific group
.\setup.ps1 -SkipElevation     # Skip UAC (for testing)
```
