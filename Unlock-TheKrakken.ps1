function Unlock-TheKrakken{
	<#    
		.SYNOPSIS
  			Disables every NIC on a target machine.
		.DESCRIPTION
  			This function will iterate through every NIC on a target machine and disable it.
    
		.PARAMETER kill
  			The remote system on which to start the process.
	  
		.EXAMPLE
  			PS> Unlock-TheKrakken -kill REMOTEPC

		.LINK
   			https://github.com/ben0xa/krakken/
		.NOTES
			AUTHOR: Ben0xA

            REQUIRES: PoshSec/Utility-Functions/Invoke-RemoteWmiProcess
	#>
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]$kill
    )

    $results = @()

    if($computer -ne "") {
        $nics = @()
        # Get a list of all NIC names
        $ifrslt = Invoke-RemoteWmiProcess $kill "netsh interface show interface"
        if($ifrslt -ne $null) {
            $ifstr = $ifrslt.Details
            $lines = $ifstr -split "\r\n"
            if($lines -ne $null) {
                #parse each line from output and extract the name of the interface
                foreach($line in $lines) {
                    if(($line -notlike "*Admin State*") -and ($line -notlike "*-------*")) {
                        $parts = $line -split "   "
                        if($parts -ne $null) {
                            $idx = 0
                            foreach($part in $parts) {
                                if($part.Trim() -ne "") {
                                    if($idx -eq 3) {
                                        $nics += $part.Trim()
                                    }
                                    else {
                                        $idx++
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if($nics -ne $null) {
            #disable each NIC found
            foreach($nic in $nics) {
                $results += Invoke-RemoteWmiProcess $kill "cmd /c netsh interface set interface name=`"$($nic)`" admin=disabled" -noredirect -nowait
            }
        }
        if($results -ne $null) {
            $results
        }
        else {
            Write-Output "The Krakken failed. He did not destroy your target."
        }
    }
    else {
        Write-Output "The Krakken doesn't know who to attack. Please specify a target computer."
    }
    
}