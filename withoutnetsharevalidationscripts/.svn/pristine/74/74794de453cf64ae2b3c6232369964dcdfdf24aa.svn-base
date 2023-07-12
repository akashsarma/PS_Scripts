$ServerType = 'wcf'
$ThisServer = (Hostname).ToLower()
if($ThisServer -match 'e1')
{$Region = "us-east-1"
$ShortRegion = 'e1'
} elseif($ThisServer -match 'w2')
{$Region = "us-west-2"
$ShortRegion = 'w2'
}
$Result = $NULL
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

$ExpectedWCFServerCount = 2
if (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "perf") -and ($Environmentattributon -eq "cookie")){$ExpectedWCFServerCount = "45"}
elseif (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "uat2" -or $EnvironmentName -eq "mock") -and ($Environmentattributon -eq "jazz")){$ExpectedWCFServerCount = "45"}
$ExpectedCoreIssueTestConnection = "True"
$Expectedenable32BitAppOnWin64 = "True"
$ExpectedidleTimeoutAction = "Suspend"
$ExpectedmaxProcesses = "4"
$ExpectedAppPooluserName = (whoami).TOLOWER()
$ExpectedConnectAs = (whoami).TOLOWER()
$ExpectedSiteBindingprotocol = "http https"
$ExpectedWCFURLSTATUS = "WORKING"

#$ServerList = (aws ec2 describe-instances --query "Reservations[*].Instances[*].{AvailabilityZone:Placement.AvailabilityZone,IpAddress:PrivateIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}" --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values='*$ServerType*'" "Name=availability-zone,Values='*'" --region (Get-EC2InstanceMetadata -Category Region).SystemName | ConvertFrom-Json).Name

$Outputreport = "<HTML><TITLE> WCF Validation Report </TITLE>
                 <BODY background-color:peachpuff>
                 <font color =""#4682B4"" face=""Microsoft Tai le"">
                 <H2>$($EnvironmentName.ToUpper()) - PLEASE VERIFY BELOW TABLE VALUES AND COMPARE WITH EXPECTED VALUES</H2></font>
                 <Table border=1 cellpadding=0 cellspacing=0>
                 <TR bgcolor=gray align=center>
                   <TD><B>WCF Version</B></TD>
                   <TD><B>KMS Value</B></TD>
                   <TD><B>Handler Value</B></TD>
                   <TD><B>Handler Test Connection</B></TD>
                   <TD><B>32Bit Enable</B></TD>
                   <TD><B>Idle Timeout Action</B></TD>
                   <TD><B>Max Worker Processes</B></TD>
                   <TD><B>AppPool userName</B></TD>
                   <TD><B>ConnectAs</B></TD>
                   <TD><B>Site Protocols</B></TD>
                   <TD><B>WCF URL STATUS</B></TD>
                   </TR>"


$option = New-PSSessionOption -ProxyAccessType NoProxyServer -OpenTimeout 20000
$Outputreport += Invoke-Command -ComputerName $MasterHost -SessionOption $option -ErrorAction Continue -HideComputerName -ScriptBlock {
param ($ExpectedCoreIssueTestConnection, $Expectedenable32BitAppOnWin64, $ExpectedidleTimeoutAction, $ExpectedmaxProcesses, $ExpectedAppPooluserName, $ExpectedConnectAs, $ExpectedSiteBindingprotocol, $ExpectedWCFURLSTATUS)
$MasterHostName = hostname
$OutputreportVarVal = $NULL

$MasterWCFVersionValue = (Get-Command D:\WebServer\WCF\bin\CC.CoreServices.common.dll).FileVersionInfo.FileVersion
$MasterKMSValue = (Select-String -Path D:\WebServer\WCF\configuration\appSettings.config -Pattern "KMSDefaultMachines").ToString().Split('=')[2] -replace '["/>]',''
$MasterHandlerTagValue = ((Select-String -Path D:\WebServer\WCF\configuration\appSettings.config -Pattern "dbbHandlerRoot").ToString().Split('=')[2] -replace '[ "/>]','').split(':')
$MasterHandlerTagValue = $MasterHandlerTagValue[0] + "://" + $MasterHandlerTagValue[1]
$OutputreportVarVal += "<TR align=center>"
$OutputreportVarVal += "<TD>$("$MasterWCFVersionValue")</TD>
                   <TD>$("$MasterKMSValue")</TD>
                   <TD align=center>$($MasterHandlerTagValue)</TD>
                   <TD>$("$ExpectedCoreIssueTestConnection")</TD>
                   <TD>$("$Expectedenable32BitAppOnWin64")</TD>
                   <TD>$("$ExpectedidleTimeoutAction")</TD>
                   <TD>$("$ExpectedmaxProcesses")</TD>
                   <TD>$("$ExpectedAppPooluserName")</TD>
                   <TD>$("$ExpectedConnectAs")</TD>
                   <TD>$("$ExpectedSiteBindingprotocol")</TD>
                   <TD>$("$ExpectedWCFURLSTATUS")</TD>
                   </TR>"


Clear-Variable MasterWCFVersionValue
Clear-Variable MasterKMSValue
Clear-Variable MasterHandlerTagValue
$OutputreportVarVal


} -ArgumentList $ExpectedCoreIssueTestConnection, $Expectedenable32BitAppOnWin64, $ExpectedidleTimeoutAction, $ExpectedmaxProcesses, $ExpectedAppPooluserName, $ExpectedConnectAs, $ExpectedSiteBindingprotocol, $ExpectedWCFURLSTATUS






