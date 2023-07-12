$ServerType = 'ew'
$ThisServer = (Hostname).ToLower()
if($ThisServer -match 'e1')
{$Region = "us-east-1"
$ShortRegion = 'e1'
} elseif($ThisServer -match 'w2')
{$Region = "us-west-2"
$ShortRegion = 'w2'
}

$EnvironmentName = (aws ec2 describe-instances --query "Reservations[*].Instances[*].{AvailabilityZone:Placement.AvailabilityZone,IpAddress:PrivateIpAddress,Type:InstanceType,Name:Tags[?Key=='environment']|[0].Value,Status:State.environment}" --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values='$ThisServer'" "Name=availability-zone,Values='*'" --region $Region | ConvertFrom-Json).Name.ToLower()
$ServerList = (aws ec2 describe-instances --query "Reservations[*].Instances[*].{AvailabilityZone:Placement.AvailabilityZone,IpAddress:PrivateIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}" --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values='*$ServerType$ShortRegion$EnvironmentName*'" "Name=availability-zone,Values='*'" --region $Region | ConvertFrom-Json).Name

$Result = @() 
ForEach($computername in $ServerList) 
{
$computername
    $option = New-PSSessionOption -ProxyAccessType NoProxyServer -OpenTimeout 20000
    $result += Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock {
    $computername = hostname
Import-Module WebAdministration
$CoreCreditVersion = (Get-Command D:\WebServer\CoreCredit\bin\CoreCredit.dll).FileVersionInfo.FileVersion
#$ScaleServiceVersion = (Get-Command D:\WebServer\ScaleService\dbbScaleService.exe).FileVersionInfo.FileVersion
$enable32BitAppOnWin64 = (Get-ItemProperty IIS:\AppPools\CoreCredit).enable32BitAppOnWin64
$managedPipelineMode = (Get-ItemProperty IIS:\AppPools\CoreCredit).managedPipelineMode
$state = (Get-ItemProperty IIS:\AppPools\CoreCredit).state
$idleTimeoutAction = Get-ItemProperty "IIS:\AppPools\CoreCredit" -Name processModel.idleTimeoutAction
$maxProcesses = Get-ItemProperty "IIS:\AppPools\CoreCredit" -Name processModel.maxProcesses.Value
$AppPooluserName = Get-ItemProperty "IIS:\AppPools\CoreCredit" -Name processModel.userName.Value
$ConnectAs = (Get-WebConfiguration "/system.applicationHost/sites/site[@name='CoreCredit']/application[@path='/']/VirtualDirectory[@path='/']").UserName
$SiteBindingprotocol = (Get-IISSite "CoreCredit").bindings.protocol #| select-object protocol, bindingInformation
$SiteBindingInfo = (Get-IISSite "CoreCredit").bindings.bindingInformation
$CoreCreditSiteBindingIP = ((Get-IISSite "CoreCredit").bindings | where-Object protocol -eq "https").bindingInformation.split(':')[0]
$ReportServerPath = (Select-String -Path D:\WebServer\CoreCredit\Web.config -Pattern "ReportServerPath").ToString().Split('=')[2] -replace '[" >]',''
$ReportServerPath = $ReportServerPath.Substring(0,$ReportServerPath.Length-1)
$LetterServerPath = (Select-String -Path D:\WebServer\CoreCredit\Web.config -Pattern "LetterServerPath").ToString().Split('=')[2] -replace '[" >]',''
$LetterServerPath = $LetterServerPath.Substring(0,$LetterServerPath.Length-1)
$JSFileVersion = (Select-String -Path D:\WebServer\CoreCredit\Web.config -Pattern "JSFileVersion").ToString().Split('=')[2] -replace '[" />]',''
$AccessControlAllowOrigin = ((Select-String -Path D:\WebServer\CoreCredit\Web.config -Pattern "Access-Control-Allow-Origin").ToString().Split('=')[2] -replace '[" >]','')
$AccessControlAllowOrigin = $AccessControlAllowOrigin.Substring(0,$AccessControlAllowOrigin.Length-2)
$WcfAPIEndPointDefault = ((Select-String -Path D:\WebServer\CoreCredit\Web.config -Pattern "CustomerService.ICustomerService").ToString().Split('=')[1]).Split('"')[1]
$DbbAPIEndPointDefault = ((Select-String -Path D:\WebServer\CoreCredit\Web.config -Pattern "dbbService.IdbbService").ToString().Split('=')[1]).Split('"')[1]
$resultvalue = @() 
$resultvalue = [PSCustomObject] @{ 
    ServerName = "$($computername)"
    CoreCreditVersion = "$($CoreCreditVersion)"
    enable32BitAppOnWin64 = "$($enable32BitAppOnWin64)"
    managedPipelineMode = "$($managedPipelineMode)"
    state = "$($state)"
    idleTimeoutAction = "$($idleTimeoutAction)"
    maxProcesses = "$($maxProcesses)"
    AppPooluserName = "$($AppPooluserName)"
    ConnectAs = "$($ConnectAs)"
    SiteBindingprotocol = "$($SiteBindingprotocol)"
    SiteBindingInfo = "$($SiteBindingInfo)"
    CoreCreditSiteBindingIP = "$($CoreCreditSiteBindingIP)"
    ReportServerPath = "$($ReportServerPath)"
    LetterServerPath = "$($LetterServerPath)"
    JSFileVersion = "$($JSFileVersion)"
    AccessControlAllowOrigin = "$($AccessControlAllowOrigin)"
    WcfAPIEndPointDefault = "$($WcfAPIEndPointDefault)"
    DbbAPIEndPointDefault = "$($DbbAPIEndPointDefault)"
    
	}
$resultvalue
}
}
$Outputreport = "<HTML><TITLE> CoreCredit WebSite Validation Report </TITLE>
                 <BODY background-color:peachpuff>
                 <font color =""#4682B4"" face=""Microsoft Tai le"">
                 <H2>  CoreCredit WebSite Validation Report - Server Count $($result.count) </H2></font>
                 <Table border=1 cellpadding=0 cellspacing=0>
                 <TR bgcolor=gray align=center>
                   <TD><B>WEB Server</B></TD>
                   <TD><B>CoreCredit Version</B></TD>
                   <TD><B>32Bit Enable</B></TD>
                   <TD><B>Pipeline Mode</B></TD>
                   <TD><B>AppPool State</B></TD>
                   <TD><B>Idle Timeout Action</B></TD>
                   <TD><B>Max Worker Processes</B></TD>
                   <TD><B>AppPool userName</B></TD>
                   <TD><B>ConnectAs</B></TD>
                   <TD><B>Site Protocols</B></TD>
                   <TD><B>Site Bindings</B></TD>
                   <TD><B>CoreCredit URL</B></TD>
                   <TD><B>Report Server URL</B></TD>
                   <TD><B>Letter Server URL</B></TD>
                   <TD><B>JSFileVersion</B></TD>
                   <TD><B>AccessControlAllowOrigin</B></TD>
                   <TD><B>WcfAPIEndPointDefault</B></TD>
                   <TD><B>DbbAPIEndPointDefault</B></TD>
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
 
#$IPAddress = (Resolve-DnsName $Entry.ServerName | Where-Object Type -eq "A").IpAddress
$IPAddress = $Entry.CoreCreditSiteBindingIP
$WCFAPIEndPointURL = $Entry.WcfAPIEndPointDefault
$WCFDBBIDAPIEndPointURL = $Entry.DbbAPIEndPointDefault
$ReportServerURL = $Entry.ReportServerPath

#CoreCreditURL
try {
$CoreCreditURL = "https://$IPAddress"
$CoreCreditRequest = Invoke-WebRequest $CoreCreditURL

} catch{

    $CoreCreditstring_err = $_ | Out-String
    

}


$CoreCreditStatus = $CoreCreditRequest.StatusCode
$CoreCreditContent = $CoreCreditRequest.Content | Select-String "Version:" |ForEach-Object { $_.Matches.Value }
if (($CoreCreditContent -eq "Version:") -and ($CoreCreditStatus	-eq 200))
{
$CoreCreditWorking="Working"
}
else
{
$CoreCreditWorking="Not Working"
$CoreCreditContent = $NULL
}
$CoreCreditURL
$CoreCreditStatus
$CoreCreditContent

Clear-Variable WCFWebCall
Clear-Variable WCFDBBIDWebCall
Clear-Variable ReportServerURL


#WCFAPIEndPointURL
try
{

$WCFWebCall = Invoke-WebRequest  $WCFAPIEndPointURL

}
Catch{
$WCFURLstring_err = $_ | Out-String
}

if (($WCFWebCall.Content -match "You have created a service") -and ($WCFWebCall.StatusCode	-eq 200))
{
$WCFURLSTATUS = "Working"
}
else
{
$WCFURLSTATUS =  "Failure"
}

#WCFDBBIDAPIEndPointURL
try
{

$WCFDBBIDWebCall = Invoke-WebRequest  $WCFDBBIDAPIEndPointURL

}
Catch{
$WCFDBBIDWebCall_err = $_ | Out-String
}

if (($WCFDBBIDWebCall.Content -match "You have created a service") -and ($WCFDBBIDWebCall.StatusCode	-eq 200))
{
$WCFDBBIBEURLSTATUS = "Working"
}
else
{
$WCFDBBIBEURLSTATUS =  "Failure"
}


#ReportServerURL
try
{

$ReportServerURL = Invoke-WebRequest  $ReportServerURL

}
Catch{
$ReportServerURL_err = $_ | Out-String
}

if (($ReportServerURL -eq "Microsoft") -and ($ReportServerWebCall.StatusCode	-eq 200))
#if ($ReportServerURL.StatusCode	-eq 200)

{
$ReportServerURLSTATUS = "Working"
}
else
{
$ReportServerURLSTATUS =  "Failure"
}





        $Outputreport += "<TR>" 
      
      $Outputreport += "
      <TD>$($Entry.ServerName)</TD><TD align=center>$($Entry.CoreCreditVersion)</TD><TD align=center>$($Entry.enable32BitAppOnWin64)</TD><TD align=center>$($Entry.managedPipelineMode)</TD><TD align=center>$($Entry.state)</TD><TD align=center>$($Entry.idleTimeoutAction)</TD><TD align=center>$($Entry.maxProcesses)</TD><TD align=center>$($Entry.AppPooluserName)</TD><TD align=center>$($Entry.ConnectAs)</TD><TD align=center>$($Entry.SiteBindingprotocol)</TD><TD align=center>$($Entry.SiteBindingInfo)</TD><TD align=center>$CoreCreditURL $CoreCreditContent $CoreCreditStatus $CoreCreditWorking</TD><TD align=center>$($Entry.ReportServerPath)</TD><TD align=center>$($Entry.LetterServerPath)</TD><TD align=center>$($Entry.JSFileVersion)</TD><TD align=center>$($Entry.AccessControlAllowOrigin)</TD><TD align=center>$($Entry.WcfAPIEndPointDefault) $WCFURLSTATUS</TD><TD align=center>$($Entry.DbbAPIEndPointDefault) $WCFDBBIBEURLSTATUS</TD></TR>"


Clear-Variable CoreCreditURL
Clear-Variable CoreCreditStatus
Clear-Variable CoreCreditWorking
Clear-Variable WCFURLStatus
Clear-Variable WCFDBBIBEURLSTATUS
Clear-Variable ReportServerURLSTATUS



 }
 $Outputreport += "</Table></BODY></HTML>" 

 
$ReportFile = "C:\Temp\CoreCredit_WebSite_Validation_$(Get-Date -Format yyyy-MM-dd-hhmm).html"
$Outputreport | out-file "$ReportFile"
Clear-Variable result
Clear-Variable Outputreport
Invoke-Item $ReportFile
