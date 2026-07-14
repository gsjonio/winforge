# PowerShell Enhancement with Oh My Posh

[English](#english) | [Português](#português)

## English

### Overview

The `shell` module transforms PowerShell into a modern, feature-rich terminal experience similar to **oh-my-zsh** in Linux. Installs Oh My Posh, Fira Code font, and configures PowerShell with intelligent autocomplete and git integration.

### Usage

```powershell
# Run shell enhancement module
.\setup.ps1 -Group shell

# Or include in full setup
.\setup.ps1  # includes shell in default run
```

### Features Installed

#### 1. Oh My Posh

- Modern, customizable prompt with themes (dracula, nord, powerlevel10k, etc)
- Git repository status display
- Directory indicators and visual cues
- Multi-line prompt support

#### 2. Fira Code Font

- Modern monospace font designed for code
- Ligature support for operators (==, =>, ->, etc)
- Better readability for programming

#### 3. PSReadLine Enhancements

- **History Search**: Ctrl+R for reverse search, Ctrl+S for forward search
- **Tab Completion**: Tab key shows interactive menu (like bash)
- **Prediction**: Shows suggestions from command history
- **Keyboard Shortcuts**:
  - Ctrl+A: Go to line beginning
  - Ctrl+E: Go to line end
  - Ctrl+LeftArrow: Jump back one word
  - Ctrl+RightArrow: Jump forward one word

#### 4. Custom Aliases (bash-like)

- `ll` - List files in long format
- `la` - List all files including hidden
- `grep` - PowerShell equivalent of grep
- `touch` - Create empty files

#### 5. Windows Terminal Integration

- Auto-configures Windows Terminal to use Fira Code
- Font size set to 10pt (adjustable)

### What Gets Configured

**PowerShell Profile ($PROFILE)**

```text
~\Documents\PowerShell\profile.ps1
```

The module creates or updates this file with:

- Oh My Posh initialization
- PSReadLine configuration
- Custom aliases
- History search setup
- Terminal title display

**Windows Terminal Config**

```text
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

Configures:

- Default font: Fira Code
- Font size: 10pt

### Prerequisites

- Windows 10 or 11
- Administrator privileges
- PowerShell 7+
- Windows Terminal (recommended, optional)

### After Installation

**Restart PowerShell** to see the new prompt and features:

```powershell
# Close current PowerShell window and open a new one
# You'll see:
#
# ╭─ user @ hostname in ~/path/to/dir on main [+!~]
# ╰─ $ 
```

### Changing the Theme

Oh My Posh comes with 100+ themes. To list and change:

```powershell
# List available themes
Get-ChildItem -Path "$(oh-my-posh get shell)/Themes"

# Set theme (edit $PROFILE)
oh-my-posh init pwsh --config "$(oh-my-posh get shell)/Themes/dracula.omp.json" | Out-String | Invoke-Expression

# Popular themes: dracula, nord, powerlevel10k, catppuccin, tokyo, gruvbox
```

### Customizing Aliases

Edit `$PROFILE` to add or modify aliases:

```powershell
# Add custom alias
Set-Alias -Name myalias -Value Get-SomeCommand -Force
```

### Keyboard Shortcuts Reference

| Shortcut | Action |
| --- | --- |
| Tab | Show completion menu |
| Ctrl+R | Search command history (reverse) |
| Ctrl+S | Search command history (forward) |
| Ctrl+A | Beginning of line |
| Ctrl+E | End of line |
| Ctrl+LeftArrow | Previous word |
| Ctrl+RightArrow | Next word |
| Ctrl+C | Cancel command |
| Ctrl+V | Paste |

### Troubleshooting

**Prompt not showing?**

- Restart PowerShell
- Run: `oh-my-posh --version`

**Font not working?**

- Install Windows Terminal
- Restart Terminal
- Font takes effect on next session

**Autocomplete not working?**

- Edit `$PROFILE`: `code $PROFILE`
- Verify PSReadLine section exists
- Reload profile: `. $PROFILE`

### Uninstallation

To revert to default PowerShell:

```powershell
# Remove Oh My Posh initialization from $PROFILE
code $PROFILE

# Remove Oh My Posh program
winget uninstall JanDeDobbeleer.OhMyPosh
```

---

## Português

### Visão Geral

O módulo `shell` transforma o PowerShell em um terminal moderno e rico em recursos similar ao **oh-my-zsh** no Linux. Instala Oh My Posh, fonte Fira Code e configura PowerShell com autocomplete inteligente e integração git.

### Uso

```powershell
# Executar módulo de aprimoramento do shell
.\setup.ps1 -Group shell

# Ou incluir na configuração completa
.\setup.ps1  # inclui shell por padrão
```

### Features Instaladas

#### 1. Oh My Posh

- Prompt moderno e customizável com temas (dracula, nord, powerlevel10k, etc)
- Exibição de status do repositório Git
- Indicadores de diretório e pistas visuais
- Suporte a prompt de múltiplas linhas

#### 2. Fonte Fira Code

- Fonte monoespaçada moderna projetada para código
- Suporte a ligaduras para operadores (==, =>, ->, etc)
- Melhor legibilidade para programação

#### 3. Aprimoramentos PSReadLine

- **Busca em Histórico**: Ctrl+R para busca reversa, Ctrl+S para busca direta
- **Conclusão com Tab**: Menu interativo (como bash)
- **Previsão**: Mostra sugestões do histórico de comandos
- **Atalhos de Teclado**:
  - Ctrl+A: Início da linha
  - Ctrl+E: Fim da linha
  - Ctrl+LeftArrow: Pular palavra anterior
  - Ctrl+RightArrow: Pular próxima palavra

#### 4. Aliases Customizados (estilo bash)

- `ll` - Listar arquivos em formato longo
- `la` - Listar todos os arquivos incluindo ocultos
- `grep` - Equivalente PowerShell do grep
- `touch` - Criar arquivos vazios

#### 5. Integração com Windows Terminal

- Auto-configura Windows Terminal para usar Fira Code
- Tamanho da fonte definido em 10pt (ajustável)

### O Que Gets Configurado

**Perfil do PowerShell ($PROFILE)**

```text
~\Documents\PowerShell\profile.ps1
```

O módulo cria ou atualiza este arquivo com:

- Inicialização de Oh My Posh
- Configuração de PSReadLine
- Aliases customizados
- Configuração de busca de histórico
- Exibição de título do terminal

**Configuração do Windows Terminal**

```text
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

Configura:

- Fonte padrão: Fira Code
- Tamanho da fonte: 10pt

### Pré-requisitos

- Windows 10 ou 11
- Privilégios de administrador
- PowerShell 7+
- Windows Terminal (recomendado, opcional)

### Após a Instalação

**Reinicie o PowerShell** para ver o novo prompt:

```powershell
# Feche a janela atual do PowerShell e abra uma nova
# Você verá:
#
# ╭─ user @ hostname in ~/path/to/dir on main [+!~]
# ╰─ $ 
```

### Mudando o Tema

Oh My Posh vem com 100+ temas. Para listar e alterar:

```powershell
# Listar temas disponíveis
Get-ChildItem -Path "$(oh-my-posh get shell)/Themes"

# Definir tema (edite $PROFILE)
oh-my-posh init pwsh --config "$(oh-my-posh get shell)/Themes/dracula.omp.json" | Out-String | Invoke-Expression

# Temas populares: dracula, nord, powerlevel10k, catppuccin, tokyo, gruvbox
```

### Personalizando Aliases

Edite `$PROFILE` para adicionar ou modificar aliases:

```powershell
# Adicionar alias customizado
Set-Alias -Name meuAlias -Value Get-AlgumComando -Force
```

### Referência de Atalhos de Teclado

| Atalho | Ação |
| --- | --- |
| Tab | Mostrar menu de conclusão |
| Ctrl+R | Buscar histórico de comandos (reverso) |
| Ctrl+S | Buscar histórico de comandos (direto) |
| Ctrl+A | Início da linha |
| Ctrl+E | Fim da linha |
| Ctrl+LeftArrow | Palavra anterior |
| Ctrl+RightArrow | Próxima palavra |
| Ctrl+C | Cancelar comando |
| Ctrl+V | Colar |

### Solução de Problemas

**Prompt não aparece?**

- Reinicie o PowerShell
- Execute: `oh-my-posh --version`

**Fonte não funcionando?**

- Instale Windows Terminal
- Reinicie o Terminal
- A fonte entra em efeito na próxima sessão

**Autocomplete não funcionando?**

- Edite `$PROFILE`: `code $PROFILE`
- Verifique se a seção PSReadLine existe
- Recarregue o perfil: `. $PROFILE`

### Desinstalação

Para reverter para PowerShell padrão:

```powershell
# Remova a inicialização de Oh My Posh de $PROFILE
code $PROFILE

# Remova programa Oh My Posh
winget uninstall JanDeDobbeleer.OhMyPosh
```
