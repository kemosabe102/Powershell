Add-Type -AssemblyName System.DirectoryServices.AccountManagement

function Validate-UserCredentials {
    param (
        [string] $Username,
        [string[]] $PasswordsToTry,
        [string] $Hostname = ($env:COMPUTERNAME)
    )

    foreach ($p in $PasswordsToTry)
    {
        $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine',$Hostname)
        $validateCreds = $DS.ValidateCredentials($Username, $p)
        
        If ($validateCreds)
        {
            Write-Output "Found it!"
            $p
            Break
        }
    }
    
    Write-Output "None of those worked, keep guessing"
}

