##########################################################################################
If (!(Test-Path .\Logs\))
{ mkdir .\Logs\
}	
$DATE = Get-date -Format MM-dd-yyyy-HH-mm-ss
Start-Transcript -Path .\Logs\APIHealthChecker_$DATE.log
#####################################################################*###################*#
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWCF*"

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
$WebCall=$NULL
$URL=$NULL
$option = New-PSSessionOption -ProxyAccessType NoProxyServer
$URL = "https://$Servers/WCF/customerservice.svc?HealthCheck"
$WebCall = Invoke-WebRequest -uri $URL
write-host -foregroundcolor Green	"============================================"	
if (($WebCall.Content -match "You have created a service") -and ($WebCall.StatusCode	-eq 200))
{
Write-Host -ForegroundColor Green "SUCCESS:: WCF is working on $Servers"

}
else
{
	
Write-Host -ForegroundColor Red "ERROR:: WCF is not working on $Servers"
}

write-host -foregroundcolor Green 	"============================================"	
}
}
	
Stop-Transcript