function Archive-OldFolders {
    param (
        [Parameter(Mandatory=$True)] [string]$Source,
        [Parameter(Mandatory=$True)] [string]$Destination,
        [Parameter(Mandatory=$True)] [datetime]$FolderLastAccessed
    )

    try {
        $SourceFolderObject = Get-Item -Path $Source

        If ($SourceFolderObject.LastAccessTime -lt $FolderLastAccessed)
        {
            Robocopy "$Source" "$Destination" /MOVE /ZB /J /R:100 /MT:32 /FP /V
        }
    }
    catch {
        Write-Error ('{0} : {1} At Line:{2} char:{3}' -f $_.InvocationInfo.ScriptName, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber, $_.InvocationInfo.OffsetInLine)
    }
}

function Remove-OldFolders {
    param (
        [Parameter(Mandatory=$True)] [string]$Target,
        [Parameter(Mandatory=$True)] [datetime]$FolderLastAccessed
    )

    try {
        $TargetFolderObject = Get-Item -Path $Target
        
        If ($TargetFolderObject.LastAccessTime -lt $FolderLastAccessed)
        {
            $TargetFolderObject | Remove-Item -Recurse -Force
        }
    }
    catch {
        Write-Error ('{0} : {1} At Line:{2} char:{3}' -f $_.InvocationInfo.ScriptName, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber, $_.InvocationInfo.OffsetInLine)
    }
}
