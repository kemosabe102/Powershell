function Get-Mutex {
    <#
        EXAMPLE
        $MutexId = 'MutexName'
        $mutex = Get-Mutex -MutexId $MutexId
        try
        {
            Do Something
        }
        catch
        {
            Write-Error ('{0} : {1} At Line:{2} char:{3}' -f $_.InvocationInfo.ScriptName, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber, $_.InvocationInfo.OffsetInLine)
        }
        finally {
            Write-Verbose "Releasing mutex $MutexId"
            $mutex.ReleaseMutex()
            $mutex.Close()
        }
    #>

    param (
        [parameter(Mandatory = $true)][string] $MutexId
    )

    Try
    {
        $mutex = New-Object System.Threading.Mutex($false, $MutexId)

        while (-not $mutex.WaitOne(4000))
        {
            Write-Verbose "Cannot start this task yet. There is already another task running that cannot be run in conjunction with this task. Please wait..."
        }

        Write-Verbose "Got mutex $MutexId"
        return $mutex
    }
    Catch [System.Threading.AbandonedMutexException]
    {
        return Get-Mutex $MutexId
    }
    Catch [System.SystemException]
    {
        Write-Verbose "Get-Mutex had an issue, possibly because it was running without sufficient privileges to recover the mutex, $($_.Exception.Message)"
    }
}
