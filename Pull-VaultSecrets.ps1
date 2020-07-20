<#
.SYNOPSIS
    Pulls secrets from an Azure key vault
.DESCRIPTION
    This script can either pull a single secret from an Azure key vault or all secrets
    contained in a YAML config file
.PARAMETER VaultName
    Name of the Azure key vault
.PARAMETER SecretName
    Name of the secret to pull from the key vault.
    This is required with OutputFileName
.PARAMETER OutputFileName
    Full path to where the secret should be downloaded to
    This is required with SecretName
    This should include the filename in the path: IE C:\path\to\filename.yaml
.PARAMETER SecretConfigFile
    Switch to enable use of secrets config file.
    This is required with SecretConfigFilePath
.PARAMETER SecretConfigFilePath
    Name of the secrets config file that contains all the secrets that should be downloaded
    This is required with the SecretConfigFile switch

    Format should be like:
    secrets:
        secretName: C:\path\to\filename.yaml
        secretName2: C:\path\to\other\filename2.yaml
#>
[CmdletBinding(SupportsShouldProcess = $true)]

param (
    [string]$VaultName,
    [string]$SecretName,
    [string]$OutputFileName,
    [switch]$SecretConfigFile = $false,
    [string]$SecretConfigFilePath
)

$ErrorActionPreference = 'Stop'

Install-Module powershell-yaml

# Helper function to download secrets from vault
function Get-SecretFromVault {
    param (
        [string]$VaultName,
        [string]$SecretName,
        [string]$OutputFileName
    )

    Write-Output "Downloading secret '$SecretName' from '$VaultName' vault"
    az keyvault secret download --file "$OutputFileName" `
    --encoding 'utf-8' `
    --name "$SecretName" `
    --vault-name "$VaultName" `
}

# Helper function to create a new directory if one does not exist
function New-ParentPathIfNotExist {
    param (
        $Path
    )

    $pathToTest = Split-Path -Path $Path

    # This creates a new folder if the path is not simply a filename without a full path and
    # if the directory does not already exist
    If (!([string]::IsNullOrEmpty($pathToTest)) -and !(Test-Path $pathToTest)) {
        New-Item -ItemType Directory -Force -Path $pathToTest
    }
}

try {
    # Checks if config file and its path were passed to script
    If (($SecretConfigFile.IsPresent) -and !([string]::IsNullOrEmpty($SecretConfigFilePath))) {
        Write-Output "Getting config file content"
        $SecretConfigFileContentYaml = Get-Content -Raw $SecretConfigFilePath
        $SecretConfigFileContent = ConvertFrom-Yaml -Yaml $SecretConfigFileContentYaml -AllDocuments -Ordered

        Write-Output "Downloading secret files"
        Foreach ($secret in $SecretConfigFileContent["secrets"].GetEnumerator()) {
            $secretName = $secret.Name
            $outputFileName = $secret.Value

            If ($secret.Name -like "*PfxCert") {
                $outputFileName = $secret.Value["path"]
            }

            # Create directory path if it does not exist; secret download requires existing folder path
            New-ParentPathIfNotExist -Path $outputFileName

            # Pull secrets
            Get-SecretFromVault -VaultName $VaultName -SecretName $secretName -OutputFileName $outputFileName
        }
    }
    # Checks if secret name and the output file name were passed
    elseif (!([string]::IsNullOrEmpty($SecretName)) -and !([string]::IsNullOrEmpty($OutputFileName))) {
        # Create directory path if it does not exist; secret download requires existing folder path
        New-ParentPathIfNotExist -Path $OutputFileName

        # Pull secrets
        Get-SecretFromVault -VaultName $VaultName -SecretName $SecretName -OutputFileName $OutputFileName
    }
    else {
        Write-Warning "Either a config file and its path or a secret and its full output path need to be specified."
        Write-Error "No secrets were downloaded."
    }
}
catch {
    Write-Warning ('{0} : {1} At Line:{2} char:{3}' -f $_.InvocationInfo.ScriptName, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber, $_.InvocationInfo.OffsetInLine)
    Write-Error "Downloading secret files failed, see prior message"
}
