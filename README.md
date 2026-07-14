# Windows Post-Format Automation Setup

[![PowerShell 7+](https://img.shields.io/badge/PowerShell-7.0%2B-blue)](https://github.com/PowerShell/PowerShell)
[![Release: v0.6.1](https://img.shields.io/badge/release-v0.6.1-blue)](https://github.com/gsjonio/windows-scripting-automation/releases/tag/v0.6.1)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Docs: EN/PT-BR](https://img.shields.io/badge/docs-EN%2FPT--BR-orange)](README.md)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy_Me_a_Coffee-gugamenezes-FFDD00?logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/gugamenezes)

🇺🇸 English

**windows-scripting-automation**: *Automate Windows post-format setup & system optimization.*

A modular PowerShell 7+ framework for configuring Windows after clean install:
program installation (15+ apps across 7 groups), system optimization (42+
registry/service tweaks), UI customization, and shell enhancement with Oh My
Posh. Smart idempotent detection, multi-method install fallback (Winget →
Chocolatey → custom URL), and production-ready with MIT license.

## Table of Contents

- [Features](#features)
- [Install](#install)
- [Architecture](#architecture)
- [Usage](#usage)
- [Optimization Details](#optimization-details)
- [Windows 11 Native `sudo`](#windows-11-native-sudo)
- [Shell Enhancement](#shell-enhancement)
- [Notes](#notes)
- [Support](#support)
- [Contributing](#contributing)
- [License](#license)

## Features

**Installation.** 15 programs organized in 7 modular groups (base, dev, gaming,
system, optimize, customize, shell). Smart detection with 4 methods (executable,
package manager, winget, registry), idempotent (safe to run multiple times),
and 3-method fallback chain (Winget → Chocolatey → custom URL) for max success.

**System Optimization.** 42+ tweaks covering services (15 disabled), power plan
(High Performance), visual effects, network (QoS/throttling disabled), storage
(TRIM, Shadow Copies disabled), and shell (Sleep/Hibernation off for 24/7
active). All reversible via Windows settings.

**UI Customization.** 18+ Windows Explorer and shell tweaks: dark mode, hidden
files, file extensions visible, context menu cleanup, taskbar optimization,
Start Menu customization, shortcut arrow removal, mouse settings.

**Shell Enhancement.** PowerShell 7.6.2 with Oh My Posh (half-life game-inspired
theme), Fira Code font (ligature support), PSReadLine (history search, autocomplete),
and bash-like aliases (ll, la, grep).

**Code Quality.** PSScriptAnalyzer linting, semantic versioning with microcommits,
GitHub Actions CI/CD (lint, validate, security, documentation), and branch
protection rulesets.

**Bilingual.** Full EN/PT-BR documentation for docs and changelog.

## Install

### Prerequisites

- PowerShell 7.0+ ([download](https://github.com/PowerShell/PowerShell/releases))
- Windows 10/11 with administrator access
- winget (built-in on Windows 11, Windows App Installer on Windows 10)

### Quick start

Clone and run with admin:

```powershell
git clone https://github.com/gsjonio/windows-scripting-automation.git
cd windows-scripting-automation
sudo .\setup.ps1
```

Or run a specific group:

```powershell
sudo .\setup.ps1 -Group shell      # Just shell enhancement
sudo .\setup.ps1 -Group optimize   # Just system optimizations
```

### Privileges by command

| Command | Privilege | Notes |
| --- | --- | --- |
| `setup.ps1` (all groups) | Admin | Services, registry, fonts, power plan |
| `setup.ps1 -Group base/dev/gaming/system` | Admin | Program installation |
| `setup.ps1 -Group optimize/customize/shell` | Admin | Registry, services, fonts |
| `.\tools\lint.ps1` | None | Code quality check |
| `.\tools\validate.ps1` | None | Installation verification |

Windows 11 users: enable native `sudo` in Settings → System → For developers
→ Terminal → "Enable sudo" to avoid UAC prompts. See [Windows 11 Native
`sudo`](#windows-11-native-sudo) below.

### Build from source

If you want to modify or inspect the code:

```powershell
git clone https://github.com/gsjonio/windows-scripting-automation.git
cd windows-scripting-automation

# Lint all PowerShell
.\tools\lint.ps1

# Validate scripts
.\tools\validate.ps1

# Run setup
sudo .\setup.ps1
```

## Architecture

**Organized by responsibility** — each layer has one job:

```text
setup.ps1 (entry point)
  ├─ src/utils/
  │  ├─ Logging.ps1         Color-coded log output (5 severity levels)
  │  ├─ System.ps1          UAC elevation, admin checks
  │  ├─ Validation.ps1      Program detection (4 methods)
  │  └─ Registry.ps1        Registry operations with path creation
  ├─ src/core/
  │  └─ Installation.ps1    Install-Program, 3-method fallback
  └─ src/modules/           Group handlers
     ├─ base.ps1           5 essential programs
     ├─ dev.ps1            4 dev tools
     ├─ gaming.ps1         2 gaming apps
     ├─ system.ps1         4 system utilities
     ├─ optimize.ps1       42 system tweaks
     ├─ customize.ps1      18 UI customizations
     └─ shell.ps1          Oh My Posh + Fira Code
```

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for full breakdown.

## Usage

### Run all groups

```powershell
# Windows 11 with sudo enabled
sudo .\setup.ps1

# Or fallback
powershell -NoProfile -ExecutionPolicy Bypass -File ".\setup.ps1"
```

### Run specific group

```powershell
sudo .\setup.ps1 -Group base       # Install 5 essential programs
sudo .\setup.ps1 -Group optimize   # Apply 42 system optimizations
sudo .\setup.ps1 -Group shell      # Install Oh My Posh + Fira Code
```

### Available groups

| Group | What | Programs/Tweaks |
| --- | --- | --- |
| **base** | Essential programs | Firefox, Git, VLC, WinRAR, LibreOffice (5) |
| **dev** | Development tools | VS Code, GitHub Desktop, Claude, Python (4) |
| **gaming** | Gaming apps | Steam, Discord (2) |
| **system** | System utilities | NVIDIA App, AMD Radeon, CPU-Z, HWMonitor (4) |
| **optimize** | System tweaks | 42 optimizations (services, power, network, storage) |
| **customize** | UI customizations | 18 Windows/shell tweaks |
| **shell** | Terminal enhancement | Oh My Posh (half-life theme) + Fira Code |

### Code quality

```powershell
# Lint all PowerShell scripts
.\tools\lint.ps1

# Lint specific directory
.\tools\lint.ps1 -Path .\src

# Show errors only
.\tools\lint.ps1 -Severity Error
```

### Validation

```powershell
# Check installation status of all programs
.\tools\validate.ps1

# Verify what's installed
Get-Package | Where-Object { $_.Name -like "*firefox*" }
```

## Optimization Details

### What gets optimized

**Services disabled (15):**
DiagTrack, dmwappushservice, OneSyncSvc, HvHost, SharedAccess, SysMain, StorSvc,
CscService, DPS, TabletInputService, TrkWks, stisvc, WMPNetworkSvc, WinRM, lfsvc

**Power & Performance:**

- High Performance power plan (forced)
- Sleep/Hibernation disabled (PC always active)
- USB Selective Suspend disabled (instant peripheral response)
- Network Throttling removed (faster updates)
- QoS Throttling disabled (full bandwidth for all apps)

**Storage:**

- Shadow Copies (System Restore) disabled
- Automatic TRIM enabled for SSDs
- Storage Sense configured (auto temp cleanup)

**Visual:**

- Animations and transitions disabled
- Window transparency/blur removed
- Tooltip animations disabled
- Dark mode enabled

**UI Customization (18 tweaks):**
File Explorer (hidden files, extensions, full path), context menu cleanup, taskbar
optimization, Start Menu customization, keyboard/mouse settings.

### Is it reversible?

Yes — all changes use standard Windows registry/services/settings. Reverse any
tweak via Settings, Services.msc, Registry Editor, or GPEdit. Most come with
undo instructions in [`docs/OPTIMIZE.md`](docs/OPTIMIZE.md).

## Windows 11 Native `sudo`

Windows 11 22H2+ includes native `sudo` — no need for `Start-Process -Verb RunAs`.

**Enable it:**

1. Open **Settings** → **System** → **For developers**
2. Scroll to **Terminal** section
3. Toggle **"Enable sudo"** ON

**Use it:**

```powershell
sudo .\setup.ps1
sudo .\setup.ps1 -Group shell
sudo Get-Process
```

Mimics Linux/macOS behavior; no UAC prompt on every admin command.

## Shell Enhancement

The **shell** group installs:

- **Oh My Posh 29.18.0** with half-life game-inspired theme (custom segments:
  user, path, git branch, timestamp)
- **Fira Code font** (7 variants, perfect ligature rendering)
- **PSReadLine** (history search with Ctrl+R/Ctrl+S, autocomplete)
- **Bash-like aliases**: `ll` (list), `la` (list all), `grep` (search)
- **Keyboard shortcuts**: Ctrl+A (line start), Ctrl+E (line end), word jump

Install with:

```powershell
sudo .\setup.ps1 -Group shell
```

Then open a new PowerShell 7.6.2 window to see the enhanced prompt.

Change themes: Edit `$env:APPDATA\oh-my-posh\config.json`. 100+ themes at
[ohmyposh.dev/docs/themes](https://ohmyposh.dev/docs/themes).

## Notes

### Installation success rates

| Method | Success |
| --- | --- |
| Winget only | ~70% |
| Winget + Chocolatey | ~95% |
| All 3 (+ custom URL) | ~99% |

### Platform support

- **Windows** is primary and fully tested (10/11, both 64-bit)
- **Linux** (WSL2) partially supported for some commands
- Requires PowerShell 7.0+ (works with 5.1 but not all features)

### About the code

- **60+ commits** with conventional messages (feat, fix, docs, chore)
- **Semantic versioning** (MAJOR.MINOR.PATCH)
- **GitHub Actions** (6 workflows) for lint, validate, security, release
- **PSScriptAnalyzer** configured in `.pslintrc` for code quality
- **MIT licensed** — free to use, modify, distribute

## Documentation

Full guides for each component:

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** — Project structure & design
- **[ADMIN-PRIVILEGES.md](docs/ADMIN-PRIVILEGES.md)** — 4 ways to elevate
- **[SHELL.md](docs/SHELL.md)** — Oh My Posh & Fira Code setup
- **[OPTIMIZE.md](docs/OPTIMIZE.md)** — 42 tweaks explained + how to undo
- **[CUSTOMIZE.md](docs/CUSTOMIZE.md)** — UI changes explained
- **[EXAMPLES.md](docs/EXAMPLES.md)** — How to add programs
- **[VALIDATION.md](docs/VALIDATION.md)** — Installation checks
- **[CHANGELOG.md](CHANGELOG.md)** — Version history (EN & PT-BR)

## Support

This project is free and open source. If it saves you setup time, you can
support development:

[![Buy Me a Coffee](https://img.shields.io/badge/Buy_Me_a_Coffee-gugamenezes-FFDD00?style=for-the-badge&logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/gugamenezes)

## Contributing

Want to contribute? See [CONTRIBUTING.md](CONTRIBUTING.md). This project follows
the [Code of Conduct](CODE_OF_CONDUCT.md).

## License

[MIT](LICENSE)
