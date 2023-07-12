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
$MasterISSHandlerVersion =  Invoke-Command -ComputerName $MasterHost -SessionOption $option -ErrorAction inquire -ScriptBlock {
$MasterISSHandlerVersion = (Get-Command D:\WebServer\DBBWEB\bin\dbbHandler2005.dll).FileVersionInfo.FileVersion
$MasterISSHandlerVersion}

$MasterScaleServiceVersion = Invoke-Command -ComputerName $MasterHost -SessionOption $option -ErrorAction inquire -ScriptBlock {
$MasterScaleServiceVersion = (Get-Command D:\WebServer\ScaleService\dbbScaleService.exe).FileVersionInfo.FileVersion
$MasterScaleServiceVersion}

$ExpectedWEBServerCount = 2
$Expectedenable32BitAppOnWin64 = "False"
$ExpectedidleTimeoutAction = "Suspend"
$ExpectedmaxProcesses = "1"
$ExpectedAppPooluserName = (whoami).TOLOWER()
$ExpectedConnectAs = (whoami).TOLOWER()
$ExpectedSiteBindingprotocol = "https"
$ExpectedIISLogging = "False"
$ExpectedCoreIssueWorking = "Working"

if (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "perf") -and ($Environmentattributon -eq "cookie")){
$ExpectedWCFServerCount = "30" 
$ExpectedmaxProcesses = "1"}
elseif (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "uat2" -or $EnvironmentName -eq "mock") -and ($Environmentattributon -eq "jazz")){
$ExpectedWCFServerCount = "30"
$ExpectedmaxProcesses = "1"}

$Outputreport = "<HTML><TITLE>CoreIssue Validation Report</TITLE>
                 <BODY background-color:peachpuff>
                 <font color =""#4682B4"" face=""Microsoft Tai le"">
                 <H2>$($EnvironmentName.ToUpper()) - PLEASE VERIFY BELOW TABLE VALUES AND COMPARE WITH EXPECTED VALUES</H2></font>
                 <Table border=1 cellpadding=0 cellspacing=0>
                 <TR bgcolor=gray align=center>
                   <TD><B>ISS Handler Version</B></TD>
                   <TD><B>Scale Service Version</B></TD>
                   <TD><B>32Bit Enable</B></TD>
                   <TD><B>Idle Timeout Action</B></TD>
                   <TD><B>Max Worker Processes</B></TD>
                   <TD><B>AppPool userName</B></TD>
                   <TD><B>ConnectAs</B></TD>
                   <TD><B>Site Protocols</B></TD>
                   <TD><B>IIS Logging</B></TD>
                   <TD><B>CoreIssue URL Status</B></TD>
                   </TR>"
                   

$Outputreport += "<TR align=center>"
$Outputreport += "<TD>$("$MasterISSHandlerVersion")</TD>
                   <TD>$("$MasterScaleServiceVersion")</TD>
                   <TD>$("$Expectedenable32BitAppOnWin64")</TD>
                   <TD>$("$ExpectedidleTimeoutAction")</TD>
                   <TD>$("$ExpectedmaxProcesses")</TD>
                   <TD>$("$ExpectedAppPooluserName")</TD>
                   <TD>$("$ExpectedConnectAs")</TD>
                   <TD>$("$ExpectedSiteBindingprotocol")</TD>
                   <TD>$("$ExpectedIISLogging")</TD>
                   <TD>$("$ExpectedCoreIssueWorking")</TD>
                  </TR>"



