<#
    .SYNOPSIS
        Set Inheritance on a directory
    .PARAMETER FullFolderPath
        Indicates the path to the target item.
    .PARAMETER Enabled
        Indicates whether NTFS permissions inheritance is enabled. Set this property to $false to ensure it is disabled. The default value is $true
    .PARAMETER PreserveInherited
        Indicates whether to preserve inherited permissions. Set this property to $true to convert inherited permissions into explicit permissions. 
        The default value is $false. Note: This property is only valid when the Enabled property is set to $false.
        Be careful before running this as it could lock you out of the item if there are no newly added permissions
    .PARAMETER Computer
        Computer Name, defaults to localhost if no input is provided
#>
[CmdletBinding(SupportsShouldProcess = $true)]

param
(
    [Parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()] [string]$FullFolderPath,
    [Parameter(Mandatory=$false)] [ValidateSet('True','False')] [string]$Enabled = "True",
    [Parameter(Mandatory=$false)] [ValidateSet('True','False')] [string]$PreserveInherited = "True",
    [Parameter(Mandatory=$false)] [string]$Computer = "localhost"
)

#----------------------------------------------------------[Declarations]----------------------------------------------------------
$ErrorActionPreference = "Stop"

#-----------------------------------------------------------[Main]------------------------------------------------------------
Write-Verbose "Starting SetDirectoryInheritance Script"
$ScriptName = "SetDirectoryInheritance"

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = $Computer
            FullFolderPath = $FullFolderPath
            Enabled = $Enabled
            PreserveInherited = $PreserveInherited
        }
    )
}


Configuration SetDirectoryInheritance {
    Import-DscResource -ModuleName cNtfsAccessControl -ModuleVersion 1.4.1
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    node $AllNodes.NodeName
    {
        cNtfsPermissionsInheritance Inheritance
        {
            Path = $AllNodes.FullFolderPath
            Enabled = [System.Convert]::ToBoolean($AllNodes.Enabled)
            PreserveInherited = [System.Convert]::ToBoolean($AllNodes.PreserveInherited)
        }
    }
}

Write-Verbose "Compiling $($ScriptName) for $Computer"
SetDirectoryInheritance -ConfigurationData $ConfigurationData

Write-Verbose "Executing $ScriptName for $Computer"
New-Item -Path ".\SetDirectoryInheritance\" -ItemType Directory -Verbose -Force
Start-DSCConfiguration -Verbose -Wait -Force -Path ".\SetDirectoryInheritance\"
