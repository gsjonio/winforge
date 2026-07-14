# Windows UI & Shell Customization

[English](#english) | [Português](#português)

## English

### Overview

The `customize` module applies 18+ Windows UI and shell customizations to match professional preferences: hidden file visibility, context menu cleanup, taskbar adjustments, and keyboard/mouse settings.

### Usage

```powershell
# Run customization module
.\setup.ps1 -Group customize

# Or include in full setup
.\setup.ps1  # includes customize in default run
```

### Customizations Applied

#### File Explorer

- ✅ Show hidden files
- ✅ Show file extensions
- ✅ Show full path in address bar
- ✅ Set default view to List

#### Context Menu

- ✅ Remove unnecessary "Share" option
- ✅ Add "Edit with Notepad++" (if installed)
- ✅ Customize file context menus

#### Taskbar

- ✅ Show all system tray icons (disable auto-hide)
- ✅ Disable news and interests widget
- ✅ Disable Cortana search icon

#### Start Menu

- ✅ Remove recommendations
- ✅ Remove suggested apps

#### Visual Settings

- ✅ Remove shortcut arrow overlay
- ✅ Enable dark mode for applications
- ✅ Enable dark mode for Windows

#### Input Devices

- ✅ Disable sticky keys confirmation dialog
- ✅ Enable mouse pointer shadow
- ✅ Disable mouse acceleration
- ✅ Configure keyboard indicators

### Registry Locations Modified

**HKEY_CURRENT_USER (User Preferences)**

```text
Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState
Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons
Software\Microsoft\Windows\CurrentVersion\Explorer
Software\Microsoft\Windows\CurrentVersion\Feeds
Software\Microsoft\Windows\CurrentVersion\Search
Software\Microsoft\Windows\CurrentVersion\Themes\Personalize
Software\Microsoft\Windows\CurrentVersion\Policies\CloudContent
Software\Classes\*\shell\*
Control Panel\Accessibility\StickyKeys
Control Panel\Cursors
Control Panel\Keyboard
Control Panel\Mouse
```

### Reversibility

All customizations use standard Windows Registry keys and can be reversed by:

1. Manually restoring registry values via regedit
2. Resetting Windows Settings (Settings → System → About → Reset this PC)
3. Reinstalling Windows

### Prerequisites

- Windows 10 or 11
- Administrator privileges
- PowerShell 7+

### Safe to Run Multiple Times

Yes - the script is idempotent and can be run multiple times safely.

### Verification

To verify customizations were applied:

```powershell
# Check File Explorer settings
Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' | 
  Select-Object Hidden, HideFileExt, FolderContentsMode

# Check theme settings
Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' |
  Select-Object AppsUseLightTheme, SystemUsesLightTheme

# Or manually via regedit:
# 1. Press Win+R, type: regedit
# 2. Navigate to paths listed above
# 3. Verify values match expected settings
```

---

## Português

### Visão Geral

O módulo `customize` aplica 18+ customizações de UI e shell do Windows para corresponder às preferências profissionais: visibilidade de arquivos ocultos, limpeza de menu de contexto, ajustes da barra de tarefas e configurações de teclado/mouse.

### Uso

```powershell
# Executar módulo de customização
.\setup.ps1 -Group customize

# Ou incluir na configuração completa
.\setup.ps1  # inclui customize por padrão
```

### Customizações Aplicadas

#### Explorador de Arquivos

- ✅ Mostrar arquivos ocultos
- ✅ Mostrar extensões de arquivo
- ✅ Mostrar caminho completo na barra de endereço
- ✅ Definir visualização padrão como Lista

#### Menu de Contexto

- ✅ Remover opção desnecessária "Compartilhar"
- ✅ Adicionar "Editar com Notepad++" (se instalado)
- ✅ Customizar menus de contexto de arquivo

#### Barra de Tarefas

- ✅ Mostrar todos os ícones da bandeja do sistema
- ✅ Desabilitar widget de notícias e interesses
- ✅ Desabilitar ícone de busca Cortana

#### Menu Iniciar

- ✅ Remover recomendações
- ✅ Remover aplicativos sugeridos

#### Configurações Visuais

- ✅ Remover sobreposição de seta de atalho
- ✅ Ativar modo escuro para aplicações
- ✅ Ativar modo escuro para Windows

#### Dispositivos de Entrada

- ✅ Desabilitar diálogo de confirmação de sticky keys
- ✅ Ativar sombra do ponteiro do mouse
- ✅ Desabilitar aceleração do mouse
- ✅ Configurar indicadores de teclado

### Reversibilidade

Todas as customizações usam chaves padrão do Registro do Windows e podem ser revertidas:

1. Manualmente restaurando valores via regedit
2. Resetando Configurações do Windows
3. Reinstalando Windows

### Verificação

Para verificar se as customizações foram aplicadas:

```powershell
# Verificar configurações do Explorador
Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' | 
  Select-Object Hidden, HideFileExt, FolderContentsMode

# Verificar configurações de tema
Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' |
  Select-Object AppsUseLightTheme, SystemUsesLightTheme

# Ou manualmente via regedit:
# 1. Pressione Win+R, digite: regedit
# 2. Navegue para os caminhos listados acima
# 3. Verifique se os valores correspondem às configurações esperadas
```

### Seguro Executar Múltiplas Vezes

Sim - o script é idempotente e pode ser executado várias vezes com segurança.
