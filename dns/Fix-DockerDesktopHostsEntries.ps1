# Tests if hosts file entries need to be updated and returns those entries
function Test-HostEntries {
    param (
        [Parameter(Mandatory = $false)] [string[]]$HostsFileEntries,
        [Parameter(Mandatory = $false)] [string]$IPAddress,
        [Parameter(Mandatory = $false)] [string]$HostsFilePath
    )
    
    $HostEntriesToUpdate = @()
    $hostsFile = Get-Content -Path $HostsFilePath

    foreach ($HostName in $HostsFileEntries) {
        $checkEntry = $hostsFile | Where-Object -FilterScript {
            [System.String]::IsNullOrEmpty($_) -eq $false -and $_.StartsWith('#') -eq $false -and $_ -like "*$HostName*"
        }

        if ($checkEntry -notlike "$IPAddress`t$HostName") {
            $HostEntriesToUpdate += $HostName
        }
    }

    return $HostEntriesToUpdate
}

# Performs an in-place edit of the system's hosts file and returns the resulting hosts file
function Update-HostEntries {
    param (
        [Parameter(Mandatory = $false)] [string[]]$HostsFileEntries,
        [Parameter(Mandatory = $false)] [string]$IPAddress,
        [Parameter(Mandatory = $false)] [string]$HostsFilePath
    )

    try {
        $hostsFile = Get-Content -Path $HostsFilePath

        foreach ($HostEntry in $HostsFileEntries) {
            $replace = $hostsFile | Where-Object -FilterScript {
                [System.String]::IsNullOrEmpty($_) -eq $false -and $_.StartsWith('#') -eq $false -and $_ -like "*$HostEntry*"
            }

            Write-Verbose "Updating $HostEntry"
            # Replace each entry
            $hostsFile = $hostsFile -replace $replace, "$IPAddress`t$HostEntry"
        }

        # Apply all entry changes
        Set-Content -Path $HostsFilePath -Value $hostsFile
        Return $hostsFile
    }
    catch {
        Write-Error ('{0} : {1} At Line:{2} char:{3}' -f $_.InvocationInfo.ScriptName, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber, $_.InvocationInfo.OffsetInLine)
    }
}
