<#
.SYNOPSIS
Set Docker Desktop hosts file entries to 127.0.0.1 on Windows
#>
[CmdletBinding(SupportsShouldProcess = $true)]

param (
    [Parameter(Mandatory = $false)] [string[]]$HostsFileEntries = @("host.docker.internal", "gateway.docker.internal", "kubernetes.docker.internal"),
    [Parameter(Mandatory = $false)] [string]$IPAddress = "127.0.0.1",
    [Parameter(Mandatory = $false)] [string]$HostsFilePath = "$env:windir\System32\drivers\etc\hosts"
)

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$mainScript = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Wrapper\.', '.'
. "$here\$mainScript"

# Collect host file entries that need to be updated and update them
$HostEntriesToUpdate = @(Test-HostEntries -HostsFileEntries $HostsFileEntries -IPAddress $IPAddress -HostsFilePath $HostsFilePath)

If ($HostEntriesToUpdate.Count -gt 0) {
    Update-HostEntries -HostsFileEntries $HostEntriesToUpdate -IPAddress $IPAddress -HostsFilePath $HostsFilePath
}
