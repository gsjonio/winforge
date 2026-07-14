# Restore — Reverse winforge's System Changes

[English](#english) | [Português](#português)

## English

### Overview

The `restore` group reverses the destructive and aggressive changes the
`optimize` module can make, putting Windows services and policy keys back to
their factory defaults. It is the **escape hatch**: `optimize` used to disable
`VSS` (removing System Restore) and `StorSvc` (breaking the Microsoft Store),
which required a full disk-image recovery on a real machine. See the safe-defaults
work in issues #8–#15; `restore` undoes that state on machines already affected.

`restore` is **never part of the default run** — it executes only when you ask
for it explicitly with `-Group restore`.

### Usage

```powershell
# Preview every action without changing anything
.\setup.ps1 -Group restore -WhatIf

# Apply the restore (run as administrator)
sudo .\setup.ps1 -Group restore

# Standalone, dot-sourced (advanced options)
. .\src\utils\Logging.ps1; . .\src\utils\Registry.ps1
. .\src\core\Installation.ps1; . .\src\modules\restore.ps1
Restore-SafeDefaults -EnableSystemRestore   # also turns System Restore back on
Restore-SafeDefaults -RestoreTelemetry      # also re-enables DiagTrack (opt-in)
```

Administrator privileges are required (services and HKLM policies). The operation
is idempotent — safe to run more than once.

### Services restored

Each service is set back to its documented Windows 11 default StartType, and the
ones that should run at boot are started. Missing services are skipped.

| Service | Restored StartType | Started | Notes |
| --- | --- | --- | --- |
| `StorSvc` | Manual | ✅ | Microsoft Store / app licensing |
| `VSS` | Manual | — | System Restore / shadow copies (on-demand) |
| `DPS` | Automatic | ✅ | Diagnostics |
| `SysMain` | Automatic | ✅ | Prefetch / SuperFetch |
| `WinRM` | Manual | — | Remote management |
| `DiagTrack` | Automatic | — | Telemetry — **opt-in** via `-RestoreTelemetry` |
| `dmwappushservice`, `OneSyncSvc`, `HvHost`, `SharedAccess`, `CscService`, `TabletInputService`, `TrkWks`, `stisvc`, `WMPNetworkSvc`, `lfsvc` | Manual / Automatic | as default | Other services `optimize` can disable |

The service list is kept in sync with `optimize.ps1` through a drift check that
warns if `optimize` learns to disable a service `restore` does not know about.

### Registry / policy reverted

Policy values are **removed** so Windows falls back to its own default (rather
than hardcoding one).

| Key | Action |
| --- | --- |
| `HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR\AllowGameDVR` | removed (re-enables Game Bar capture) |
| `HKCU:\...\GameDVR\AppCaptureEnabled`, `HKCU:\System\GameConfigStore\GameDVR_Enabled` | set to `1` |
| `SmartScreenEnabled`, `EnableWebContentEvaluation` | removed (SmartScreen back to default) |
| `EnableAppsInstallationFromNonStoreLocation` | removed (allows non-Store installs) |
| `DisableShadowCopy` | removed (re-enables shadow copies) |

> `AllowGameDVR=0` is **not** written by winforge, but it is a common breakage
> that greys out Game Bar capture, so `restore` clears it defensively.

### System Restore

After `VSS` is restored, protection may still be OFF. `restore` recommends
re-enabling it and, with `-EnableSystemRestore`, runs
`Enable-ComputerRestore -Drive "C:\"`. It is never forced silently.

### Verification

```powershell
.\tools\validate.ps1 -Group restore
```

Asserts `StorSvc`, `VSS`, `DPS` and `SysMain` are not `Disabled` and that
`AllowGameDVR` is absent or `1`.

---

## Português

### Visão Geral

O grupo `restore` reverte as mudanças destrutivas e agressivas que o módulo
`optimize` pode fazer, devolvendo serviços e chaves de política do Windows aos
padrões de fábrica. É a **saída de emergência**: o `optimize` desabilitava `VSS`
(removendo a Restauração do Sistema) e `StorSvc` (quebrando a Microsoft Store), o
que exigiu recuperar uma imagem de disco completa numa máquina real. Veja o
trabalho de padrões seguros nas issues #8–#15; o `restore` desfaz esse estado em
máquinas já afetadas.

O `restore` **nunca faz parte da execução padrão** — só roda quando pedido
explicitamente com `-Group restore`.

### Uso

```powershell
# Prévia de todas as ações sem alterar nada
.\setup.ps1 -Group restore -WhatIf

# Aplicar o restore (como administrador)
sudo .\setup.ps1 -Group restore

# Standalone, via dot-source (opções avançadas)
. .\src\utils\Logging.ps1; . .\src\utils\Registry.ps1
. .\src\core\Installation.ps1; . .\src\modules\restore.ps1
Restore-SafeDefaults -EnableSystemRestore   # também religa a Restauração do Sistema
Restore-SafeDefaults -RestoreTelemetry      # também religa o DiagTrack (opt-in)
```

São necessários privilégios de administrador (serviços e políticas HKLM). A
operação é idempotente — seguro rodar mais de uma vez.

### Serviços restaurados

Cada serviço volta ao StartType padrão documentado do Windows 11, e os que devem
rodar no boot são iniciados. Serviços ausentes são ignorados.

| Serviço | StartType restaurado | Iniciado | Notas |
| --- | --- | --- | --- |
| `StorSvc` | Manual | ✅ | Microsoft Store / licenciamento |
| `VSS` | Manual | — | Restauração do Sistema (sob demanda) |
| `DPS` | Automatic | ✅ | Diagnóstico |
| `SysMain` | Automatic | ✅ | Prefetch / SuperFetch |
| `WinRM` | Manual | — | Gerenciamento remoto |
| `DiagTrack` | Automatic | — | Telemetria — **opt-in** via `-RestoreTelemetry` |
| demais serviços que o `optimize` desabilita | padrão | conforme padrão | `dmwappushservice`, `OneSyncSvc`, etc. |

A lista de serviços é mantida em sincronia com `optimize.ps1` por uma verificação
de drift que avisa se o `optimize` passar a desabilitar um serviço desconhecido
pelo `restore`.

### Registro / política revertidos

Valores de política são **removidos** para o Windows voltar ao próprio padrão.

| Chave | Ação |
| --- | --- |
| `HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR\AllowGameDVR` | removida (religa a captura da Game Bar) |
| `AppCaptureEnabled`, `GameDVR_Enabled` | definidos como `1` |
| `SmartScreenEnabled`, `EnableWebContentEvaluation` | removidas (SmartScreen ao padrão) |
| `EnableAppsInstallationFromNonStoreLocation` | removida (permite instalação fora da Store) |
| `DisableShadowCopy` | removida (religa shadow copies) |

> `AllowGameDVR=0` **não** é gravado pelo winforge, mas é uma quebra comum que
> desabilita a captura da Game Bar, então o `restore` a limpa defensivamente.

### Restauração do Sistema

Depois que o `VSS` é restaurado, a proteção ainda pode estar DESLIGADA. O
`restore` recomenda religá-la e, com `-EnableSystemRestore`, executa
`Enable-ComputerRestore -Drive "C:\"`. Nunca é forçado silenciosamente.

### Verificação

```powershell
.\tools\validate.ps1 -Group restore
```

Verifica que `StorSvc`, `VSS`, `DPS` e `SysMain` não estão `Disabled` e que
`AllowGameDVR` está ausente ou `1`.
