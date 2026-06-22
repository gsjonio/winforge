# System group: System monitoring and utilities

function Install-SystemPrograms {
    Write-GroupHeader "SYSTEM - System Utilities"

    $programs = @(
        @{
            Name     = "NVIDIA App"
            WingetId = "NVIDIA.NVIDIAGPUMonitoringTool"
            ChocoId  = "nvidia-app"
            Executable = "nvidia-app"
        },
        @{
            Name     = "CPU-Z"
            WingetId = "CPUID.CPU-Z"
            ChocoId  = "cpu-z"
            Executable = "cpuz"
        },
        @{
            Name     = "HWMonitor"
            WingetId = "CPUID.HWMonitor"
            ChocoId  = "hwmonitor"
            Executable = "hwmonitor"
        },
        @{
            Name     = "AMD Radeon Software"
            WingetId = "AMD.RadeonSoftware"
            Executable = "radeon"
        }
    )

    foreach ($program in $programs) {
        Install-Program @program
    }
}

function Set-SystemConfiguration {
    Write-GroupHeader "SYSTEM - System Configuration"

    # Example: Configure system monitoring
    # Apply-SystemConfig "Enable detailed system monitoring" {
    #     Write-Log "System monitoring configured" -Level Success
    # }

    # Example: System performance optimization
    # Apply-SystemConfig "Optimize system performance" {
    #     # Add system optimizations here
    # }
}
