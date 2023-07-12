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
write-host -foregroundcolor Darkcyan  '___________________________[GroupID:101] STEP:01 Verifying Platform Version___________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCSVC*","*CCISSU*","*CCAUTH*","*CCSRC*","*CCSINK*","*CCTNP*","*CCWKFW*","*CCBAT*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
$SEL = Select-String -Path \\$Servers\D$\CC_Runtime\appsys30.dsl -Pattern $PlatformVersion
if ($SEL -ne $null)
{
    Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-102]:: PlatformCode $PlatformVersion is Up to date on $RemoteHost Server." 
}
else
{
    Write-Host -ForegroundColor Red "ERROR [ResponseCode-104]:: PlatformCode $PlatformVersion is not Up to date on $RemoteHost Server." 
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________[GroupID:101] STEP:01 Completed____________________________________'
""
write-host -foregroundcolor Darkcyan  '______________________________[GroupID:101] STEP:02 Verifying DSLs Version______________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCSVC*","*CCISSU*","*CCAUTH*","*CCSRC*","*CCSINK*","*CCTNP*","*CCWKFW*","*CCBAT*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}

$CI = Select-String \\$Servers\d$\DBBSetup\DSLs\CI\About.dsl -Pattern $ApplicationVersion
if($CI -ne $null)
{
	Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-102]:: CoreIssue DSL $ApplicationVersion is up to date on Server."
}
else
{
	Write-host -ForegroundColor Red  "ERROR [ResponseCode-104]:: CoreIssue DSL $ApplicationVersion is not up to date on $RemoteHost Server."
}
$CAuth = Select-String \\$Servers\d$\DBBSetup\DSLs\CoreAuth\About.dsl -Pattern $ApplicationVersion
if($CAuth -ne $null)
{
	Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-102]:: CoreAuth DSL $ApplicationVersion is up to date on $RemoteHost Server."
}
else
{
	Write-host -ForegroundColor Red  "ERROR [ResponseCode-104]:: CoreAuth DSL $ApplicationVersion is not up to date on $RemoteHost Server."
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________[GroupID:101] STEP:02 Completed____________________________________'
""
write-host -foregroundcolor Darkcyan  '___________________________[GroupID:101] STEP:03 Verifying SetupCI Configuration___________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCSVC*","*CCISSU*","*CCAUTH*","*CCSRC*","*CCSINK*","*CCTNP*","*CCWKFW*","*CCBAT*"
$Config = $ExperianSetup,$Enviroment,$PlatPIIHubEnv,$PlatPIIHubTokenEnv,$PlatAutoRewardRedeem,$HSMEndPoint,$RelaxIssueStatusCheckForActivation,$TokenRefreshCall
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
write-host -foregroundcolor Darkcyan  '====================================================================================================================='
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Green "ServerName: $RemoteHost"
write-host -foregroundcolor Green "========================="
Foreach ($SplitConfig in $Config)
{
$SEL = Select-String "\\$Servers\D$\DBBSetup\BatchScripts\CoreIssue\SetupCI.bat" -Pattern $SplitConfig
if($SEL -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-102]:: Variable $SplitConfig in SetupCI is up to date on $RemoteHost Server."
}
else
{
Write-host -ForegroundColor Red  "ERROR [ResponseCode-104]:: Variable $SplitConfig in SetupCI is not up to date on $RemoteHost Server."
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_________________________________________[GroupID:101] STEP:03 Completed_________________________________________'
""
write-host -foregroundcolor Darkcyan  '___________________________[GroupID:101] STEP:04 Verifying CoreAuthSetup Configuration___________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCSVC*","*CCISSU*","*CCAUTH*","*CCSRC*","*CCSINK*","*CCTNP*","*CCWKFW*","*CCBAT*"
$Config = $ICANumber,$GSINumber,$NetworkManagementInformationCode
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
write-host -foregroundcolor Darkcyan  '====================================================================================================================='
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
write-host -foregroundcolor Green "ServerName: $RemoteHost"
write-host -foregroundcolor Green "========================="
Foreach ($SplitConfig in $Config)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
$SEL = Select-String "\\$Servers\D$\DBBSetup\BatchScripts\CoreAuth\CoreAuthSetup.bat" -Pattern $SplitConfig
if($SEL -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-102]:: Variable $SplitConfig in CoreAuthSetup is up to date on $RemoteHost Server."
}
else
{
Write-host -ForegroundColor Red  "ERROR [ResponseCode-104]:: Variable $SplitConfig in CoreAuthSetup is not up to date on $RemoteHost Server."
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________[GroupID:101] STEP:04 Completed____________________________________'
""
$ScaleGrpConfirmation = "$AZWiseScaleVerification"
if ($ScaleGrpConfirmation -eq 'YES') {
write-host -foregroundcolor green =================================================================
Write-Host ********You have Selected AZ Wise Scale Validation********
write-host -foregroundcolor green =================================================================
##ZoneA
write-host -foregroundcolor Darkcyan  "___________________________[GroupID:101] STEP:05 Verifying" $ZoneA "ScaleFile___________________________"
""
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
$Configuration = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$ScaleFile.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host -ForegroundColor green "SUCCESS [ResponseCode-102]:: SINK IP $ScaleIP is up to date in $ScaleFile on $RemoteHost Server."
}
else
{
write-host -ForegroundColor red "ERROR [ResponseCode-104]:: SINK IP $ScaleIP is not up to date in $ScaleFile on $RemoteHost Server."
}
$WebServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like "*CCWEB*"}
Foreach ($WebServers in $WebServerIP.PrivateIpAddress)
{
$WebIP = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$ScaleFile.ini" -Pattern $WebServers
if($WebIP -ne $null)
{
Write-Host -ForegroundColor green "SUCCESS [ResponseCode-102]:: Source IP $WebServers is up to date in $ScaleFile on $RemoteHost Server."
}
else
{
write-host -ForegroundColor red "ERROR [ResponseCode-104]:: Source IP $WebServers is not up to date in $ScaleFile on $RemoteHost Server."
}
}
}
}
}
write-host -foregroundcolor Darkcyan  '___________________________[GroupID:101] STEP:05 Verifying MC SOURCE and MC SINK ScaleFile___________________________'
""
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
$Configuration = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$MCScaleName_ZoneA.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host "SUCCESS [ResponseCode-102]:: SINK IP $ScaleIP is up to date in $MCScaleName_ZoneA on $RemoteHost Server." -ForegroundColor green
}
else
{
write-host "ERROR [ResponseCode-104]:: SINK IP $ScaleIP is not up to date in $MCScaleName_ZoneA on $RemoteHostServer." -ForegroundColor red
}
}
}
}
##ZoneC
write-host -foregroundcolor Darkcyan  "___________________________[GroupID:101] STEP:05 Verifying" $ZoneC "ScaleFile___________________________"
""
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
$Configuration = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$ScaleFile.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host -ForegroundColor green "SUCCESS [ResponseCode-102]:: SINK IP $ScaleIP is up to date in $ScaleFile on $RemoteHostServer."
}
else
{
write-host  -ForegroundColor red "ERROR [ResponseCode-104]:: SINK IP $ScaleIP is not up to date in $ScaleFile on $RemoteHost Server."
}
$WebServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like "*CCWEB*"}
Foreach ($WebServers in $WebServerIP.PrivateIpAddress)
{
$WebIP = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$ScaleFile.ini" -Pattern $WebServers
if($WebIP -ne $null)
{
Write-Host  -ForegroundColor green "SUCCESS [ResponseCode-102]:: Source IP $WebServers is up to date in $ScaleFile on $RemoteHost Server."
}
else
{
write-host  -ForegroundColor red "ERROR [ResponseCode-104]:: Source IP $WebServers is not up to date in $ScaleFile on $RemoteHost Server."
}
}
}
}
}
write-host -foregroundcolor Darkcyan  '___________________________[GroupID:101] STEP:05 Verifying SOURCE and SINK ScaleFile___________________________'
""
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
$Configuration = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$MCScaleName_ZoneC.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host -ForegroundColor green "SUCCESS [ResponseCode-102]:: SINK IP $ScaleIP is up to date in $MCScaleName_ZoneC on $RemoteHost Server."
}
else
{
write-host -ForegroundColor red "ERROR [ResponseCode-104]:: SINK IP $ScaleIP is not up to date in $MCScaleName_ZoneC on $RemoteHost Server."
}
}
}
}
##ZoneD
write-host -foregroundcolor Darkcyan  "___________________________[GroupID:101] STEP:05 Verifying" $ZoneD "ScaleFile___________________________"
""
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
$Configuration = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$ScaleFile.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host "SUCCESS [ResponseCode-102]:: SINK IP $ScaleIP is up to date in $ScaleFile on $RemoteHost Server." -ForegroundColor green
}
else
{
write-host "ERROR [ResponseCode-104]:: SINK IP $ScaleIP is not up to date in $ScaleFile on $RemoteHost Server." -ForegroundColor red
}
$WebServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like "*CCWEB*"}
Foreach ($WebServers in $WebServerIP.PrivateIpAddress)
{
$WebIP = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$ScaleFile.ini" -Pattern $WebServers
if($WebIP -ne $null)
{
Write-Host -ForegroundColor green "SUCCESS [ResponseCode-102]:: Source IP $WebServers is up to date in $ScaleFile on $RemoteHost Server."
}
else
{
write-host -ForegroundColor red "ERROR [ResponseCode-104]:: Source IP $WebServers is not up to date in $ScaleFile on $RemoteHost Server."
}
}
}
}
}
write-host -foregroundcolor Darkcyan  '___________________________[GroupID:101] STEP:05 Verifying SOURCE and SINK ScaleFile___________________________'
""
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
$Configuration = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$MCScaleName_ZoneD.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host -ForegroundColor green "SUCCESS [ResponseCode-102]:: SINK IP $ScaleIP is up to date in $MCScaleName_ZoneD on $RemoteHost Server."
}
else
{
write-host -ForegroundColor red "ERROR [ResponseCode-104]:: SINK IP $ScaleIP is not up to date in $MCScaleName_ZoneD on $RemoteHost Server."
}
}
}
}
}
else {
write-host -foregroundcolor green =================================================================
Write-Host ********You have Selected Simple Scale Validation********
write-host -foregroundcolor green =================================================================
write-host -foregroundcolor Darkcyan  "_________________________[GroupID:101] STEP:05 Verifying ActiveRegion ScaleFile_________________________"
""
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
$SINKScaleIP = $ScaleIP -like '*CCISSU*'
} elseif ($RemoteHost -like '*CCSVC*') {
$ScaleFile = "scale_appServices"
$SINKScaleIP = $ScaleIP -like '*CCSVC*'
} elseif ($RemoteHost -like '*CCAUTH*') {
$ScaleFile = "scale_appCoreAuth"
$SINKScaleIP = $ScaleIP -like '*CCAUTH*'
}
$Configuration = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$ScaleFile.ini" -Pattern $SINKScaleIP
if($Configuration -ne $null)
{
write-host -ForegroundColor red "ERROR [ResponseCode-104]:: SINK IP  $ScaleIP is not up to date in $ScaleFile on $RemoteHost Server."
}
else
{
Write-Host -ForegroundColor green "SUCCESS [ResponseCode-102]:: SINK IP $ScaleIP is up to date in $ScaleFile on $RemoteHost Server."
}
$WebServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like "*CCWEB*"}
Foreach ($WebServers in $WebServerIP.PrivateIpAddress)
{
$WebIP = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\$ScaleFile.ini" -Pattern $WebServers
if($WebIP -ne $null)
{
Write-Host -ForegroundColor green "SUCCESS [ResponseCode-102]:: Source IP $WebServers is up to date in $ScaleFile on $RemoteHost Server."
}
else
{
write-host -ForegroundColor red "ERROR [ResponseCode-104]:: Source IP $WebServers is not up to date in $ScaleFile on $RemoteHost Server."
}
}
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '______________________[GroupID:101] STEP:05 Verifying MC SOURCE and MC SINK ScaleFile____________________'
""
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
$Configuration = Select-String "\\$Servers\D$\DBBSetup\ScaleFiles\scale_MC.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host -ForegroundColor green "SUCCESS [ResponseCode-102]:: SINK IP $ScaleIP is up to date in scale_MC.ini on $RemoteHost Server."
}
else
{
write-host -ForegroundColor red "ERROR [ResponseCode-104]:: SINK IP $ScaleIP is not up to date in scale_MC.ini on $RemoteHost Server."
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_______________________________________________Completed_______________________________________________'
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
write-host -foregroundcolor Darkcyan  '___________________________[GroupID:201] STEP:06 Verifying KMS Configuration___________________________'
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
$Configuration = Select-String "\\$RemoteHost\D$\KMS\KMM\KMService.exe.config" -Pattern $SplitConfig
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-202]:: Value $SplitConfig in KMS is up to date on $RemoteHost Server."
}
else
{
Write-host -ForegroundColor Red  "ERROR [ResponseCode-204]:: Value $SplitConfig in KMS is not up to date on $RemoteHost Server."
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________[GroupID:201] STEP:06 Completed____________________________________'
""
write-host -foregroundcolor Darkcyan  '______________________________[GroupID:201] STEP:06 Verifying KMS Service_______________________________'
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
$ServiceName = 'KMSService'
If (Get-Service $ServiceName -ErrorAction SilentlyContinue) 
{
If ((Get-Service $ServiceName -computername $RemoteHost).Status -eq 'Running') 

{
     write-host -ForegroundColor green "SUCCESS [ResponseCode-202]:: $ServiceName found and is running on  $RemoteHost Server."
} 
else
{
     write-host -Foregroundcolor Red "ERROR [ResponseCode-204]:: $ServiceName found, but it is not running on $RemoteHost Server."
} 
}
else 
{
write-host -ForegroundColor Red "ERROR [ResponseCode-204]:: $ServiceName not found on $RemoteHost Server."
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________[GroupID:201] STEP:06 Completed____________________________________'
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
write-host -foregroundcolor Darkcyan '___________________________[GroupID:301] STEP:07 Verifying WCF AppPool_____________________'
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
Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-302]:: Enable32BitApplication is" $pool.enable32BitAppOnWin64 "FOR" $AppPoolName on $RemoteHost Server. 
}
else{
Write-Host -ForegroundColor Red  "ERROR [ResponseCode-304]:: Enable32BitApplication is" $pool.enable32BitAppOnWin64 "FOR" $AppPoolName on $RemoteHost Server. 
} 
}
$Configuration = Get-ItemProperty -Path "IIS:\AppPools\$AppPoolList" -name "ProcessModel" | Select-Object maxProcesses | Where-Object maxProcesses -EQ 4
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-302]::" $webapp.name "4 WorkerProcess is set on $RemoteHost Server."
}
else
{
Write-host -ForegroundColor Red  "ERROR [ResponseCode-304]::" $webapp.name "4 WorkerProcess is not set on $RemoteHost Server."
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

Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-302]::" $webapp.name "AppPool is running on $RemoteHost Server." 
}
else
{
Write-Host -ForegroundColor Red "ERROR [ResponseCode-304]::" $webapp.name "AppPool is not running on $RemoteHost Server." 
}
if ($item.Username -like '*ccgs-app-svc*') {
Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-302]:: CCGS-APP-SVC user is up to date in Application Pool of $RemoteHost Server."
} else {
Write-Host -ForegroundColor Red "ERROR [ResponseCode-304]:: CCGS-APP-SVC user is not up to date in Application Pool of  $RemoteHost Server."
}
}
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_______________________________________[GroupID:301] STEP:07 Completed______________________________________'
""
write-host -foregroundcolor Darkcyan  '___________________________[GroupID:301] STEP:08 Verifying User in Basic Settings___________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWCF*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
$SEL = Select-String -Path \\$Servers\C$\Windows\System32\inetsrv\config\applicationHost.config -Pattern ccgs-app-svc
if ($SEL -ne $null)
{
    Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-302]:: CCGS-APP-SVC User is up to date on Basic Settings of $RemoteHost Server." 
}
else
{
    Write-Host -ForegroundColor Red "ERROR [ResponseCode-304]:: CCGS-APP-SVC User is not up to date on Basic Settings of $RemoteHost Server." 
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________[GroupID:301] STEP:08 Completed____________________________________'
""
write-host -foregroundcolor Darkcyan '____________________________[GroupID:301] STEP:09 Verifying CoreCardServices AppPool_____________________'
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
if($pool.enable32BitAppOnWin64 -ne $True){
Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-302]:: Enable32BitApplication is" $pool.enable32BitAppOnWin64 "FOR" $AppPoolName on $RemoteHost Server. 
}
else{
Write-Host -ForegroundColor Red  "ERROR [ResponseCode-304]:: Enable32BitApplication is" $pool.enable32BitAppOnWin64 "FOR" $AppPoolName on $RemoteHost Server. 
} 
}
$Configuration = Get-ItemProperty -Path "IIS:\AppPools\$AppPoolList" -name "ProcessModel" | Select-Object maxProcesses | Where-Object maxProcesses -EQ 4
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-302]::" $webapp.name "4 WorkerProcess is up to date on $RemoteHost Server."
}
else
{
Write-host -ForegroundColor Red  "ERROR [ResponseCode-304]::" $webapp.name "4 WorkerProcess is not up to date on $RemoteHost Server."
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

Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-302]::" $webapp.name "AppPool is running on $RemoteHost Server." 
}
else
{
Write-Host -ForegroundColor Red "ERROR [ResponseCode-304]::" $webapp.name "AppPool is not running on $RemoteHost Server." 
}
if ($item.Username -like '*ccgs-app-svc*') {
Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-302]:: CCGS-APP-SVC User is up to date in Application Pool of $RemoteHost Server."
} else {
Write-Host -ForegroundColor Red "ERROR [ResponseCode-304]:: CCGS-APP-SVC User is not up to date in Application Pool of  $RemoteHost Server."
}
}
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '____________________________________[GroupID:301] STEP:09 Completed_________________________________'
""
write-host -foregroundcolor Darkcyan  '___________________________[GroupID:301] STEP:10 Verifying WCF AppSettings___________________________'
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
$Configuration = Select-String "\\$Servers\D$\WebServer\WCF\configuration\appSettings.config" -Pattern $SplitConfig
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-302]:: Value $SplitConfig in WCF is up to date on $Servers Server."
}
else
{
Write-host -ForegroundColor Red  "ERROR [ResponseCode-304]:: Value $SplitConfig in WCF is not up to date on $Servers Server."
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________[GroupID:301] STEP:10 Completed____________________________________'
""
write-host -foregroundcolor Darkcyan  '___________________________[GroupID:301] STEP:11 Verifying CoreCARD Services___________________________'
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
$Configuration = Select-String "\\$Servers\D$\WebServer\CoreCardServices\connectionStrings.config" -Pattern $SplitConfig
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-302]:: Value $SplitConfig in CoreCARD Services is up to date on $Servers Server."
}
else
{
Write-host -ForegroundColor Red  "ERROR [ResponseCode-304]:: Value $SplitConfig in CoreCARD Services is not up to date on $Servers Server."
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________[GroupID:301] STEP:11 Completed____________________________________'
""
write-host -foregroundcolor Darkcyan  '____________________[GroupID:301] STEP:12 Verifying CoreIssue Site Accessibility___________________'
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
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -Property Name | ForEach-Object {$_.Name}
. "D:\TempVariableFile\SetupFile.ps1"
$URL = "http://$CoreIssueSSLCert"
$HTTP_Request = Invoke-WebRequest $URL
$HTTP_Status = $HTTP_Request.StatusCode
if ($HTTP_Status -eq 200) {
    Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-302]:: CoreIssue Site is Accessible on $RemoteHost Server."
}
Else {
    Write-Host -ForegroundColor Red "ERROR [ResponseCode-304]:: CoreIssue Site is not Accessible on $RemoteHost Server."
}
Remove-Item -Path D:\TempVariableFile -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}
}
}
""
write-host -foregroundcolor Darkcyan  '____________________________________[GroupID:301] STEP:12 Completed_________________________________'
""
write-host -foregroundcolor Darkcyan  '___________________________[GroupID:301] STEP:13 Verifying WCF SSL Certificate___________________________'
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
Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-302]:: WCF SSL Certificate $WCFSSLCert is up to date on $RemoteHost Server."
}
else
{
Write-host -ForegroundColor Red  "ERROR [ResponseCode-304]:: WCF SSL Certificate $WCFSSLCert is not up to date on $RemoteHost Server."
}
}
Remove-Item -Path D:\TempVariableFile -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________[GroupID:301] STEP:13 Completed____________________________________'
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
write-host -foregroundcolor Darkcyan  "___________________________[GroupID:401] STEP:14 Verifying" $ZoneA "Services ScaleFile___________________________"
""
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
$Configuration = Select-String "\\$ServicesServers\D$\WebServer\DbbScale\DbbScale.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host -ForegroundColor green "SUCCESS [ResponseCode-402]:: SINK IP $ScaleIP is up to date in DbbScale.ini of $ZoneA on $RemoteHost Server."
}
else
{
write-host -ForegroundColor red "ERROR [ResponseCode-404]:: SINK IP $ScaleIP is not up to date in DbbScale.ini $ZoneA on $RemoteHost Server."
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
Write-Host "SUCCESS [ResponseCode-402]:: SOURCE IP $ScaleIP is up to date in DbbScale.ini of $ZoneA on $RemoteHost Server." -ForegroundColor green
}
else
{
write-host "ERROR [ResponseCode-404]:: SOURCE IP $ScaleIP is not up to date in DbbScale.ini of $ZoneA on $RemoteHost Server." -ForegroundColor red
}
}
}
}
write-host -foregroundcolor Darkcyan  "___________________________[GroupID:401] STEP:14 Verifying" $ZoneC "Services ScaleFile___________________________"
""
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
$Configuration = Select-String "\\$ServicesServers\D$\WebServer\DbbScale\DbbScale.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host -ForegroundColor green "SUCCESS [ResponseCode-402]:: SINK IP $ScaleIP SINK IP is up to date in DbbScale.ini of $ZoneC on $RemoteHost Server."
}
else
{
write-host -ForegroundColor red "ERROR [ResponseCode-404]:: SINK IP $ScaleIP is not up to date in DbbScale.ini of $ZoneC on $RemoteHost Server."
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
Write-Host "SUCCESS [ResponseCode-402]:: SOURCE IP is $ScaleIP up to date in DbbScale.ini of $ZoneC on $RemoteHost Server." -ForegroundColor green
}
else
{
write-host "ERROR [ResponseCode-404]:: SOURCE IP is $ScaleIP is not up to date in DbbScale.ini of $ZoneC on $RemoteHost Server." -ForegroundColor red
}
}
}
}
write-host -foregroundcolor Darkcyan  "___________________________[GroupID:401] STEP:14 Verifying" $ZoneD "DbbScaleFile___________________________"
""
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
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ServicesServers -Property Name | ForEach-Object {$_.Name}
$Configuration = Select-String "\\$ServicesServers\D$\WebServer\DbbScale\DbbScale.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
Write-Host -ForegroundColor green "SUCCESS [ResponseCode-402]:: SINK IP $ScaleIP is up to date in DbbScale.ini of $ZoneD on $RemoteHost Server."
}
else
{
write-host -ForegroundColor red "ERROR [ResponseCode-404]:: SINK IP $ScaleIP is not up to date in DbbScale.ini of $ZoneD on $RemoteHost Server."
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
Write-Host -ForegroundColor green "SUCCESS [ResponseCode-402]:: SOURCE IP $ScaleIP is up to date in DbbScale.ini of $ZoneD on $RemoteHost Server."
}
else
{
write-host -ForegroundColor red "ERROR [ResponseCode-404]:: SOURCE IP $ScaleIP is not up to date in DbbScale.ini of $ZoneD on $RemoteHost Server."
}
}
}
}
}
else {
write-host -foregroundcolor Darkcyan  '___________________________[GroupID:401] STEP:14 Verifying  DbbScaleFile___________________________'
""
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
$Configuration = Select-String "\\$ServicesServers\D$\WebServer\DbbScale\DbbScale.ini" -Pattern $ScaleIP
if($Configuration -ne $null)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ServicesServers -Property Name | ForEach-Object {$_.Name}
Write-Host -ForegroundColor green "SUCCESS [ResponseCode-402]:: $ScaleIP SINK IP is up to date in DbbScale.ini on $RemoteHost Server."
}
else
{
write-host -ForegroundColor red "ERROR [ResponseCode-404]:: $ScaleIP SINK IP is not up to date in DbbScale.ini on $RemoteHost Server."
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
Write-Host -ForegroundColor green "SUCCESS [ResponseCode-402]:: $ScaleIP SOURCE IP is up to date in DbbScale.ini on $RemoteHost Server."
}
else
{
write-host -ForegroundColor red "ERROR [ResponseCode-404]:: $ScaleIP SOURCE IP is not up to date in DbbScale.ini on $RemoteHost Server."
}
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________[GroupID:401] STEP:14 Completed_____________________________________'
""

