# Project Architecture

## Directory Structure

```
win-setup/
├── setup.ps1                    # Main entry point
├── validate.ps1                 # Validation utility
├── README.md                    # Main documentation
│
├── src/                         # Source code
│   ├── core/                    # Core installation logic
│   │   ├── Installation.ps1     # Install-Program, Apply-SystemConfig
│   │   └── Configuration.ps1    # (Reserved) System configuration
│   │
│   ├── utils/                   # Utility functions
│   │   ├── Logging.ps1          # Write-Log, Write-GroupHeader, Write-Section
│   │   ├── Validation.ps1       # Test-ProgramInstalled, Get-InstallationStatus, Show-InstallationReport
│   │   ├── Registry.ps1         # Set-RegistryValue, Get-RegistryValue, Enable-Feature, Disable-Feature
│   │   └── System.ps1           # Test-IsElevated, Request-Elevation, Wait-ProcessExit
│   │
│   └── modules/                 # Installation groups (PowerShell Modules)
│       ├── base.psm1            # Essential programs & configuration
│       ├── dev.psm1             # Development tools & configuration
│       └── gaming.psm1          # Gaming programs & configuration
│
├── docs/                        # Documentation
│   ├── ARCHITECTURE.md          # This file
│   ├── EXAMPLES.md              # Configuration examples
│   └── VALIDATION.md            # Validation guide
│
├── tools/                       # Utility scripts
│   └── (Reserved for future tools)
│
├── config/                      # Configuration files
│   └── (Reserved for future config)
│
└── tests/                       # Test scripts
    └── (Reserved for future tests)
```

## Responsibility Breakdown

### `setup.ps1` (Main Entry Point)
- Orchestrates the entire setup process
- Handles command-line arguments (-Group, -SkipElevation)
- Loads and executes installation modules
- Manages elevation/UAC prompts

### `src/core/`
**Core business logic for installation and configuration**

- **Installation.ps1**
  - `Install-Program()` - Main installation function (Winget + fallback)
  - `Install-FromUrl()` - Custom installer download and execution
  - `Apply-SystemConfig()` - Apply system configurations with error handling

### `src/utils/`
**Reusable utilities and helpers**

- **Logging.ps1** - Output formatting
  - `Write-Log()` - Timestamped colored log messages
  - `Write-GroupHeader()` - Format group section headers
  - `Write-Section()` - Generic section headers

- **Validation.ps1** - Installation detection
  - `Test-ProgramInstalled()` - Quick boolean check (4 detection methods)
  - `Get-InstallationStatus()` - Detailed status with method info
  - `Show-InstallationReport()` - Visual report for multiple programs

- **System.ps1** - System operations
  - `Test-IsElevated()` - Check admin privileges
  - `Request-Elevation()` - Request UAC elevation
  - `Wait-ProcessExit()` - Wait for process completion
  - `Get-InstalledPrograms()` - List all installed packages

- **Registry.ps1** - Windows registry operations
  - `Set-RegistryValue()` - Set registry entries (creates paths)
  - `Get-RegistryValue()` - Read registry entries
  - `Enable-Feature()` / `Disable-Feature()` - Windows optional features
  - `Set-FileAssociation()` - Configure file type associations

### `src/modules/`
**Installation groups (PowerShell Modules)**

Each group contains:
- `Install-{Group}Programs()` - List and install programs
- `Set-{Group}Configuration()` - Apply group-specific configurations

Supported groups:
- **base.psm1** - Always executed; essential programs
- **dev.psm1** - Development tools and IDEs
- **gaming.psm1** - Gaming programs and configs

### `docs/`
**User-facing documentation**

- **ARCHITECTURE.md** - This file; explains project structure
- **EXAMPLES.md** - How to add programs and configurations
- **VALIDATION.md** - Comprehensive validation guide

## Loading Order

When `setup.ps1` executes with `-Group base`:

1. **Load Logging** → `.\src\utils\Logging.ps1`
2. **Load System Utils** → `.\src\utils\System.ps1`
3. **Load Validation** → `.\src\utils\Validation.ps1`
4. **Load Registry Utils** → `.\src\utils\Registry.ps1`
5. **Load Core Installation** → `.\src\core\Installation.ps1`
6. **Load Module** → `.\src\modules\base.psm1`
7. **Execute Functions**
   - `Install-BasePrograms()`
   - `Set-BaseConfiguration()`

## Function Dependencies

```
setup.ps1
  ├─ Logging.ps1 (required first)
  ├─ System.ps1 (elevation, privileges)
  ├─ Validation.ps1 (check installations)
  ├─ Registry.ps1 (system config)
  ├─ Installation.ps1 (core logic)
  │  └─ Validation.ps1 (detect already-installed)
  │  └─ Registry.ps1 (apply config)
  └─ modules/{group}.psm1 (installation groups)
     ├─ Installation.ps1 (Install-Program)
     ├─ Logging.ps1 (Write-GroupHeader, Write-Log)
     └─ Registry.ps1 (Set-RegistryValue)
```

## Adding New Features

### Add a New Installation Group

1. Create `src/modules/mygroup.psm1`
2. Define `Install-MygroupPrograms()`
3. Define `Set-MygroupConfiguration()`
4. Update `setup.ps1` to include in `$groupsToRun`

### Add a New Utility Function

1. Add to appropriate file in `src/utils/`
   - Logging? → `Logging.ps1`
   - System check? → `System.ps1`
   - Installation detection? → `Validation.ps1`
   - Registry? → `Registry.ps1`

2. Import in dependent files:
   ```powershell
   . "$libPath\utils\Logging.ps1"
   ```

### Add System Configuration

1. Edit appropriate module in `src/modules/`
2. Use `Apply-SystemConfig` in `Set-{Group}Configuration()`:
   ```powershell
   Apply-SystemConfig "Enable Dark Mode" {
       Set-RegistryValue -Path "HKCU:\Software\..." -Name "..." -Value 0 -Type DWord
   }
   ```

## Design Principles

1. **Single Responsibility** - Each file has one clear purpose
2. **Modularity** - Groups are independent; can be enabled/disabled
3. **Reusability** - Utilities are shared across all modules
4. **Idempotency** - Installation checks prevent redundant work
5. **Logging** - All operations are logged with clear status
6. **Testability** - Functions are small and independently verifiable

## Performance Considerations

- **Validation**: ~1-2 seconds per program (4 detection methods)
- **Installation**: Depends on program size and internet speed
- **Total**: 5-10 minutes for ~50 programs (varies by system)

Optimize by:
- Providing executable name for faster detection
- Using Winget IDs when available
- Grouping related programs

## Future Enhancements

- [ ] Configuration file format (YAML/JSON) for declarative setup
- [ ] Dry-run mode to preview changes
- [ ] Rollback functionality
- [ ] Installation parallelization
- [ ] Post-installation verification tests
- [ ] Integration with Chocolatey/Scoop
- [ ] Cloud sync for settings
