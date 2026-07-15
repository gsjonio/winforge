# winforge — Windows Post-Format Automation

[![PowerShell 7+](https://img.shields.io/badge/PowerShell-7.0%2B-blue)](https://github.com/PowerShell/PowerShell)
[![Release: v0.7.1](https://img.shields.io/badge/release-v0.7.1-blue)](https://github.com/gsjonio/winforge/releases/tag/v0.7.1)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Docs: EN/PT-BR](https://img.shields.io/badge/docs-EN%2FPT--BR-orange)](README.md)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy_Me_a_Coffee-gugamenezes-FFDD00?logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/gugamenezes)

**[English](#english) · [Português](#português)**

---

## English

winforge is a modular PowerShell 7+ framework for setting up Windows right after a
clean install. It installs your programs (multi-method fallback: winget →
Chocolatey → custom URL), applies privacy/performance tweaks, customizes the UI,
and enhances the shell — organized into groups so you run only what you want.
Detection is idempotent (re-running is safe), and the `optimize` group is **safe
by default** with an explicit escape hatch (`restore`) to undo its changes.

### Requirements

- **PowerShell 7.0+** — [download](https://github.com/PowerShell/PowerShell/releases)
- **Windows 10 or 11**
- **Administrator** — required for most groups (services, registry, fonts, power plan)
- **winget** — built-in on Windows 11; install "App Installer" from the Store on Windows 10

### Install / quick start

```powershell
git clone https://github.com/gsjonio/winforge.git
cd winforge
sudo .\setup.ps1            # all groups (except restore)
```

No `sudo`? Use the fallback launcher:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\setup.ps1"
```

### Command reference

`setup.ps1` parameters (from the `param()` block in [setup.ps1](setup.ps1)):

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `-Group` | `string` (ValidateSet: `base`, `dev`, `gaming`, `system`, `optimize`, `customize`, `shell`, `restore`) | *(all except `restore`)* | Run a single group. Omit to run every group except `restore`. |
| `-Profile` | `string` (ValidateSet: `safe`, `desktop`, `gaming`) | `safe` | Aggressiveness of the `optimize` group. Ignored by other groups. |
| `-SkipElevation` | `switch` | off | Skip the admin check (for testing in the current session). |
| `-WhatIf` | `switch` | off | Preview state-changing actions without applying them (supported by `restore`). |

**Groups:**

| Group | What it does |
| --- | --- |
| `base` | Firefox, Git, VLC, WinRAR, LibreOffice |
| `dev` | VS Code, GitHub Desktop, Claude, Python |
| `gaming` | Steam, Discord |
| `system` | NVIDIA App, AMD Radeon Software, CPU-Z, HWMonitor |
| `optimize` | Privacy + performance tweaks (safe by default; see `-Profile`) |
| `customize` | Windows Explorer / shell UI tweaks |
| `shell` | Oh My Posh (half-life theme) + Fira Code + PSReadLine |
| `restore` | Reverse `optimize`'s changes to Windows defaults (explicit-only) |

**`optimize` profiles** are cumulative — `safe ⊂ desktop ⊂ gaming`:

- `safe` — reversible privacy, visual, storage and low-impact service tweaks.
- `desktop` — adds power / 24-7 tweaks (High Performance, no sleep/hibernate).
- `gaming` — adds network/latency tweaks and aggressive service disables (SysMain, DPS, WinRM).

It **never** disables VSS/System Restore, StorSvc (Microsoft Store) or SmartScreen.

### Configuration reference

winforge has **no external config file**. Configuration is in-code: each program
is a hashtable in its group module under `src/modules/`, consumed by
`Install-Program` ([src/core/Installation.ps1](src/core/Installation.ps1)).

| Key | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `Name` | string | yes | — | Display name; used for detection and logging. |
| `WingetId` | string | yes | — | winget package id (primary install method). |
| `ChocoId` | string | no | *(none)* | Chocolatey package id (fallback if winget fails). |
| `Executable` | string | no | *(none)* | Command probed on PATH for idempotent detection. |
| `InstallerUrl` | string | no | *(none)* | Direct installer URL (last-resort fallback, run silently with `/S`). |

Example — add a program to a group:

```powershell
# in src/modules/dev.ps1, inside the $programs array
@{
    Name       = "Node.js"
    WingetId   = "OpenJS.NodeJS.LTS"
    ChocoId    = "nodejs-lts"   # optional
    Executable = "node"          # optional, enables skip-if-installed
}
```

The `optimize` group is configured differently: it is a data-driven tweak table
in [src/modules/optimize.ps1](src/modules/optimize.ps1), where each tweak is
tagged with a tier (`safe`/`desktop`/`gaming`) and selected by `-Profile` via the
pure `Get-OptimizeTweaks` function.

### Usage examples

```powershell
# Minimal — just install the essentials
sudo .\setup.ps1 -Group base

# Realistic — a dev + gaming desktop, more aggressive optimization
sudo .\setup.ps1 -Group dev
sudo .\setup.ps1 -Group optimize -Profile desktop
sudo .\setup.ps1 -Group shell

# Check what is already installed, without installing anything
.\tools\validate.ps1 -Group dev -ShowDetails

# Update installed apps (works even if the Microsoft Store is broken)
.\tools\update.ps1 -DryRun
sudo .\tools\update.ps1

# Undo optimize's changes — preview first, then apply
.\setup.ps1 -Group restore -WhatIf
sudo .\setup.ps1 -Group restore
```

### Safety

- **What it changes.** Program installs; registry values (privacy, UI, policies);
  Windows services (disable a subset); power plan and Storage Sense. See
  [docs/OPTIMIZE.md](docs/OPTIMIZE.md) and [docs/SERVICES.md](docs/SERVICES.md)
  for the exact keys/services and their risk.
- **Idempotent.** Every install checks current state first; registry writes are
  deterministic. Re-running is safe.
- **Reversible, but not all via Settings.** Visual/per-user tweaks revert through
  Windows Settings; HKLM policy keys and disabled services do not — use
  `-Group restore` (see [docs/RESTORE.md](docs/RESTORE.md)). `restore` supports
  `-WhatIf` to preview.
- **Elevation** is checked explicitly; without admin, winforge warns and (in a
  non-interactive shell) continues, skipping steps that need it.

### Documentation

The **[Wiki](https://github.com/gsjonio/winforge/wiki)** is the narrative layer;
`docs/` is the reference layer:
[OPTIMIZE](docs/OPTIMIZE.md) ·
[SERVICES](docs/SERVICES.md) ·
[RESTORE](docs/RESTORE.md) ·
[CUSTOMIZE](docs/CUSTOMIZE.md) ·
[SYSTEM](docs/SYSTEM.md) ·
[SHELL](docs/SHELL.md) ·
[ARCHITECTURE](docs/ARCHITECTURE.md) ·
[STRUCTURE](docs/STRUCTURE.md).

### Contributing

Git-flow: `main` is protected (PR-only), work off `develop`. See
[CONTRIBUTING.md](CONTRIBUTING.md). Conventional commits; PSScriptAnalyzer runs in
CI. A code-quality audit lives in [REFACTOR.md](REFACTOR.md).

### License & status

MIT ([LICENSE](LICENSE)). **Status:** active — current release **v0.7.1**.
If winforge saves you time, you can [buy me a coffee](https://buymeacoffee.com/gugamenezes).

---

## Português

winforge é um framework modular em PowerShell 7+ para configurar o Windows logo
após uma instalação limpa. Ele instala seus programas (fallback multi-método:
winget → Chocolatey → URL customizada), aplica ajustes de privacidade/desempenho,
customiza a UI e melhora o shell — organizado em grupos para você rodar só o que
quer. A detecção é idempotente (reexecutar é seguro), e o grupo `optimize` é
**seguro por padrão**, com uma saída de emergência (`restore`) para desfazer.

### Requisitos

- **PowerShell 7.0+** — [download](https://github.com/PowerShell/PowerShell/releases)
- **Windows 10 ou 11**
- **Administrador** — necessário na maioria dos grupos (serviços, registro, fontes, plano de energia)
- **winget** — nativo no Windows 11; instale o "Instalador de Aplicativo" pela Store no Windows 10

### Instalação / início rápido

```powershell
git clone https://github.com/gsjonio/winforge.git
cd winforge
sudo .\setup.ps1            # todos os grupos (exceto restore)
```

Sem `sudo`? Use o lançador alternativo:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\setup.ps1"
```

### Referência de comandos

Parâmetros do `setup.ps1` (do bloco `param()` em [setup.ps1](setup.ps1)):

| Parâmetro | Tipo | Padrão | Descrição |
| --- | --- | --- | --- |
| `-Group` | `string` (ValidateSet: `base`, `dev`, `gaming`, `system`, `optimize`, `customize`, `shell`, `restore`) | *(todos exceto `restore`)* | Roda um único grupo. Omita para rodar todos exceto `restore`. |
| `-Profile` | `string` (ValidateSet: `safe`, `desktop`, `gaming`) | `safe` | Agressividade do grupo `optimize`. Ignorado pelos outros grupos. |
| `-SkipElevation` | `switch` | desligado | Pula a checagem de admin (para testes na sessão atual). |
| `-WhatIf` | `switch` | desligado | Prévia das ações que alteram estado, sem aplicá-las (suportado pelo `restore`). |

**Grupos:**

| Grupo | O que faz |
| --- | --- |
| `base` | Firefox, Git, VLC, WinRAR, LibreOffice |
| `dev` | VS Code, GitHub Desktop, Claude, Python |
| `gaming` | Steam, Discord |
| `system` | NVIDIA App, AMD Radeon Software, CPU-Z, HWMonitor |
| `optimize` | Ajustes de privacidade + desempenho (seguro por padrão; veja `-Profile`) |
| `customize` | Ajustes de UI do Explorer / shell |
| `shell` | Oh My Posh (tema half-life) + Fira Code + PSReadLine |
| `restore` | Reverte as mudanças do `optimize` aos padrões do Windows (apenas explícito) |

**Perfis do `optimize`** são cumulativos — `safe ⊂ desktop ⊂ gaming`:

- `safe` — ajustes reversíveis de privacidade, visual, armazenamento e serviços de baixo impacto.
- `desktop` — adiciona energia / 24-7 (Alto Desempenho, sem suspensão/hibernação).
- `gaming` — adiciona rede/latência e desabilitação agressiva de serviços (SysMain, DPS, WinRM).

Ele **nunca** desabilita VSS/Restauração do Sistema, StorSvc (Microsoft Store) ou SmartScreen.

### Referência de configuração

O winforge **não tem arquivo de config externo**. A configuração é no código: cada
programa é um hashtable no módulo do grupo em `src/modules/`, consumido pelo
`Install-Program` ([src/core/Installation.ps1](src/core/Installation.ps1)).

| Chave | Tipo | Obrigatório | Padrão | Descrição |
| --- | --- | --- | --- | --- |
| `Name` | string | sim | — | Nome de exibição; usado na detecção e nos logs. |
| `WingetId` | string | sim | — | Id do pacote winget (método principal). |
| `ChocoId` | string | não | *(nenhum)* | Id do pacote Chocolatey (fallback se o winget falhar). |
| `Executable` | string | não | *(nenhum)* | Comando procurado no PATH para detecção idempotente. |
| `InstallerUrl` | string | não | *(nenhum)* | URL direta do instalador (último recurso, silencioso com `/S`). |

Exemplo — adicionar um programa a um grupo:

```powershell
# em src/modules/dev.ps1, dentro do array $programs
@{
    Name       = "Node.js"
    WingetId   = "OpenJS.NodeJS.LTS"
    ChocoId    = "nodejs-lts"   # opcional
    Executable = "node"          # opcional, habilita pular-se-instalado
}
```

O grupo `optimize` é configurado de outra forma: é uma tabela de tweaks orientada
a dados em [src/modules/optimize.ps1](src/modules/optimize.ps1), onde cada tweak
tem um nível (`safe`/`desktop`/`gaming`) e é selecionado por `-Profile` via a
função pura `Get-OptimizeTweaks`.

### Exemplos de uso

```powershell
# Mínimo — só instalar o essencial
sudo .\setup.ps1 -Group base

# Realista — desktop de dev + jogos, otimização mais agressiva
sudo .\setup.ps1 -Group dev
sudo .\setup.ps1 -Group optimize -Profile desktop
sudo .\setup.ps1 -Group shell

# Verificar o que já está instalado, sem instalar nada
.\tools\validate.ps1 -Group dev -ShowDetails

# Atualizar apps instalados (funciona mesmo com a Microsoft Store quebrada)
.\tools\update.ps1 -DryRun
sudo .\tools\update.ps1

# Desfazer as mudanças do optimize — prévia primeiro, depois aplicar
.\setup.ps1 -Group restore -WhatIf
sudo .\setup.ps1 -Group restore
```

### Segurança

- **O que muda.** Instalação de programas; valores de registro (privacidade, UI,
  políticas); serviços do Windows (desabilita um subconjunto); plano de energia e
  Sensor de Armazenamento. Veja [docs/OPTIMIZE.md](docs/OPTIMIZE.md) e
  [docs/SERVICES.md](docs/SERVICES.md) para as chaves/serviços exatos e o risco.
- **Idempotente.** Toda instalação verifica o estado atual antes; escritas de
  registro são determinísticas. Reexecutar é seguro.
- **Reversível, mas não tudo via Configurações.** Ajustes visuais/por usuário
  voltam pelas Configurações do Windows; chaves de política HKLM e serviços
  desabilitados não — use `-Group restore` (veja [docs/RESTORE.md](docs/RESTORE.md)).
  O `restore` suporta `-WhatIf` para prévia.
- **Elevação** é checada explicitamente; sem admin, o winforge avisa e (num shell
  não-interativo) continua, pulando os passos que exigem admin.

### Documentação

A **[Wiki](https://github.com/gsjonio/winforge/wiki)** é a camada narrativa;
`docs/` é a camada de referência:
[OPTIMIZE](docs/OPTIMIZE.md) ·
[SERVICES](docs/SERVICES.md) ·
[RESTORE](docs/RESTORE.md) ·
[CUSTOMIZE](docs/CUSTOMIZE.md) ·
[SYSTEM](docs/SYSTEM.md) ·
[SHELL](docs/SHELL.md) ·
[ARCHITECTURE](docs/ARCHITECTURE.md) ·
[STRUCTURE](docs/STRUCTURE.md).

### Contribuindo

Git-flow: a `main` é protegida (só via PR), trabalhe a partir da `develop`. Veja
[CONTRIBUTING.md](CONTRIBUTING.md). Conventional commits; o PSScriptAnalyzer roda
no CI. A auditoria de qualidade está em [REFACTOR.md](REFACTOR.md).

### Licença & status

MIT ([LICENSE](LICENSE)). **Status:** ativo — release atual **v0.7.1**.
Se o winforge te economiza tempo, você pode [me pagar um café](https://buymeacoffee.com/gugamenezes).
