$ServerType = 'web'
$ThisServer = (Hostname).ToLower()
if($ThisServer -match 'e1')
{$Region = "us-east-1"
$ShortRegion = 'e1'
} elseif($ThisServer -match 'w2')
{$Region = "us-west-2"
$ShortRegion = 'w2'
}

$AWSVarialbes = (aws ec2 describe-instances --query "Reservations[*].Instances[*].{AvailabilityZone:Placement.AvailabilityZone,IpAddress:PrivateIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name,Environment:Tags[?Key=='environment']|[0].Value,Status:State.environment,Stack:Tags[?Key=='stack']|[0].Value,Status:State.stack,Attribution:Tags[?Key=='attribution']|[0].Value,Status:State.attribution}" --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values='$ThisServer'" "Name=availability-zone,Values='*'" --region $Region | ConvertFrom-Json)


$EnvironmentName = $AWSVarialbes.Environment.ToLower()
$EnvironmentName
$Environmentattributon = $AWSVarialbes.Attribution.ToLower()
$Environmentattributon
$EnvironmentStack = ($AWSVarialbes.Stack.ToLower())[0]
$EnvironmentStack

$ServerList = ((aws ec2 describe-instances --query "Reservations[*].Instances[*].{AvailabilityZone:Placement.AvailabilityZone,IpAddress:PrivateIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}" --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values='*$ServerType$ShortRegion$EnvironmentName$EnvironmentStack*'" "Name=availability-zone,Values='*'" --region $Region | ConvertFrom-Json) | Select-Object @{n = "Name"; e = { $_.Name } }, @{n = "serial"; e = { [double]($_.Name -split "$EnvironmentName$EnvironmentStack")[1] } } | Sort-Object -Property serial).Name
#$ServerList

$MasterHost = $ServerList | Select-Object -First 1

If (Test-Connection $MasterHost -Quiet){
Write-Host "Master Host - " $MasterHost
}
else{
$MasterHost = $ServerList | Select-Object -Last 1
Write-Host "Master Host - " $MasterHost
}

$option = New-PSSessionOption -ProxyAccessType NoProxyServer -OpenTimeout 20000
$MasterSVCHandlerVersion = Invoke-Command -ComputerName $MasterHost -SessionOption $option -ErrorAction inquire -ScriptBlock {
$MasterSVCHandlerVersion = (Get-Command D:\WebServer\Services\bin\dbbHandler2005.dll).FileVersionInfo.FileVersion
$MasterSVCHandlerVersion}

$MasterScaleServiceVersion = Invoke-Command -ComputerName $MasterHost -SessionOption $option -ErrorAction inquire -ScriptBlock {
$file = "D:\WebServer\ScaleService\dbbScaleService.exe"
If (Test-Path $file){
$MasterScaleServiceVersion = (Get-Command $file).FileVersionInfo.FileVersion} 
else{
$MasterScaleServiceVersion = "ScaleService does not exist"}
$MasterScaleServiceVersion}

$MasterSVCWebsiteHash = Invoke-Command -ComputerName $MasterHost -SessionOption $option -ErrorAction inquire -ScriptBlock {
(Get-ChildItem -Path D:\WebServer\Services\ -Recurse -Filter *.* | Get-FileHash).Hash | %{ $MasterSVCWebsiteHash += "$_"}
$MasterSVCWebsite_stream = [IO.MemoryStream]::new([byte[]][char[]]$MasterSVCWebsiteHash)
$MasterSVCWebsiteHash = (Get-FileHash -InputStream $MasterSVCWebsite_stream).Hash
$MasterSVCWebsiteHash}


$ExpectedWEBServerCount = 3
$Expectedenable32BitAppOnWin64 = "False"
$ExpectedidleTimeoutAction = "Terminate"
$ExpectedLoadUserProfile = "True"
$ExpectedmaxProcesses = "4"
$ExpectedPrivateMemoryLimit = "0"
$ExpectedRecyclingPeriodicRestartTime = "1740"
$ExpectedAnonymousAuthentication = "Application Pool Identity"
$ExpectedAppPooluserName = ((whoami).TOLOWER()).Split('\')[0] + '\gMSA-web-svc$'
$ExpectedConnectAs = "Pass-through Authentication"
$ExpectedSiteBindingprotocol = "http https"
$ExpectedXRequestID = "X-Request-ID"
$ExpectedASStatus = "Method not allowed"
$ExpectedPASRequest = "Method not allowed"
$ExpectedLAStatus = "Method not allowed"
$ExpectedIsOnlineWorking = "Working"

if (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "perf") -and ($Environmentattributon -eq "cookie")){
$ExpectedWEBServerCount = "45" 
$ExpectedmaxProcesses = "32"
$ExpectedPrivateMemoryLimit = "400000"
$ExpectedRecyclingPeriodicRestartTime = "240"}
elseif (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "uat2" -or $EnvironmentName -eq "mock") -and ($Environmentattributon -eq "jazz")){
$ExpectedWEBServerCount = "30"
$ExpectedmaxProcesses = "64"
$ExpectedPrivateMemoryLimit = "0"
$ExpectedRecyclingPeriodicRestartTime = "1740"}


$Outputreport = "<HTML><TITLE>Services Website Validation Report</TITLE>
                 <BODY background-color:peachpuff>
                 <font color =""#4682B4"" face=""Microsoft Tai le"">
                 <H2>$($EnvironmentName.ToUpper()) - PLEASE VERIFY BELOW TABLE VALUES AND COMPARE WITH EXPECTED VALUES</H2></font>
                 <Table border=1 cellpadding=0 cellspacing=0>
                 <TR bgcolor=gray align=center>
                   <TD><B>Master Host</B></TD>
                   <TD><B>SVC Handler Version</B></TD>
                   <TD><B>Scale Service Version</B></TD>
                   <TD><B>SVC Website Hash</B></TD>
                   <TD><B>32Bit Enable</B></TD>
                   <TD><B>Idle Timeout Action</B></TD>
                   <TD><B>Load User Profile</B></TD>
                   <TD><B>Max Worker Processes</B></TD>
                   <TD><B>Private Memory Limit</B></TD>
                   <TD><B>Recycling Periodic Restart Time (in min)</B></TD>
                   <TD><B>Anonymous Authentication</B></TD>
                   <TD><B>AppPool userName</B></TD>
                   <TD><B>ConnectAs</B></TD>
                   <TD><B>Site Protocols</B></TD>
                   <TD><B>XRequestID</B></TD>
                   <TD><B>Account Summary URL Status</B></TD>
                   <TD><B>Person Account Summary URL Status</B></TD>
                   <TD><B>List Accounts URL Status</B></TD>
                   <TD><B>IsOnline URL Status</B></TD>
                   </TR>"
                   

$Outputreport += "<TR align=center>"
$Outputreport += "<TD>$("$MasterHost".ToUpper())</TD>
                   <TD>$("$MasterSVCHandlerVersion")</TD>
                   <TD>$("$MasterScaleServiceVersion")</TD>
                   <TD>$("$MasterSVCWebsiteHash")</TD>
                   <TD>$("$Expectedenable32BitAppOnWin64")</TD>
                   <TD>$("$ExpectedidleTimeoutAction")</TD>
                   <TD>$("$ExpectedLoadUserProfile")</TD>
                   <TD>$("$ExpectedmaxProcesses")</TD>
                   <TD>$("$ExpectedPrivateMemoryLimit")</TD>
                   <TD>$("$ExpectedRecyclingPeriodicRestartTime")</TD>
                   <TD>$("$ExpectedAnonymousAuthentication")</TD>
                   <TD>$("$ExpectedAppPooluserName")</TD>
                   <TD>$("$ExpectedConnectAs")</TD>
                   <TD>$("$ExpectedSiteBindingprotocol")</TD>
                   <TD>$("$ExpectedXRequestID")</TD>
                   <TD>$("$ExpectedASStatus")</TD>
                   <TD>$("$ExpectedPASRequest")</TD>
                   <TD>$("$ExpectedLAStatus")</TD>
                   <TD>$("$ExpectedIsOnlineWorking")</TD>
                  </TR>"



$Result = @() 
#ForEach($computername in $ServerList) 
#{

#$computername
#If ((Test-Connection $computername -Quiet)){
#Write-Host "$computername Server is  Accessible"

$option = New-PSSessionOption -ProxyAccessType NoProxyServer 
$result += Invoke-Command -ComputerName $ServerList -SessionOption $option -ErrorAction inquire -ScriptBlock {
$computername = hostname
Import-Module WebAdministration
$SVCHandlerVersion = (Get-Command D:\WebServer\Services\bin\dbbHandler2005.dll).FileVersionInfo.FileVersion
$ServerSVCWebsiteHash = $NULL
(Get-ChildItem -Path D:\WebServer\Services\ -Recurse -Filter *.* | Get-FileHash).Hash | %{ $ServerSVCWebsiteHash += "$_"}
$ServerSVCWebsite_stream = [IO.MemoryStream]::new([byte[]][char[]]$ServerSVCWebsiteHash)
$ServerSVCWebsiteHash = (Get-FileHash -InputStream $ServerSVCWebsite_stream).Hash
#$ScaleServiceVersion = (Get-Command D:\WebServer\ScaleService\dbbScaleService.exe).FileVersionInfo.FileVersion
$file = "D:\WebServer\ScaleService\dbbScaleService.exe"
If (Test-Path $file){
$ScaleServiceVersion = (Get-Command $file).FileVersionInfo.FileVersion} 
else{
$ScaleServiceVersion = "ScaleService does not exist"}
$enable32BitAppOnWin64 = (Get-ItemProperty IIS:\AppPools\Services).enable32BitAppOnWin64
$managedPipelineMode = (Get-ItemProperty IIS:\AppPools\Services).managedPipelineMode
$state = (Get-ItemProperty IIS:\AppPools\Services).state
$idleTimeoutAction = Get-ItemProperty "IIS:\AppPools\Services" -Name processModel.idleTimeoutAction
$LoadUserProfile = Get-ItemProperty "IIS:\AppPools\Services" -Name processModel.LoadUserProfile.Value
$maxProcesses = Get-ItemProperty "IIS:\AppPools\Services" -Name processModel.maxProcesses.Value
$PrivateMemoryLimit = (Get-ItemProperty IIS:\apppools\Services -Name recycling.periodicrestart.privateMemory).value
$RecyclingPeriodicRestartTime = ((Get-ItemProperty -Path "IIS:\AppPools\Services" -Name Recycling.PeriodicRestart.Time).value.TotalMinutes)
$AnonymousAuthentication = (Get-WebConfigurationProperty -Filter '/system.webServer/security/authentication/anonymousAuthentication'  -PSPath 'IIS:\' -Location "Services" -Name userName).Value
if($AnonymousAuthentication -eq ""){$AnonymousAuthentication = "Application Pool Identity"}
#else{$AnonymousAuthentication = "Application Pool Identity"}
$AppPooluserName = Get-ItemProperty "IIS:\AppPools\Services" -Name processModel.userName.Value
$ConnectAs = (Get-WebConfiguration "/system.applicationHost/sites/site[@name='Services']/application[@path='/']/VirtualDirectory[@path='/']").UserName
if($ConnectAs -eq ""){$ConnectAs = "Pass-through Authentication"}
#else{Write-Host "Connect AS- User Set:$ConnectAs"}
$SiteBindingprotocol = (Get-IISSite "Services").bindings.protocol #| select-object protocol, bindingInformation
$SiteBindingInfo = (Get-IISSite "Services").bindings.bindingInformation
$XRequestID = (Get-ItemProperty 'IIS:\Sites\Services' -Name logfile.customFields.collection).logFieldName
$resultvalue = @() 
$resultvalue = [PSCustomObject] @{ 
    ServerName = "$($computername)"
    SVCHandlerVersion = "$($SVCHandlerVersion)"
    ScaleServiceVersion = "$($ScaleServiceVersion)"
    ServerSVCWebsiteHash = "$($ServerSVCWebsiteHash)"
    enable32BitAppOnWin64 = "$($enable32BitAppOnWin64)"
    managedPipelineMode = "$($managedPipelineMode)"
    state = "$($state)"
    idleTimeoutAction = "$($idleTimeoutAction)"
    LoadUserProfile = "$($LoadUserProfile)"
    maxProcesses = "$($maxProcesses)"
    PrivateMemoryLimit = "$($PrivateMemoryLimit)"
    RecyclingPeriodicRestartTime = "$($RecyclingPeriodicRestartTime)"
    AnonymousAuthentication = "$($AnonymousAuthentication)"
    AppPooluserName = "$($AppPooluserName)"
    ConnectAs = "$($ConnectAs)"
    SiteBindingprotocol = "$($SiteBindingprotocol)"
    SiteBindingInfo = "$($SiteBindingInfo)"
    XRequestID = "$($XRequestID)"
	}
$resultvalue
}
#} else{

#Write-Host "$computername Server is NOT Accessible"
#$ServerNotAccesible = "Unreachable"
#$resultvalue = @() 
#$resultvalue = [PSCustomObject] @{ 
#    ServerName = "$(($computername).ToUpper())"
#    SVCHandlerVersion = "$($ServerNotAccesible)"
#    ServerSVCWebsiteHash = "$($ServerNotAccesible)"
#    enable32BitAppOnWin64 = "$($ServerNotAccesible)"
#    managedPipelineMode = "$($ServerNotAccesible)"
#    state = "$($ServerNotAccesible)"
#    idleTimeoutAction = "$($ServerNotAccesible)"
#    LoadUserProfile = "$($LoadUserProfile)"
#    maxProcesses = "$($ServerNotAccesible)"
#    PrivateMemoryLimit = "$($ServerNotAccesible)"
#    AnonymousAuthentication = "$($ServerNotAccesible)"
#    AppPooluserName = "$($ServerNotAccesible)"
#    ConnectAs = "$($ServerNotAccesible)"
#    SiteBindingprotocol = "$($ServerNotAccesible)"
#    SiteBindingInfo = "$($ServerNotAccesible)"
#    XRequestID = "$($ServerNotAccesible)"
#	}
#$result += $resultvalue
#}
#}

if($Serverlist.Count -eq $ExpectedWEBServerCount)
{
$Outputreport += "</Table>
                 <font color =""#4682B4"" face=""Microsoft Tai le"">
                   <H2>  Services Website Validation Report - Server Count $($result.count) </H2></font>"


}else{
$Outputreport += "</Table>
                 <font color =""#CD5C5C"" face=""Microsoft Tai le"">
                   <H2>Services Website Validation Report - Server Count $($result.count) is not matching with expected count $ExpectedWEBServerCount </H2></font>"
}


$Outputreport += "<Table border=1 cellpadding=0 cellspacing=0>
                 <TR bgcolor=gray align=center>
                    <TD><B>WEB Server</B></TD>
                   <TD><B>Services Handler Version</B></TD>
                   <TD><B>Services Service Version</B></TD>
                   <TD><B>SVC website Hash</B></TD>
                   <TD><B>32Bit Enable</B></TD>
                   <TD><B>Idle Timeout Action</B></TD>
                   <TD><B>Load user Profile</B></TD>
                   <TD><B>Max Worker Processes</B></TD>
                   <TD><B>Private Memory Limit</B></TD>
                   <TD><B>Recycling Periodic Restart Time(in min)</B></TD>
                   <TD><B>Anonymous Authentication</B></TD>
                   <TD><B>AppPool userName</B></TD>
                   <TD><B>ConnectAs</B></TD>
                   <TD><B>Site Protocols</B></TD>
                   <TD><B>Site Bindings</B></TD>
                   <TD><B>XRequestID</B></TD>
                   <TD><B>Account Summary URL</B></TD>
                   <TD><B>Person Account Sumary URL</B></TD>
                   <TD><B>List Accounts URL</B></TD>
                   <TD><B>IsOnline URL</B></TD>
                   </TR>"

class TrustAllCertsPolicy : System.Net.ICertificatePolicy {
    [bool] CheckValidationResult([System.Net.ServicePoint] $a,
                                 [System.Security.Cryptography.X509Certificates.X509Certificate] $b,
                                 [System.Net.WebRequest] $c,
                                 [int] $d) {
        return $true
    }
}
[System.Net.ServicePointManager]::CertificatePolicy = [TrustAllCertsPolicy]::new()


Foreach($Entry in $Result){ 
$ASRequest = $NULL
$PASRequest = $NULL
$LARequest = $NULL
$IsOnlineRequest = $NULL

 
$IPAddress = (Resolve-DnsName $Entry.ServerName | Where-Object Type -eq "A").IpAddress
try {
$ASURL = "https://$IPAddress/CoreCardServices/CoreCardServices.svc/AccountSummary"
$ASRequest = Invoke-WebRequest $ASURL
} catch {

    $ASstring_err = $_ | Out-String

}

$ASStatus = $ASstring_err | Select-String "Method not allowed" |ForEach-Object { $_.Matches.Value }
if ($ASStatus -eq $NULL) {$ASStatus = "Not Working"}
$ASURL
$ASStatus

try {
$PASURL = "https://$IPAddress/CoreCardServices/CoreCardServices.svc/PersonAccountSummary"
$PASRequest = Invoke-WebRequest $PASURL
} catch {

    $PASstring_err = $_ | Out-String

}

$PASStatus = $PASstring_err | Select-String "Method not allowed" |ForEach-Object { $_.Matches.Value }
if ($PASStatus -eq $NULL) {$PASStatus = "Not Working"}
$PASURL
$PASStatus


try {
$LAURL = "https://$IPAddress/CoreCardServices/CoreCardServices.svc/ListAccounts"
$LARequest = Invoke-WebRequest $LAURL
} catch {

    $LAstring_err = $_ | Out-String

}

$LAStatus = $LAstring_err | Select-String "Method not allowed" |ForEach-Object { $_.Matches.Value }
if ($LAStatus -eq $NULL) {$LAStatus = "Not Working"}
$LAURL
$LAStatus



try {
$IsOnlineURL = "https://$IPAddress/CoreCardServices/CoreCardServices.svc/IsOnline"
$IsOnlineRequest = Invoke-WebRequest $IsOnlineURL
} catch {

    $IsOnlinestring_err = $_ | Out-String

}

$IsOnlineStatus = $IsOnlineRequest.StatusCode
$IsOnlineContent = $IsOnlineRequest.Content | Select-String "LoginFailure" |ForEach-Object { $_.Matches.Value }
if (($IsOnlineContent -eq "LoginFailure") -and ($IsOnlineStatus	-eq 200))
{
$IsOnlineWorking="Working"
}
else
{
$IsOnlineWorking="Not Working"
$IsOnlineContent = $NULL
}
$IsOnlineURL
$IsOnlineStatus
$IsOnlineContent


if(($Entry.ScaleServiceVersion -eq $MasterScaleServiceVersion) `
-and ($Entry.ScaleServiceVersion -eq $MasterScaleServiceVersion) `
-and ($Entry.ServerSVCWebsiteHash -eq $MasterSVCWebsiteHash) `
-and ($Entry.enable32BitAppOnWin64 -eq $Expectedenable32BitAppOnWin64) `
-and ($Entry.idleTimeoutAction -eq $ExpectedidleTimeoutAction) `
-and ($Entry.LoadUserProfile -eq $ExpectedLoadUserProfile) `
-and ($Entry.maxProcesses -eq $ExpectedmaxProcesses) `
-and ($Entry.PrivateMemoryLimit -eq $ExpectedPrivateMemoryLimit) `
-and ($Entry.RecyclingPeriodicRestartTime -eq $ExpectedRecyclingPeriodicRestartTime) `
-and ($Entry.AnonymousAuthentication -eq $ExpectedAnonymousAuthentication) `
-and ($Entry.AppPooluserName -eq $ExpectedAppPooluserName) `
-and ($Entry.ConnectAs -eq  $ExpectedConnectAs ) `
-and ($Entry.SiteBindingprotocol -eq $ExpectedSiteBindingprotocol) `
-and ($Entry.XRequestID -eq $ExpectedXRequestID) `
-and ($ASStatus -eq $ExpectedASStatus) `
-and ($PASStatus -eq $ExpectedPASRequest) `
-and ($LAStatus -eq $ExpectedLAStatus) `
-and ($IsOnlineWorking -eq $ExpectedIsOnlineWorking))
{
$Outputreport += "<TR align=center>" 
}else{
$Outputreport += "<TR bgcolor=LightSalmon align=center>"
}

$Outputreport += "<TD>$($Entry.ServerName)</TD>
                  <TD align=center>$($Entry.SVCHandlerVersion)</TD>
                  <TD align=center>$($Entry.ScaleServiceVersion)</TD>
                  <TD align=center>$($Entry.ServerSVCWebsiteHash -eq $MasterSVCWebsiteHash)</TD>
                  <TD align=center>$($Entry.enable32BitAppOnWin64)</TD>
                  <TD align=center>$($Entry.idleTimeoutAction)</TD>
                  <TD align=center>$($Entry.LoadUserProfile)</TD>
                  <TD align=center>$($Entry.maxProcesses)</TD>
                  <TD align=center>$($Entry.PrivateMemoryLimit)</TD>
                  <TD align=center>$($Entry.RecyclingPeriodicRestartTime)</TD>
                  <TD align=center>$($Entry.AnonymousAuthentication)</TD>
                  <TD align=center>$($Entry.AppPooluserName)</TD>
                  <TD align=center>$($Entry.ConnectAs)</TD>
                  <TD align=center>$($Entry.SiteBindingprotocol)</TD>
                  <TD align=center>$($Entry.SiteBindingInfo)</TD>
                  <TD align=center>$($Entry.XRequestID)</TD>
                  <TD align=center><p>$ASURL </br> $ASStatus</p></TD>
                  <TD align=center><p>$PASURL </br> $PASStatus</p></TD>
                  <TD align=center><p>$LAURL $LAStatus</p></TD>
                  <TD align=center><p>$IsOnlineURL </br> $IsOnlineContent </br> $ISOnlineStatus </br> $IsOnlineWorking</p></TD></TR>"
Clear-Variable ASstring_err
Clear-Variable ASURL
Clear-Variable ASSTATUS
Clear-Variable IPAddress

Clear-Variable PASstring_err
Clear-Variable PASURL
Clear-Variable PASSTATUS

Clear-Variable LAstring_err
Clear-Variable LAURL
Clear-Variable LASTATUS

Clear-Variable IsOnlineURL
Clear-Variable IsOnlineStatus
Clear-Variable IsOnlineWorking

Clear-Variable ASRequest
Clear-Variable PASRequest
Clear-Variable LARequest
Clear-Variable IsOnlineRequest

 }
 $Outputreport += "</Table></BODY></HTML>" 

 
$ReportFile = "C:\Temp\Services_WebSite_Validation_$(Get-Date -Format yyyy-MM-dd-hhmm).html"
$Outputreport | out-file "$ReportFile"
Clear-Variable result
Clear-Variable Outputreport

Clear-Variable MasterHost
Clear-Variable ExpectedWEBServerCount
Clear-Variable MasterSVCHandlerVersion
Clear-Variable MasterScaleServiceVersion
Clear-Variable Expectedenable32BitAppOnWin64
Clear-Variable ExpectedidleTimeoutAction
Clear-Variable ExpectedLoadUserProfile
Clear-Variable ExpectedmaxProcesses
Clear-Variable ExpectedPrivateMemoryLimit
Clear-Variable ExpectedAnonymousAuthentication
Clear-Variable ExpectedAppPooluserName
Clear-Variable ExpectedConnectAs
Clear-Variable ExpectedSiteBindingprotocol
Clear-Variable ExpectedXRequestID
Clear-Variable ExpectedASStatus
Clear-Variable ExpectedPASRequest
Clear-Variable ExpectedLAStatus
Clear-Variable ExpectedIsOnlineWorking
Clear-Variable MasterSVCWebsiteHash
Clear-Variable ExpectedRecyclingPeriodicRestartTime

Invoke-Item $ReportFile
