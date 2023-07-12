##########################################################################################
If (!(Test-Path .\Logs\))
{ mkdir .\Logs\
}	
$DATE = Get-date -Format MM-dd-yyyy-HH-mm-ss
Start-Transcript -Path .\Logs\APIHealthChecker_$DATE.log
#####################################################################*###################*#
$InstancesList = GET-EC2lnstance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWEB*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances|Where-Object {($_	|Select-Object -ExpandProperty tags | where-Object -Property key -eq Name).value -like $serverType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$option = New-PSSessionOption -ProxyAccessType NoProxyServer
$URL = "http://$Servers/CoreCardServices/CoreCardServices.svc/IsOnline"$WebCall = Invoke-WebRequest -uri SURL
write-host -foregroundcolor Green	"============================================"	
if (($WebCall.Content -eq "LoginFailure") -and ($WebCall.StatusCode	-eq 200))
{
Write-Host -ForegroundColor Green "SUCCESS:: APIs are working on $Servers"

}
else
{
	
Write-Host -ForegroundColor Red "ERROR:: APIs are not working on $Servers"
}

write-host -foregroundcolor Green 	"============================================"	
}
}
	
Stop-Transcript
