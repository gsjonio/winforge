# System Utilities

[English](#english) | [Português](#português)

## English

### Overview

The `system` group ([src/modules/system.ps1](../src/modules/system.ps1)) installs
hardware-monitoring and GPU utilities. It only installs programs — it changes no
registry keys or services, so there is nothing here to reverse.

### Usage

```powershell
.\setup.ps1 -Group system
```

Each program is installed through the fallback chain (Winget → Chocolatey →
custom URL) and skipped if already present.

### Programs installed

| Program | Winget ID | Purpose |
| --- | --- | --- |
| NVIDIA App | `NVIDIA.NVIDIAGPUMonitoringTool` | NVIDIA GPU drivers, monitoring and control |
| AMD Radeon Software | `AMD.RadeonSoftware` | AMD GPU drivers and control |
| CPU-Z | `CPUID.CPU-Z` | CPU / memory / mainboard information |
| HWMonitor | `CPUID.HWMonitor` | Temperatures, voltages and fan speeds |

Both GPU vendors are listed so the group works on either hardware; the one that
does not match your GPU simply fails to install and is skipped.

## Português

### Visão Geral

O grupo `system` ([src/modules/system.ps1](../src/modules/system.ps1)) instala
utilitários de monitoramento de hardware e de GPU. Ele apenas instala programas —
não altera chaves de registro nem serviços, então não há nada a reverter aqui.

### Uso

```powershell
.\setup.ps1 -Group system
```

Cada programa é instalado pela cadeia de fallback (Winget → Chocolatey → URL
customizada) e ignorado se já estiver presente.

### Programas instalados

| Programa | Winget ID | Finalidade |
| --- | --- | --- |
| NVIDIA App | `NVIDIA.NVIDIAGPUMonitoringTool` | Drivers, monitoramento e controle de GPU NVIDIA |
| AMD Radeon Software | `AMD.RadeonSoftware` | Drivers e controle de GPU AMD |
| CPU-Z | `CPUID.CPU-Z` | Informações de CPU / memória / placa-mãe |
| HWMonitor | `CPUID.HWMonitor` | Temperaturas, voltagens e velocidade de ventoinhas |

Ambos os fabricantes de GPU são listados para o grupo funcionar em qualquer
hardware; o que não corresponder à sua GPU apenas falha na instalação e é ignorado.
