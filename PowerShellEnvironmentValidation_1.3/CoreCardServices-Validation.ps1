﻿$ServerType = 'wcf'
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
#$MasterHost.ToUPPER()
If (Test-Connection $MasterHost -Quiet){
Write-Host "Master Host - " $MasterHost
}
else{
$MasterHost = $ServerList | Select-Object -Last 1
Write-Host "Master Host - " $MasterHost
}


$ExpectedWCFServerCount = 2
if (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "perf") -and ($Environmentattributon -eq "cookie")){$ExpectedWCFServerCount = "45"}
elseif (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "uat2" -or $EnvironmentName -eq "mock") -and ($Environmentattributon -eq "jazz")){$ExpectedWCFServerCount = "45"}
$Expectedenable32BitAppOnWin64 = "False"
$ExpectedidleTimeoutAction = "Terminate"
$ExpectedLoadUserProfile = "True"
$ExpectedmaxProcesses = "4"
$ExpectedPrivateMemoryLimit = "0"
$ExpectedRecyclingPeriodicRestartTime = "1740"
$ExpectedAnonymousAuthentication = "Application Pool Identity"
$ExpectedAppPooluserName = ((whoami).TOLOWER()).Split('\')[0] + '\gmsa-app-svc$'
$ExpectedConnectAs = "Pass-through Authentication"
$ExpectedSiteBindingprotocol = "http https"
$ExpectedCCSURLSTATUS = "Method not allowed"



$Outputreport = "<HTML><TITLE>CCS Validation Report</TITLE>
                 <BODY background-color:peachpuff>
                 <font color =""#4682B4"" face=""Microsoft Tai le"">
                 <H2>$($EnvironmentName.ToUpper()) - PLEASE VERIFY BELOW TABLE VALUES AND COMPARE WITH EXPECTED VALUES</H2></font>
                 <Table border=1 cellpadding=0 cellspacing=0>
                 <TR bgcolor=gray align=center>
                   <TD><B>Master Host</B></TD>
                   <TD><B>CCS Version</B></TD>
                   <TD><B>CCS Hash</B></TD>
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
                   <TD><B>CCS URL Status</B></TD>
                   </TR>"
$option = New-PSSessionOption -ProxyAccessType NoProxyServer 
$MasterCCSVersionValue =  Invoke-Command -ComputerName $MasterHost -SessionOption $option -ErrorAction inquire -ScriptBlock {
$MasterCCSVersionValueInternal =  (Get-Command D:\WebServer\CoreCardServices\bin\CC.HP.Api.dll).FileVersionInfo.FileVersion
$MasterCCSVersionValueInternal
}

$MasterCCSHash = Invoke-Command -ComputerName $MasterHost -SessionOption $option -ErrorAction inquire -ScriptBlock {
(Get-ChildItem -Path D:\WebServer\CoreCardServices\ -Recurse -Filter *.* | Get-FileHash).Hash | %{ $MasterCCSHash += "$_"}
$MasterCCS_stream = [IO.MemoryStream]::new([byte[]][char[]]$MasterCCSHash)
$MasterCCSHash = (Get-FileHash -InputStream $MasterCCS_stream).Hash
$MasterCCSHash}

$Outputreport += "<TR align=center>"
$Outputreport += "<TD>$("$MasterHost".TOUPPER())</TD>
                   <TD>$("$MasterCCSVersionValue")</TD>
                   <TD>$("$MasterCCSHash")</TD>
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
                   <TD>$("$ExpectedCCSURLSTATUS")</TD>
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
$CCSVersion = (Get-Command D:\WebServer\CoreCardServices\bin\CC.HP.Api.dll).FileVersionInfo.FileVersion
$ServerCCSHash = $NULL
(Get-ChildItem -Path D:\WebServer\CoreCardServices\ -Recurse -Filter *.* | Get-FileHash).Hash | %{ $ServerCCSHash += "$_"}
$ServerCCS_stream = [IO.MemoryStream]::new([byte[]][char[]]$ServerCCSHash)
$ServerCCSHash = (Get-FileHash -InputStream $ServerCCS_stream).Hash

#$KMSDefaultMachinesTag = (Select-String -Path D:\WebServer\WCF\configuration\appSettings.config -Pattern "KMSDefaultMachines").ToString().Split('=')[2] -replace '["/>]',''
#$dbbHandlerRoot = ((Select-String -Path D:\WebServer\WCF\configuration\appSettings.config -Pattern "dbbHandlerRoot").ToString().Split('=')[2] -replace '[ "/>]','').split(':')
#$CoreIssueTestConnection = (Test-NetConnection -computername $dbbHandlerRoot[1] -port 443).TcpTestSucceeded
#$dbbHandlerRoot = $dbbHandlerRoot[0] + "://" + $dbbHandlerRoot[1]
$enable32BitAppOnWin64 = (Get-ItemProperty IIS:\AppPools\CoreCardServices).enable32BitAppOnWin64
$managedPipelineMode = (Get-ItemProperty IIS:\AppPools\CoreCardServices).managedPipelineMode
$state = (Get-ItemProperty IIS:\AppPools\CoreCardServices).state
$idleTimeoutAction = Get-ItemProperty "IIS:\AppPools\CoreCardServices" -Name processModel.idleTimeoutAction
$loadUserProfile = Get-ItemProperty "IIS:\AppPools\CoreCardServices" -Name processModel.LoadUserProfile.Value
$maxProcesses = Get-ItemProperty "IIS:\AppPools\CoreCardServices" -Name processModel.maxProcesses.Value
$privateMemoryLimit = (Get-ItemProperty "IIS:\apppools\CoreCardServices" -Name recycling.periodicrestart.privateMemory).value
$RecyclingPeriodicRestartTime = ((Get-ItemProperty -Path "IIS:\AppPools\CoreCardServices" -Name Recycling.PeriodicRestart.Time).value.TotalMinutes)
$anonymousAuthentication = (Get-WebConfigurationProperty -Filter '/system.webServer/security/authentication/anonymousAuthentication'  -PSPath 'IIS:\' -Location "Webserver/CoreCardServices" -Name userName).Value
if($anonymousAuthentication -eq ""){$anonymousAuthentication = "Application Pool Identity"}
$AppPooluserName = Get-ItemProperty "IIS:\AppPools\CoreCardServices" -Name processModel.userName.Value
#$ConnectAs = (Get-WebConfiguration "/system.applicationHost/sites/site[@name='Webserver']/application[@path='/CoreCardServices']/VirtualDirectory[@path='/']").UserName
$ConnectAs = (Get-WebConfiguration "/system.applicationHost/sites/site[@name='WebServer']/application[@path='/CoreCardServices']/VirtualDirectory[@path='/']").UserName
if($ConnectAs -match ""){$ConnectAs = "Pass-through Authentication"}
$SiteBindingprotocol = (Get-IISSite "WebServer").bindings.protocol #| select-object protocol, bindingInformation
$SiteBindingInfo = (Get-IISSite "WebServer").bindings.bindingInformation
$resultvalue = @() 
$resultvalue = [PSCustomObject] @{ 
    ServerName = "$($computername)"
    CCSVersion = "$($CCSVersion)"
    ServerCCSHash = "$($ServerCCSHash)"
    enable32BitAppOnWin64 = "$($enable32BitAppOnWin64)"
    managedPipelineMode = "$($managedPipelineMode)"
    state = "$($state)"
    idleTimeoutAction = "$($idleTimeoutAction)"
    loadUserProfile = "$($loadUserProfile)"
    maxProcesses = "$($maxProcesses)"
    privateMemoryLimit = "$($privateMemoryLimit)"
    RecyclingPeriodicRestartTime = "$($RecyclingPeriodicRestartTime)"
    anonymousAuthentication = "$($anonymousAuthentication)"
    AppPooluserName = "$($AppPooluserName)"
    ConnectAs = "$($ConnectAs)"
    SiteBindingprotocol = "$($SiteBindingprotocol)"
    SiteBindingInfo = "$($SiteBindingInfo)"
	}
$resultvalue
}
}else{

Write-Host "$computername Server is NOT Accessible"
$ServerNotAccesible = "Unreachable"
$resultvalue = @() 
$resultvalue = [PSCustomObject] @{ 
    ServerName = "$(($computername).ToUpper())"
    CCSVersion = "$($ServerNotAccesible)"
    ServerCCSHash = "$($ServerNotAccesible)"
    enable32BitAppOnWin64 = "$($ServerNotAccesible)"
    managedPipelineMode = "$($ServerNotAccesible)"
    state = "$($ServerNotAccesible)"
    idleTimeoutAction = "$($ServerNotAccesible)"
    loadUserProfile = "$($ServerNotAccesible)"
    maxProcesses = "$($ServerNotAccesible)"
    privateMemoryLimit = "$($ServerNotAccesible)"
    anonymousAuthentication = "$($ServerNotAccesible)"
    AppPooluserName = "$($ServerNotAccesible)"
    ConnectAs = "$($ServerNotAccesible)"
    SiteBindingprotocol = "$($ServerNotAccesible)"
    SiteBindingInfo = "$($ServerNotAccesible)"
	}
$result += $resultvalue
}
}






