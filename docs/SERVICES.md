# Windows Services Reference

[English](#english) | [Português](#português)

This is the doc to read **before** running `optimize`. It lists every Windows
service winforge can touch, what it does to it, the Windows factory default, and
whether disabling it is safe on a developer/desktop machine. Verified against
`src/modules/optimize.ps1`. To reverse any of these, see
[RESTORE.md](RESTORE.md) (`-Group restore`).

## English

### Services the `optimize` module can disable

The profile column shows which `-Profile` first includes the tweak (`safe` runs
on every profile; `gaming` only under `-Profile gaming`).

| Service | Display name | winforge action | Profile | Factory default | Impact of disabling | Safe to disable? |
| --- | --- | --- | --- | --- | --- | --- |
| `DiagTrack` | Connected User Experiences and Telemetry | disable ([optimize.ps1:100](../src/modules/optimize.ps1#L100)) | safe | Automatic | Telemetry stops; some feedback/diagnostics UI inert | Yes (privacy) |
| `dmwappushservice` | WAP Push Message Routing | disable ([:103](../src/modules/optimize.ps1#L103)) | safe | Manual | Negligible on non-MDM devices | Yes |
| `OneSyncSvc` | Sync Host | disable ([:106](../src/modules/optimize.ps1#L106)) | safe | Automatic (per-user) | Mail/Calendar/People sync may stop | Caution |
| `HvHost` | HV Host Service | disable ([:109](../src/modules/optimize.ps1#L109)) | safe | Manual | Only affects Hyper-V hosts | Yes (non-VM) |
| `SharedAccess` | Internet Connection Sharing (ICS) | disable ([:112](../src/modules/optimize.ps1#L112)) | safe | Manual | Mobile hotspot / ICS stops | Yes (unless sharing) |
| `CscService` | Offline Files | disable ([:115](../src/modules/optimize.ps1#L115)) | safe | Manual | Offline Files unavailable | Yes (non-domain) |
| `TabletInputService` | Touch Keyboard and Handwriting Panel | disable ([:118](../src/modules/optimize.ps1#L118)) | safe | Manual | Touch keyboard / emoji panel may break | Caution (touch/tablet) |
| `TrkWks` | Distributed Link Tracking Client | disable ([:121](../src/modules/optimize.ps1#L121)) | safe | Automatic | Shortcut link tracking across volumes stops | Yes |
| `stisvc` | Windows Image Acquisition (WIA) | disable ([:124](../src/modules/optimize.ps1#L124)) | safe | Manual | Scanners / some cameras stop working | Caution (scanner users) |
| `WMPNetworkSvc` | Windows Media Player Network Sharing | disable ([:127](../src/modules/optimize.ps1#L127)) | safe | Manual | Media streaming from WMP stops | Yes |
| `lfsvc` | Geolocation Service | disable ([:130](../src/modules/optimize.ps1#L130)) | safe | Manual | Location-aware apps lose location | Yes (privacy) |
| `SysMain` | SysMain (Prefetch / SuperFetch) | disable ([:224](../src/modules/optimize.ps1#L224)) | gaming | Automatic | Prefetch caching off; perf effect is mixed on SSDs | Caution |
| `DPS` | Diagnostic Policy Service | disable ([:227](../src/modules/optimize.ps1#L227)) | gaming | Automatic | Windows troubleshooters and diagnostics stop working | Caution |
| `WinRM` | Windows Remote Management | disable ([:230](../src/modules/optimize.ps1#L230)) | gaming | Manual | PowerShell Remoting / Ansible (WinRM) break | Caution (remote mgmt) |

### Services winforge no longer disables

These were removed because disabling them broke real machines. `optimize` never
touches them now; `restore` can re-enable them if an older version left them off.

| Service | Display name | Factory default | Why it must stay enabled |
| --- | --- | --- | --- |
| `StorSvc` | Storage Service | Manual (Trigger Start) | The Microsoft Store and app-licensing stack depend on it; disabling it breaks Store downloads/updates (issue #9). |
| `VSS` | Volume Shadow Copy | Manual | Powers System Restore and VSS-based backups; disabling it removes rollback (issue #8). |

> Factory defaults are the documented Windows 11 clean-install values and are the
> baseline `restore` maps each service back to. `Manual` services are usually
> trigger-started and run on demand.

## Português

### Serviços que o módulo `optimize` pode desabilitar

A coluna de perfil mostra qual `-Profile` inclui o tweak pela primeira vez
(`safe` roda em todos; `gaming` só com `-Profile gaming`).

| Serviço | Nome de exibição | Ação do winforge | Perfil | Padrão de fábrica | Impacto ao desabilitar | Seguro desabilitar? |
| --- | --- | --- | --- | --- | --- | --- |
| `DiagTrack` | Experiências do Usuário Conectado e Telemetria | desabilitar ([optimize.ps1:100](../src/modules/optimize.ps1#L100)) | safe | Automatic | Telemetria para; parte da UI de diagnóstico fica inerte | Sim (privacidade) |
| `dmwappushservice` | Roteamento de Mensagens Push WAP | desabilitar ([:103](../src/modules/optimize.ps1#L103)) | safe | Manual | Insignificante fora de MDM | Sim |
| `OneSyncSvc` | Host de Sincronização | desabilitar ([:106](../src/modules/optimize.ps1#L106)) | safe | Automatic (por usuário) | Sincronização de Email/Calendário/Pessoas pode parar | Cautela |
| `HvHost` | Serviço Host do HV | desabilitar ([:109](../src/modules/optimize.ps1#L109)) | safe | Manual | Afeta apenas hosts Hyper-V | Sim (sem VM) |
| `SharedAccess` | Compartilhamento de Conexão (ICS) | desabilitar ([:112](../src/modules/optimize.ps1#L112)) | safe | Manual | Hotspot móvel / ICS para | Sim (a menos que compartilhe) |
| `CscService` | Arquivos Offline | desabilitar ([:115](../src/modules/optimize.ps1#L115)) | safe | Manual | Arquivos Offline indisponíveis | Sim (sem domínio) |
| `TabletInputService` | Teclado de Toque e Manuscrito | desabilitar ([:118](../src/modules/optimize.ps1#L118)) | safe | Manual | Teclado de toque / painel de emoji podem quebrar | Cautela (toque/tablet) |
| `TrkWks` | Cliente de Rastreamento de Link Distribuído | desabilitar ([:121](../src/modules/optimize.ps1#L121)) | safe | Automatic | Rastreamento de atalhos entre volumes para | Sim |
| `stisvc` | Aquisição de Imagem do Windows (WIA) | desabilitar ([:124](../src/modules/optimize.ps1#L124)) | safe | Manual | Scanners / algumas câmeras param | Cautela (uso de scanner) |
| `WMPNetworkSvc` | Compartilhamento de Rede do WMP | desabilitar ([:127](../src/modules/optimize.ps1#L127)) | safe | Manual | Streaming de mídia do WMP para | Sim |
| `lfsvc` | Serviço de Geolocalização | desabilitar ([:130](../src/modules/optimize.ps1#L130)) | safe | Manual | Apps que usam localização a perdem | Sim (privacidade) |
| `SysMain` | SysMain (Prefetch / SuperFetch) | desabilitar ([:224](../src/modules/optimize.ps1#L224)) | gaming | Automatic | Cache de prefetch desligado; efeito misto em SSD | Cautela |
| `DPS` | Serviço de Política de Diagnóstico | desabilitar ([:227](../src/modules/optimize.ps1#L227)) | gaming | Automatic | Solucionadores de problemas do Windows param | Cautela |
| `WinRM` | Gerenciamento Remoto do Windows | desabilitar ([:230](../src/modules/optimize.ps1#L230)) | gaming | Manual | PowerShell Remoting / Ansible (WinRM) quebram | Cautela (gestão remota) |

### Serviços que o winforge não desabilita mais

Foram removidos porque desabilitá-los quebrou máquinas reais. O `optimize` não os
toca mais; o `restore` pode religá-los se uma versão antiga os deixou desligados.

| Serviço | Nome de exibição | Padrão de fábrica | Por que deve permanecer ativo |
| --- | --- | --- | --- |
| `StorSvc` | Serviço de Armazenamento | Manual (Trigger Start) | A Microsoft Store e o licenciamento de apps dependem dele; desabilitar quebra downloads/atualizações da Store (issue #9). |
| `VSS` | Cópia de Sombra de Volume | Manual | Sustenta a Restauração do Sistema e backups via VSS; desabilitar remove o rollback (issue #8). |

> Os padrões de fábrica são os valores documentados de uma instalação limpa do
> Windows 11 e são a base para a qual o `restore` mapeia cada serviço. Serviços
> `Manual` geralmente são iniciados por gatilho e rodam sob demanda.
