# Windows Post-Format Automation Setup

[English](#english) | [Português](#português)

> **📁 Organized by Responsibility** — See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for project structure

## English

### Overview

A PowerShell 7+ automation framework for configuring Windows systems after a clean installation.

### Features

- **Modular groups**: Organize setups by category (base, dev, gaming, or custom)
- **Selective execution**: Run all groups or target specific ones
- **Idempotent**: Checks if programs are already installed
- **Detailed logging**: Color-coded status messages
- **Automatic elevation**: Requests administrator privileges if needed
- **Multi-method installation**: Winget → Chocolatey → Custom URL fallback chain
- **Smart validation**: 4-method program detection (executable, package, winget, registry)

### Prerequisites

- PowerShell 7.0+
- Windows 10/11 with administrator access
- winget

### Project Structure

```text
src/
├── core/          Core installation logic (Install-Program, Apply-SystemConfig)
├── utils/         Reusable functions (Logging, Validation, Registry, System)
└── modules/       Installation groups (base, dev, gaming)

docs/              Documentation (Architecture, Examples, Validation guide)
tools/             Utilities (validate.ps1)
```

**See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for detailed architecture.**

### Code Quality

PowerShell linting with **PSScriptAnalyzer**:

```powershell
# Install analyzer (one-time)
Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force

# Check code quality
.\tools\lint.ps1              # Lint all scripts
.\tools\lint.ps1 -Path .\src  # Lint src directory
.\tools\lint.ps1 -Severity Error  # Only show errors
```

Configuration: `.pslintrc`

### Quick Start

```powershell
# Run all groups
.\setup.ps1

# Run specific group
.\setup.ps1 -Group dev
.\setup.ps1 -Group gaming

# Validate installations
.\tools\validate.ps1
```

### Documentation

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Project structure and design
- **[EXAMPLES.md](docs/EXAMPLES.md)** - How to add programs and configurations
- **[VALIDATION.md](docs/VALIDATION.md)** - Installation validation guide
- **[STRUCTURE.md](docs/STRUCTURE.md)** - Quick reference of all files
- **[CLEANUP.md](docs/CLEANUP.md)** - How to clean up old files (if upgrading)

---

## Português

### Visão Geral

Um framework de automação PowerShell 7+ para configurar sistemas Windows após instalação limpa.

### Características

- **Grupos modulares**: Organize por categoria (base, dev, gaming)
- **Execução seletiva**: Execute todos ou grupos específicos
- **Idempotente**: Verifica se programas já estão instalados
- **Logging detalhado**: Mensagens coloridas
- **Elevação automática**: Solicita privilégios de administrador

### Início Rápido

```powershell
# Executar todos os grupos
.\setup.ps1

# Executar grupo específico
.\setup.ps1 -Group dev
```
