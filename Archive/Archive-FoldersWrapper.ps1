param (
    $LastAccessedDate = (Get-Date).AddDays(-500),
    $RemoveAfterDate = (Get-Date).AddDays(-800),
    $ColdStorageLocation = "O:\BackUp",
    $TopLevelDirectoriesThatCanBeArchived = ("D:\Downloads"),
    $PsModulePath = "../Modules"
)

$PowerShellModules = Get-ChildItem -Path $PsModulePath
foreach ($Module in $PowerShellModules) {
	Write-Host "Import Module $($Module.FullName)"
	Import-Module $Module.FullName -Force -DisableNameChecking
}

# The archival process
ForEach ($Dir in $TopLevelDirectoriesThatCanBeArchived)
{
    $ArchivableFolders = Get-ChildItem $Dir

    foreach ($item in $ArchivableFolders)
    {
        Archive-OldFolders -Source $item -Destination $ColdStorageLocation -FolderLastAccessed $LastAccessedDate
    }
}

Remove-OldFolders -Target $ColdStorageLocation -FolderLastAccessed $RemoveAfterDate
