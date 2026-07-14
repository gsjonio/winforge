# System Optimization & Privacy Configuration

[English](#english) | [Português](#português)

## English

### Overview

The `optimize` module applies system optimizations and privacy tweaks via Windows Registry settings and service configuration. It is **safe by default**: a `-Profile` (safe / desktop / gaming, cumulative) controls how aggressive it is. The `safe` profile never disables VSS/System Restore, StorSvc (Microsoft Store), SmartScreen, DPS or WinRM — the destructive tweaks were removed or made opt-in after breaking a real machine.

### Usage

```powershell
# Safe defaults (privacy, visual, storage, harmless services)
.\setup.ps1 -Group optimize

# Add power / 24-7 tweaks
.\setup.ps1 -Group optimize -Profile desktop

# Everything, incl. network + aggressive service disables (SysMain, DPS, WinRM)
.\setup.ps1 -Group optimize -Profile gaming
```

### Optimizations Applied

#### Telemetry & Data Collection

- ✅ Disable diagnostic data collection (AllowDiagnosticData = 0)
- ✅ Disable DiagTrack service
- ✅ Disable consumer experiences tracking

#### Background Activities

- ✅ Disable background application activity
- ✅ Disable tailored experiences and suggestions
- ✅ Disable automatic driver installation
- ✅ Disable Multimedia Class Scheduler (if RAM ≥ 8GB)

#### Microsoft Services

- ✅ Disable Find My Device feature
- ✅ Disable Activity History sync
- ✅ Disable settings synchronization (Accessibility, Apps, Personalization, StartLayout)
- ✅ Disable Cortana assistance

#### Installation & Updates

- ✅ Disable App Installer (Push Installation service)
- ✅ Disable automatic update notifications
- ✅ Disable Windows Update automatic downloads

#### User Experience

- ✅ Disable Problem Steps Recorder (PSR)
- ✅ Disable File Explorer quick access insights
- ✅ Disable recent documents history in Start menu
- ✅ Disable web content evaluation in Microsoft Edge

#### Security Features

- ✅ Configure privacy policies
- SmartScreen is **not** disabled — turning it off is a security regression (removed, issue #11)
- Non-Store install lockdown is **opt-in** (gaming profile only), never in the safe default

### Registry Locations Modified

**HKEY_CURRENT_USER (User Settings)**

```text
Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack
Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications
Software\Microsoft\Windows\CurrentVersion\Settings\Privacy\General
Software\Microsoft\Windows\CurrentVersion\FindMyDevice
Software\Microsoft\Windows\CurrentVersion\ActivityHistory
Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\*
Software\Microsoft\Personalization\Settings
Software\Microsoft\Windows\CurrentVersion\AppHost
Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
```

**HKEY_LOCAL_MACHINE (System Settings)**

```text
SOFTWARE\Policies\Microsoft\Windows\DataCollection
SOFTWARE\Policies\Microsoft\Windows\AppInstaller
SOFTWARE\Policies\Microsoft\Windows\System
SOFTWARE\Policies\Microsoft\Windows\Explorer
SOFTWARE\Policies\Microsoft\Windows\CloudContent
SOFTWARE\Policies\Microsoft\Windows\Device Metadata
SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer
```

### Reversibility

All optimizations use standard Windows Registry keys and can be reversed by:

1. Manually restoring registry values via regedit
2. Using Group Policy Editor (gpedit.msc) to revert settings
3. Reinstalling Windows (clean slate)

### Prerequisites

- Windows 10 or 11
- Administrator privileges
- PowerShell 7+

### Safe to Run Multiple Times

Yes - the script checks current values and applies settings idempotently.

### Verification

To verify optimizations were applied:

```powershell
# Check registry values
Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack'
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'

# Or manually via regedit:
# 1. Press Win+R, type: regedit
# 2. Navigate to paths listed above
# 3. Verify DWORD values are set correctly
```

---

## Português

### Visão Geral

O módulo `optimize` aplica otimizações de sistema e ajustes de privacidade via Registro do Windows e configuração de serviços. É **seguro por padrão**: um `-Profile` (safe / desktop / gaming, cumulativo) controla o quão agressivo ele é. O perfil `safe` nunca desabilita VSS/Restauração do Sistema, StorSvc (Microsoft Store), SmartScreen, DPS ou WinRM — os tweaks destrutivos foram removidos ou tornados opt-in depois de quebrarem uma máquina real.

### Uso

```powershell
# Padrão seguro (privacidade, visual, armazenamento, serviços inofensivos)
.\setup.ps1 -Group optimize

# Adiciona tweaks de energia / 24-7
.\setup.ps1 -Group optimize -Profile desktop

# Tudo, incl. rede + desabilitação agressiva de serviços (SysMain, DPS, WinRM)
.\setup.ps1 -Group optimize -Profile gaming
```

### Otimizações Aplicadas

#### Telemetria & Coleta de Dados

- ✅ Desabilitar coleta de dados de diagnóstico
- ✅ Desabilitar serviço DiagTrack
- ✅ Desabilitar rastreamento de experiências de consumidor

#### Atividades em Background

- ✅ Desabilitar atividade de aplicativos em segundo plano
- ✅ Desabilitar experiências e sugestões personalizadas
- ✅ Desabilitar instalação automática de drivers
- ✅ Desabilitar Multimedia Class Scheduler (se RAM ≥ 8GB)

#### Serviços Microsoft

- ✅ Desabilitar recurso Localizar Meu Dispositivo
- ✅ Desabilitar sincronização do Histórico de Atividades
- ✅ Desabilitar sincronização de configurações
- ✅ Desabilitar Cortana

#### Instalação & Atualizações

- ✅ Desabilitar serviço de Push Installation
- ✅ Desabilitar notificações de atualização automática
- ✅ Desabilitar downloads automáticos do Windows Update

#### Experiência do Usuário

- ✅ Desabilitar Gravador de Passos (PSR)
- ✅ Desabilitar insights de acesso rápido no Explorador
- ✅ Desabilitar histórico de documentos recentes no menu Iniciar
- ✅ Desabilitar avaliação de conteúdo web no Microsoft Edge

#### Recursos de Segurança

- ✅ Configurar políticas de privacidade
- SmartScreen **não** é desabilitado — desligá-lo é uma regressão de segurança (removido, issue #11)
- Bloqueio de instalação fora da Store é **opt-in** (apenas perfil gaming), nunca no padrão safe

### Reversibilidade

Todas as otimizações usam chaves padrão do Registro do Windows e podem ser revertidas:

1. Manualmente restaurando valores via regedit
2. Usando o Editor de Política de Grupo (gpedit.msc)
3. Reinstalando Windows

### Verificação

Para verificar se as otimizações foram aplicadas:

```powershell
# Verificar valores do registro
Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack'
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'

# Ou manualmente via regedit:
# 1. Pressione Win+R, digite: regedit
# 2. Navegue para os caminhos listados acima
# 3. Verifique que os valores DWORD estão configurados corretamente
```

### Seguro Executar Múltiplas Vezes

Sim - o script verifica valores atuais e aplica configurações de forma idempotente.
