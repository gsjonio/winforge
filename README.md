# Windows Setup

[![](https://github.com/gsjonio/windows-scripting-automation/actions/workflows/lint.yml/badge.svg)](https://github.com/gsjonio/windows-scripting-automation/actions/workflows/lint.yml)
[![](https://github.com/gsjonio/windows-scripting-automation/actions/workflows/validate.yml/badge.svg)](https://github.com/gsjonio/windows-scripting-automation/actions/workflows/validate.yml)
[![](https://github.com/gsjonio/windows-scripting-automation/actions/workflows/security.yml/badge.svg)](https://github.com/gsjonio/windows-scripting-automation/actions/workflows/security.yml)
[![](https://github.com/gsjonio/windows-scripting-automation/actions/workflows/documentation.yml/badge.svg)](https://github.com/gsjonio/windows-scripting-automation/actions/workflows/documentation.yml)
[![](https://img.shields.io/badge/version-v0.5.3-blue)](https://github.com/gsjonio/windows-scripting-automation/releases/tag/v0.5.3)
[![](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![](https://img.shields.io/badge/PowerShell-7.0%2B-blue)](https://github.com/PowerShell/PowerShell)
[![](https://img.shields.io/badge/docs-EN%2FPT--BR-orange)](README.md)

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

- **Grupos modulares**: Organize por categoria (base, dev, gaming, system)
- **Execução seletiva**: Execute todos os grupos ou apenas os que precisa
- **Idempotente**: Verifica se programas já estão instalados
- **Logging detalhado**: Mensagens coloridas com status
- **Elevação automática**: Solicita privilégios de administrador quando necessário
- **Instalação multi-método**: Winget → Chocolatey → URL customizada
- **Validação inteligente**: 4 métodos de detecção de instalação

### Pré-requisitos

- PowerShell 7.0+
- Windows 10/11 com acesso administrativo
- winget

### Estrutura do Projeto

```text
src/
├── core/          Lógica de instalação (Install-Program, Set-SystemConfig)
├── utils/         Funções reutilizáveis (Logging, Validation, Registry, System)
└── modules/       Grupos de instalação (base, dev, gaming, system)

docs/              Documentação (Arquitetura, Exemplos, Guia de Validação)
tools/             Utilitários (lint.ps1, validate.ps1)
```

**Veja [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) para arquitetura detalhada.**

### Qualidade de Código

Linting PowerShell com **PSScriptAnalyzer**:

```powershell
# Instalar analisador (uma única vez)
Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force

# Verificar qualidade do código
.\tools\lint.ps1              # Lint de todos os scripts
.\tools\lint.ps1 -Path .\src  # Lint no diretório src
.\tools\lint.ps1 -Severity Error  # Apenas erros
```

Configuração: `.pslintrc`

### Grupos Disponíveis (7 total, 15 programas)

**Base (5)**: Firefox, Git, VLC, WinRAR, LibreOffice
**Dev (4)**: VS Code, GitHub Desktop, Claude, Python
**Gaming (2)**: Steam, Discord
**Sistema (4)**: NVIDIA App, AMD Radeon, CPU-Z, HWMonitor
**Optimize**: System optimizations & privacy tweaks (16+ configs)
**Customize**: Windows UI & shell customizations (18+ configs)
**Shell**: PowerShell enhancement with Oh My Posh (half-life theme) + Fira Code

### Início Rápido

```powershell
# Executar todos os grupos (17 programas)
.\setup.ps1

# Executar com privilégios de administrador
powershell -NoProfile -ExecutionPolicy Bypass -File ".\setup.ps1"

# Ou executar grupo específico
.\setup.ps1 -Group base       # 5 programas essenciais
.\setup.ps1 -Group dev        # 4 ferramentas desenvolvimento
.\setup.ps1 -Group gaming     # 2 programas jogos
.\setup.ps1 -Group system     # 4 utilitários de sistema
.\setup.ps1 -Group optimize   # Otimizações de privacidade e performance
.\setup.ps1 -Group customize  # Customizações de UI do Windows
.\setup.ps1 -Group shell      # Oh My Posh + Fira Code + customizações PowerShell

# Validar instalações
.\tools\validate.ps1
```

### Windows 11 Native `sudo` Support

Windows 11 (22H2+) supports native `sudo` command - no need for `Start-Process -Verb RunAs`!

**Enable sudo:**

1. Open **Settings** → **System** → **For developers**
2. Scroll to **Terminal** section
3. Toggle **"Habilitar sudo"** (Enable sudo) **ON**

**Usage:**

```powershell
# Run script with admin privileges
sudo .\setup.ps1

# Run specific group
sudo .\setup.ps1 -Group shell

# Run any command as admin
sudo Get-Process
sudo code
```

**Info:** This mimics Linux/macOS `sudo` behavior, making scripts more portable across platforms.

### Oh My Posh with Half-Life Theme

The **shell** group installs **Oh My Posh** with the **half-life** theme (a modern, game-inspired prompt).

**Features:**

- 🎮 Game-inspired prompt with custom segments
- 🔄 Git repository status (branch, changes)
- 🔤 User name and directory display
- ⏱️ Timestamps and command status
- 🎨 Fira Code font with perfect ligature rendering
- ⚙️ Fully customizable via JSON configuration

**Install shell enhancement:**

```powershell
sudo .\setup.ps1 -Group shell
```

**Customize theme:** Edit `$env:APPDATA\oh-my-posh\config.json`

**Available themes:** 100+ themes at [ohmyposh.dev/docs/themes](https://ohmyposh.dev/docs/themes)

---

### Português - Suporte `sudo` Nativo do Windows 11

Windows 11 (22H2+) suporta comando `sudo` nativo - sem precisa usar `Start-Process -Verb RunAs`!

**Ativar sudo:**

1. Abra **Configurações** → **Sistema** → **Para desenvolvedores**
2. Role até a seção **Terminal**
3. Ative **"Habilitar sudo"** com o toggle

**Uso:**

```powershell
# Executar script com privilégios admin
sudo .\setup.ps1

# Executar grupo específico
sudo .\setup.ps1 -Group shell

# Executar qualquer comando como admin
sudo Get-Process
sudo code
```

**Info:** Isso imita o comportamento de `sudo` do Linux/macOS, tornando scripts mais portáveis entre plataformas.

### Oh My Posh com Tema Half-Life

O grupo **shell** instala **Oh My Posh** com o tema **half-life** (um prompt moderno e inspirado em jogos).

**Características:**

- 🎮 Prompt inspirado em games com segmentos customizados
- 🔄 Status do repositório Git (branch, alterações)
- 🔤 Exibição de usuário e diretório
- ⏱️ Timestamps e status de comando
- 🎨 Fonte Fira Code com renderização perfeita de ligaduras
- ⚙️ Totalmente customizável via configuração JSON

**Instalar aprimoramento do shell:**

```powershell
sudo .\setup.ps1 -Group shell
```

**Customizar tema:** Edite `$env:APPDATA\oh-my-posh\config.json`

**Temas disponíveis:** 100+ temas em [ohmyposh.dev/docs/themes](https://ohmyposh.dev/docs/themes)

---

### Documentação

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Estrutura e design do projeto
- **[EXAMPLES.md](docs/EXAMPLES.md)** - Como adicionar programas e configurações
- **[VALIDATION.md](docs/VALIDATION.md)** - Guia de validação de instalação
- **[STRUCTURE.md](docs/STRUCTURE.md)** - Referência rápida de todos os arquivos
- **[CLEANUP.md](docs/CLEANUP.md)** - Como limpar arquivos antigos (ao atualizar)
- **[GITHUB-ACTIONS.md](docs/GITHUB-ACTIONS.md)** - Guia de automação CI/CD
