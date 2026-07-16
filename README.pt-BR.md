# winforge

[EN](README.md) | PT-BR

[![PowerShell 7+](https://img.shields.io/badge/PowerShell-7.0%2B-blue)](https://github.com/PowerShell/PowerShell)
[![Release](https://img.shields.io/github/v/release/gsjonio/winforge)](https://github.com/gsjonio/winforge/releases/latest)
[![License: MIT](https://img.shields.io/github/license/gsjonio/winforge)](LICENSE)
[![Wiki](https://img.shields.io/badge/docs-wiki-blue?logo=github)](https://github.com/gsjonio/winforge/wiki)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy_Me_a_Coffee-gugamenezes-FFDD00?logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/gugamenezes)

Automatize a configuração pós-formatação e a otimização do Windows.

winforge é um framework modular em PowerShell 7+ para configurar o Windows após
uma instalação limpa: instala seus programas (fallback multi-método: winget →
Chocolatey → URL customizada), aplica ajustes de privacidade/desempenho,
customiza a UI e melhora o shell — agrupado para você rodar só o que quer. A
detecção é idempotente, e o grupo `optimize` é seguro por padrão, com uma saída
de emergência `restore` para desfazer suas mudanças.

> Primeira vez? Comece pelo guia do iniciante
> ([docs/GUIDE.pt-BR.md](docs/GUIDE.pt-BR.md), EN: [docs/GUIDE.md](docs/GUIDE.md)):
> ele explica cada termo em linguagem simples. A
> [wiki](https://github.com/gsjonio/winforge/wiki) tem referência completa de
> comandos, FAQ e solução de problemas.

## Índice

- [Recursos](#recursos)
- [Instalação](#instalação)
- [Arquitetura](#arquitetura)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Uso](#uso)
- [Notas](#notas)
- [Apoio](#apoio)
- [Licença](#licença)

## Recursos

- **Instalação de programas** — apps nos grupos `base`, `dev`, `gaming` e
  `system`, instalados por um fallback multi-método (winget → Chocolatey → URL
  customizada). Idempotente: programas já instalados são detectados e pulados.
- **Otimização de sistema** — o grupo `optimize` é **seguro por padrão** por meio
  de um `-Profile` (`safe` / `desktop` / `gaming`, cumulativo). Ele nunca
  desabilita VSS/Restauração do Sistema, StorSvc (Microsoft Store) nem SmartScreen.
- **Customização de UI** — Explorer, barra de tarefas, modo escuro, mouse/teclado.
- **Aprimoramento do shell** — Oh My Posh (tema half-life), Fira Code, PSReadLine.
- **Restauração** — `-Group restore` reverte as mudanças do `optimize` aos padrões
  do Windows.
- **Prévia** — `-WhatIf` prevê as ações de qualquer grupo sem aplicá-las.

## Instalação

### Requisitos

- PowerShell 7.0+ ([download](https://github.com/PowerShell/PowerShell/releases))
- Windows 10 ou 11
- Administrador (necessário na maioria dos grupos: serviços, registro, fontes,
  plano de energia)
- winget (nativo no Windows 11; "Instalador de Aplicativo" pela Store no Windows 10)

### Início rápido

```powershell
git clone https://github.com/gsjonio/winforge.git
cd winforge
sudo .\setup.ps1            # todos os grupos (exceto restore)
```

Sem `sudo` (Windows 10):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\setup.ps1"
```

## Arquitetura

winforge é um conjunto de scripts PowerShell carregados via dot-source, não um
módulo: o `setup.ps1` carrega os utils e o core compartilhados e depois despacha
os módulos de grupo pelo nome. O grupo `optimize` é uma tabela de tweaks orientada
a dados, selecionada por `-Profile` através do seletor puro `Get-OptimizeTweaks`;
toda mudança de estado passa pelo `Invoke-SystemConfig`, que suporta `-WhatIf`.
Design completo: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Estrutura do Projeto

```text
setup.ps1              Ponto de entrada (-Group, -Profile, -SkipElevation, -WhatIf)
src/utils/             Logging, System (elevação), Validation, Registry
src/core/              Installation.ps1 (Install-Program, Invoke-SystemConfig)
src/modules/           Um arquivo por grupo (base, dev, gaming, system, optimize,
                       customize, shell, restore)
tools/                 lint.ps1, validate.ps1, update.ps1
tests/                 Testes Pester
```

Mapa completo: [docs/STRUCTURE.md](docs/STRUCTURE.md).

## Uso

Parâmetros do `setup.ps1`:

| Parâmetro | Tipo | Padrão | Descrição |
| --- | --- | --- | --- |
| `-Group` | `base`, `dev`, `gaming`, `system`, `optimize`, `customize`, `shell`, `restore` | *(todos exceto `restore`)* | Roda um grupo; omita para todos exceto `restore`. |
| `-Profile` | `safe`, `desktop`, `gaming` | `safe` | Agressividade do grupo `optimize`. Ignorado pelos outros. |
| `-SkipElevation` | switch | off | Pula a checagem de admin (testes). |
| `-WhatIf` | switch | off | Prévia das ações de qualquer grupo sem aplicá-las. |

Programas são declarados no código como hashtables em cada módulo de grupo em
`src/modules/`, consumidos pelo `Install-Program`:

| Chave | Obrigatório | Descrição |
| --- | --- | --- |
| `Name` | sim | Nome de exibição; usado na detecção e nos logs. |
| `WingetId` | sim | Id do pacote winget (método principal). |
| `ChocoId` | não | Id do pacote Chocolatey (fallback se o winget falhar). |
| `Executable` | não | Comando procurado no PATH para pular-se-instalado. |
| `InstallerUrl` | não | URL direta do instalador (último recurso, silencioso). |
| `InstallerSha256` | não | SHA256 esperado do `InstallerUrl`; verificado antes de rodar. |

Exemplos:

```powershell
sudo .\setup.ps1 -Group base                  # só o essencial
sudo .\setup.ps1 -Group optimize -Profile desktop
.\tools\validate.ps1 -Group dev -ShowDetails  # verifica installs, sem alterar
.\tools\update.ps1 -DryRun                    # prévia de atualizações de apps
.\setup.ps1 -Group restore -WhatIf            # prévia do undo do optimize
sudo .\setup.ps1 -Group restore               # aplica o undo
```

## Notas

- **O que muda.** Instalação de programas; valores de registro (privacidade, UI,
  políticas); serviços do Windows (um subconjunto desabilitado); plano de energia
  e Sensor de Armazenamento.
- **Idempotente.** Toda instalação verifica o estado atual antes e as escritas de
  registro são determinísticas, então reexecutar é seguro.
- **Reversibilidade.** Ajustes visuais/por usuário voltam pelas Configurações do
  Windows, mas chaves de política HKLM e serviços desabilitados não — use
  `-Group restore` ([docs/RESTORE.md](docs/RESTORE.md)), que suporta `-WhatIf`.
- **Segurança.** O perfil `safe` padrão nunca desabilita VSS, StorSvc ou
  SmartScreen. Veja [docs/OPTIMIZE.md](docs/OPTIMIZE.md) e
  [docs/SERVICES.md](docs/SERVICES.md) para as chaves/serviços exatos e os riscos.

## Apoio

Se o winforge é útil pra você, você pode
[me pagar um café](https://buymeacoffee.com/gugamenezes).

Relatos de bug e pedidos de recurso vão pelas
[issues](https://github.com/gsjonio/winforge/issues). Problemas de segurança vão
por um [advisory privado](https://github.com/gsjonio/winforge/security/advisories/new).

## Licença

MIT - veja [LICENSE](LICENSE).
