[string[]]$HostsFileEntries = @("host.docker.internal", "gateway.docker.internal", "kubernetes.docker.internal")
[string]$IPAddress = "127.0.0.1"
[string]$HostsFilePath = "$env:windir\System32\drivers\etc\hosts"

Set-StrictMode -Version Latest

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

# JSON file is used to store complex data that is returned in mock calls
$JsonMockData = Get-Content -Path "$PSScriptRoot\Fix-DockerDesktopHostsEntries.Tests.Objects.json" -Raw
$MockData = ConvertFrom-Json $JsonMockData


Describe 'Test-HostEntries' {
    Context 'Gets Hosts file entries' {
        $OriginalHostsFileMock = $MockData.'original_hosts_file'
        Mock Get-Content { $OriginalHostsFileMock }
        $HostEntriesToUpdate = @(Test-HostEntries -HostsFileEntries $HostsFileEntries -IPAddress $IPAddress -HostsFilePath $HostsFilePath)
        
        It 'Returns a string type with 3 values' {
            $HostEntriesToUpdate | Should BeOfType [System.String]
            $HostEntriesToUpdate.Count | Should HaveCount 1 3 # 1 string with 3 values
        }
        It 'Returns host, gateway, and kubernetes values' {
            $HostEntriesToUpdate | Should Be $HostsFileEntries
        }
    }
}

Describe 'Update-HostEntries' {
    Context 'Updates Hosts file entries' {
        $OriginalHostsFileMock = $MockData.'original_hosts_file'
        $UpdatedHostsFileMock = $MockData.'updated_hosts_file'
        Mock Get-Content { $OriginalHostsFileMock }
        Mock Set-Content { }

        $HostEntriesToUpdate = @(Test-HostEntries -HostsFileEntries $HostsFileEntries -IPAddress $IPAddress -HostsFilePath $HostsFilePath)
        $UpdatedHostsFile = Update-HostEntries -HostsFileEntries $HostEntriesToUpdate -IPAddress $IPAddress -HostsFilePath $HostsFilePath

        It 'Returns a hosts file string' {
            $UpdatedHostsFile | Should BeOfType [System.String]
        }
        It 'Returns a hosts file with updated entries' {
            $UpdatedHostsFile | Should Be $UpdatedHostsFileMock
        }
    }
}
