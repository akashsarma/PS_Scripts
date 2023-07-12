######################################################################################################################
# Validation Tool | DEVELOPED BY:: Siddhartha Chaurasia
# Version 1.1 | Initial Release | Date:: 17-November-2021
######################################################################################################################
$Path = Split-Path $MyInvocation.MyCommand.Path
$Drive = (Get-Item $Path).Root.Name
Remove-Variable -Force HOME
Set-Variable HOME $Path
###########################################Call PowerShell Variable File##############################################
. "$HOME\SetupFile.ps1"
######################################################################################################################
If (!(Test-Path .\Logs\))
{
mkdir .\Logs\
}
else {
    mkdir .\Logs\Archive
    Move-Item .\Logs\*.* .\Logs\Archive\
}
$DATE = Get-date -Format MM-dd-yyyy-HH-mm-ss
$ErrorDATE = Get-date -Format MM-dd-yyyy-HH
Start-Transcript -Path .\Logs\Validation_Tool_$DATE.log
######################################################################################################################
$line = '========================================================='
do {
   
    Clear-Host
    Write-Host $line
    Write-Host '************** Configuration Validation **************'
    Write-Host $line
    Write-Host ' 1', ' - ', 'Validate - Application'
    Write-Host ' 2', ' - ', 'Validate - KMS'
    Write-Host ' 3', ' - ', 'Validate - WCF'
    Write-Host ' 4', ' - ', 'Validate - WebServer'
    Write-Host ' 5', ' - ', 'Validate - HSM & MIP'
    Write-Host ' 6', ' - ', 'Validate - BAT'
    Write-Host ' 7', ' - ', 'Validate - ReportDelivery'
    Write-Host ' 8', ' - ', 'Validate - ReportServer'
    Write-Host ' 9', ' - ', 'Complete - Validation'
    Write-Host ' 10', '- ', 'Quit'
    Write-Host $line
    $input = Read-Host 'Select'
    Switch ($input) {10 {exit}

'1'
{
cls
write-host -foregroundcolor green '==============================Application Validation Started=============================='
""
write-host -foregroundcolor green ======================================================================
Write-Host "Instructions::Press Enter Once Application Validation is Completed"
Write-Host "Do not Close the Console, This is Important to generate the ErrFile"
write-host -foregroundcolor green ======================================================================
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCSVC*","*CCISSU*","*CCAUTH*","*CCSRC*","*CCSINK*","*CCTNP*","*CCWKFW*","*CCBAT*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  '___________________________Verifying Platform Version___________________________'
""
$SEL = Select-String -Path \\$Servers\D$\CC_Runtime\appsys30.dsl -Pattern $PlatformVersion
if ($SEL -ne $null)
{
    Write-Host -ForegroundColor Green "SUCCESS:: PlatformCode is Up to date on $RemoteHost..!!" 
}
else
{
    Write-Host -ForegroundColor Red "ERROR:: PlatformCode is not Up to date on $RemoteHost..!!" 
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCSVC*","*CCISSU*","*CCAUTH*","*CCSRC*","*CCSINK*","*CCTNP*","*CCWKFW*","*CCBAT*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  '___________________________Verifying DSLs Version___________________________'
""
$CI = Select-String \\$Servers\d$\DBBSetup\DSLs\CI\About.dsl -Pattern $ApplicationVersion
if($CI -ne $null)
{
	Write-Host -ForegroundColor Green "SUCCESS:: CoreIssue DSL is up to date on $RemoteHost..!!"
}
else
{
	Write-host -ForegroundColor Red  "ERROR:: CoreIssue DSL is not up to date on $RemoteHost..!!"
}
$CAuth = Select-String \\$Servers\d$\DBBSetup\DSLs\CoreAuth\About.dsl -Pattern $ApplicationVersion
if($CAuth -ne $null)
{
	Write-Host -ForegroundColor Green "SUCCESS:: CoreAuth DSL is up to date on $RemoteHost..!!"
}
else
{
	Write-host -ForegroundColor Red  "ERROR:: CoreAuth DSL is not up to date on $RemoteHost..!!"
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCSVC*","*CCISSU*","*CCAUTH*","*CCSRC*","*CCSINK*","*CCTNP*","*CCWKFW*","*CCBAT*"
$Config = $ExperianSetup,$Enviroment,$PlatPIIHubEnv,$PlatPIIHubTokenEnv,$PlatAutoRewardRedeem,$MIPEndPoint,$MIPPort,$HSMEndPoint,$RelaxIssueStatusCheckForActivation,$TokenRefreshCall
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
Foreach ($SplitConfig in $Config)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  '___________________________Verifying SetupCI Configuration___________________________'
""
$SEL = Select-String "\\$Servers\D$\DBBSetup\BatchScripts\CoreIssue\SetupCI.bat" -Pattern $SplitConfig
if($SEL -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS:: $SplitConfig SetupCI is up to date on $RemoteHost..!!"
}
else
{
Write-host -ForegroundColor Red  "ERROR:: $SplitConfig SetupCI is not up to date on $RemoteHost..!!"
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCSVC*","*CCISSU*","*CCAUTH*","*CCSRC*","*CCSINK*","*CCTNP*","*CCWKFW*","*CCBAT*"
$Config = $ICANumber,$GSINumber,$NetworkManagementInformationCode
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
Foreach ($SplitConfig in $Config)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  '___________________________Verifying CoreAuthSetup Configuration___________________________'
""
$SEL = Select-String "\\$Servers\D$\DBBSetup\BatchScripts\CoreAuth\CoreAuthSetup.bat" -Pattern $SplitConfig
if($SEL -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS:: $SplitConfig SetupCI is up to date on $RemoteHost..!!"
}
else
{
Write-host -ForegroundColor Red  "ERROR:: $SplitConfig SetupCI is not up to date on $RemoteHost..!!"
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
$ScaleGrpConfirmation = "$AZWiseScaleVerification"
if ($ScaleGrpConfirmation -eq 'YES') {
write-host -foregroundcolor green =================================================================
Write-Host ********You have Selected AZ Wise Scale Validation********
write-host -foregroundcolor green =================================================================
##ZoneA
$InstancesList = Get-EC2Instance -Filter @(@{name='instance-state-name'
;values='running'}, @{ name='availability-zone'
values="$ZoneA"})
$SplitServerType = "*CCSVC*","*CCISSU*","*CCAUTH*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
Foreach ($ScaleIP in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
if ($RemoteHost -like '*CCISSU*') {
$ScaleFile = $CoreIssueScaleName_ZoneA
} elseif ($RemoteHost -like '*CCSVC*') {
$ScaleFile = $ServicesScaleName_ZoneA
} elseif ($RemoteHost -like '*CCAUTH*') {
$ScaleFile = $CoreAuthScaleName_ZoneA
}
write-host -foregroundcolor Darkcyan  "___________________________Verifying" $ZoneA "ScaleFile___________________________"
""
$Configuration = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$ScaleFile.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host "SUCCESS:: $ScaleIP SINK IP is up to date in $ScaleFile on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $ScaleIP SINK IP is not up to date in $ScaleFile on $RemoteHost..!!" -ForegroundColor red
}
$WebServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like "*CCWEB*"}
Foreach ($WebServers in $WebServerIP.PrivateIpAddress)
{
$WebIP = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$ScaleFile.ini" -Pattern $WebServers
if($WebIP -ne $null)
{
Write-Host "SUCCESS:: $WebServers Source IP is up to date in $ScaleFile on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $WebServers Source IP is not up to date in $ScaleFile on $RemoteHost..!!" -ForegroundColor red
}
}
}
}
}
$InstancesList = Get-EC2Instance -Filter @(@{name='instance-state-name'
;values='running'}, @{ name='availability-zone'
values="$ZoneA"})
$SplitServerType = "*CCSRC*","*CCSINK*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($ScaleIP in $ServerIP.PrivateIpAddress)
{
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  '___________________________Verifying SOURCE and SINK ScaleFile___________________________'
""
$Configuration = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$MCScaleName_ZoneA.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host "SUCCESS:: $ScaleIP SINK IP is up to date in $MCScaleName_ZoneA on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $ScaleIP SINK IP is not up to date in $MCScaleName_ZoneA on $RemoteHost..!!" -ForegroundColor red
}
}
}
}
##ZoneC
$InstancesList = Get-EC2Instance -Filter @(@{name='instance-state-name'
;values='running'}, @{ name='availability-zone'
values="$ZoneC"})
$SplitServerType = "*CCSVC*","*CCISSU*","*CCAUTH*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
Foreach ($ScaleIP in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
if ($RemoteHost -like '*CCISSU*') {
$ScaleFile = $CoreIssueScaleName_ZoneC
} elseif ($RemoteHost -like '*CCSVC*') {
$ScaleFile = $ServicesScaleName_ZoneC
} elseif ($RemoteHost -like '*CCAUTH*') {
$ScaleFile = $CoreAuthScaleName_ZoneC
}
write-host -foregroundcolor Darkcyan  "___________________________Verifying" $ZoneC "ScaleFile___________________________"
""
$Configuration = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$ScaleFile.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host "SUCCESS:: $ScaleIP SINK IP is up to date in $ScaleFile on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $ScaleIP SINK IP is not up to date in $ScaleFile on $RemoteHost..!!" -ForegroundColor red
}
$WebServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like "*CCWEB*"}
Foreach ($WebServers in $WebServerIP.PrivateIpAddress)
{
$WebIP = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$ScaleFile.ini" -Pattern $WebServers
if($WebIP -ne $null)
{
Write-Host "SUCCESS:: $WebServers Source IP is up to date in $ScaleFile on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $WebServers Source IP is not up to date in $ScaleFile on $RemoteHost..!!" -ForegroundColor red
}
}
}
}
}
$InstancesList = Get-EC2Instance -Filter @(@{name='instance-state-name'
;values='running'}, @{ name='availability-zone'
values="$ZoneC"})
$SplitServerType = "*CCSRC*","*CCSINK*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($ScaleIP in $ServerIP.PrivateIpAddress)
{
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  '___________________________Verifying SOURCE and SINK ScaleFile___________________________'
""
$Configuration = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$MCScaleName_ZoneC.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host "SUCCESS:: $ScaleIP SINK IP is up to date in $MCScaleName_ZoneC on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $ScaleIP SINK IP is not up to date in $MCScaleName_ZoneC on $RemoteHost..!!" -ForegroundColor red
}
}
}
}
##ZoneD
$InstancesList = Get-EC2Instance -Filter @(@{name='instance-state-name'
;values='running'}, @{ name='availability-zone'
values="$ZoneD"})
$SplitServerType = "*CCSVC*","*CCISSU*","*CCAUTH*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
Foreach ($ScaleIP in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
if ($RemoteHost -like '*CCISSU*') {
$ScaleFile = $CoreIssueScaleName_ZoneD
} elseif ($RemoteHost -like '*CCSVC*') {
$ScaleFile = $ServicesScaleName_ZoneD
} elseif ($RemoteHost -like '*CCAUTH*') {
$ScaleFile = $CoreAuthScaleName_ZoneD
}
write-host -foregroundcolor Darkcyan  "___________________________Verifying" $ZoneD "ScaleFile___________________________"
""
$Configuration = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$ScaleFile.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host "SUCCESS:: $ScaleIP SINK IP is up to date in $ScaleFile on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $ScaleIP SINK IP is not up to date in $ScaleFile on $RemoteHost..!!" -ForegroundColor red
}
$WebServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like "*CCWEB*"}
Foreach ($WebServers in $WebServerIP.PrivateIpAddress)
{
$WebIP = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$ScaleFile.ini" -Pattern $WebServers
if($WebIP -ne $null)
{
Write-Host "SUCCESS:: $WebServers Source IP is up to date in $ScaleFile on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $WebServers Source IP is not up to date in $ScaleFile on $RemoteHost..!!" -ForegroundColor red
}
}
}
}
}
$InstancesList = Get-EC2Instance -Filter @(@{name='instance-state-name'
;values='running'}, @{ name='availability-zone'
values="$ZoneD"})
$SplitServerType = "*CCSRC*","*CCSINK*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($ScaleIP in $ServerIP.PrivateIpAddress)
{
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  '___________________________Verifying SOURCE and SINK ScaleFile___________________________'
""
$Configuration = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$MCScaleName_ZoneD.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host "SUCCESS:: $ScaleIP SINK IP is up to date in $MCScaleName_ZoneD on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $ScaleIP SINK IP is not up to date in $MCScaleName_ZoneD on $RemoteHost..!!" -ForegroundColor red
}
}
}
}
}
else {
write-host -foregroundcolor green =================================================================
Write-Host ********You have Selected Simple Scale Validation********
write-host -foregroundcolor green =================================================================
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCSVC*","*CCISSU*","*CCAUTH*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
Foreach ($ScaleIP in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
if ($RemoteHost -like '*CCISSU*') {
$ScaleFile = "scale_appCoreIssue"
$ScaleIP = $ScaleIP -like '*CCISSU*'
} elseif ($RemoteHost -like '*CCSVC*') {
$ScaleFile = "scale_appServices"
$ScaleIP = $ScaleIP -like '*CCSVC*'
} elseif ($RemoteHost -like '*CCAUTH*') {
$ScaleFile = "scale_appCoreAuth"
$ScaleIP = $ScaleIP -like '*CCAUTH*'
}
write-host -foregroundcolor Darkcyan  "___________________________Verifying ActiveRegion ScaleFile___________________________"
""
$Configuration = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$ScaleFile.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host "SUCCESS:: $ScaleIP SINK IP is up to date in $ScaleFile on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $ScaleIP SINK IP is not up to date in $ScaleFile on $RemoteHost..!!" -ForegroundColor red
}
$WebServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like "*CCWEB*"}
Foreach ($WebServers in $WebServerIP.PrivateIpAddress)
{
$WebIP = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$ScaleFile.ini" -Pattern $WebServers
if($WebIP -ne $null)
{
Write-Host "SUCCESS:: $WebServers Source IP is up to date in $ScaleFile on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $WebServers Source IP is not up to date in $ScaleFile on $RemoteHost..!!" -ForegroundColor red
}
}
}
}
}
}
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCSRC*","*CCSINK*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
Foreach ($ScaleIP in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  '___________________________Verifying SOURCE and SINK ScaleFile___________________________'
""
$Configuration = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\scale_MC.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host "SUCCESS:: $ScaleIP SINK IP is up to date in scale_MC.ini on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $ScaleIP SINK IP is not up to date in scale_MC.ini on $RemoteHost..!!" -ForegroundColor red
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
write-host -foregroundcolor green '==============================Application Validation Completed=============================='
write-host -foregroundcolor green 'Press any key to return to Main Menu'
[void][System.Console]::ReadKey($true)
cls
}
'2'
{
cls
write-host -foregroundcolor green '==============================KMS Validation Started=============================='
""
write-host -foregroundcolor green ======================================================================
Write-Host "Instructions::Press Enter Once Application Validation is Completed"
Write-Host "Do not Close the Console, This is Important to generate the ErrFile"
write-host -foregroundcolor green ======================================================================
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCKMS*"
$Config = $KMSDB,$ODBCName
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
Foreach ($SplitConfig in $Config)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  '___________________________Verifying KMS Configuration___________________________'
""
$Configuration = Select-String "\\$Servers\D$\KMS\KMM\KMService.exe.config" -Pattern $SplitConfig
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS:: $SplitConfig KMS is up to date on $Servers..!!"
}
else
{
Write-host -ForegroundColor Red  "ERROR:: $SplitConfig KMS is not up to date on $Servers..!!"
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCKMS*"
$Config = $KMSDB,$ODBCName
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
Foreach ($SplitConfig in $Config)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  '___________________________Verifying KMS Service___________________________'
""
$ServiceName = 'KMSService'
If (Get-Service $ServiceName -ErrorAction SilentlyContinue) 
{
If ((Get-Service $ServiceName -computername $Servers).Status -eq 'Running') 

{
     write-host "SUCCESS:: $ServiceName found and is running on  $Servers..!!" -ForegroundColor green
} 
else
{
     write-host "ERROR:: $ServiceName found, but it is not running on $Servers..!!" -Foregroundcolor Red
} 
}
else 
{
write-host "ERROR:: $ServiceName not found on $Servers..!!" -ForegroundColor Red
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
write-host -foregroundcolor green '==============================KMS Validation Completed=============================='
write-host -foregroundcolor green 'Press any key to return to Main Menu'
[void][System.Console]::ReadKey($true)
cls
}
'3'
{
cls
write-host -foregroundcolor green '==============================WCF Validation Started=============================='
""
write-host -foregroundcolor green ======================================================================
Write-Host "Instructions::Press Enter Once Application Validation is Completed"
Write-Host "Do not Close the Console, This is Important to generate the ErrFile"
write-host -foregroundcolor green ======================================================================
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWCF*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$option = New-PSSessionOption -ProxyAccessType NoProxyServer
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
Invoke-Command -ComputerName $RemoteHost -SessionOption $option -ErrorAction inquire -ScriptBlock {
write-host -foregroundcolor Darkcyan '___________________________Verifying WCF AppPool_____________________'
""
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -Property Name | ForEach-Object {$_.Name}
Import-Module WebAdministration
$webapps = Get-WebApplication
$Pool = "WCF"
$AppPoolList = $Pool
foreach($AppPoolName in $AppPoolList){
$list = @()
foreach ($webapp in get-childitem IIS:\AppPools\ | where Name -Match $AppPoolName )
{
Get-ChildItem  IIS:\AppPools\ | where {$_.enable32BitAppOnWin64 -eq $true | Out-Null } 
$AppPool = Get-ChildItem iis:\apppools\ | where Name -Match $AppPoolName
ForEach($pool in $AppPool){
if($pool.enable32BitAppOnWin64 -eq $True){
Write-Host -ForegroundColor Green "SUCCESS:: 32Bit is" $pool.enable32BitAppOnWin64 "FOR" $AppPoolName on $RemoteHost..!! 
}
else{
Write-Host -ForegroundColor Red  "ERROR:: 32Bit is" $pool.enable32BitAppOnWin64 "FOR" $AppPoolName on $RemoteHost..!! 
} 
}
$Configuration = Get-ItemProperty -Path "IIS:\AppPools\$WCFPool" -name "processModel" | Select-Object maxProcesses | Where-Object maxProcesses -EQ 4
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS::" $webapp.name "WorkerProcess is up to date on $RemoteHost..!!"
}
else
{
Write-host -ForegroundColor Red  "ERROR::" $webapp.name "WorkerProcess is not up to date on $RemoteHost..!!"
}
$name = "IIS:\AppPools\" + $webapp.name
$item = @{}
$item.server = $computer;
$item.WebAppName = $webapp.name
$item.Version = (Get-ItemProperty $name managedRuntimeVersion).Value
$item.State = (Get-WebAppPoolState -Name $webapp.name).Value
$item.UserIdentityType = $webapp.processModel.identityType
$item.Username = $webapp.processModel.userName
$item.Password = $webapp.processModel.password
$obj = New-Object PSObject -Property $item 
$list += $obj
if((Get-WebAppPoolState -Name $webapp.name).Value -eq 'started'){

Write-Host -ForegroundColor Green "SUCCESS::" $webapp.name "AppPool is running on $RemoteHost..!!" 
}
else
{
Write-Host -ForegroundColor Red "SUCCESS::" $webapp.name "AppPool is not running on $RemoteHost..!!" 
}
$list | Format-Table -a -Property "WebAppName","Username"
}
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '____________________________________Completed_________________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWCF*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$option = New-PSSessionOption -ProxyAccessType NoProxyServer
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
Invoke-Command -ComputerName $RemoteHost -SessionOption $option -ErrorAction inquire -ScriptBlock {
write-host -foregroundcolor Darkcyan '___________________________Verifying CoreCardServices AppPool_____________________'
""
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -Property Name | ForEach-Object {$_.Name}
Import-Module WebAdministration
$webapps = Get-WebApplication
$Pool = "CoreCardServices"
$AppPoolList = $Pool
foreach($AppPoolName in $AppPoolList){
$list = @()
foreach ($webapp in get-childitem IIS:\AppPools\ | where Name -Match $AppPoolName )
{
Get-ChildItem  IIS:\AppPools\ | where {$_.enable32BitAppOnWin64 -eq $true | Out-Null } 
$AppPool = Get-ChildItem iis:\apppools\ | where Name -Match $AppPoolName
ForEach($pool in $AppPool){
if($pool.enable32BitAppOnWin64 -eq $True){
Write-Host -ForegroundColor Green "SUCCESS:: 32Bit is" $pool.enable32BitAppOnWin64 "FOR" $AppPoolName on $RemoteHost..!! 
}
else{
Write-Host -ForegroundColor Red  "ERROR:: 32Bit is" $pool.enable32BitAppOnWin64 "FOR" $AppPoolName on $RemoteHost..!! 
} 
}
$Configuration = Get-ItemProperty -Path "IIS:\AppPools\$WCFPool" -name "processModel" | Select-Object maxProcesses | Where-Object maxProcesses -EQ 4
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS::" $webapp.name "WorkerProcess is up to date on $RemoteHost..!!"
}
else
{
Write-host -ForegroundColor Red  "ERROR::" $webapp.name "WorkerProcess is not up to date on $RemoteHost..!!"
}
$name = "IIS:\AppPools\" + $webapp.name
$item = @{}
$item.server = $computer;
$item.WebAppName = $webapp.name
$item.Version = (Get-ItemProperty $name managedRuntimeVersion).Value
$item.State = (Get-WebAppPoolState -Name $webapp.name).Value
$item.UserIdentityType = $webapp.processModel.identityType
$item.Username = $webapp.processModel.userName
$item.Password = $webapp.processModel.password
$obj = New-Object PSObject -Property $item 
$list += $obj
if((Get-WebAppPoolState -Name $webapp.name).Value -eq 'started'){

Write-Host -ForegroundColor Green "SUCCESS::" $webapp.name "AppPool is running on $RemoteHost..!!" 
}
else
{
Write-Host -ForegroundColor Red "SUCCESS::" $webapp.name "AppPool is not running on $RemoteHost..!!" 
}
$list | Format-Table -a -Property "WebAppName","Username"
}
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '____________________________________Completed_________________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWCF*"
$Config = $KMS,$CoreIssueSSLCert
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
Foreach ($SplitConfig in $Config)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  '___________________________Verifying WCF AppSettings___________________________'
""
$Configuration = Select-String "\\$Servers\D$\WebServer\WCF\configuration\appSettings.config" -Pattern $SplitConfig
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS:: $SplitConfig WCF is up to date on $Servers..!!"
}
else
{
Write-host -ForegroundColor Red  "ERROR:: $SplitConfig WCF is not up to date on $Servers..!!"
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWCF*"
$Config = $CoreIsseDB,$CoreAuthDB,$CoreLibraryDB,$DBServer
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
Foreach ($SplitConfig in $Config)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  '___________________________Verifying CoreCARD Services___________________________'
""
$Configuration = Select-String "\\$Servers\D$\WebServer\CoreCardServices\connectionStrings.config" -Pattern $SplitConfig
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS:: $SplitConfig CoreCARD Services is up to date on $Servers..!!"
}
else
{
Write-host -ForegroundColor Red  "ERROR:: $SplitConfig CoreCARD Services is not up to date on $Servers..!!"
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWEB*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$option = New-PSSessionOption -ProxyAccessType NoProxyServer
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
mkdir \\$RemoteHost\D$\TempVariableFile -ErrorAction SilentlyContinue | Out-Null
Copy-Item ".\SetupFile.ps1" -Destination "\\$RemoteHost\D$\TempVariableFile\" | Out-Null
Invoke-Command -ComputerName $RemoteHost -SessionOption $option -ErrorAction inquire -ScriptBlock {

write-host -foregroundcolor Darkcyan  '____________________Verifying CoreIssue Site Accessibility___________________'
""
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -Property Name | ForEach-Object {$_.Name}
. "D:\TempVariableFile\SetupFile.ps1"
$URL = "http://$CoreIssueSSLCert"
$HTTP_Request = Invoke-WebRequest $URL
$HTTP_Status = $HTTP_Request.StatusCode
if ($HTTP_Status -eq 200) {
    Write-Host -ForegroundColor Green "SUCCESS:: CoreIssue Site is Accessible on $RemoteHost..!!"
}
Else {
    Write-Host -ForegroundColor Red "ERROR:: CoreIssue Site is not Accessible on $RemoteHost..!!"
}
Remove-Item -Path D:\TempVariableFile -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}
}
}
""
write-host -foregroundcolor Darkcyan  '____________________________________Completed_________________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWCF*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$option = New-PSSessionOption -ProxyAccessType NoProxyServer
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
mkdir \\$RemoteHost\D$\TempVariableFile -ErrorAction SilentlyContinue | Out-Null
Copy-Item ".\SetupFile.ps1" -Destination "\\$RemoteHost\D$\TempVariableFile\" | Out-Null
Invoke-Command -ComputerName $RemoteHost -SessionOption $option -ErrorAction inquire -ScriptBlock {
    
write-host -foregroundcolor Darkcyan  '___________________________Verifying WCF SSL Certificate___________________________'
""
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -Property Name | ForEach-Object {$_.Name}
. "D:\TempVariableFile\SetupFile.ps1"
Import-Module -Name WebAdministration
Get-ChildItem -Path IIS:SSLBindings | Where Port -notlike *5986* | ForEach-Object -Process `
{
if ($_.Sites)
{
$certificate = Get-ChildItem -Path CERT:LocalMachine/My |
Where-Object -Property Thumbprint -EQ -Value $_.Thumbprint
}
if($certificate.DnsNameList -EQ "$WCFSSLCert")
{
Write-Host -ForegroundColor Green "SUCCESS:: WCF SSL Certificate is up to date on $RemoteHost..!!"
}
else
{
Write-host -ForegroundColor Red  "ERROR:: WCF SSL Certificate is not up to date on $RemoteHost..!!"
}
}
Remove-Item -Path D:\TempVariableFile -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
write-host -foregroundcolor green '==============================WCF Validation Completed=============================='
write-host -foregroundcolor green 'Press any key to return to Main Menu'
[void][System.Console]::ReadKey($true)
cls
}
'4'
{
cls
write-host -foregroundcolor green '==============================WebServer Validation Started=============================='
""
write-host -foregroundcolor green ======================================================================
Write-Host "Instructions::Press Enter Once Application Validation is Completed"
Write-Host "Do not Close the Console, This is Important to generate the ErrFile"
write-host -foregroundcolor green ======================================================================
""
$ScaleGrpConfirmation = "$AZWiseScaleVerification"
if ($ScaleGrpConfirmation -eq 'YES') {

$InstancesList = Get-EC2Instance -Filter @(@{name='instance-state-name'
;values='running'}, @{ name='availability-zone'
values="$ZoneA"})
$SplitServerType = "*CCWEB*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($ServicesServers in $ServerIP.PrivateIpAddress)
{
$Values = "*CCSVC*","*CCISSU*","*CCAUTH*"
Foreach ($SplitValues in $Values)
{
$EachServer = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $SplitValues}
Foreach ($ScaleIP in $EachServer.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ServicesServers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  "___________________________Verifying" $ZoneA "Services ScaleFile___________________________"
""
$Configuration = Select-String "\\$ServicesServers\D$\WebServer\DbbScale\DbbScale.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host "SUCCESS:: $ScaleIP SINK IP is up to date in DbbScale.ini of $ZoneA on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $ScaleIP SINK IP is not up to date in DbbScale.ini $ZoneA on $RemoteHost..!!" -ForegroundColor red
}
}
}
}
$InstancesList = Get-EC2Instance -Filter @(@{name='instance-state-name'
;values='running'}, @{ name='availability-zone'
values="$ZoneA"})
$SplitServerType = "*CCWEB*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($ScaleIP in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ServicesServers -Property Name | ForEach-Object {$_.Name}
$Configuration = Select-String "\\$ScaleIP\D$\WebServer\DbbScale\DbbScale.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host "SUCCESS:: $ScaleIP SOURCE IP is up to date in DbbScale.ini of $ZoneA on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $ScaleIP SOURCE IP is not up to date in DbbScale.ini of $ZoneA on $RemoteHost..!!" -ForegroundColor red
}
}
}
}
$InstancesList = Get-EC2Instance -Filter @(@{name='instance-state-name'
;values='running'}, @{ name='availability-zone'
values="$ZoneC"})
$SplitServerType = "*CCWEB*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($ServicesServers in $ServerIP.PrivateIpAddress)
{
$Values = "*CCSVC*","*CCISSU*","*CCAUTH*"
Foreach ($SplitValues in $Values)
{
$EachServer = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $SplitValues}
Foreach ($ScaleIP in $EachServer.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ServicesServers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  "___________________________Verifying" $ZoneC "Services ScaleFile___________________________"
""
$Configuration = Select-String "\\$ServicesServers\D$\WebServer\DbbScale\DbbScale.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host "SUCCESS:: $ScaleIP SINK IP is up to date in DbbScale.ini of $ZoneC on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $ScaleIP SINK IP is not up to date in DbbScale.ini of $ZoneC on $RemoteHost..!!" -ForegroundColor red
}
}
}
}
$InstancesList = Get-EC2Instance -Filter @(@{name='instance-state-name'
;values='running'}, @{ name='availability-zone'
values="$ZoneC"})
$SplitServerType = "*CCWEB*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($ScaleIP in $ServerIP.PrivateIpAddress)
{
$Configuration = Select-String "\\$ScaleIP\D$\WebServer\DbbScale\DbbScale.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ServicesServers -Property Name | ForEach-Object {$_.Name}
Write-Host "SUCCESS:: $ScaleIP SOURCE IP is up to date in DbbScale.ini of $ZoneC on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $ScaleIP SOURCE IP is not up to date in DbbScale.ini of $ZoneC on $RemoteHost..!!" -ForegroundColor red
}
}
}
}
$InstancesList = Get-EC2Instance -Filter @(@{name='instance-state-name'
;values='running'}, @{ name='availability-zone'
values="$ZoneD"})
$SplitServerType = "*CCWEB*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($ServicesServers in $ServerIP.PrivateIpAddress)
{
$Values = "*CCSVC*","*CCISSU*","*CCAUTH*"
Foreach ($SplitValues in $Values)
{
$EachServer = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $SplitValues}
Foreach ($ScaleIP in $EachServer.PrivateIpAddress)
{
write-host -foregroundcolor Darkcyan  "___________________________Verifying" $ZoneD "DbbScaleFile___________________________"
""
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ServicesServers -Property Name | ForEach-Object {$_.Name}
$Configuration = Select-String "\\$ServicesServers\D$\WebServer\DbbScale\DbbScale.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host "SUCCESS:: $ScaleIP SINK IP is up to date in DbbScale.ini of $ZoneD on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $ScaleIP SINK IP is not up to date in DbbScale.ini of $ZoneD on $RemoteHost..!!" -ForegroundColor red
}
}
}
}
$InstancesList = Get-EC2Instance -Filter @(@{name='instance-state-name'
;values='running'}, @{ name='availability-zone'
values="$ZoneD"})
$SplitServerType = "*CCWEB*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($ScaleIP in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ServicesServers -Property Name | ForEach-Object {$_.Name}
$Configuration = Select-String "\\$ScaleIP\D$\WebServer\DbbScale\DbbScale.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host "SUCCESS:: $ScaleIP SOURCE IP is up to date in DbbScale.ini of $ZoneD on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $ScaleIP SOURCE IP is not up to date in DbbScale.ini of $ZoneD on $RemoteHost..!!" -ForegroundColor red
}
}
}
}
}
else {
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWEB*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($ServicesServers in $ServerIP.PrivateIpAddress)
{
$Values = "*CCSVC*","*CCISSU*","*CCAUTH*"
Foreach ($SplitValues in $Values)
{
$EachServer = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $SplitValues}
Foreach ($ScaleIP in $EachServer.PrivateIpAddress)
{
write-host -foregroundcolor Darkcyan  '___________________________Verifying  DbbScaleFile___________________________'
""
$Configuration = Select-String "\\$ServicesServers\D$\WebServer\DbbScale\DbbScale.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ServicesServers -Property Name | ForEach-Object {$_.Name}
Write-Host "SUCCESS:: $ScaleIP SINK IP is up to date in DbbScale.ini on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $ScaleIP SINK IP is not up to date in DbbScale.ini on $RemoteHost..!!" -ForegroundColor red
}
}
}
}
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWEB*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($ScaleIP in $ServerIP.PrivateIpAddress)
{
$Configuration = Select-String "\\$ScaleIP\D$\WebServer\DbbScale\DbbScale.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ServicesServers -Property Name | ForEach-Object {$_.Name}
Write-Host "SUCCESS:: $ScaleIP SOURCE IP is up to date in DbbScale.ini on $RemoteHost..!!" -ForegroundColor green
}
else
{
write-host "ERROR:: $ScaleIP SOURCE IP is not up to date in DbbScale.ini on $RemoteHost..!!" -ForegroundColor red
}
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWEB*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$option = New-PSSessionOption -ProxyAccessType NoProxyServer
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
mkdir \\$RemoteHost\D$\TempVariableFile -ErrorAction SilentlyContinue | Out-Null
Copy-Item ".\SetupFile.ps1" -Destination "\\$RemoteHost\D$\TempVariableFile\" | Out-Null
Invoke-Command -ComputerName $RemoteHost -SessionOption $option -ErrorAction inquire -ScriptBlock {
    
write-host -foregroundcolor Darkcyan  '___________________________Verifying WCF SSL Certificate___________________________'
""
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -Property Name | ForEach-Object {$_.Name}
. "D:\TempVariableFile\SetupFile.ps1"
Import-Module -Name WebAdministration
Get-ChildItem -Path IIS:SSLBindings | Where Port -notlike *5986* | ForEach-Object -Process `
{
if ($_.Sites)
{
$certificate = Get-ChildItem -Path CERT:LocalMachine/My |
Where-Object -Property Thumbprint -EQ -Value $_.Thumbprint
}
if($certificate.DnsNameList -EQ "$ServicesSSLCert")
{
Write-Host -ForegroundColor Green "SUCCESS:: WCF SSL Certificate is up to date on $RemoteHost..!!"
}
else
{
Write-host -ForegroundColor Red  "ERROR:: WCF SSL Certificate is not up to date on $RemoteHost..!!"
}
}
Remove-Item -Path D:\TempVariableFile -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWEB*"
$Config = $WCFSSLCert
Foreach ($SplitConfig in $Config)
{
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  '___________________________Verifying AccountSummary Configuration___________________________'
""
$Configuration = Select-String "\\$Servers\D$\WebServer\Services\CoreCardServices\CoreCardServices.svc\AccountSummary\Web.config" -Pattern $SplitConfig
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS:: $SplitConfig AccountSummary is up to date on $RemoteHost..!!"
}
else
{
Write-host -ForegroundColor Red  "ERROR:: $SplitConfig AccountSummary is not up to date on $RemoteHost..!!"
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWEB*"
$Config = $WCFSSLCert
Foreach ($SplitConfig in $Config)
{
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  '___________________________Verifying ListAccounts Configuration___________________________'
""
$Configuration = Select-String "\\$Servers\D$\WebServer\Services\CoreCardServices\CoreCardServices.svc\ListAccounts\Web.config" -Pattern $SplitConfig
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS:: $SplitConfig ListAccounts is up to date on $RemoteHost..!!"
}
else
{
Write-host -ForegroundColor Red  "ERROR:: $SplitConfig ListAccounts is not up to date on $RemoteHost..!!"
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWEB*"
$Config = $WCFSSLCert
Foreach ($SplitConfig in $Config)
{
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  '___________________________Verifying PersonAccountSummary Configuration___________________________'
""
$Configuration = Select-String "\\$Servers\D$\WebServer\Services\CoreCardServices\CoreCardServices.svc\PersonAccountSummary\Web.config" -Pattern $SplitConfig
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS:: $SplitConfig PersonAccountSummary is up to date on $RemoteHost..!!"
}
else
{
Write-host -ForegroundColor Red  "ERROR:: $SplitConfig PersonAccountSummary is not up to date on $RemoteHost..!!"
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWEB*"
$Config = $WCFSSLCert
Foreach ($SplitConfig in $Config)
{
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  '___________________________Verifying CoreCredit Configuration___________________________'
""
$Configuration = Select-String "\\$Servers\D$\WebServer\CoreCredit\Web.config" -Pattern $SplitConfig
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS:: $SplitConfig CoreCredit is up to date on $RemoteHost..!!"
}
else
{
Write-host -ForegroundColor Red  "ERROR:: $SplitConfig CoreCredit is not up to date on $RemoteHost..!!"
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWEB*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$option = New-PSSessionOption -ProxyAccessType NoProxyServer
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
Invoke-Command -ComputerName $RemoteHost -SessionOption $option -ErrorAction inquire -ScriptBlock {
write-host -foregroundcolor Darkcyan  '____________________Verifying CoreIssue Site Accessibility___________________'
""
$ARRCheck = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" | Select-Object "IIS URL Rewrite Module 2"
if ($ARRCheck -ne $null)
{
   $RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -Property Name | ForEach-Object {$_.Name}
   Write-Host -ForegroundColor Green "SUCCESS:: IIS URL Rewrite Module 2 is Available on $RemoteHost..!!" 
}
else
{
    Write-Host -ForegroundColor Red "ERROR:: IIS URL Rewrite Module 2 is not Available on $RemoteHost..!!" 
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
write-host -foregroundcolor green '==============================WebServer Validation Completed=============================='
write-host -foregroundcolor green 'Press any key to return to Main Menu'
[void][System.Console]::ReadKey($true)
cls
}
'5'
{
cls
write-host -foregroundcolor green '==============================MIP and HSM Validation Started=============================='
""
write-host -foregroundcolor green ======================================================================
Write-Host "Instructions::Press Enter Once Application Validation is Completed"
Write-Host "Do not Close the Console, This is Important to generate the ErrFile"
write-host -foregroundcolor green ======================================================================
""
$MIPTest = $MIPTestRequired
If ($MIPTest -EQ 'YES') {
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCSRC*","*CCAUTH*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$option = New-PSSessionOption -ProxyAccessType NoProxyServer
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
mkdir \\$RemoteHost\D$\TempVariableFile -ErrorAction SilentlyContinue | Out-Null
Copy-Item ".\SetupFile.ps1" -Destination "\\$RemoteHost\D$\TempVariableFile\" | Out-Null
Invoke-Command -ComputerName $RemoteHost -SessionOption $option -ErrorAction inquire -ScriptBlock {

write-host -foregroundcolor Darkcyan  '____________________Verifying MIP Connectivity___________________'
""
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -Property Name | ForEach-Object {$_.Name}
. "D:\TempVariableFile\SetupFile.ps1"
$TestConnection = Test-NetConnection -Computername $MIPEndPoint -Port $MIPPort
$TestConnectionResult = $TestConnection.TcpTestSucceeded
if ($TestConnectionResult -eq 'True') {
    Write-Host -ForegroundColor Green "SUCCESS:: MIP Connectivity is Established on $RemoteHost..!!"
}
Else {
    Write-Host -ForegroundColor Red "ERROR:: MIP Connectivity is not Established on $RemoteHost..!!"
}
Remove-Item -Path D:\TempVariableFile -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}
}
}
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCSRC*","*CCAUTH*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$option = New-PSSessionOption -ProxyAccessType NoProxyServer
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
mkdir \\$RemoteHost\D$\TempVariableFile -ErrorAction SilentlyContinue | Out-Null
Copy-Item ".\SetupFile.ps1" -Destination "\\$RemoteHost\D$\TempVariableFile\" | Out-Null
Invoke-Command -ComputerName $RemoteHost -SessionOption $option -ErrorAction inquire -ScriptBlock {

write-host -foregroundcolor Darkcyan  '____________________Verifying HSM Connectivity___________________'
""
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -Property Name | ForEach-Object {$_.Name}
. "D:\TempVariableFile\SetupFile.ps1"
$TestConnection = Test-NetConnection -Computername $HSMEndPoint -Port $HSMPort
$TestConnectionResult = $TestConnection.TcpTestSucceeded
if ($TestConnectionResult -eq 'True') {
    Write-Host -ForegroundColor Green "SUCCESS:: HSM Connectivity is Established on $RemoteHost..!!"
}
Else {
    Write-Host -ForegroundColor Red "ERROR:: HSM Connectivity is not Established on $RemoteHost..!!"
}
Remove-Item -Path D:\TempVariableFile -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}
}
}
}
else {
write-host -foregroundcolor green =================================================================
Write-Host "You have Skipped the MIP Connectivity Test"
write-host -foregroundcolor green =================================================================
""
write-host -foregroundcolor green Moving to HSM Test...
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCISSU*","*CCSVC*","*CCSRC*","*CCSINK*","*CCAUTH*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$option = New-PSSessionOption -ProxyAccessType NoProxyServer
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
mkdir \\$RemoteHost\D$\TempVariableFile -ErrorAction SilentlyContinue | Out-Null
Copy-Item ".\SetupFile.ps1" -Destination "\\$RemoteHost\D$\TempVariableFile\" | Out-Null
Invoke-Command -ComputerName $RemoteHost -SessionOption $option -ErrorAction inquire -ScriptBlock {

write-host -foregroundcolor Darkcyan  '____________________Verifying HSM Connectivity___________________'
""
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -Property Name | ForEach-Object {$_.Name}
. "D:\TempVariableFile\SetupFile.ps1"
$TestConnection = Test-NetConnection -Computername $HSMEndPoint -Port $HSMPort
$TestConnectionResult = $TestConnection.TcpTestSucceeded
if ($TestConnectionResult -eq 'True') {
    Write-Host -ForegroundColor Green "SUCCESS:: HSM Connectivity is Established on $RemoteHost..!!"
}
Else {
    Write-Host -ForegroundColor Red "ERROR:: HSM Connectivity is not Established on $RemoteHost..!!"
}
Remove-Item -Path D:\TempVariableFile -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWEB*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  '___________________________Verifying User in Basic Settings___________________________'
""
$SEL = Select-String -Path \\$Servers\C$\Windows\System32\inetsrv\config\applicationHost.config -Pattern ccgs-web-svc
if ($SEL -ne $null)
{
    Write-Host -ForegroundColor Green "SUCCESS:: CCGS-WEB-SVC User is up to date on $RemoteHost..!!" 
}
else
{
    Write-Host -ForegroundColor Red "ERROR:: CCGS-WEB-SVC User is not up to date on $RemoteHost..!!" 
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
write-host -foregroundcolor green '==============================MIP and HSM Completed=============================='
write-host -foregroundcolor green 'Press any key to return to Main Menu'
[void][System.Console]::ReadKey($true)
cls
}
'6'
{
cls
write-host -foregroundcolor green '==============================BAT Validation Started=============================='
""
write-host -foregroundcolor green ======================================================================
Write-Host "Instructions::Press Enter Once Application Validation is Completed"
Write-Host "Do not Close the Console, This is Important to generate the ErrFile"
write-host -foregroundcolor green ======================================================================
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCBAT*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$option = New-PSSessionOption -ProxyAccessType NoProxyServer
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
Invoke-Command -ComputerName $RemoteHost -SessionOption $option -ErrorAction inquire -ScriptBlock {

write-host -foregroundcolor Darkcyan  '____________________Listing BAT Server Jobs___________________'
""
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -Property Name | ForEach-Object {$_.Name}
Pushd "C:\Program Files (x86)\VisualCron\VCCommand"
cmd.exe /c "VCCommand.exe --action listjobs --connectionmode local --username admin"
}
}
}

""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
write-host -foregroundcolor green '===================================Completed==================================='
write-host -foregroundcolor green 'Press any key to return to Main Menu'
[void][System.Console]::ReadKey($true)
cls
}
'7'
{
cls
write-host -foregroundcolor green '==============================BAT Validation Started=============================='
""
write-host -foregroundcolor green ======================================================================
Write-Host "Instructions::Press Enter Once Application Validation is Completed"
Write-Host "Do not Close the Console, This is Important to generate the ErrFile"
write-host -foregroundcolor green ======================================================================
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCRPTD*"
$Config = $CoreIsseDB,$DBServer
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
Foreach ($SplitConfig in $Config)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Darkcyan  '___________________________Verifying ListAccounts Configuration___________________________'
""
$Configuration = Select-String "\\$Servers\D$\ReportDelivery\ReportDelivery\WFRunReports.exe.config" -Pattern $SplitConfig
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS:: $SplitConfig ReportDelivery is up to date on $RemoteHost..!!"
}
else
{
Write-host -ForegroundColor Red  "ERROR:: $SplitConfig ReportDelivery is not up to date on $RemoteHost..!!"
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
write-host -foregroundcolor green '==============================MIP and HSM Completed=============================='
write-host -foregroundcolor green 'Press any key to return to Main Menu'
[void][System.Console]::ReadKey($true)
cls
}
'8'
{
cls
write-host -foregroundcolor green '==============================ReportServer Validation Started=============================='
""
write-host -foregroundcolor green ======================================================================
Write-Host "Instructions::Press Enter Once Application Validation is Completed"
Write-Host "Do not Close the Console, This is Important to generate the ErrFile"
write-host -foregroundcolor green ======================================================================
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCRPTS*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$option = New-PSSessionOption -ProxyAccessType NoProxyServer
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
Invoke-Command -ComputerName $RemoteHost -SessionOption $option -ErrorAction inquire -ScriptBlock {

write-host -foregroundcolor Darkcyan  '____________________Listing SSRS Configuration___________________'
""

$servername = "Hostname"
$key = "Software\\Microsoft\\Microsoft SQL Server"

$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $server)
$regKey = $reg.OpenSubKey($key)

$keys = $regKey.GetSubKeyNames()

$v = 0
foreach($k in $keys)
{
   if(( $k -match 'MSRS[\d\d].') -and ($k -notcontains '\@'))
   {
       $pv = $k.Substring(4, 2)

       if ($v -le $pv)
       {
           $v = $pv
           $rs = "RS_" + $k.Substring($k.IndexOf('.') + 1)
       }
   }
}

$nspace = "root\Microsoft\SQLServer\ReportServer\$rs\v$v\Admin"
$RSServers = Get-WmiObject -Namespace $nspace -class MSReportServer_ConfigurationSetting -ComputerName $servername -ErrorVariable perror -ErrorAction SilentlyContinue

foreach ($r in $RSServers)
{
    
    $ssrsHost = $r.InstanceName
    $ssrsVers = $r.version
    $ssrsDB = $r.DatabaseName
    $ssrsShare = $r.IsSharePointIntegrated
    $ssrsService = $r.ServiceName
    $vPath = $r.VirtualDirectoryReportServer
    $urls = $r.ListReservedUrls() 
    $urls = $urls.UrlString[0]
    $urls = $urls.Replace('+', $servername) + "/$vPath"

Write-Host -ForegroundColor Green "========================================"
Write-Host -ForegroundColor Green "Configured Database Name in SSRS:"
$ssrsDB
Write-Host -ForegroundColor Green "========================================"
""
Write-Host -ForegroundColor Green "========================================"
Write-Host -ForegroundColor Green "Configured URL Endpoint in SSRS:"
$urls
Write-Host -ForegroundColor Green "========================================"
""
}
}
}
}

""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
write-host -foregroundcolor green '===================================Completed==================================='
write-host -foregroundcolor green 'Press any key to return to Main Menu'
[void][System.Console]::ReadKey($true)
cls
}
'9'
{
cls
write-host -foregroundcolor green '==============================Complete Validation Started=============================='
""
write-host -foregroundcolor green ======================================================================
Write-Host "Instructions::Press Enter Once Application Validation is Completed"
Write-Host "Do not Close the Console, This is Important to generate the ErrFile"
write-host -foregroundcolor green ======================================================================
""
Write-Host -foregroundcolor Red 'This Feature is not Ready to use'
""
write-host -foregroundcolor Darkcyan  '_____________________________________Completed____________________________________'
""
write-host -foregroundcolor green '============================== Completed=============================='
write-host -foregroundcolor green 'Press any key to return to Main Menu'
[void][System.Console]::ReadKey($true)
cls
}
default {
            Write-Host -foregroundcolor Red 'Incorrect Option, Please enter the correct number!!'
            [void][System.Console]::ReadKey($true)
        }
	
    }
    Select-String -Path ".\Logs\*Validation_Tool_$ErrorDATE*.log" -Pattern "ERROR" | Select line | Out-File ".\Logs\Validation_Tool_ERRORS_$DATE.log" -append
} 
while ($input -ne '0')
Stop-Transcript
pause