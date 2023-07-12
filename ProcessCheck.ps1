clear-host

$processname = read-host "ENTER THE PROCESS NAME"

if($Processname -match "note*" ){

get-process $Processname* | select-Object name, ID, Starttime

}

else {

Write-Host -foregroundcolor Red "WF IS NOT RUNNING"

}



