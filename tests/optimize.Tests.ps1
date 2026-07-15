#Requires -Version 7.0
# Pester 5+ tests for the pure Get-OptimizeTweaks selector, which is the safety
# contract of the optimize module. Run:  Invoke-Pester ./tests

BeforeAll {
    . "$PSScriptRoot/../src/modules/optimize.ps1"

    $script:Forbidden = @('VSS', 'StorSvc', 'DPS', 'WinRM', 'SysMain')

    # Service names disabled by a profile (only tweaks that carry a Services key).
    function Get-TweakServices {
        param([string]$ProfileName)
        Get-OptimizeTweaks -Profile $ProfileName | ForEach-Object {
            if ($_.ContainsKey('Services')) { $_.Services }
        }
    }
}

Describe 'Get-OptimizeTweaks' {

    It 'defaults to the safe profile' {
        (Get-OptimizeTweaks).Count | Should -Be (Get-OptimizeTweaks -Profile safe).Count
    }

    It 'rejects an invalid profile' {
        { Get-OptimizeTweaks -Profile bogus } | Should -Throw
    }

    It 'safe profile disables no critical service' {
        $services = Get-TweakServices -ProfileName 'safe'
        foreach ($critical in $script:Forbidden) {
            $services | Should -Not -Contain $critical
        }
    }

    It 'never disables VSS or StorSvc on any profile' {
        $services = Get-TweakServices -ProfileName 'gaming'
        $services | Should -Not -Contain 'VSS'
        $services | Should -Not -Contain 'StorSvc'
    }

    It 'gaming profile disables SysMain, DPS and WinRM' {
        $services = Get-TweakServices -ProfileName 'gaming'
        $services | Should -Contain 'SysMain'
        $services | Should -Contain 'DPS'
        $services | Should -Contain 'WinRM'
    }

    It 'tiers are cumulative (safe < desktop < gaming)' {
        $safe = (Get-OptimizeTweaks -Profile safe).Count
        $desktop = (Get-OptimizeTweaks -Profile desktop).Count
        $gaming = (Get-OptimizeTweaks -Profile gaming).Count
        $desktop | Should -BeGreaterThan $safe
        $gaming | Should -BeGreaterThan $desktop
    }

    It 'keeps the non-Store install lockdown out of safe but in gaming' {
        @((Get-OptimizeTweaks -Profile safe).Name -match 'non-Store') | Should -BeNullOrEmpty
        @((Get-OptimizeTweaks -Profile gaming).Name -match 'non-Store') | Should -Not -BeNullOrEmpty
    }
}
