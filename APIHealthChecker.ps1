##########################################################################################
If (!(Test-Path .\Logs\))
{ mkdir .\Logs\
}	
$DATE = Get-date -Format MM-dd-yyyy-HH-mm-ss
Start-Transcript -Path .\Logs\APIHealthChecker_$DATE.log
#####################################################################*###################*#
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWEBE1PATUAT*"

class TrustAllCertsPolicy : System.Net.ICertificatePolicy {
    [bool] CheckValidationResult([System.Net.ServicePoint] $a,
                                 [System.Security.Cryptography.X509Certificates.X509Certificate] $b,
                                 [System.Net.WebRequest] $c,
                                 [int] $d) {
        return $true
    }
}

[System.Net.ServicePointManager]::CertificatePolicy = [TrustAllCertsPolicy]::new()


Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances|Where-Object {($_ | Select-Object -ExpandProperty tags | where-Object -Property key -eq Name).value -like $serverType}





Foreach ($Servers in $ServerIP.PrivateIpAddress)
{




$option = New-PSSessionOption -ProxyAccessType NoProxyServer
try 
{
$URL = "https://$Servers/CoreCardServices/CoreCardServices.svc/IsOnline"
$IsOnlineRequest = Invoke-WebRequest -uri $URL
}
catch {

    $IsOnlinestring_err = $_ | Out-String

}

$IsOnlineStatus = $IsOnlineRequest.StatusCode
$IsOnlineContent = $IsOnlineRequest.Content | Select-String "LoginFailure" |ForEach-Object { $_.Matches.Value }

write-host -foregroundcolor Green	"============================================"	
if (($IsOnlineContent -eq "LoginFailure") -and ($IsOnlineStatus	-eq 200))
{
Write-Host -ForegroundColor Green "SUCCESS:: APIs are working on $Servers"

}
else
{
	
Write-Host -ForegroundColor Red "ERROR:: APIs are not working on $Servers"
}

write-host -foregroundcolor Green 	"============================================"	
}
Clear-Variable Servers
Clear-Variable IsOnlineRequest
Clear-Variable IsOnlineStatus

}

	
Stop-Transcript