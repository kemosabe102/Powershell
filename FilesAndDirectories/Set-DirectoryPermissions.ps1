<#
    .SYNOPSIS
        Set Permissions on a directory
    .PARAMETER FullFolderPath
        Indicates the path to the target item
    .PARAMETER PrincipalToAssignPermissions
        Security principal to assign permissions
        Valid formats are:
            DOMAIN\UserName, SAM, SID, and UPN
    .PARAMETER AccessControlType
        Indicates whether to Allow or Deny access to the target item. The default value is Allow
    .PARAMETER FileSystemRights
        Indicates the access rights to be granted to the principal. Specify one or more values from the System.Security.AccessControl.FileSystemRights enumeration type.
        Multiple values can be specified by using an array of strings or a single comma-separated string. The default value is ReadAndExecute.
        Can also include numbers. Add numbers to include multiple combinations of permissions
        Permissions that can be assigned are listed here: https://docs.microsoft.com/en-us/dotnet/api/system.security.accesscontrol.filesystemrights?redirectedfrom=MSDN&view=netframework-4.8
        DeleteSubdirectoriesAndFiles and ReadAndExecute = 131305
    .PARAMETER Inheritance
        Indicates the inheritance type of the permission entry. This property is only applicable to directories.
    .PARAMETER NoPropagateInherit
        Indicates whether the permission entry is not propagated to child objects. This property is only applicable to directories. Set this property to $true to
        ensure inheritance is limited only to those sub-objects that are immediately subordinate to the target item. The default value is $false.
    .PARAMETER Computer
        Computer Name, defaults to localhost if no input is provided
    .PARAMETER Ensure
        Valid options are 'Present' or 'Absent'
        Defaults to Present. Will delete folder if Absent
#>
[CmdletBinding(SupportsShouldProcess = $true)]

param
(
    [Parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()] [string]$FullFolderPath,
    [Parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()] [string]$PrincipalToAssignPermissions,
    [Parameter(Mandatory=$false)] [ValidateSet('Allow','Deny')] [string]$AccessControlType = 'Allow',
    [Parameter(Mandatory=$true)] [string[]]$FileSystemRights,

    [Parameter(Mandatory=$false)]
    [ValidateSet('None','ThisFolderOnly','ThisFolderSubfoldersAndFiles','ThisFolderAndSubfolders','ThisFolderAndFiles','SubfoldersAndFilesOnly','SubfoldersOnly','FilesOnly')]
    [string]$Inheritance = 'ThisFolderSubfoldersAndFiles',
    
    [Parameter(Mandatory=$false)] [ValidateSet('True','False')] [string]$NoPropagateInherit = "False",
    [Parameter(Mandatory=$false)] [string]$Computer = "localhost",
    [Parameter(Mandatory=$false)] [ValidateSet('Present','Absent')] [string]$Ensure = "Present"
)

#----------------------------------------------------------[Declarations]----------------------------------------------------------
$ErrorActionPreference = "Stop"

#-----------------------------------------------------------[Main]------------------------------------------------------------
Write-Verbose "Starting SetDirectoryPermissions Script"
$ScriptName = "SetDirectoryPermissions"

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = $Computer
            FullFolderPath = $FullFolderPath
            Ensure = $Ensure
            PrincipalToAssignPermissions = $PrincipalToAssignPermissions
            AccessControlType = $AccessControlType
            FileSystemRights = $FileSystemRights
            Inheritance = $Inheritance
            NoPropagateInherit = $NoPropagateInherit
        }
    )
}


Configuration SetDirectoryPermissions {
    Import-DscResource -ModuleName cNtfsAccessControl -ModuleVersion 1.4.1
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    node $AllNodes.NodeName
    {
        cNtfsPermissionEntry Permissions
        {
            Ensure = $AllNodes.Ensure
            Path = $AllNodes.FullFolderPath
            Principal = $AllNodes.PrincipalToAssignPermissions
            AccessControlInformation = @(
                cNtfsAccessControlInformation
                {
                    AccessControlType = $AllNodes.AccessControlType
                    FileSystemRights = $AllNodes.FileSystemRights
                    Inheritance = $AllNodes.Inheritance
                    NoPropagateInherit = [System.Convert]::ToBoolean($AllNodes.NoPropagateInherit)
                }
            )
        }
    }
}

Write-Verbose "Compiling $($ScriptName) for $Computer"
SetDirectoryPermissions -ConfigurationData $ConfigurationData

Write-Verbose "Executing $ScriptName for $Computer"
New-Item -Path ".\SetDirectoryPermissions\" -ItemType Directory -Verbose -Force
Start-DSCConfiguration -Verbose -Wait -Force -Path ".\SetDirectoryPermissions\"
