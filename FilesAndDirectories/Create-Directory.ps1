<#
    .SYNOPSIS
        Create a directory
    .PARAMETER FullFolderPath
        Full folder path including the name of the directory being created
    .PARAMETER Computer
        Computer Name. Defaults to localhost if no input is provided
    .PARAMETER Ensure
        Valid options are 'Present' or 'Absent'
        Defaults to Present. Will delete folder if Absent
#>
[CmdletBinding(SupportsShouldProcess = $true)]

param
(
    [Parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()] [string]$FullFolderPath,
    [Parameter(Mandatory=$false)] [string]$Computer = "localhost",
    [Parameter(Mandatory=$false)] [ValidateSet('Present','Absent')] [string]$Ensure = "Present"
)

#----------------------------------------------------------[Declarations]----------------------------------------------------------
$ErrorActionPreference = "Stop"

#-----------------------------------------------------------[Main]------------------------------------------------------------
$ScriptName = "CreateDirectoryDSCScript"
Write-Output "Starting $($ScriptName -csplit "([A-Z][a-z]+)" | Where-Object { $_ }) script"

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName    = $Computer
            FullFolderPath   = $FullFolderPath
            Ensure = $Ensure
        }
    )
}

Configuration CreateDirectory {
    [CmdletBinding(SupportsShouldProcess = $true)]

    Import-DscResource -ModuleName PsDesiredStateConfiguration

    node $AllNodes.NodeName
    {
        File Directory {
            Ensure          = $AllNodes.Ensure
            Type            = 'Directory'
            DestinationPath = $AllNodes.FullFolderPath
        }
    }
}

Write-Output "Compiling $($ScriptName) for $Computer"
CreateDirectory -ConfigurationData $ConfigurationData

Write-Output "Executing $ScriptName for $Computer"
New-Item -Path ".\CreateDirectory\" -ItemType Directory -Verbose -Force
Start-DSCConfiguration -Verbose -Wait -Force -Path ".\CreateDirectory\"
