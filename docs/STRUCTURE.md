# Quick Reference - Project Structure

## File Organization by Responsibility

### Entry Points

| File | Purpose |
| ------ | --------- |
| `setup.ps1` | Main automation script - orchestrates everything |
| `tools/validate.ps1` | Validation utility for checking installations |

### Core Logic (`src/core/`)

| File | Functions | Purpose |
| ------ | ----------- | --------- |
| `Installation.ps1` | `Install-Program()` | Install via Winget with fallback |
| | `Install-FromUrl()` | Download and execute custom installer |
| | `Invoke-SystemConfig()` | Apply system configuration with error handling |

### Utilities (`src/utils/`)

| File | Functions | Purpose |
| ------ | ----------- | --------- |
| `Logging.ps1` | `Write-Log()` | Timestamped colored log output |
| | `Write-GroupHeader()` | Format group section headers |
| | `Write-Section()` | Generic section headers |
| `Validation.ps1` | `Test-ProgramInstalled()` | Quick check: is program installed? |
| | `Get-InstallationStatus()` | Detailed status with detection method |
| | `Show-InstallationReport()` | Visual report for multiple programs |
| `Registry.ps1` | `Set-RegistryValue()` | Set registry entries (creates paths) |
| | `Remove-RegistryValue()` | Remove a value (fall back to Windows default) |
| | `Get-RegistryValue()` | Read registry entries |
| | `Enable-Feature()` | Enable Windows optional feature |
| | `Disable-Feature()` | Disable Windows optional feature |
| | `Set-FileAssociation()` | Configure file type associations |
| `System.ps1` | `Test-IsElevated()` | Check admin privileges |
| | `Request-Elevation()` | Request UAC elevation |
| | `Wait-ProcessExit()` | Wait for process completion |
| | `Get-InstalledPrograms()` | List all installed packages |

### Installation Modules (`src/modules/`)

| File | Functions | Purpose |
| ------ | ----------- | --------- |
| `base.ps1` | `Install-BasePrograms()` | Install essential programs |
| | `Set-BaseConfiguration()` | Apply base system configuration |
| `dev.ps1` | `Install-DevPrograms()` | Install development tools |
| | `Set-DevConfiguration()` | Apply development configuration |
| `gaming.ps1` | `Install-GamingPrograms()` | Install gaming programs |
| | `Set-GamingConfiguration()` | Apply gaming configuration |
| `optimize.ps1` | `Get-OptimizeTweaks()` | Pure selector: tweak table filtered by `-Profile` |
| | `Set-OptimizeConfiguration()` | Apply optimize tweaks for a profile |
| `restore.ps1` | `Restore-SafeDefaults()` | Reverse optimize's changes to Windows defaults |
| | `Set-RestoreConfiguration()` | Entry point for `-Group restore` (supports `-WhatIf`) |

### Documentation (`docs/`)

| File | Content |
| ------ | --------- |
| `ARCHITECTURE.md` | Project design, dependencies, future enhancements |
| `EXAMPLES.md` | How to add programs, configurations, troubleshooting |
| `VALIDATION.md` | Installation validation methods, detection details |

### Configuration & Tools

| File | Purpose |
| ------ | --------- |
| `config/` | (Reserved) Future configuration files |
| `tests/` | (Reserved) Future test scripts |

## Loading Order (setup.ps1)

```text
1. Logging.ps1       (needed by everything)
2. System.ps1        (elevation checks)
3. Validation.ps1    (installation detection)
4. Registry.ps1      (system operations)
5. Installation.ps1  (core logic)
6. modules/*.ps1     (user's chosen group)
```

## Function Dependencies

```text
setup.ps1 (entry point)
  ├─ Logging.ps1
  │  └─ Write-Log()              ← Used everywhere
  │  └─ Write-GroupHeader()      ← Used in modules
  │
  ├─ System.ps1
  │  └─ Request-Elevation()      ← Check admin
  │
  ├─ Validation.ps1
  │  └─ Test-ProgramInstalled()  ← Check before install
  │
  ├─ Registry.ps1
  │  └─ Set-RegistryValue()      ← Apply configurations
  │
  ├─ Installation.ps1
  │  ├─ Install-Program()        ← Main install function
  │  │  └─ Test-ProgramInstalled()
  │  └─ Invoke-SystemConfig()     ← Execute config blocks
  │
  └─ modules/{group}.ps1
     ├─ Install-{Group}Programs()
     │  └─ Install-Program()     ← Delegates to core
     └─ Set-{Group}Configuration()
        └─ Invoke-SystemConfig()  ← Delegates to core
```

## Responsibility Summary

### `src/core/` - What to do?

**Installation and configuration application logic**

- How to install programs
- How to apply system configurations
- Error handling and fallbacks

### `src/utils/` - How to do it?

**Reusable utilities for common operations**

- How to log output
- How to detect installations
- How to manipulate the registry
- How to work with system privileges

### `src/modules/` - What to install?

**Declaration of what to install and configure**

- Which programs belong to each group
- What configurations to apply
- Uses core logic via `Install-Program()` and `Invoke-SystemConfig()`

### `docs/` - Documentation

**User and developer guides**

- How the project is organized
- How to add new programs
- How validation works

## Adding New Features

### Add a new installation group?

→ Create `src/modules/mygroup.ps1`

### Add a new utility function?

→ Add to appropriate file in `src/utils/`

- Logging output? → `Logging.ps1`
- System check? → `System.ps1`
- Installation detection? → `Validation.ps1`
- Registry manipulation? → `Registry.ps1`

### Add a new core installation method?

→ Modify `src/core/Installation.ps1`

### Add system configuration?

→ Add to `Set-{Group}Configuration()` in modules

## File Size Reference

Optimized for clarity and maintainability:

- `Installation.ps1` - ~70 lines (core logic)
- `Logging.ps1` - ~45 lines (simple output)
- `Validation.ps1` - ~180 lines (4 detection methods)
- `Registry.ps1` - ~60 lines (registry operations)
- `System.ps1` - ~35 lines (system utilities)
- `base.ps1` - ~40 lines (template)
- `dev.ps1` - ~45 lines (template)
- `gaming.ps1` - ~45 lines (template)

**Total: ~520 lines of focused, well-organized code**

## Finding Specific Functions

| Looking for... | File | Function |
| --- | --- | --- |
| Log output | `src/utils/Logging.ps1` | `Write-Log()` |
| Check if installed | `src/utils/Validation.ps1` | `Test-ProgramInstalled()` |
| Change registry | `src/utils/Registry.ps1` | `Set-RegistryValue()` |
| Request admin | `src/utils/System.ps1` | `Request-Elevation()` |
| Main install | `src/core/Installation.ps1` | `Install-Program()` |
| Apply config | `src/core/Installation.ps1` | `Invoke-SystemConfig()` |
| Base programs | `src/modules/base.ps1` | `Install-BasePrograms()` |
| Dev config | `src/modules/dev.ps1` | `Set-DevConfiguration()` |

---

**Need help?** See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed design documentation.
