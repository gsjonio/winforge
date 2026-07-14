# System Optimization & Privacy Configuration

[English](#english) | [Português](#português)

## English

### Overview

The `optimize` group ([src/modules/optimize.ps1](../src/modules/optimize.ps1))
applies privacy, performance and service tweaks. It is **safe by default**: the
tweaks are a data-driven table, each tagged with a risk tier, and a `-Profile`
selects how far it goes. Tiers are cumulative — `safe ⊂ desktop ⊂ gaming`.

This page explains what each tweak does, why, and its trade-off. For the service
details see [SERVICES.md](SERVICES.md); to undo anything see [RESTORE.md](RESTORE.md).

### Running it

```powershell
.\setup.ps1 -Group optimize                  # safe (default)
.\setup.ps1 -Group optimize -Profile desktop # + power / 24-7 tweaks
.\setup.ps1 -Group optimize -Profile gaming  # + network + aggressive services
```

### Prominent safety call-outs

These changes broke a real machine and are **no longer applied** — read this
before assuming an older run left your system in a good state:

- **VSS / System Restore was disabled** (removed, issue #8). Disabling `VSS` set
  `DisableShadowCopy=1` and stopped the service, removing System Restore and any
  VSS-based backup — i.e. no rollback if another tweak breaks something.
- **StorSvc was disabled** (removed, issue #9). It is a runtime dependency of the
  Microsoft Store; disabling it breaks Store downloads/updates.
- **SmartScreen was disabled** (removed, issue #11). Turning off `SmartScreenEnabled`
  and `EnableWebContentEvaluation` is a security regression on a machine that
  downloads binaries.
- **The non-Store install lockdown is now opt-in.** `EnableAppsInstallationFromNonStoreLocation=0`
  ([optimize.ps1:237](../src/modules/optimize.ps1#L237)) **blocks sideloading /
  installs from non-Store locations** — it is not a "push installation" toggle,
  despite what the old comment said. It now runs only under `-Profile gaming`.

If an older winforge version applied these, run `.\setup.ps1 -Group restore` to
put them back.

### Safe profile — privacy & telemetry

Registry preferences that reduce data collection and background noise. All are
low-risk; the HKLM policy entries need removal (not a Settings toggle) to revert.

| Tweak | Key / value | Effect | Risk / trade-off |
| --- | --- | --- | --- |
| Diagnostic data | `...\DataCollection\AllowDiagnosticData=0` | Minimizes telemetry | Feedback Hub / some diagnostics inert |
| Background activity | `...\BackgroundAccessApplications`, `AllowTailoredExperiences=0` | Fewer background apps / tailored tips | Low |
| Find My Device | `...\FindMyDevice\LocationSyncEnabled=0` | Turns off device location sync | Can't locate a lost device |
| Activity history | `EnableActivityFeed=0` (policy + HKCU) | Disables Timeline sync | Low |
| Problem Steps Recorder | `...\AppCompat\DisablePCA=1` | Disables PSR | Low |
| Update toasts | `...UpdateNotification\Enabled=0` | Fewer update notifications | Low |
| Quick Access insights | `...\Explorer\DisableQuickAccess=1` | Hides recent/frequent in Explorer | Quick Access unavailable |
| Recent docs | `ShowRecent=0`, `ShowFrequent=0` | No recent-docs history | Low |
| Settings sync | `SettingSync\SyncPolicy=0` (+ groups) | No cross-device settings sync | Low |
| Cortana | `AllowCortana=0` (policy) | Disables Cortana | Low |
| Consumer experiences | `CloudContent\DisableWindowsSpotlightFeatures=1` | No suggested apps / Spotlight | Low |
| Driver metadata | `...\Device Metadata\PreventDeviceMetadataFromNetwork=1` | Blocks driver-metadata fetch | Generic device names/icons |

### Safe profile — visual performance

`UserPreferencesMask`, `TaskbarAnimations=0`, `EnableTransparency=0`,
`MenuShowDelay=0` and related keys turn off animations, transparency/blur and
tooltip delay for snappier UI. **Purely cosmetic and fully reversible** via
Settings → System → About → Advanced system settings → Performance.

### Safe profile — storage

Enables Storage Sense (automatic temp cleanup, recycle bin ≥ 30 days) and SSD
TRIM (`fsutil behavior set DisableDeleteNotify 0`). Low risk; Storage Sense only
cleans temp files and the recycle bin, not your documents. VSS/System Restore is
**left intact**.

### Safe profile — services

Eleven low-impact services are set to `Disabled`. See the full table with factory
defaults and per-service risk in [SERVICES.md](SERVICES.md). A few
(`TabletInputService`, `stisvc`, `OneSyncSvc`) have feature side effects worth
checking there before running.

### Desktop profile — power / 24-7

Adds tweaks for a desktop that stays on: High Performance power plan, USB
Selective Suspend off, sleep/hibernation off (`powercfg /h off`), Fast Startup
off, and memory compression off (`Disable-MMAgent`, RAM ≥ 8 GB). Trade-off: higher
idle power draw and no sleep; disabling hibernation removes `hiberfil.sys` and
Fast Startup. All reversible via power settings.

### Gaming profile — network & aggressive services

- **QoS** `NonBestEffortLimit=0` — removes the reserved bandwidth ([optimize.ps1:206](../src/modules/optimize.ps1#L206)).
- **Network throttling** `NetworkThrottlingIndex=0xFFFFFFFF` ([optimize.ps1:214](../src/modules/optimize.ps1#L214)) — now written safely as `-1` with read-back. **Known limitation:** it is written under `...\Services\Psched\Parameters`, but the documented location is `...\Multimedia\SystemProfile`, so it may have no effect (tracked separately).
- **SysMain, DPS, WinRM** disabled — see [SERVICES.md](SERVICES.md). These affect prefetch, diagnostics and remote management, hence gaming-only.

### Gaming profile — non-Store install lockdown

`EnableAppsInstallationFromNonStoreLocation=0` blocks installing apps from
non-Store locations (sideloading). Opt-in only — it would otherwise block
legitimate developer workflows.

### Reversibility

The README once claimed optimizations are "all reversible via Windows settings."
That is **not accurate** for every tweak:

| Category | How to revert |
| --- | --- |
| Visual, most HKCU privacy prefs | Windows Settings |
| Power / sleep / Fast Startup | Power settings (`powercfg`) |
| Service disables | `services.msc`, or `restore` |
| **HKLM policy keys** (DataCollection, CloudContent, Explorer, AppInstaller, Device Metadata, Windows Search) | **Not undone by Settings** — the value must be removed (via `restore` or `gpedit.msc`) |

The reliable way to revert everything is `.\setup.ps1 -Group restore`
(see [RESTORE.md](RESTORE.md)).

### Prerequisites

- Windows 10 or 11, administrator privileges, PowerShell 7+.

### Safe to run multiple times

Yes — `Set-RegistryValue` is idempotent and every tweak re-applies cleanly.

---

## Português

### Visão Geral

O grupo `optimize` ([src/modules/optimize.ps1](../src/modules/optimize.ps1))
aplica ajustes de privacidade, desempenho e serviços. É **seguro por padrão**: os
tweaks são uma tabela orientada a dados, cada um com um nível de risco, e um
`-Profile` decide até onde ele vai. Os níveis são cumulativos —
`safe ⊂ desktop ⊂ gaming`.

Esta página explica o que cada tweak faz, por quê, e o trade-off. Para detalhes
dos serviços veja [SERVICES.md](SERVICES.md); para desfazer, [RESTORE.md](RESTORE.md).

### Como executar

```powershell
.\setup.ps1 -Group optimize                  # safe (padrão)
.\setup.ps1 -Group optimize -Profile desktop # + tweaks de energia / 24-7
.\setup.ps1 -Group optimize -Profile gaming  # + rede + serviços agressivos
```

### Avisos de segurança em destaque

Estas mudanças quebraram uma máquina real e **não são mais aplicadas** — leia
antes de supor que uma execução antiga deixou seu sistema em bom estado:

- **VSS / Restauração do Sistema era desabilitado** (removido, issue #8). Isso
  definia `DisableShadowCopy=1` e parava o serviço, removendo a Restauração do
  Sistema e backups via VSS — ou seja, sem rollback se outro tweak quebrasse algo.
- **StorSvc era desabilitado** (removido, issue #9). É dependência de runtime da
  Microsoft Store; desabilitar quebra downloads/atualizações da Store.
- **SmartScreen era desabilitado** (removido, issue #11). Desligar
  `SmartScreenEnabled` e `EnableWebContentEvaluation` é uma regressão de segurança
  numa máquina que baixa binários.
- **O bloqueio de instalação fora da Store agora é opt-in.**
  `EnableAppsInstallationFromNonStoreLocation=0`
  ([optimize.ps1:237](../src/modules/optimize.ps1#L237)) **bloqueia sideload /
  instalações fora da Store** — não é um botão de "push installation", apesar do
  comentário antigo. Agora roda apenas sob `-Profile gaming`.

Se uma versão antiga aplicou isso, rode `.\setup.ps1 -Group restore` para reverter.

### Perfil safe — privacidade & telemetria

Preferências de registro que reduzem coleta de dados e ruído em segundo plano.
Todas de baixo risco; as entradas de política HKLM precisam ser removidas (não é
um botão em Configurações) para reverter.

| Tweak | Chave / valor | Efeito | Risco / trade-off |
| --- | --- | --- | --- |
| Dados de diagnóstico | `...\DataCollection\AllowDiagnosticData=0` | Minimiza telemetria | Feedback Hub / diagnósticos inertes |
| Atividade em background | `...\BackgroundAccessApplications`, `AllowTailoredExperiences=0` | Menos apps / dicas personalizadas | Baixo |
| Localizar Dispositivo | `...\FindMyDevice\LocationSyncEnabled=0` | Desliga sync de localização | Não localiza dispositivo perdido |
| Histórico de atividades | `EnableActivityFeed=0` (política + HKCU) | Desabilita Timeline | Baixo |
| Gravador de Passos | `...\AppCompat\DisablePCA=1` | Desabilita PSR | Baixo |
| Avisos de atualização | `...UpdateNotification\Enabled=0` | Menos notificações | Baixo |
| Insights do Explorer | `...\Explorer\DisableQuickAccess=1` | Oculta recentes/frequentes | Quick Access indisponível |
| Docs recentes | `ShowRecent=0`, `ShowFrequent=0` | Sem histórico de recentes | Baixo |
| Sync de configurações | `SettingSync\SyncPolicy=0` (+ grupos) | Sem sync entre dispositivos | Baixo |
| Cortana | `AllowCortana=0` (política) | Desabilita Cortana | Baixo |
| Experiências de consumidor | `CloudContent\DisableWindowsSpotlightFeatures=1` | Sem apps sugeridos / Spotlight | Baixo |
| Metadados de driver | `...\Device Metadata\PreventDeviceMetadataFromNetwork=1` | Bloqueia busca de metadados | Nomes/ícones genéricos |

### Perfil safe — desempenho visual

`UserPreferencesMask`, `TaskbarAnimations=0`, `EnableTransparency=0`,
`MenuShowDelay=0` e chaves relacionadas desligam animações, transparência/blur e
o atraso de tooltip para uma UI mais responsiva. **Puramente cosmético e
totalmente reversível** em Configurações → Sistema → Sobre → Configurações
avançadas → Desempenho.

### Perfil safe — armazenamento

Ativa o Sensor de Armazenamento (limpeza automática de temporários, lixeira ≥ 30
dias) e o TRIM de SSD (`fsutil behavior set DisableDeleteNotify 0`). Baixo risco;
o Sensor só limpa temporários e a lixeira, não seus documentos. VSS/Restauração do
Sistema é **mantido intacto**.

### Perfil safe — serviços

Onze serviços de baixo impacto vão para `Disabled`. Veja a tabela completa com
padrões de fábrica e risco por serviço em [SERVICES.md](SERVICES.md). Alguns
(`TabletInputService`, `stisvc`, `OneSyncSvc`) têm efeitos colaterais que vale
conferir lá antes de rodar.

### Perfil desktop — energia / 24-7

Adiciona tweaks para um desktop que fica ligado: plano Alto Desempenho, USB
Selective Suspend desligado, suspensão/hibernação desligadas (`powercfg /h off`),
Fast Startup desligado e compressão de memória desligada (`Disable-MMAgent`, RAM ≥
8 GB). Trade-off: maior consumo em repouso e sem suspensão; desabilitar
hibernação remove `hiberfil.sys` e o Fast Startup. Tudo reversível nas
configurações de energia.

### Perfil gaming — rede & serviços agressivos

- **QoS** `NonBestEffortLimit=0` — remove a banda reservada ([optimize.ps1:206](../src/modules/optimize.ps1#L206)).
- **Network throttling** `NetworkThrottlingIndex=0xFFFFFFFF` ([optimize.ps1:214](../src/modules/optimize.ps1#L214)) — agora gravado com segurança como `-1` com releitura. **Limitação conhecida:** é gravado em `...\Services\Psched\Parameters`, mas o local documentado é `...\Multimedia\SystemProfile`, então pode não ter efeito (rastreado à parte).
- **SysMain, DPS, WinRM** desabilitados — veja [SERVICES.md](SERVICES.md). Afetam prefetch, diagnóstico e gestão remota, por isso só no gaming.

### Perfil gaming — bloqueio de instalação fora da Store

`EnableAppsInstallationFromNonStoreLocation=0` bloqueia instalar apps fora da
Store (sideload). Apenas opt-in — senão bloquearia fluxos legítimos de dev.

### Reversibilidade

O README já afirmou que as otimizações são "todas reversíveis pelas configurações
do Windows". Isso **não é preciso** para todo tweak:

| Categoria | Como reverter |
| --- | --- |
| Visual, maioria das prefs HKCU de privacidade | Configurações do Windows |
| Energia / suspensão / Fast Startup | Configurações de energia (`powercfg`) |
| Desabilitação de serviços | `services.msc`, ou `restore` |
| **Chaves de política HKLM** (DataCollection, CloudContent, Explorer, AppInstaller, Device Metadata, Windows Search) | **Não desfeitas por Configurações** — o valor precisa ser removido (via `restore` ou `gpedit.msc`) |

A forma confiável de reverter tudo é `.\setup.ps1 -Group restore`
(veja [RESTORE.md](RESTORE.md)).

### Pré-requisitos

- Windows 10 ou 11, privilégios de administrador, PowerShell 7+.

### Seguro Executar Múltiplas Vezes

Sim — `Set-RegistryValue` é idempotente e cada tweak reaplica de forma limpa.