if($Serverlist.Count -eq $ExpectedWCFServerCount)
{
$Outputreport += "</Table>
                 <font color =""#4682B4"" face=""Microsoft Tai le"">
                   <H2>  CCS Validation Report - Server Count $($result.count) </H2></font>"


}else{
$Outputreport += "</Table>
                 <font color =""#CD5C5C"" face=""Microsoft Tai le"">
                   <H2>  WCF Validation Report - Server Count $($result.count) is not matching with expected count $ExpectedWCFServerCount </H2></font>"


}


$Outputreport += "<Table border=1 cellpadding=0 cellspacing=0>
                 <TR bgcolor=gray align=center>
                   <TD><B>WCF Server</B></TD>
                   <TD><B>CCS Version</B></TD>
                   <TD><B>CCS Hash</B></TD>
                   <TD><B>32Bit Enable</B></TD>
                   <TD><B>Idle Timeout Action</B></TD>
                   <TD><B>Load User Profile</B></TD>
                   <TD><B>Max Worker Processes</B></TD>
                   <TD><B>Private Memory Limit</B></TD>
                   <TD><B>Recycling Periodic Restart Time(in min)</B></TD>
                   <TD><B>Anonymous Authentication</B></TD>
                   <TD><B>AppPool userName</B></TD>
                   <TD><B>ConnectAs</B></TD>
                   <TD><B>Site Protocols</B></TD>
                   <TD><B>Site Bindings</B></TD>
                   <TD><B>CoreCardServices URL & STATUS</B></TD>
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
 