$Result = @() 
ForEach($computername in $ServerList) 
{
$computername
If ((Test-Connection $computername -Quiet)){
Write-Host "$computername Server is  Accessible"
$option = New-PSSessionOption -ProxyAccessType NoProxyServer 
$result += Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock {
$computername = hostname
Import-Module WebAdministration
$ISSHandlerVersion = (Get-Command D:\WebServer\DBBWEB\bin\dbbHandler2005.dll).FileVersionInfo.FileVersion
$ScaleServiceVersion = (Get-Command D:\WebServer\ScaleService\dbbScaleService.exe).FileVersionInfo.FileVersion
$enable32BitAppOnWin64 = (Get-ItemProperty IIS:\AppPools\DBBWEB).enable32BitAppOnWin64
$managedPipelineMode = (Get-ItemProperty IIS:\AppPools\DBBWEB).managedPipelineMode
$state = (Get-ItemProperty IIS:\AppPools\DBBWEB).state
$idleTimeoutAction = Get-ItemProperty "IIS:\AppPools\DBBWEB" -Name processModel.idleTimeoutAction
$maxProcesses = Get-ItemProperty "IIS:\AppPools\DBBWEB" -Name processModel.maxProcesses.Value
$AppPooluserName = Get-ItemProperty "IIS:\AppPools\DBBWEB" -Name processModel.userName.Value
$ConnectAs = (Get-WebConfiguration "/system.applicationHost/sites/site[@name='CoreIssue']/application[@path='/']/VirtualDirectory[@path='/']").UserName
$SiteBindingprotocol = (Get-IISSite "CoreIssue").bindings.protocol #| select-object protocol, bindingInformation
$SiteBindingInfo = (Get-IISSite "CoreIssue").bindings.bindingInformation
#$XRequestID = (Get-ItemProperty 'IIS:\Sites\Services' -Name logfile.customFields.collection).logFieldName
$IISLogging = Get-ItemProperty 'IIS:\Sites\CoreIssue' -Name Logfile.enabled.value
$CoreIssueSiteBindingIP = ((Get-IISSite "CoreIssue").bindings | where-Object protocol -eq "https").bindingInformation.split(':')[0]
$resultvalue = @() 
$resultvalue = [PSCustomObject] @{ 
    ServerName = "$($computername)"
    ISSHandlerVersion = "$($ISSHandlerVersion)"
    ScaleServiceVersion = "$($ScaleServiceVersion)"
    enable32BitAppOnWin64 = "$($enable32BitAppOnWin64)"
    managedPipelineMode = "$($managedPipelineMode)"
    state = "$($state)"
    idleTimeoutAction = "$($idleTimeoutAction)"
    maxProcesses = "$($maxProcesses)"
    AppPooluserName = "$($AppPooluserName)"
    ConnectAs = "$($ConnectAs)"
    SiteBindingprotocol = "$($SiteBindingprotocol)"
    SiteBindingInfo = "$($SiteBindingInfo)"
    IISLogging = "$($IISLogging)"
    CoreIssueSiteBindingIP = "$($CoreIssueSiteBindingIP)"
	}
$resultvalue
}
} else{

Write-Host "$computername Server is NOT Accessible"
$ServerNotAccesible = "Unreachable"
$resultvalue = @() 
$resultvalue = [PSCustomObject] @{ 
    ServerName = "$(($computername).ToUpper())"
    ISSHandlerVersion = "$($ServerNotAccesible)"
    ScaleServiceVersion = "$($ServerNotAccesible)"
    enable32BitAppOnWin64 = "$($ServerNotAccesible)"
    managedPipelineMode = "$($ServerNotAccesible)"
    state = "$($ServerNotAccesible)"
    idleTimeoutAction = "$($ServerNotAccesible)"
    maxProcesses = "$($ServerNotAccesible)"
    AppPooluserName = "$($ServerNotAccesible)"
    ConnectAs = "$($ServerNotAccesible)"
    SiteBindingprotocol = "$($ServerNotAccesible)"
    SiteBindingInfo = "$($ServerNotAccesible)"
    IISLogging = "$($ServerNotAccesible)"
    CoreIssueSiteBindingIP = "$($ServerNotAccesible)"
	}
$result += $resultvalue
}
}


if($Serverlist.Count -eq $ExpectedWEBServerCount)
{
$Outputreport += "</Table>
                 <font color =""#4682B4"" face=""Microsoft Tai le"">
                   <H2>  CoreIssue Website Validation Report - Server Count $($result.count) </H2></font>"


}else{
$Outputreport += "</Table>
                 <font color =""#CD5C5C"" face=""Microsoft Tai le"">
                   <H2>CoreIssue Website Validation Report - Server Count $($result.count) is not matching with expected count $ExpectedWEBServerCount </H2></font>"
}

$Outputreport += "<Table border=1 cellpadding=0 cellspacing=0>
                 <TR bgcolor=gray align=center>
                   <TD><B>WEB Server</B></TD>
                   <TD><B>CoreIssue Handler Version</B></TD>
                   <TD><B>Scale Service Version</B></TD>
                   <TD><B>32Bit Enable</B></TD>
                   <TD><B>Idle Timeout Action</B></TD>
                   <TD><B>Max Worker Processes</B></TD>
                   <TD><B>AppPool userName</B></TD>
                   <TD><B>ConnectAs</B></TD>
                   <TD><B>Site Protocols</B></TD>
                   <TD><B>Site Bindings</B></TD>
                   <TD><B>IIS Logging</B></TD>
                   <TD><B>CoreIssue URL</B></TD>
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
 