write-host -foregroundcolor Darkcyan  '___________________________[GroupID:401] STEP:15 Verifying Services SSL Certificate___________________________'
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
Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-402]:: Services SSL Certificate $ServicesSSLCert is up to date on $RemoteHost Server."
}
else
{
Write-host -ForegroundColor Red  "ERROR [ResponseCode-404]:: Services SSL Certificate $ServicesSSLCert is not up to date on $RemoteHost Server."
}
}
Remove-Item -Path D:\TempVariableFile -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________[GroupID:401] STEP:15 Completed____________________________________'
""
write-host -foregroundcolor Darkcyan  '___________________________[GroupID:401] STEP:15 Verifying User in Basic Settings___________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWEB*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}

$SEL = Select-String -Path \\$Servers\C$\Windows\System32\inetsrv\config\applicationHost.config -Pattern ccgs-web-svc
if ($SEL -ne $null)
{
    Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-402]:: CCGS-WEB-SVC User is up to date in Basic Settings of $RemoteHost Server." 
}
else
{
    Write-Host -ForegroundColor Red "ERROR [ResponseCode-404]:: CCGS-WEB-SVC User is not up to date in Basic Settings of $RemoteHost Server." 
}
}
}
""
write-host -foregroundcolor Darkcyan  '_________________________________________[GroupID:401] STEP:15 Completed__________________________________________'
""
write-host -foregroundcolor Darkcyan  '___________________________[GroupID:401] STEP:16 Verifying AccountSummary Configuration___________________________'
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
$Configuration = Select-String "\\$Servers\D$\WebServer\Services\CoreCardServices\CoreCardServices.svc\AccountSummary\Web.config" -Pattern $SplitConfig
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-402]:: WCF Certificate $SplitConfig in AccountSummary is up to date on $RemoteHost Server."
}
else
{
Write-host -ForegroundColor Red  "ERROR [ResponseCode-404]:: WCF Certificate $SplitConfig in AccountSummary is not up to date on $RemoteHost Server."
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_______________________________________[GroupID:401] STEP:16 Completed_________________________________________'
""
write-host -foregroundcolor Darkcyan  '___________________________[GroupID:401] STEP:17 Verifying ListAccounts Configuration__________________________'
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
$Configuration = Select-String "\\$Servers\D$\WebServer\Services\CoreCardServices\CoreCardServices.svc\ListAccounts\Web.config" -Pattern $SplitConfig
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-402]:: WCF Certificate $SplitConfig in ListAccounts is up to date on $RemoteHost Server."
}
else
{
Write-host -ForegroundColor Red  "ERROR [ResponseCode-404]:: WCF Certificate $SplitConfig in ListAccounts is not up to date on $RemoteHost Server."
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________[GroupID:401] STEP:17 Completed_____________________________________'
""
write-host -foregroundcolor Darkcyan  '___________________[GroupID:401] STEP:18 Verifying PersonAccountSummary Configuration____________________'
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
$Configuration = Select-String "\\$Servers\D$\WebServer\Services\CoreCardServices\CoreCardServices.svc\PersonAccountSummary\Web.config" -Pattern $SplitConfig
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-402]:: WCF Certificate $SplitConfig in PersonAccountSummary is up to date on $RemoteHost Server."
}
else
{
Write-host -ForegroundColor Red  "ERROR [ResponseCode-404]:: WCF Certificate $SplitConfig in PersonAccountSummary is not up to date on $RemoteHost Server."
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________[GroupID:401] STEP:18 Completed____________________________________'
""
write-host -foregroundcolor Darkcyan  '________________________[GroupID:401] STEP:19 Verifying CoreCredit Configuration________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCWEB*"
$Config = $WCFSSLCert
Foreach ($ServerType in $SplitServerType)
{
Foreach ($SplitConfig in $Config)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
$Configuration = Select-String "\\$Servers\D$\WebServer\CoreCredit\Web.config" -Pattern $SplitConfig
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-402]:: Value $SplitConfig in CoreCredit is up to date on $RemoteHost Server."
}
else
{
Write-host -ForegroundColor Red  "ERROR [ResponseCode-404]:: Value $SplitConfig in CoreCredit is not up to date on $RemoteHost Server."
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________[GroupID:401] STEP:19 Completed____________________________________'
""
write-host -foregroundcolor Darkcyan  '_________________________[GroupID:401] STEP:20 Verifying CoreIssue Site Accessibility___________________'
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
$ARRCheck = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" | Select-Object "IIS URL Rewrite Module 2"
if ($ARRCheck -ne $null)
{
   $RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -Property Name | ForEach-Object {$_.Name}
   Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-402]:: IIS URL Rewrite Module 2 is Available on $RemoteHost Server." 
}
else
{
    Write-Host -ForegroundColor Red "ERROR [ResponseCode-404]:: IIS URL Rewrite Module 2 is not Available on $RemoteHost Server." 
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________[GroupID:401] STEP:20 Completed____________________________________'
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
write-host -foregroundcolor Darkcyan  '____________________[GroupID:501] STEP:21 Verifying MIP Connectivity___________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCSRC*","*CCAUTH*"
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$option = New-PSSessionOption -ProxyAccessType NoProxyServer
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
mkdir \\$RemoteHost\D$\DBBSetup\MonitoringScripts\CCValidationTool -ErrorAction SilentlyContinue | Out-Null
Copy-Item ".\SetupFile.ps1" -Destination "\\$RemoteHost\D$\DBBSetup\MonitoringScripts\CCValidationTool\" | Out-Null
Invoke-Command -ComputerName $RemoteHost -SessionOption $option -ErrorAction inquire -ScriptBlock {
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -Property Name | ForEach-Object {$_.Name}
. "D:\DBBSetup\MonitoringScripts\CCValidationTool\SetupFile.ps1"
$TestConnection = Test-NetConnection -Computername $MIPEndPoint -Port $MIPPort
$TestConnectionResult = $TestConnection.TcpTestSucceeded
if ($TestConnectionResult -eq 'True') {
    Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-502]:: MIP Connectivity is Established on $RemoteHost Server."
}
Else {
    Write-Host -ForegroundColor Red "ERROR [ResponseCode-504]:: MIP Connectivity is not Established on $RemoteHost Server."
}
Remove-Item -Path D:\TempVariableFile -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}
}
}
write-host -foregroundcolor Darkcyan  '_____________________________________[GroupID:501] STEP:21 Completed____________________________________'
""
write-host -foregroundcolor Darkcyan  '______________________________[GroupID:501] STEP:22 Verifying HSM Connectivity__________________________'
""
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
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -Property Name | ForEach-Object {$_.Name}
. "D:\TempVariableFile\SetupFile.ps1"
$TestConnection = Test-NetConnection -Computername $HSMEndPoint -Port $HSMPort
$TestConnectionResult = $TestConnection.TcpTestSucceeded
if ($TestConnectionResult -eq 'True') {
    Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-502]:: HSM Connectivity is Established on $RemoteHost Server."
}
Else {
    Write-Host -ForegroundColor Red "ERROR [ResponseCode-504]:: HSM Connectivity is not Established on $RemoteHost Server."
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
write-host -foregroundcolor Darkcyan  '____________________[GroupID:501] STEP:22 Verifying HSM Connectivity___________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCISSU*","*CCSVC*","*CCSRC*","*CCSINK*","*CCAUTH*","*CCBAT*"
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
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -Property Name | ForEach-Object {$_.Name}
. "D:\TempVariableFile\SetupFile.ps1"
$TestConnection = Test-NetConnection -Computername $HSMEndPoint -Port $HSMPort
$TestConnectionResult = $TestConnection.TcpTestSucceeded
if ($TestConnectionResult -eq 'True') {
    Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-502]:: HSM Connectivity is Established on $RemoteHost Server."
}
Else {
    Write-Host -ForegroundColor Red "ERROR [ResponseCode-504]:: HSM Connectivity is not Established on $RemoteHost Server."
}
Remove-Item -Path D:\TempVariableFile -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}
}
}
}
""
write-host -foregroundcolor Darkcyan  '_____________________________________[GroupID:501] STEP:22 Completed____________________________________'
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
$HostName = HostName
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
$option = New-PSSessionOption -ProxyAccessType NoProxyServer
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
If ($RemoteHost -eq "$HostName"){
continue}
write-host -foregroundcolor Darkcyan  "_______________________Listing BAT Server Jobs on $RemoteHost___________________"
""
Invoke-Command -ComputerName $RemoteHost -SessionOption $option -ErrorAction inquire -ScriptBlock {
$Host = Get-WmiObject -Class Win32_ComputerSystem -Property Name | ForEach-Object {$_.Name}
$Host
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
write-host -foregroundcolor green '==============================Report Delivery Validation Started=============================='
""
write-host -foregroundcolor green ======================================================================
Write-Host "Instructions::Press Enter Once Application Validation is Completed"
Write-Host "Do not Close the Console, This is Important to generate the ErrFile"
write-host -foregroundcolor green ======================================================================
""
write-host -foregroundcolor Darkcyan  '___________________________Verifying ReportDelivery Configuration___________________________'
""
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$ReportServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like "*CCRPTSE*"}
Foreach ($RSIP in $ReportServerIP.PrivateIpAddress)
{
$RSIP = $RSIP
$RSURL = "http://$RSIP/ReportServer"
}
$InstancesList = GET-EC2Instance -Filter @{'name'='instance-state-name';'values'='running'}
$SplitServerType = "*CCRPTD*"
$Config = $CoreIsseDB,$DBServer,$RSURL,$KMS
Foreach ($ServerType in $SplitServerType)
{
$ServerIP = $InstancesList.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name ).value -like $ServerType}
Foreach ($Servers in $ServerIP.PrivateIpAddress)
{
Foreach ($SplitConfig in $Config)
{
$RemoteHost = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Servers -Property Name | ForEach-Object {$_.Name}
$Configuration = Select-String "\\$RemoteHost\D$\ReportDelivery\ReportDelivery\WFRunReports.exe.config" -Pattern $SplitConfig
if($Configuration -ne $null)
{
Write-Host -ForegroundColor Green "SUCCESS [ResponseCode-402]:: Value $SplitConfig in ReportDelivery is up to date on $RemoteHost Server."
}
else
{
Write-host -ForegroundColor Red  "ERROR [ResponseCode-404]:: Value $SplitConfig in ReportDelivery is not up to date on $RemoteHost Server."
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

$servername = Hostname
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
    Select-String -Path ".\Logs\*Validation_Tool_$ErrorDATE*.log" -Pattern "04]::" | Select line | Out-File ".\Logs\Validation_Tool_ERRORS_$DATE.log" -append
} 
while ($input -ne '0')
Stop-Transcript
pause