$IPAddress = (Resolve-DnsName $Entry.ServerName | Where-Object Type -eq "A").IpAddress
try {
$CCSURL = "https://$IPAddress/CoreCardServices/CoreCardServices.svc/AccountSummary"
$CCSRequest = Invoke-WebRequest $CCSURL
} catch {

    $string_err = $_ | Out-String

}

$CCSStatus = $string_err | Select-String "Method not allowed" |ForEach-Object { $_.Matches.Value }
if ($CCSStatus -eq $NULL) {$CCSStatus = "Not Working"}
$CCSURL
$CCSStatus

            if(($MasterCCSVersionValue -eq $Entry.CCSVersion) -and ($Entry.ServerCCSHash -eq $MasterCCSHash) -and ($Entry.enable32BitAppOnWin64 -eq $Expectedenable32BitAppOnWin64) -and ($Entry.idleTimeoutAction -eq $ExpectedidleTimeoutAction) -and ($Entry.loadUserProfile -eq $ExpectedLoadUserProfile) -and ($Entry.maxProcesses -eq $ExpectedmaxProcesses) -and ($Entry.privateMemoryLimit -eq $ExpectedPrivateMemoryLimit) -and ($Entry.RecyclingPeriodicRestartTime -eq $ExpectedRecyclingPeriodicRestartTime) -and ($Entry.anonymousAuthentication -eq $ExpectedAnonymousAuthentication) -and ($Entry.AppPooluserName -eq $ExpectedAppPooluserName) -and ($Entry.ConnectAs -eq  $ExpectedConnectAs ) -and ($Entry.SiteBindingprotocol -eq $ExpectedSiteBindingprotocol) -and ($CCSStatus -eq $ExpectedCCSURLSTATUS))
           {
           $Outputreport += "<TR align=center>" 
           }else{
           $Outputreport += "<TR bgcolor=LightSalmon align=center>"
           }

      

      $Outputreport += "<TD>$($Entry.ServerName)</TD>
                        <TD>$($Entry.CCSVersion)</TD>
                        <TD>$($Entry.ServerCCSHash -eq $MasterCCSHash)</TD>
                        <TD>$($Entry.enable32BitAppOnWin64)</TD>
                        <TD>$($Entry.idleTimeoutAction)</TD>
                        <TD>$($Entry.loadUserProfile)</TD>
                        <TD>$($Entry.maxProcesses)</TD>
                        <TD>$($Entry.privateMemoryLimit)</TD>
                        <TD>$($Entry.RecyclingPeriodicRestartTime)</TD>
                        <TD>$($Entry.anonymousAuthentication)</TD>
                        <TD>$($Entry.AppPooluserName)</TD>
                        <TD>$($Entry.ConnectAs)</TD>
                        <TD>$($Entry.SiteBindingprotocol)</TD>
                        <TD>$($Entry.SiteBindingInfo)</TD>
                        <TD><p>$CCSURL <br> $CCSSTATUS</p></TD></TR>"
Clear-Variable string_err
Clear-Variable CCSURL
Clear-Variable CCSSTATUS
Clear-Variable IPAddress

 }
 $Outputreport += "</Table></BODY></HTML>" 

 
$ReportFile = "C:\Temp\CCS_Validation_$(Get-Date -Format yyyy-MM-dd-hhmm).html"
$Outputreport | out-file "$ReportFile"
Clear-Variable result
Clear-Variable Outputreport

Clear-Variable Environmentattributon
Clear-Variable MasterHost
Clear-Variable ExpectedWCFServerCount
Clear-Variable Expectedenable32BitAppOnWin64
Clear-Variable ExpectedidleTimeoutAction
Clear-Variable ExpectedmaxProcesses
Clear-Variable ExpectedAppPooluserName
Clear-Variable ExpectedConnectAs
Clear-Variable ExpectedSiteBindingprotocol
Clear-Variable ExpectedCCSURLSTATUS
Clear-Variable MasterCCSVersionValue
Clear-Variable MasterCCSHash
Clear-Variable ExpectedRecyclingPeriodicRestartTime

Invoke-Item $ReportFile
