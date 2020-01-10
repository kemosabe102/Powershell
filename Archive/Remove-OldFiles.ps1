param (
    [Parameter(Mandatory=$false)] [datetime]$LastModifiedDate = $((Get-Date).AddDays(-14)),
    [Parameter(Mandatory=$false)] [string[]]$Directories = @('/first/path/', '/second/path/'),
    [Parameter(Mandatory=$false)] [string]$PsModulePath = "C:\Scripts\FileArchiver"
)

$PowerShellModules = Get-ChildItem -Path $PsModulePath -Filter FileSystem.psm1
foreach ($Module in $PowerShellModules) {
    Import-Module $Module.FullName -Force -DisableNameChecking
}

ForEach ($dir in $Directories) {
    Remove-Files -Directory $dir -LastModified $LastModifiedDate
}