Clear-Variable Result
$Result = @() 
#ForEach($computername in $ServerList) 
#{
# $computername
#If ((Test-Path -path \\$computername\d$\)){
#Write-Host "$computername Server is  Accessible"

$option = New-PSSessionOption -ProxyAccessType NoProxyServer  -OpenTimeout 20000
$result += Invoke-Command -ComputerName $ServerList -SessionOption $option -ErrorAction continue -HideComputerName -ScriptBlock {
$computername = hostname
#$computername
Import-Module WebAdministration
$WCFVersion = (Get-Command D:\WebServer\WCF\bin\CC.CoreServices.common.dll).FileVersionInfo.FileVersion
$KMSDefaultMachinesTag = (Select-String -Path D:\WebServer\WCF\configuration\appSettings.config -Pattern "KMSDefaultMachines").ToString().Split('=')[2] -replace '["/>]',''
$dbbHandlerRoot = ((Select-String -Path D:\WebServer\WCF\configuration\appSettings.config -Pattern "dbbHandlerRoot").ToString().Split('=')[2] -replace '[ "/>]','').split(':')
$CoreIssueTestConnection = (Test-NetConnection -computername $dbbHandlerRoot[1] -port 443).TcpTestSucceeded
$dbbHandlerRoot = $dbbHandlerRoot[0] + "://" + $dbbHandlerRoot[1]
$enable32BitAppOnWin64 = (Get-ItemProperty IIS:\AppPools\WCF).enable32BitAppOnWin64
$managedPipelineMode = (Get-ItemProperty IIS:\AppPools\WCF).managedPipelineMode
$state = (Get-ItemProperty IIS:\AppPools\WCF).state
$idleTimeoutAction = Get-ItemProperty "IIS:\AppPools\WCF" -Name processModel.idleTimeoutAction
$maxProcesses = Get-ItemProperty "IIS:\AppPools\WCF" -Name processModel.maxProcesses.Value
$AppPooluserName = (Get-ItemProperty "IIS:\AppPools\WCF" -Name processModel.userName.Value).TOLOWER()
$ConnectAs = ((Get-WebConfiguration "/system.applicationHost/sites/site[@name='Webserver']/application[@path='/WCF']/VirtualDirectory[@path='/']").UserName).TOLOWER()
$SiteBindingprotocol = (Get-IISSite "WebServer").bindings.protocol #| select-object protocol, bindingInformation
$SiteBindingInfo = (Get-IISSite "WebServer").bindings.bindingInformation

class TrustAllCertsPolicy : System.Net.ICertificatePolicy {
    [bool] CheckValidationResult([System.Net.ServicePoint] $a,
                                 [System.Security.Cryptography.X509Certificates.X509Certificate] $b,
                                 [System.Net.WebRequest] $c,
                                 [int] $d) {
        return $true
    }
}
[System.Net.ServicePointManager]::CertificatePolicy = [TrustAllCertsPolicy]::new()

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$IPAddress = (Resolve-DnsName $computername | Where-Object Type -eq "A").IpAddress
#$option = New-PSSessionOption -ProxyAccessType NoProxyServer
$WCFURL = "https://$IPAddress/WCF/dbbService.svc"
#$WCFURL
$WebCall = Invoke-WebRequest  $WCFURL
#$WebCall.Content
if (($WebCall.Content -match "You have created a service") -and ($WebCall.StatusCode	-eq 200))
{#$WebCall.StatusCode
$WCFURLSTATUS = "WORKING"
}
else
{#$WebCall.StatusCode
$WCFURLSTATUS =  "FAILURE"
}
#$WebCall.StatusCode





$resultvalue = @() 
$resultvalue = [PSCustomObject] @{ 
    ServerName = "$($computername)"
    WCFVersion = "$($WCFVersion)"
    KMSDefaultMachinesTag = "$($KMSDefaultMachinesTag)"
    dbbHandlerRoot = "$($dbbHandlerRoot)"
    CoreIssueTestConnection = "$($CoreIssueTestConnection)"
    enable32BitAppOnWin64 = "$($enable32BitAppOnWin64)"
    managedPipelineMode = "$($managedPipelineMode)"
    state = "$($state)"
    idleTimeoutAction = "$($idleTimeoutAction)"
    maxProcesses = "$($maxProcesses)"
    AppPooluserName = "$($AppPooluserName)"
    ConnectAs = "$($ConnectAs)"
    SiteBindingprotocol = "$($SiteBindingprotocol)"
    SiteBindingInfo = "$($SiteBindingInfo)"
    WCFURL = "$($WCFURL)"
    WCFURLSTATUS = "$($WCFURLSTATUS)"
	}
$resultvalue
} 

