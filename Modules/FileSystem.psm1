function Archive-Folder {
    param (
        [Parameter(Mandatory=$True)] [string]$Source,
        [Parameter(Mandatory=$True)] [string]$Destination,
        [Parameter(Mandatory=$True)] [datetime]$LastModified
    )

    try {
        $SourceFolderObject = Get-Item -Path $Source | Where-Object {$_.LastWriteTime -lt $LastModified}

        If ($SourceFolderObject) {
            Robocopy "$Source" "$Destination" /MOVE /ZB /J /R:100 /MT:32 /FP /V
        }
    }
    catch {
        Write-Error ('{0} : {1} At Line:{2} char:{3}' -f $_.InvocationInfo.ScriptName, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber, $_.InvocationInfo.OffsetInLine)
    }
}

 function Remove-Folder {
    param (
        [Parameter(Mandatory=$True)] [string]$Target,
        [Parameter(Mandatory=$True)] [datetime]$LastModified
    )

    try {
        $TargetFolderObjects = Get-Item -Path $Target | Where-Object {$_.LastWriteTime -lt $LastModified}
        $TargetFolderObjects | Remove-Item -Recurse -Force
    }
    catch {
        Write-Error ('{0} : {1} At Line:{2} char:{3}' -f $_.InvocationInfo.ScriptName, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber, $_.InvocationInfo.OffsetInLine)
    }
}

function Remove-Files {
    param (
        [Parameter(Mandatory=$True)] [string]$Directory,
        [Parameter(Mandatory=$True)] [datetime]$LastModified
    )

    try {
        $TargetFileObjects = Get-ChildItem -Path $Directory -Recurse -File | Where-Object {$_.LastWriteTime -lt $LastModified}
        Write-Output "Removing files from $Directory"
        $TargetFileObjects.count
        "Cleaning up {0:N2} GB" -f (($TargetFileObjects | Measure-Object Length -s).Sum /1GB)
        $TargetFileObjects | Remove-Item -Force
    }
    catch {
        Write-Error ('{0} : {1} At Line:{2} char:{3}' -f $_.InvocationInfo.ScriptName, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber, $_.InvocationInfo.OffsetInLine)
    }
}
