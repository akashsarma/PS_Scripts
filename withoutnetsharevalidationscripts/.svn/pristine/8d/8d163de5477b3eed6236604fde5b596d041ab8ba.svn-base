Clear-Host
$ScheduledTasks = 'Task_*'
$ScheduledProcesses = 'DbbAppServer*', 'Rundbb*'

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
if ($Environmentattributon -eq "cookie") {
Clear-Host
Write-Host "1. COOKIE - POD2"
Write-Host "2. COOKIE - POD3 (POD4)"

$PODNumberSelected = Read-Host "Enter your choice (1 or 2)"

if ($PODNumberSelected -eq "1") {$PODName = "pod2"}
elseif ($PODNumberSelected -eq "2") {$PODName = "pod4"}
else{$PODName = NULL
Write-Host "Invalid POD Name. Exiting..." 
Break Script
}

$PODName = "pod2"} elseif($Environmentattributon -eq "jazz") {$PODName = "jazz"} else{Write-Host "Invalid Environment Attributon. Exiting..." 
#Break Script
}

$EnvironmentStack = ($AWSVarialbes.Stack.ToLower())[0]
$EnvironmentStack

$AvailabilityZonesDefaultServerType = "tnp"
$AvailabilityZone = $NULL
$AvailabilityZones = ((aws ec2 describe-instances --query "Reservations[*].Instances[*].{AvailabilityZone:Placement.AvailabilityZone,IpAddress:PrivateIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}" --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values='*$AvailabilityZonesDefaultServerType$ShortRegion$EnvironmentName$EnvironmentStack*'" "Name=availability-zone,Values='*'" --region $Region | ConvertFrom-Json).AvailabilityZone)  | Get-Unique


$RunJob = $NULL

Clear-Host
Write-Host "1. Process Management"
Write-Host "2. Tasks Management "
Write-Host "3. IIS Management"
Write-Host "4. Manage Specifc workflows for ZDT on WF Servers"
Write-Host "5. Copy Files"


$RunJob = Read-Host "Enter your choice (1 or 2 or 3 or 4 or 5) "
$RunJob

Clear-Host
$ServerNameConvention = $NULL
$ServerTypesList = $NULL
Write-Host "1. Server Name convetion NEW ('svc', 'iss', 'aut', 'tnp', 'wf', 'src', 'sk')"
Write-Host "2. Server Name convetion OLD ('svc', 'issu', 'auth', 'tnp', 'wkfw', 'src', 'sink')"

$ServerNameConvention  = Read-Host "Enter your choice (1 or 2) "
$ServerNameConvention
If ($ServerNameConvention -eq "1") {
$ServerTypesList = 'svc', 'iss', 'aut', 'tnp', 'wf', 'src', 'sk'
If ($RunJob -eq "3"){$ServerTypesList = 'wcf', 'web', 'ew'}
If ($RunJob -eq "4"){$ServerTypesList = 'wf'}
If ($RunJob -eq "5"){$ServerTypesList = 'svc', 'iss', 'aut', 'tnp', 'wf', 'src', 'sk', 'bat'
Clear-Host
Write-Host "1. Copy APP Files"
Write-Host "2. Copy WCF Files"
Write-Host "3. Copy WEB Files"
Write-Host "4. Copy CoreCredit Files (EW)"

$CopyFileType = Read-Host "Enter your choice (1 or 2 or 3 or 4) "

}
If ($RunJob -eq "6"){$ServerTypesList = 'wcf'}
If ($RunJob -eq "7"){$ServerTypesList = 'web'}
If ($RunJob -eq "8"){$ServerTypesList = 'ew'}
}
If ($ServerNameConvention -eq "2") {
$ServerTypesList = 'svc', 'issu', 'auth', 'tnp', 'wkfw', 'src', 'sink'
If ($RunJob -eq "3"){$ServerTypesList = 'wcf', 'web', 'ew'}
If ($RunJob -eq "4"){$ServerTypesList = 'wkfw'}
If ($RunJob -eq "5"){$ServerTypesList = 'svc', 'issu', 'auth', 'tnp', 'wkfw', 'src', 'sink', 'bat'}
If ($RunJob -eq "6"){$ServerTypesList = 'wcf'}
If ($RunJob -eq "7"){$ServerTypesList = 'web'}
If ($RunJob -eq "8"){$ServerTypesList = 'ew'}
$EnvironmentStack = ""
}
$ServerTypesList

$StartStopProcess  = $NULL

If ($RunJob -eq "1"){
Clear-Host

Write-Host "1. Stop Process"
Write-Host "2. Start Process"
$StartStopProcess  = Read-Host "Enter your choice (1 or 2) "
$StartStopProcess
}

$EnableDisableTasks  = $NULL
If ($RunJob -eq "2"){
Clear-Host
Write-Host "1. Disable Tasks"
Write-Host "2. Enable Tasks"
$EnableDisableTasks  = Read-Host "Enter your choice (1 or 2) "
$EnableDisableTasks
}

$IISTasks  = $NULL
If ($RunJob -eq "3"){
Clear-Host
Write-Host "1. Stop IIS"
Write-Host "2. Start IIS"
$IISTasks  = Read-Host "Enter your choice (1 or 2) "
$IISTasks
}

$ZDTWFs  = $NULL
If ($RunJob -eq "4"){
Clear-Host
$ZDTWFsScheduledTasks = 'Task_CoreAuthAging', 'Task_DBPD', 'Task_AccountReinstate', 'Task_ACHSendPIIRequest*', 'Task_ACHCreatePIIRequest*', 'Task_CBRSendPIIRequest*',  'Task_CBRCreatePIIRequest*', 'Task_MergeAccounts', 'Task_AccountParametersUpdates','Task_ACHBHubCreatePIIRequest*','Task_ACHBHubSendPIIRequest*','Task_CBRBHubCreatePIIRequest*','Task_CBRBHubSendPIIRequest*'
$ZDTWFsScheduledProcesses = 'Rundbb_CoreAuthAging*','Rundbb_DBPD*','Rundbb_AccountReinstate*','Rundbb_ACHSendPIIRequest*','Rundbb_ACHSendPIIRequest*','Rundbb_ACHCreatePIIRequest*','Rundbb_ACHCreatePIIRequest*','Rundbb_CBRSendPIIRequest*','Rundbb_CBRSendPIIRequest*','Rundbb_CBRCreatePIIRequest*','Rundbb_CBRCreatePIIRequest*','Rundbb_MergeAccounts*','Rundbb_AccountParametersUpdates*','Rundbb_ACHCreatePIIRequest*','Rundbb_ACHSendPIIRequest*','Rundbb_ACHBHubCreatePIIRequest*','Rundbb_ACHBHubSendPIIRequest*','Rundbb_CBRCreatePIIRequest*','Rundbb_CBRSendPIIRequest*','Rundbb_CBRBHubCreatePIIRequest*','Rundbb_CBRBHubSendPIIRequest*'
foreach($ZDTWFsScheduledTask in $ZDTWFsScheduledTasks){
Write-Host "Scheduled Tasks - $ZDTWFsScheduledTask"}
Write-Host ""
foreach($ZDTWFsScheduledProcess in $ZDTWFsScheduledProcesses){
Write-Host "Workflows - $ZDTWFsScheduledProcess"}
Write-Host ""
Write-Host "1. Disable Tasks"
Write-Host "2. Enable Tasks"
Write-Host "3. Disable Tasks & Stop Workflows"
Write-Host "4. Enable Tasks & Start Workflows"
$ZDTWFs  = Read-Host "Enter your choice (1 or 2 or 3 or 4) "
$ZDTWFs
}


$CopyAPPPath         = $NULL
$CopyAPPPathArchive  = $NULL
$CopyAPPPathS3       = $NULL

$CopyWCFPath         = $NULL
$CopyWCFPathArchive  = $NULL
$CopyWCFPathS3       = $NULL

$CopyWEBPath         = $NULL
$CopyWEBPathArchive  = $NULL
$CopyWEBPathS3       = $NULL

$CopyEWPath          = $NULL
$CopyEWPathArchive   = $NULL
$CopyEWPathS3        = $NULL

$GetConfirmation = $NULL

If ($RunJob -eq "5"){


Write-Host "1. Copy APP Files"
Write-Host "2. Copy WCF Files"
Write-Host "3. Copy WEB Files"
Write-Host "4. Copy CoreCredit Files (EW)"
Clear-Host


$CopyAPPPath         = "C:\TEMP\COPYAPP"
$CopyAPPPathArchive  = "C:\TEMP\COPYAPP_Archive"
$CopyAPPPathS3       = "s3://corecard-$PODName-$EnvironmentName-$Region-config-files/COPY/APP/APP_SETUP.Zip"

$CopyWCFPath         = "C:\TEMP\COPYWCF"
$CopyWCFPathArchive  = "C:\TEMP\COPYWCF_Archive"
$CopyWCFPathS3       = "s3://corecard-$PODName-$EnvironmentName-$Region-config-files/COPY/WCF/WCF_SETUP.Zip"

$CopyWEBPath         = "C:\TEMP\COPYWEB"
$CopyWEBPathArchive  = "C:\TEMP\COPYWEB_Archive"
$CopyWEBPathS3       = "s3://corecard-$PODName-$EnvironmentName-$Region-config-files/COPY/WEB/WEB_SETUP.Zip"

$CopyEWPath          = "C:\TEMP\COPYEW"
$CopyEWPathArchive   = "C:\TEMP\COPYEW_Archive"
$CopyEWPathS3        = "s3://corecard-$PODName-$EnvironmentName-$Region-config-files/COPY/EW/EW_SETUP.Zip"


if($CopyFileType -eq "1"){

if(Test-Path -Path $CopyAPPPath){
Remove-Item -Force -Path $CopyAPPPath -Recurse}

if(Test-Path -Path $CopyAPPPathArchive){
Remove-Item -Force -Path $CopyAPPPathArchive -Recurse}

if(Test-Path -Path $CopyAPPPath){Write-Host "Folder Already exist please delete and try again - " $CopyAPPPath
Break Script}

if(Test-Path -Path $CopyAPPPathArchive){Write-Host "Folder Already exist please delete and try again - " $CopyAPPPathArchive
Break Script}

New-Item -ItemType Directory -Force -Path "$CopyAPPPath\DBBSetup\DSLs\CI\"
New-Item -ItemType Directory -Force -Path "$CopyAPPPath\DBBSetup\DSLs\CoreAuth\"
New-Item -ItemType Directory -Force -Path "$CopyAPPPath\DBBSetup\DSLs\Modularization\"
New-Item -ItemType Directory -Force -Path "$CopyAPPPath\DBBSetup\BatchScripts\CoreAuth\"
New-Item -ItemType Directory -Force -Path "$CopyAPPPath\DBBSetup\BatchScripts\CoreIssue\"
New-Item -ItemType Directory -Force -Path "$CopyAPPPath\DBBSetup\ScaleFiles\"
New-Item -ItemType Directory -Force -Path "$CopyAPPPath\CC_runtime\"
New-Item -ItemType Directory -Force -Path "$CopyAPPPath\CC_Python\"
New-Item -ItemType Directory -Force -Path "$CopyAPPPath\TraceFiles\CoreAuth\"
New-Item -ItemType Directory -Force -Path "$CopyAPPPath\TraceFiles\CoreIssue\"

New-Item -ItemType Directory -Force -Path "$CopyAPPPathArchive\"

Clear-Host
Read-Host "Copy or verify your Files in respctive folders at $CopyAPPPath ... Press enter to open the path. Do not create or copy any other folder manually"
Invoke-Item $CopyAPPPath

$GetConfirmation = Read-Host "Copy your Files in respctive folders at $CopyAPPPath and type confirm to continue".

If ($GetConfirmation -ne "confirm") {
Write-Host "Invalid Input. Exiting..." 
Break Script}


$CopyAPPPathS3

$compressAPP = @{
  Path = "$CopyAPPPath\*"
  CompressionLevel = "Fastest"
  DestinationPath = "$CopyAPPPathArchive\APP_SETUP.Zip"
  Force = $True
}
Compress-Archive @compressAPP

aws s3 rm $CopyAPPPathS3 # --recursive
aws s3 cp $CopyAPPPathArchive\APP_SETUP.Zip $CopyAPPPathS3
#Read-Host "Wait"

}

elseif($CopyFileType -eq "2"){

if(Test-Path -Path $CopyWCFPath){
Remove-Item -Force -Path $CopyWCFPath -Recurse}

if(Test-Path -Path $CopyWCFPathArchive){
Remove-Item -Force -Path $CopyWCFPathArchive -Recurse}

if(Test-Path -Path $CopyWCFPath){Write-Host "Folder Already exist please delete and try again - " $CopyWCFPath
Break Script}

if(Test-Path -Path $CopyWCFPathArchive){Write-Host "Folder Already exist please delete and try again - " $CopyWCFPathArchive
Break Script}

New-Item -ItemType Directory -Force -Path "$CopyWCFPath\CoreCardServices\"
New-Item -ItemType Directory -Force -Path "$CopyWCFPath\WCF\"

New-Item -ItemType Directory -Force -Path "$CopyWCFPathArchive\"

Clear-Host
Read-Host "Copy or verify your Files in respctive folders at $CopyWCFPath ... Press enter to open the path. Do not create or copy any other folder manually"
Invoke-Item $CopyWCFPath

$GetConfirmation = Read-Host "Copy your Files in respctive folders at $CopyWCFPath and type confirm to continue".

If ($GetConfirmation -ne "confirm") {
Write-Host "Invalid Input. Exiting..." 
Break Script}

$CopyWCFPathS3

$compressWCF = @{
  Path = "$CopyWCFPath\*"
  CompressionLevel = "Fastest"
  DestinationPath = "$CopyWCFPathArchive\WCF_SETUP.Zip"
  Force = $True
}
Compress-Archive @compressWCF

aws s3 rm $CopyWCFPathS3 # --recursive
aws s3 cp $CopyWCFPathArchive\WCF_SETUP.Zip $CopyWCFPathS3


}

elseif($CopyFileType -eq "3"){

if(Test-Path -Path $CopyWEBPath){
Remove-Item -Force -Path $CopyWEBPath -Recurse}

if(Test-Path -Path $CopyWEBPathArchive){
Remove-Item -Force -Path $CopyWEBPathArchive -Recurse}

if(Test-Path -Path $CopyWEBPath){Write-Host "Folder Already exist please delete and try again - " $CopyWEBPath
Break Script}

if(Test-Path -Path $CopyWEBPathArchive){Write-Host "Folder Already exist please delete and try again - " $CopyWEBPathArchive
Break Script}


New-Item -ItemType Directory -Force -Path "$CopyWEBPath\DBBScale\"
New-Item -ItemType Directory -Force -Path "$CopyWEBPath\ScaleService\"
New-Item -ItemType Directory -Force -Path "$CopyWEBPath\DBBWEB\"
New-Item -ItemType Directory -Force -Path "$CopyWEBPath\Services\"


New-Item -ItemType Directory -Force -Path "$CopyWEBPathArchive\"

Clear-Host
Read-Host "Copy or verify your Files in respctive folders at $CopyWEBPath ... Press enter to open the path. Do not create or copy any other folder manually"
Invoke-Item $CopyWEBPath

$GetConfirmation = Read-Host "Copy your Files in respctive folders at $CopyWEBPath and type confirm to continue".

If ($GetConfirmation -ne "confirm") {
Write-Host "Invalid Input. Exiting..." 
Break Script}



$CopyWEBPathS3

$compressWEB = @{
  Path = "$CopyWEBPath\*"
  CompressionLevel = "Fastest"
  DestinationPath = "$CopyWEBPathArchive\WEB_SETUP.Zip"
  Force = $True
}
Compress-Archive @compressWEB

aws s3 rm $CopyWEBPathS3 # --recursive
aws s3 cp $CopyWEBPathArchive\WEB_SETUP.Zip $CopyWEBPathS3


}

elseif($CopyFileType -eq "4"){

if(Test-Path -Path $CopyEWPath){
Remove-Item -Force -Path $CopyEWPath -Recurse}

if(Test-Path -Path $CopyEWPathArchive){
Remove-Item -Force -Path $CopyEWPathArchive -Recurse}

if(Test-Path -Path $CopyEWPath){Write-Host "Folder Already exist please delete and try again - " $CopyEWPath
Break Script}

if(Test-Path -Path $CopyEWPathArchive){Write-Host "Folder Already exist please delete and try again - " $CopyEWPathArchive
Break Script}

New-Item -ItemType Directory -Force -Path "$CopyEWPath\CoreCredit\"

New-Item -ItemType Directory -Force -Path "$CopyEWPathArchive\"

Clear-Host
Read-Host "Copy or verify your Files in respctive folders at $CopyEWPath ... Press enter to open the path. Do not create or copy any other folder manually"
Invoke-Item $CopyEWPath

$GetConfirmation = Read-Host "Copy your Files in respctive folders at $CopyEWPath and type confirm to continue".

If ($GetConfirmation -ne "confirm") {
Write-Host "Invalid Input. Exiting..." 
Break Script}


$CopyEWPathS3

$compressEW = @{
  Path = "$CopyEWPath\*"
  CompressionLevel = "Fastest"
  DestinationPath = "$CopyEWPathArchive\EW_SETUP.Zip"
  Force = $True
}
Compress-Archive @compressEW

aws s3 rm $CopyEWPathS3 # --recursive
aws s3 cp $CopyEWPathArchive\EW_SETUP.Zip $CopyEWPathS3


}

else{Write-Host "Invalid Copy Option. Exiting..." 
Break Script}

}



Clear-Host
$AvailabilityZone = $NULL
$AvailabilityZone =  Read-Host "Type Availability Zones your choice  $AvailabilityZones or * for all zones "
$AvailabilityZone

Clear-Host
$ServerTypes = $NULL
$ServerTypes =  Read-Host "Type any server Type($ServerTypesList) or * for all server types except bat "
If ($ServerTypes -eq "*") {$ServerTypes = $ServerTypesList}
$ServerTypes

Clear-Host
$SpecificProcessName = $NULL

If ($StartStopProcess -eq "1") {
$SpecificProcessName =  Read-Host "Enter the specific process name like DbbAppServer_Services or Rundbb_TNP or * for all processes on server type $ServerTypes "
if ($SpecificProcessName -ne "*") {$ScheduledProcesses = "$SpecificProcessName*"}
$ScheduledProcesses
}
$SpecificScheduledTasks = $NULL
If ($StartStopProcess -eq "2") {
$SpecificScheduledTasks =  Read-Host "Enter the specific Task name like Task_DbbAppServer_Services or Task_TNP or * for all processes on server type $ServerTypes "
if ($SpecificScheduledTasks -ne "*") {$ScheduledTasks = "$SpecificScheduledTasks*"}
$ScheduledTasks
}

If ($EnableDisableTasks -eq "1" -or $EnableDisableTasks -eq "2") {
$SpecificScheduledTasks =  Read-Host "Enter the specific Task name like Task_DbbAppServer_Services or Task_TNP or * for all processes on server type $ServerTypes "
if ($SpecificScheduledTasks -ne "*") {$ScheduledTasks = "$SpecificScheduledTasks*"}
$ScheduledTasks
}

Clear-Host
$ServerRange = $NULL
$ServerRangeStart = $NULL
$ServerRangeEnd = $NULL
$ServerRange =  Read-Host "Enter the $ServerTypes Server range like 1-5 or 15-30 or 16-16 or * for all servers"
if ($ServerRange -ne "*") {
$ServerRangeStart = $ServerRange.Split("-")[0]
$ServerRangeEnd = $ServerRange.Split("-")[1]
$ServerRangeStart-$ServerRangeEnd
}







ForEach($ServerType in $ServerTypes) {
Write-Host "ServerTpye - $ServerType"

if ($ServerRange -eq "*") {
$ServerList = ((aws ec2 describe-instances --query "Reservations[*].Instances[*].{AvailabilityZone:Placement.AvailabilityZone,IpAddress:PrivateIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}" --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values='*$ServerType$ShortRegion$EnvironmentName$EnvironmentStack*'" "Name=availability-zone,Values='$AvailabilityZone'" --region $Region | ConvertFrom-Json) | Select-Object @{n = "Name"; e = { $_.Name } },@{n = "AvailabilityZone"; e = { $_.AvailabilityZone } }, @{n = "serial"; e = { [double]($_.Name -split "$EnvironmentName$EnvironmentStack")[1] } } |Sort-Object -Property serial)
}else{
$ServerList = (((aws ec2 describe-instances --query "Reservations[*].Instances[*].{AvailabilityZone:Placement.AvailabilityZone,IpAddress:PrivateIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}" --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values='*$ServerType$ShortRegion$EnvironmentName$EnvironmentStack*'" "Name=availability-zone,Values='$AvailabilityZone'" --region $Region | ConvertFrom-Json) | Select-Object @{n = "Name"; e = { $_.Name } },@{n = "AvailabilityZone"; e = { $_.AvailabilityZone } }, @{n = "serial"; e = { [double]($_.Name -split "$EnvironmentName$EnvironmentStack")[1] } } |Sort-Object -Property serial) | Where-Object -Property serial -ge $ServerRangeStart | Where-Object -Property serial -le $ServerRangeEnd )
}
$ServerList | Out-Host


#Read-Host "Press enter to see the Server List"
if ($ServerList -eq $NULL) {
Write-Host "No Server in the the gven criteria... Please try again"
Break Script
}

$ServerList = $ServerList.Name
Read-Host "Please verify the server list and press enter to continue or Stop the script"

$option = New-PSSessionOption -ProxyAccessType NoProxyServer -OpenTimeout 20000
Invoke-Command -ComputerName $ServerList -SessionOption $option -ErrorAction inquire -ScriptBlock {

param ($RunJob, $StartStopProcess, $EnableDisableTasks, $ScheduledTasks, $ScheduledProcesses, $IISTasks, $ZDTWFs, $ZDTWFsScheduledTasks, $ZDTWFsScheduledProcesses, $CopyFileType, $CopyAPPPathS3, $CopyWCFPathS3, $CopyWEBPathS3, $CopyEWPathS3)

$computername = hostname

if($RunJob -eq "1"){
#Write-Host "1. Process Management"
If ($StartStopProcess  -eq "1") {
$ScheduledProcessesStop = $NULL
$ScheduledProcessesStop = (Get-Process -Name $ScheduledProcesses).Name
If ($ScheduledProcessesStop -ne $NULL){Write-Host "Process stopping on "  $computername :  $ScheduledProcessesStop}
else{Write-Host "Process starting on "  $computername ": " "No Process to Stop"}
Get-Process -Name $ScheduledProcesses | Stop-Process -Force}

If ($StartStopProcess  -eq "2") {
$ScheduledJobs = $NULL
$ScheduledJobs = (Get-ScheduledTask  -TaskName $ScheduledTasks -ErrorAction SilentlyContinue | Start-ScheduledTask -ErrorAction SilentlyContinue).TaskName
If((Get-ScheduledTask  -TaskName $ScheduledTasks -ErrorAction SilentlyContinue) -ne $NULL){
Write-Host "Process starting on "  $computername ": " (((Get-ScheduledTask  -TaskName $ScheduledTasks -ErrorAction SilentlyContinue).TaskName).replace("Task_","  Task_"))

}
#else{Write-Host "Process starting on "  $computername ": " "No Process to Start"}
}
}

elseif($RunJob -eq "2"){

If ($EnableDisableTasks -eq "1") {
$ScheduledJobs = $NULL
foreach ($Task in $ScheduledTasks){
$ScheduledJobs += (Get-ScheduledTask  -TaskName "*$Task*" -ErrorAction SilentlyContinue | Disable-ScheduledTask).TaskName
if ($ScheduledJobs -ne $NULL){Write-Host "Disabled Jobs on "  $computername ":"  $ScheduledJobs.replace("Task_","  Task_")}
#else{Write-Host "Process starting on "  $computername ": " "No Task to Disable"}
}
}
If ($EnableDisableTasks  -eq "2") {
$ScheduledJobs = $NULL
foreach ($Task in $ScheduledTasks){
$ScheduledJobs += (Get-ScheduledTask  -TaskName "*$Task*" -ErrorAction SilentlyContinue | Enable-ScheduledTask).TaskName
if ($ScheduledJobs -ne $NULL){Write-Host "Enabled Jobs on "  $computername ":"  $ScheduledJobs.replace("Task_","  Task_")}
#else{Write-Host "Process starting on "  $computername ": " "No Task to Enable"}
}
}
}

elseif($RunJob -eq "3"){

If ($IISTasks -eq "1"){
$IISResetResult = IISRESET /stop
Write-Host $computername  $IISResetResult}

If ($IISTasks -eq "2"){
$IISResetResult = IISRESET /start
Write-Host $computername  $IISResetResult} 

}

elseif($RunJob -eq "4"){

If ($ZDTWFs  -eq "1") {
$ScheduledJobs = $NULL
foreach ($Task in $ZDTWFsScheduledTasks){
$ScheduledJobs += (Get-ScheduledTask  -TaskName $Task -ErrorAction SilentlyContinue | Disable-ScheduledTask).TaskName}
if ($ScheduledJobs -ne $NULL){Write-Host "Disabled Jobs on "  $computername ":"  $ScheduledJobs.replace("Task_","  Task_")}
}

If ($ZDTWFs -eq "2") {
$ScheduledJobs = $NULL
foreach ($Task in $ZDTWFsScheduledTasks){
$ScheduledJobs += (Get-ScheduledTask  -TaskName $Task -ErrorAction SilentlyContinue | Enable-ScheduledTask).TaskName
}
if ($ScheduledJobs -ne $NULL){Write-Host "Enabled Jobs on "  $computername ":"  $ScheduledJobs.replace("Task_","  Task_")}
}

If ($ZDTWFs  -eq "3") {
$ScheduledJobs = $NULL
foreach ($Task in $ZDTWFsScheduledTasks){
$ScheduledJobs += (Get-ScheduledTask  -TaskName $Task -ErrorAction SilentlyContinue | Disable-ScheduledTask).TaskName}
Get-Process -Name $ZDTWFsScheduledProcesses | Stop-Process -Force
if ($ScheduledJobs -ne $NULL){Write-Host "Disabled Jobs and Stopped on "  $computername ":"  $ScheduledJobs.replace("Task_","  Task_")}


If ($ZDTWFs  -eq "4") {
$ScheduledJobs = $NULL
foreach ($Task in $ZDTWFsScheduledTasks){
$ScheduledJobs += (Get-ScheduledTask  -TaskName $Task -ErrorAction SilentlyContinue | Enable-ScheduledTask | Start-ScheduledTask).TaskName}
if ($ScheduledJobs -ne $NULL){Write-Host "Enable Jobs and Started on "  $computername ":"  $ScheduledJobs.replace("Task_","  Task_")}
}


If ($ZDTWFs  -eq "5") {
$ScheduledJobs = $NULL
foreach ($Task in $ZDTWFsScheduledTasks){
$ScheduledJobs += (Get-ScheduledTask  -TaskName $Task -ErrorAction SilentlyContinue | Enable-ScheduledTask | Start-ScheduledTask).TaskName}
if ($ScheduledJobs -ne $NULL){Write-Host "Enable Jobs and Started on "  $computername ":"  $ScheduledJobs.replace("Task_","  Task_")}
}
}
}

elseif($RunJob -eq "5"){

write-host  $computername

#if(Test-Path -Path D:\TEST\){
#Remove-Item -Force -Path D:\TEST\ -Recurse}


if($CopyFileType -eq "1"){
aws s3 cp $CopyAPPPathS3 C:\TEMP\APP_SETUP.Zip
Expand-Archive -Path C:\TEMP\APP_SETUP.Zip -DestinationPath D:\ -Force}

elseif($CopyFileType -eq "2"){
aws s3 cp $CopyWCFPathS3 C:\TEMP\WCF_SETUP.Zip
Expand-Archive -Path C:\TEMP\WCF_SETUP.Zip -DestinationPath D:\WebServer\ -Force}

elseif($CopyFileType -eq "3"){
aws s3 cp $CopyWEBPathS3 C:\TEMP\WEB_SETUP.Zip
Expand-Archive -Path C:\TEMP\WEB_SETUP.Zip -DestinationPath D:\WebServer\ -Force}

elseif($CopyFileType -eq "4"){
aws s3 cp $CopyEWPathS3 C:\TEMP\EW_SETUP.Zip
Expand-Archive -Path C:\TEMP\EW_SETUP.Zip -DestinationPath D:\WebServer\ -Force}

else{Write-Host "Invalid Option"
Break Script}

}

else{
Write-Host "$RunJob. Invalid Option"
}

} -ArgumentList $RunJob, $StartStopProcess, $EnableDisableTasks, $ScheduledTasks, $ScheduledProcesses, $IISTasks,$ZDTWFs, $ZDTWFsScheduledTasks, $ZDTWFsScheduledProcesses, $CopyFileType, $CopyAPPPathS3, $CopyWCFPathS3, $CopyWEBPathS3, $CopyEWPathS3

}