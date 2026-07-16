# winforge

EN | [PT-BR](README.pt-BR.md)

[![PowerShell 7+](https://img.shields.io/badge/PowerShell-7.0%2B-blue)](https://github.com/PowerShell/PowerShell)
[![Release](https://img.shields.io/github/v/release/gsjonio/winforge)](https://github.com/gsjonio/winforge/releases/latest)
[![License: MIT](https://img.shields.io/github/license/gsjonio/winforge)](LICENSE)
[![Wiki](https://img.shields.io/badge/docs-wiki-blue?logo=github)](https://github.com/gsjonio/winforge/wiki)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy_Me_a_Coffee-gugamenezes-FFDD00?logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/gugamenezes)

Automate Windows post-format setup and system optimization.

winforge is a modular PowerShell 7+ framework for configuring Windows after a
clean install: it installs your programs (multi-method fallback: winget →
Chocolatey → custom URL), applies privacy/performance tweaks, customizes the UI,
and enhances the shell — grouped so you run only what you want. Detection is
idempotent, and the `optimize` group is safe by default with a `restore` escape
hatch to undo its changes.

> New to this? Start with the beginner's guide
> ([docs/GUIDE.md](docs/GUIDE.md), pt-BR: [docs/GUIDE.pt-BR.md](docs/GUIDE.pt-BR.md))
> instead: it explains every term in plain language. The
> [wiki](https://github.com/gsjonio/winforge/wiki) has a full command reference,
> FAQ, and troubleshooting.

## Table of Contents

- [Features](#features)
- [Install](#install)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Notes](#notes)
- [Support](#support)
- [License](#license)

## Features

- **Program installation** — apps across the `base`, `dev`, `gaming` and `system`
  groups, installed via a multi-method fallback (winget → Chocolatey → custom
  URL). Idempotent: already-installed programs are detected and skipped.
- **System optimization** — the `optimize` group is **safe by default** through a
  `-Profile` (`safe` / `desktop` / `gaming`, cumulative). It never disables
  VSS/System Restore, StorSvc (Microsoft Store), or SmartScreen.
- **UI customization** — File Explorer, taskbar, dark mode, mouse/keyboard tweaks.
- **Shell enhancement** — Oh My Posh (half-life theme), Fira Code, PSReadLine.
- **Restore** — `-Group restore` reverses `optimize`'s changes to Windows defaults.
- **Preview** — `-WhatIf` previews any group's actions without applying them.

## Install

### Requirements

- PowerShell 7.0+ ([download](https://github.com/PowerShell/PowerShell/releases))
- Windows 10 or 11
- Administrator (required for most groups: services, registry, fonts, power plan)
- winget (built-in on Windows 11; "App Installer" from the Store on Windows 10)

### Quick start

```powershell
git clone https://github.com/gsjonio/winforge.git
cd winforge
sudo .\setup.ps1            # all groups (except restore)
```

Without `sudo` (Windows 10):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\setup.ps1"
```

## Architecture

winforge is a set of dot-sourced PowerShell scripts, not a module: `setup.ps1`
loads the shared utils and core, then dispatches per-group modules by name. The
`optimize` group is a data-driven tweak table selected by `-Profile` through the
pure `Get-OptimizeTweaks` selector; all state changes route through
`Invoke-SystemConfig`, which supports `-WhatIf`. Full design:
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Project Structure

```text
setup.ps1              Entry point (-Group, -Profile, -SkipElevation, -WhatIf)
src/utils/             Logging, System (elevation), Validation, Registry
src/core/              Installation.ps1 (Install-Program, Invoke-SystemConfig)
src/modules/           One file per group (base, dev, gaming, system, optimize,
                       customize, shell, restore)
tools/                 lint.ps1, validate.ps1, update.ps1
tests/                 Pester tests
```

Full map: [docs/STRUCTURE.md](docs/STRUCTURE.md).

## Usage

`setup.ps1` parameters:

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `-Group` | `base`, `dev`, `gaming`, `system`, `optimize`, `customize`, `shell`, `restore` | *(all except `restore`)* | Run a single group; omit to run all except `restore`. |
| `-Profile` | `safe`, `desktop`, `gaming` | `safe` | Aggressiveness of the `optimize` group. Ignored by other groups. |
| `-SkipElevation` | switch | off | Skip the admin check (testing). |
| `-WhatIf` | switch | off | Preview actions on any group without applying them. |

Programs are declared in-code as hashtables in each group module under
`src/modules/`, consumed by `Install-Program`:

| Key | Required | Description |
| --- | --- | --- |
| `Name` | yes | Display name; used for detection and logging. |
| `WingetId` | yes | winget package id (primary install method). |
| `ChocoId` | no | Chocolatey package id (fallback if winget fails). |
| `Executable` | no | Command probed on PATH for skip-if-installed detection. |
| `InstallerUrl` | no | Direct installer URL (last-resort fallback, run silently). |
| `InstallerSha256` | no | Expected SHA256 of `InstallerUrl`; verified before it runs. |

Examples:

```powershell
sudo .\setup.ps1 -Group base                  # just the essentials
sudo .\setup.ps1 -Group optimize -Profile desktop
.\tools\validate.ps1 -Group dev -ShowDetails  # check installs, change nothing
.\tools\update.ps1 -DryRun                    # preview app updates
.\setup.ps1 -Group restore -WhatIf            # preview undoing optimize
sudo .\setup.ps1 -Group restore               # apply the undo
```

## Notes

- **What it changes.** Program installs; registry values (privacy, UI, policies);
  Windows services (a subset disabled); power plan and Storage Sense.
- **Idempotent.** Every install checks current state first and registry writes are
  deterministic, so re-running is safe.
- **Reversibility.** Visual/per-user tweaks revert through Windows Settings, but
  HKLM policy keys and disabled services do not — use `-Group restore`
  ([docs/RESTORE.md](docs/RESTORE.md)), which supports `-WhatIf`.
- **Safety.** The default `safe` profile never disables VSS, StorSvc or
  SmartScreen. See [docs/OPTIMIZE.md](docs/OPTIMIZE.md) and
  [docs/SERVICES.md](docs/SERVICES.md) for the exact keys/services and risks.

## Support

If winforge is useful to you, you can
[buy me a coffee](https://buymeacoffee.com/gugamenezes).

Bug reports and feature requests go through
[issues](https://github.com/gsjonio/winforge/issues). Security issues go through a
[private advisory](https://github.com/gsjonio/winforge/security/advisories/new)
instead.

## License

MIT - see [LICENSE](LICENSE).
