Set-StrictMode -Version 5

function Start-RoboCommand {

<#
.Synopsis
   Function that tries to run a command until it succeeds or forever
.DESCRIPTION
   Function that tries to run a command until it succeeds or forever. By default this function tries to run a command three times with three seconds intervals.
.PARAMETER Command
    Command to execute
.PARAMETER Args
    Arguments to pass to the command
.PARAMETER Count
    Number of tries before throwing an error
.PARAMETER Wait
    Run the command forever even if it succeeds
.PARAMETER Delay
    Time in seconds between two tries
.PARAMETER LogFile
    The path to the error log
.EXAMPLE
   Start-RoboCommand -Command 'Invoke-RestMethod' -Args @{ URI = "http://guid.it/json"; TimeoutSec = 1 } -Count 2 -Verbose
.EXAMPLE
   Start-RoboCommand -Command 'Invoke-RestMethod' -Args @{ URI = "http://notexisting.it/json"; TimeoutSec = 1 } -Count 2 -Verbose
.EXAMPLE
   Start-RoboCommand -Command 'Invoke-RestMethod' -Args @{ URI = "http://guid.it/json"; TimeoutSec = 1 } -Wait -Verbose
.EXAMPLE
   Start-RoboCommand -Command 'Invoke-RestMethod' -Args @{ URI = "http://notexisting.it/json"; TimeoutSec = 1 } -Wait -Verbose
.EXAMPLE
   Start-RoboCommand -Command 'Test-Connection' -Args @{ ComputerName = "bing.it" } -Wait -Verbose
.EXAMPLE
   Start-RoboCommand -Command 'Test-Connection' -Args @{ ComputerName = "nocomputer" } -Wait -LogFile $Env:temp\error.log -Verbose
.EXAMPLE
   Start-RoboCommand -Command Get-Content -Args @{path='d:\inputfile.txt'} -Wait -DelaySec 2 -LogFile $Env:temp\error.log -Verbose
.NOTES
   happysysadm.com
   @sysadm2010
#>

    [CmdletBinding(SupportsShouldProcess,DefaultParameterSetName='Limited')]
    Param (
    
    [Parameter(Mandatory=$true)]
    [Alias("Cmd")]
    [string]$Command, 

    [Parameter(Mandatory=$true)]
    [hashtable]$Args, 

    [Parameter(Mandatory=$false,ParameterSetName = 'Limited')]
    [int32]$Count = 3, 

    [Parameter(Mandatory=$false,ParameterSetName = 'Forever')]
    [switch]$Wait,

    [Parameter(Mandatory=$false)]
    [int32]$DelaySec = 3,

    [Parameter(Mandatory=$false)]
    $LogFile
    )
    
    $Args.ErrorAction = "Stop"
        
    $RetryCount = 0

    $Success = $false
    
    do {

        try {

            & $command @args

            Write-Verbose "$(Get-Date) - Command $Command with arguments `"$($Args.values[0])`" succeeded."

            if(!$Wait) {
                
                $Success = $true

                }
            
            }
        
        catch {

            if($LogFile) {

                "$(Get-Date) - Error: $($_.Exception.Message) - Command: $Command - Arguments: $($Args.values[0])" | Out-File $LogFile -Append

                }
            
            if ($retrycount -ge $Count) {

                Write-Verbose "$(Get-Date) - Command $Command with arguments `"$($Args.values[0])`" failed $RetryCount times. Exiting."

                $PSCmdlet.ThrowTerminatingError($_)
                
                }

            else {

                Write-Verbose "$(Get-Date) - Command $Command with arguments `"$($Args.values[0])`" failed. Retrying in $DelaySec seconds."

                Start-Sleep -Seconds $DelaySec

                if(!$Wait) {
                
                    $RetryCount++

                    }

                }

            }

        }

    while (!$Success)

 }