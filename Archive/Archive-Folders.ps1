<#
    Days to years
    1.5 years = 550 days
    2 years = 730 days
    2.5 years = 900 days
    3 years = 1100 days
#>

param (
   $LastModifiedDate = (Get-Date).AddDays(-365), # change this to adjust cold storage date - default 365
   $RemoveAfterDate = (Get-Date).AddDays(-730), # change this to adjust remove after date - default 730
   $ColdStorageLocation = "D:\ColdStorage",
   $DirectoriesToCheck = ("D:\Downloads", "D:\Completed Downloads", "D:\Movies", "D:\TV Shows"),
   $PsModulePath = "C:\Powershell-master\Modules"
)

$PowerShellModules = Get-ChildItem -Path $PsModulePath
foreach ($Module in $PowerShellModules) {
    Write-Host "Import Module $($Module.FullName)"
    Import-Module $Module.FullName -Force -DisableNameChecking
}

# The archival process
ForEach ($Dir in $DirectoriesToCheck)
{
   $ArchivableFolders = Get-ChildItem $Dir

   foreach ($item in $ArchivableFolders)
   {
       Archive-OldFolders -Source $item.FullName -Destination $ColdStorageLocation -LastModified $LastModifiedDate
   }
}

$RarFiles = Get-ChildItem $ColdStorageLocation -Recurse -Filter *.r\d\d,
Select-String r\d\d -input $string -AllMatches

Remove-OldFolders -Target $ColdStorageLocation -LastModified $RemoveAfterDate