$Result


if($Serverlist.Count -eq $ExpectedWCFServerCount)
{
$Outputreport += "</Table>
                 <font color =""#4682B4"" face=""Microsoft Tai le"">
                   <H2>  WCF Validation Report - Server Count $($result.count) </H2></font>"


}else{
$Outputreport += "</Table>
                 <font color =""#CD5C5C"" face=""Microsoft Tai le"">
                   <H2>  WCF Validation Report - Server Count $($result.count) is not matching with expected count $ExpectedWCFServerCount </H2></font>"


}




$Outputreport += "<Table border=1 cellpadding=0 cellspacing=0>
                 <TR bgcolor=gray align=center>
                   <TD><B>WCF Server</B></TD>
                   <TD><B>WCF Version</B></TD>
                   <TD><B>KMS Value</B></TD>
                   <TD><B>Handler Value & Test Connectivity</B></TD>
                   <TD><B>32Bit Enable</B></TD>
                   <TD><B>Idle Timeout Action</B></TD>
                   <TD><B>Max Worker Processes</B></TD>
                   <TD><B>AppPool userName</B></TD>
                   <TD><B>ConnectAs</B></TD>
                   <TD><B>Site Protocols</B></TD>
                   <TD><B>Site Bindings</B></TD>
                   <TD><B>WCF URL & STATUS</B></TD>
                   </TR>"




Foreach($ServerEntry in $Serverlist) 

    { 
     try{
    Clear-Variable Entry

   $Entry =  $Result | Where-Object {$_.ServerName -eq $ServerEntry}


$Entry.WCFURL
$Entry.WCFURLSTATUS



if(($MasterWCFVersionValue -eq $Entry.WCFVersion) -and ($MasterKMSValue -eq $Entry.KMSDefaultMachinesTag) -and ($MasterHandlerTagValue -eq $Entry.dbbHandlerRoot) -and ($Entry.CoreIssueTestConnection -eq $ExpectedCoreIssueTestConnection) -and ($Entry.enable32BitAppOnWin64 -eq $Expectedenable32BitAppOnWin64) -and ($Entry.idleTimeoutAction -eq $ExpectedidleTimeoutAction) -and ($Entry.maxProcesses -eq $ExpectedmaxProcesses) -and ($Entry.AppPooluserName -eq $ExpectedAppPooluserName) -and ($Entry.ConnectAs -eq  $ExpectedConnectAs ) -and ($Entry.SiteBindingprotocol -eq $ExpectedSiteBindingprotocol) -and ($Entry.WCFURLSTATUS -eq $ExpectedWCFURLSTATUS))
{
$Outputreport += "<TR align=center>" 
}else{
$Outputreport += "<TR bgcolor=LightSalmon align=center>"
}
$Outputreport += "<TD>$ServerEntry</TD>
                  <TD>$($Entry.WCFVersion)</TD>
                  <TD>$($Entry.KMSDefaultMachinesTag)</TD>
                  <TD><p>$($Entry.dbbHandlerRoot)  <br>  $($Entry.CoreIssueTestConnection)</p></TD>
                  <TD>$($Entry.enable32BitAppOnWin64)</TD>
                  <TD>$($Entry.idleTimeoutAction)</TD>
                  <TD>$($Entry.maxProcesses)</TD>
                  <TD>$($Entry.AppPooluserName)</TD>
                  <TD>$($Entry.ConnectAs)</TD>
                  <TD>$($Entry.SiteBindingprotocol)</TD>
                  <TD>$($Entry.SiteBindingInfo)</TD>
                  <TD><p>$($Entry.WCFURL) <br> $($Entry.WCFURLSTATUS)</p></TD></TR>"
}Catch{
$Outputreport += "<TR bgcolor=LightSalmon align=center>"
$Outputreport += "<TD>$ServerEntry</TD>
                  <TD>Problem</TD>
                  <TD>Problem</TD>
                  <TD>Problem</TD>
                  <TD>Problem</TD>
                  <TD>Problem</TD>
                  <TD>Problem</TD>
                  <TD>Problem</TD>
                  <TD>Problem</TD>
                  <TD>Problem</TD>
                  <TD>Problem</TD></TR>"
}



 }
 $Outputreport += "</Table></BODY></HTML>" 

 
$ReportFile = "C:\Temp\WCF_Validation_$(Get-Date -Format yyyy-MM-dd-hhmm).html"
$Outputreport | out-file "$ReportFile"
Clear-Variable result
Clear-Variable Outputreport



Clear-Variable Environmentattributon
Clear-Variable MasterHost
Clear-Variable ExpectedWCFServerCount
Clear-Variable ExpectedCoreIssueTestConnection
Clear-Variable Expectedenable32BitAppOnWin64
Clear-Variable ExpectedidleTimeoutAction
Clear-Variable ExpectedmaxProcesses
Clear-Variable ExpectedAppPooluserName
Clear-Variable ExpectedConnectAs
Clear-Variable ExpectedSiteBindingprotocol
Clear-Variable ExpectedWCFURLSTATUS




Invoke-Item $ReportFile