$IPAddress = $Entry.CoreIssueSiteBindingIP




try {
$CoreIssueRequest = $NULL
$CoreIssueURL = "https://$IPAddress"
$CoreIssueRequest = Invoke-WebRequest $CoreIssueURL
} catch {

    $CoreIssuestring_err = $_ | Out-String

}

$CoreIssueStatus = $CoreIssueRequest.StatusCode
$CoreIssueContent = $CoreIssueRequest.Content | Select-String "Please Log In" |ForEach-Object { $_.Matches.Value }
$CoreIssueContent
if (($CoreIssueContent -eq "Please Log In") -and ($CoreIssueStatus	-eq 200))
{
$CoreIssueWorking="Working"
}
else
{
$CoreIssueWorking="Not Working"
$CoreIssueContent = $NULL
}
$CoreIssueURL
$CoreIssueStatus
$CoreIssueContent


        
if(($Entry.ISSHandlerVersion -eq $MasterISSHandlerVersion) `
-and ($Entry.ScaleServiceVersion -eq $MasterScaleServiceVersion) `
-and ($Entry.enable32BitAppOnWin64 -eq $Expectedenable32BitAppOnWin64) `
-and ($Entry.idleTimeoutAction -eq $ExpectedidleTimeoutAction) `
-and ($Entry.maxProcesses -eq $ExpectedmaxProcesses) `
-and ($Entry.AppPooluserName -eq $ExpectedAppPooluserName) `
-and ($Entry.ConnectAs -eq  $ExpectedConnectAs ) `
-and ($Entry.SiteBindingprotocol -eq $ExpectedSiteBindingprotocol) `
-and ($Entry.IISLogging -eq $ExpectedIISLogging) `
-and ($CoreIssueWorking -eq $ExpectedCoreIssueWorking))
{
$Outputreport += "<TR align=center>" 
}else{
$Outputreport += "<TR bgcolor=LightSalmon align=center>"
}


$Outputreport += "<TD>$($Entry.ServerName)</TD>
                  <TD align=center>$($Entry.ISSHandlerVersion)</TD>
                  <TD align=center>$($Entry.ScaleServiceVersion)</TD>
                  <TD align=center>$($Entry.enable32BitAppOnWin64)</TD>
                  <TD align=center>$($Entry.idleTimeoutAction)</TD>
                  <TD align=center>$($Entry.maxProcesses)</TD>
                  <TD align=center>$($Entry.AppPooluserName)</TD>
                  <TD align=center>$($Entry.ConnectAs)</TD>
                  <TD align=center>$($Entry.SiteBindingprotocol)</TD>
                  <TD align=center>$($Entry.SiteBindingInfo)</TD>
                  <TD align=center>$($Entry.IISLogging)</TD>
                  <TD align=center><p>$CoreIssueURL </br> $CoreIssueContent </br> $CoreIssueStatus </br> $CoreIssueWorking</p></TD></TR>"


Clear-Variable CoreIssueURL
Clear-Variable CoreIssueStatus
Clear-Variable CoreIssueWorking



 }
 $Outputreport += "</Table></BODY></HTML>" 

 
$ReportFile = "C:\Temp\CoreIssue_WebSite_Validation_$(Get-Date -Format yyyy-MM-dd-hhmm).html"
$Outputreport | out-file "$ReportFile"
Clear-Variable result
Clear-Variable Outputreport

Clear-Variable MasterHost
Clear-Variable ExpectedWEBServerCount
Clear-Variable MasterISSHandlerVersion
Clear-Variable MasterScaleServiceVersion
Clear-Variable Expectedenable32BitAppOnWin64
Clear-Variable ExpectedidleTimeoutAction
Clear-Variable ExpectedmaxProcesses
Clear-Variable ExpectedAppPooluserName
Clear-Variable ExpectedConnectAs
Clear-Variable ExpectedSiteBindingprotocol
Clear-Variable ExpectedIISLogging
Clear-Variable ExpectedCoreIssueWorking

Invoke-Item $ReportFile
