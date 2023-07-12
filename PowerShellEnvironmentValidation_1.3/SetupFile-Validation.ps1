$ServerTypes = 'svc', 'iss', 'aut', 'tnp', 'wf', 'src', 'sk', 'bat'
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
$MasterServerType = $ServerTypes[0]
$MasterServerType
$MasterHostList = ((aws ec2 describe-instances --query "Reservations[*].Instances[*].{AvailabilityZone:Placement.AvailabilityZone,IpAddress:PrivateIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}" --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values='*$MasterServerType$ShortRegion$EnvironmentName$EnvironmentStack*'" "Name=availability-zone,Values='*'" --region $Region | ConvertFrom-Json) | Select-Object @{n = "Name"; e = { $_.Name } }, @{n = "serial"; e = { [double]($_.Name -split "$EnvironmentName$EnvironmentStack")[1] } } | Sort-Object -Property serial).Name
$MasterHostList
$MasterHost = $MasterHostList | Select-Object -First 1

If (Test-Connection $MasterHost -Quiet){
Write-Host "Master Host - " $MasterHost
}
else{
$MasterHost = $MasterHostList | Select-Object -Last 1
Write-Host "Master Host - " $MasterHost
}



$Outputreport = "<HTML><TITLE> Application Viarable Validation Report </TITLE>
                 <BODY background-color:peachpuff>
                 <font color =""#4682B4"" face=""Microsoft Tai le"">
                 <H2> $($EnvironmentName.ToUpper()) - $($MasterHost.ToUpper()) - PLEASE VERIFY BELOW TABLE VALUES AND COMPARE WITH EXPECTED VALUES / VALIDATION SHEET</H2></font>
                 <Table border=1 cellpadding=0 cellspacing=0>"


$SetupFileList = "D:\DBBSetup\BatchScripts\CoreIssue\SetupCI.bat", "D:\DBBSetup\BatchScripts\CoreAuth\CoreAuthSetup.bat", "D:\DBBSetup\DSLs\CI\About.DSL", "D:\DBBSetup\DSLs\CoreAuth\About.DSL","D:\CC_Runtime\appsys30.DSL"
$SetupCIEnvVarialbeList = 'SET emKMSdefaultMachines=', 'SET emThalesConnectionAddrBase=', 'SET SCALE_SERVER_HOST=', 'SET Enviroment=', 'SET ExperianSetup=', 'SET PlatPIIHubEnv=', 'SET PlatPIIHubTokenEnv=', 'SET PlatAutoRewardRedeem=', 'SET RelaxIssueStatusCheckForActivation=', 'SET DummyMmsApiResult=', 'SET UsePIIFromBearerForEmbossing=', 'SET InterestAlertByTNP=', 'SET PodActiveTQR4=', 'SET PlatModelScore=', 'SET DummyModelScore=', 'SET MultiPODEnabled_IPM=', 'SET TokenRefreshCall=', 'SET UseBhubFromBearerForEmbossing=','SET RptSrvrName_StlRcn='
$CoreAuthSetupEnvVarialbeList = 'SET emKMSdefaultMachines=', 'SET emThalesConnectionAddrBase=', 'SET SCALE_SERVER_HOST=', 'SET Enviroment=', 'SET TLS12Required=', 'SET Environment=', 'SET ICANumber=', 'SET GSINumber=', 'SET NetworkManagementInformationcode='
$AboutDSLVarialbeList = 'CreditProcessing '
$PlatformVersionVarialbeList = 'Application Release '


$MasterResult = @()
$option = New-PSSessionOption -ProxyAccessType NoProxyServer -OpenTimeout 20000
$MasterResult += Invoke-Command -ComputerName $MasterHost -SessionOption $option -ErrorAction Continue -HideComputerName -ScriptBlock {


$MasterHashSetupCI = (Get-FileHash D:\DBBSetup\BatchScripts\CoreIssue\SetupCI.bat).Hash
$MasterHashRunccCI = (Get-FileHash D:\DBBSetup\BatchScripts\CoreIssue\RunccCI.bat).Hash
$MasterHashSetupCIPy = (Get-FileHash D:\DBBSetup\BatchScripts\CoreIssue\SetupCIPy.ini).Hash
$MasterHashSetUp = (Get-FileHash D:\DBBSetup\BatchScripts\CoreIssue\SetUp.py).Hash
$MasterHashCoreAuthSetup = (Get-FileHash D:\DBBSetup\BatchScripts\CoreAuth\CoreAuthSetup.bat).Hash
$MasterHashRunccCoreAuth = (Get-FileHash D:\DBBSetup\BatchScripts\CoreAuth\RunccCoreAuth.bat).Hash
$MasterHashCoreIssueAboutDSL = (Get-FileHash D:\DBBSetup\DSLs\CI\About.DSL).Hash
$MasterHashCoreAuthAboutDSL = (Get-FileHash D:\DBBSetup\DSLs\CoreAuth\About.DSL).Hash


(Get-ChildItem -Path D:\DBBSetup\DSLs\ -Recurse -Filter *.DSL | Get-FileHash).Hash | %{ $MasterDSLsHash += "$_"}
$MasterDSLs_stream = [IO.MemoryStream]::new([byte[]][char[]]$MasterDSLsHash)
$MasterDSLsHash = (Get-FileHash -InputStream $MasterDSLs_stream).Hash


(Get-ChildItem -Path D:\DBBSetup\BatchScripts\ -Recurse -Filter *.bat | Get-FileHash).Hash | %{ $MasterBatchScriptsHash += "$_"}
$MasterBatchScripts_stream = [IO.MemoryStream]::new([byte[]][char[]]$MasterBatchScriptsHash)
$MasterBatchScriptsHash = (Get-FileHash -InputStream $MasterBatchScripts_stream).Hash

$MasterPlatformVersionHash = (Get-FileHash D:\CC_runtime\appsys30.DSL).Hash



$Masterresultvalue = @() 
$Masterresultvalue = [PSCustomObject] @{
    MasterHashSetupCI = "$($MasterHashSetupCI)"
    MasterHashRunccCI = "$($MasterHashRunccCI)"
    MasterHashSetupCIPy = "$($MasterHashSetupCIPy)"
    MasterHashSetUp = "$($MasterHashSetUp)"
    MasterHashCoreAuthSetup = "$($MasterHashCoreAuthSetup)"
    MasterHashRunccCoreAuth = "$($MasterHashRunccCoreAuth)"
    MasterHashCoreIssueAboutDSL = "$($MasterHashCoreIssueAboutDSL)"
    MasterHashCoreAuthAboutDSL = "$($MasterHashCoreAuthAboutDSL)"
    MasterDSLsHash = "$($MasterDSLsHash)"
    MasterBatchScriptsHash = "$($MasterBatchScriptsHash)"
    MasterPlatformVersionHash = "$($MasterPlatformVersionHash)"
	}
$Masterresultvalue

Clear-Variable MasterHashSetupCI
Clear-Variable MasterHashRunccCI
Clear-Variable MasterHashSetupCIPy
Clear-Variable MasterHashCoreAuthAboutDSL
Clear-Variable MasterHashSetUp
Clear-Variable MasterHashCoreAuthSetup
Clear-Variable MasterHashRunccCoreAuth
Clear-Variable MasterHashCoreIssueAboutDSL
Clear-Variable MasterHashCoreAuthAboutDSL
Clear-Variable MasterDSLsHash
Clear-Variable MasterBatchScriptsHash
Clear-Variable MasterPlatformVersionHash
}

$MasterResult



$MasterHashSetupCI = $MasterResult.MasterHashSetupCI
$MasterHashRunccCI = $MasterResult.MasterHashRunccCI
$MasterHashSetupCIPy = $MasterResult.MasterHashSetupCIPy
$MasterHashSetUp = $MasterResult.MasterHashSetUp
$MasterHashCoreAuthSetup = $MasterResult.MasterHashCoreAuthSetup
$MasterHashRunccCoreAuth = $MasterResult.MasterHashRunccCoreAuth
$MasterHashCoreIssueAboutDSL = $MasterResult.MasterHashCoreIssueAboutDSL
$MasterHashCoreAuthAboutDSL = $MasterResult.MasterHashCoreAuthAboutDSL
$MasterDSLsHash = $MasterResult.MasterDSLsHash
$MasterBatchScriptsHash = $MasterResult.MasterBatchScriptsHash
$MasterPlatformVersionHash = $MasterResult.MasterPlatformVersionHash






$option = New-PSSessionOption -ProxyAccessType NoProxyServer -OpenTimeout 20000
$Outputreport += Invoke-Command -ComputerName $MasterHost -SessionOption $option -ErrorAction Continue -HideComputerName -ScriptBlock {
param ($SetupFileList, $SetupCIEnvVarialbeList, $CoreAuthSetupEnvVarialbeList, $AboutDSLVarialbeList, $PlatformVersionVarialbeList)
$MasterHostName = hostname

$OutputreportVarVal = $NULL
$SetupFile = $NULL
$EnvVarialbe = $NULL
foreach($SetupFile in $SetupFileList)
{$SetupFile
   $OutputreportVarVal += "<TR bgcolor=gray align=center><TD colspan=2><B>$MasterHostName - $SetupFile</B></TD></TR>
                    <TR bgcolor=silver align=center>
                    <TD><B>Varaible Name</B></TD>
                   <TD><B>Value</B></TD>
                   </TR>"

if ($SetupFile.ToString() -match "SetupCI.bat") {$EnvVarialbeList = $SetupCIEnvVarialbeList}
elseif ($SetupFile.ToString() -match  "CoreAuthSetup.bat"){$EnvVarialbeList = $CoreAuthSetupEnvVarialbeList}
elseif ($SetupFile.ToString() -match  "About.DSL"){$EnvVarialbeList = $AboutDSLVarialbeList}
elseif ($SetupFile.ToString() -match  "appsys30.DSL"){$EnvVarialbeList = $PlatformVersionVarialbeList}


foreach($EnvVarialbe in $EnvVarialbeList)
{
if ($EnvVarialbeList -eq  $AboutDSLVarialbeList)
{$EnvVarialbeValue = (Select-String -Path $SetupFile -Pattern "$EnvVarialbe").ToString().Split('"')[1]
$EnvVarialbe = "DSL Version"}
elseif ($EnvVarialbeList -eq  $PlatformVersionVarialbeList)
{$EnvVarialbeValue = (Select-String -Path $SetupFile -Pattern "$EnvVarialbe").ToString().Split('"')[1]
$EnvVarialbe = "Platform Version"}
else{
$EnvVarialbeValue = (Select-String -Path $SetupFile -Pattern "$EnvVarialbe").ToString().Split('=')[1]}


        $OutputreportVarVal += "<TR>" 
      
      $OutputreportVarVal += "</TD><TD>$("$EnvVarialbe")</TD><TD align=center>$($EnvVarialbeValue)</TD></TR>"

}
Clear-Variable EnvVarialbeList
}



$OutputreportVarVal


} -ArgumentList $SetupFileList, $SetupCIEnvVarialbeList, $CoreAuthSetupEnvVarialbeList, $AboutDSLVarialbeList, $PlatformVersionVarialbeList



ForEach($ServerType in $ServerTypes) {
$ServerType
    $ServerList = (aws ec2 describe-instances --query "Reservations[*].Instances[*].{AvailabilityZone:Placement.AvailabilityZone,IpAddress:PrivateIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}" --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values='*$ServerType$ShortRegion$EnvironmentName$EnvironmentStack*'" "Name=availability-zone,Values='*'" --region $Region | ConvertFrom-Json)
    $ServerList = ($ServerList | Select-Object @{n = "Name"; e = { $_.Name } }, @{n = "serial"; e = { [double]($_.Name -split "$EnvironmentName$EnvironmentStack")[1] } } | Sort-Object -Property serial).Name
 
 if($ServerType -eq "svc")
{
$ExpectedServerCount = 4
if (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "perf") -and ($Environmentattributon -eq "cookie")){$ExpectedServerCount = "45"}
elseif (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "uat2" -or $EnvironmentName -eq "mock") -and ($Environmentattributon -eq "jazz")){$ExpectedServerCount = "45"}
}


elseif($ServerType -eq "iss")
{
$ExpectedServerCount = 2
if (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "perf") -and ($Environmentattributon -eq "cookie")){$ExpectedServerCount = "3"}
elseif (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "uat2" -or $EnvironmentName -eq "mock") -and ($Environmentattributon -eq "jazz")){$ExpectedServerCount = "6"}
}
   
elseif($ServerType -eq "aut")
{
$ExpectedServerCount = 4
if (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "perf") -and ($Environmentattributon -eq "cookie")){$ExpectedServerCount = "30"}
elseif (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "uat2" -or $EnvironmentName -eq "mock") -and ($Environmentattributon -eq "jazz")){$ExpectedServerCount = "4"}
}


elseif($ServerType -eq "tnp")
{
$ExpectedServerCount = 15
if (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "perf") -and ($Environmentattributon -eq "cookie")){$ExpectedServerCount = "60"}
elseif (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "uat2" -or $EnvironmentName -eq "mock") -and ($Environmentattributon -eq "jazz")){$ExpectedServerCount = "60"}
}


elseif($ServerType -eq "wf")
{
$ExpectedServerCount = 10
if (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "perf") -and ($Environmentattributon -eq "cookie")){$ExpectedServerCount = "80"}
elseif (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "uat2" -or $EnvironmentName -eq "mock") -and ($Environmentattributon -eq "jazz")){$ExpectedServerCount = "80"}
}


elseif($ServerType -eq "src")
{
$ExpectedServerCount = 2
if (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "perf") -and ($Environmentattributon -eq "cookie")){$ExpectedServerCount = "12"}
elseif (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "uat2" -or $EnvironmentName -eq "mock") -and ($Environmentattributon -eq "jazz")){$ExpectedServerCount = "12"}
}


elseif($ServerType -eq "sk")
{
$ExpectedServerCount = 2
if (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "perf") -and ($Environmentattributon -eq "cookie")){$ExpectedServerCount = "36"}
elseif (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "uat2" -or $EnvironmentName -eq "mock") -and ($Environmentattributon -eq "jazz")){$ExpectedServerCount = "36"}
}

elseif($ServerType -eq "bat")
{
$ExpectedServerCount = 4
if (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "perf") -and ($Environmentattributon -eq "cookie")){$ExpectedServerCount = "4"}
elseif (($EnvironmentName -eq "prod" -or $EnvironmentName -eq "uat2" -or $EnvironmentName -eq "mock") -and ($Environmentattributon -eq "jazz")){$ExpectedServerCount = "4"}
}


$Result = $NULL

$Result = @() 
try{

$option = New-PSSessionOption -ProxyAccessType NoProxyServer -OpenTimeout 20000
$Result += Invoke-Command -ComputerName $ServerList -SessionOption $option -ErrorAction Continue -HideComputerName -ScriptBlock {

param ($MasterHashSetupCI, $MasterHashRunccCI, $MasterHashSetupCIPy, $MasterHashSetUp, $MasterHashCoreAuthSetup, $MasterHashRunccCoreAuth, $MasterHashCoreIssueAboutDSL, $MasterHashCoreAuthAboutDSL, $MasterDSLsHash, $MasterBatchScriptsHash, $MasterPlatformVersionHash)

$computername = hostname

    $ServerHashSetupCI = $MasterHashSetupCI -eq (Get-FileHash D:\DBBSetup\BatchScripts\CoreIssue\SetupCI.bat).Hash
    $ServerHashRunccCI = $MasterHashRunccCI -eq (Get-FileHash D:\DBBSetup\BatchScripts\CoreIssue\RunccCI.bat).Hash
    $ServerHashSetupCIPy = $MasterHashSetupCIPy -eq (Get-FileHash D:\DBBSetup\BatchScripts\CoreIssue\SetupCIPy.ini).Hash
    $ServerHashSetUp = $MasterHashSetUp -eq (Get-FileHash D:\DBBSetup\BatchScripts\CoreIssue\SetUp.py).Hash
    $ServerHashCoreAuth = $MasterHashCoreAuthSetup -eq (Get-FileHash D:\DBBSetup\BatchScripts\CoreAuth\CoreAuthSetup.bat).Hash
    $ServerHashRunccCoreAuth = $MasterHashRunccCoreAuth -eq (Get-FileHash D:\DBBSetup\BatchScripts\CoreAuth\RunccCoreAuth.bat).Hash
    $ServerHashCoreIssueAboutDSL = $MasterHashCoreIssueAboutDSL -eq (Get-FileHash D:\DBBSetup\DSLs\CI\About.DSL).Hash
    $ServerHashCoreAuthAboutDSL = $MasterHashCoreAuthAboutDSL -eq (Get-FileHash D:\DBBSetup\DSLs\CoreAuth\About.DSL).Hash
    $ServerDSLsHash = $NULL
    (Get-ChildItem -Path D:\DBBSetup\DSLs\ -Recurse -Filter *.DSL | Get-FileHash).Hash | %{ $ServerDSLsHash += "$_"}  
    $DSLs_stream = [IO.MemoryStream]::new([byte[]][char[]]$ServerDSLsHash)
    $ServerDSLsHash = $MasterDSLsHash -eq (Get-FileHash -InputStream $DSLs_stream).Hash

    $ServerBatchScriptsHash = $NULL
    (Get-ChildItem -Path D:\DBBSetup\BatchScripts\ -Recurse -Filter *.bat | Get-FileHash).Hash | %{ $ServerBatchScriptsHash += "$_"}  
    $BatchScripts_stream = [IO.MemoryStream]::new([byte[]][char[]]$ServerBatchScriptsHash)
    #$ServerBatchScriptsHash = (Get-FileHash -InputStream $BatchScripts_stream).Hash
    $ServerBatchScriptsHash = $MasterBatchScriptsHash -eq (Get-FileHash -InputStream $BatchScripts_stream).Hash
    $ServerHashPlatformVersion = $MasterPlatformVersionHash -eq (Get-FileHash D:\CC_runtime\appsys30.DSL).Hash
    



$resultvalue = @() 
$resultvalue = [PSCustomObject] @{ 
    ServerName = "$($computername)"
    ServerHashSetupCI = "$($ServerHashSetupCI)"
    ServerHashRunccCI = "$($ServerHashRunccCI)"
    ServerHashSetupCIPy = "$($ServerHashSetupCIPy)"
    ServerHashSetUp = "$($ServerHashSetUp)"
    ServerHashCoreAuth = "$($ServerHashCoreAuth)"
    ServerHashRunccCoreAuth = "$($ServerHashRunccCoreAuth)"
    ServerHashCoreIssueAboutDSL = "$($ServerHashCoreIssueAboutDSL)"
    ServerHashCoreAuthAboutDSL = "$($ServerHashCoreAuthAboutDSL)"
    ServerDSLsHash = "$($ServerDSLsHash)"
    ServerBatchScriptsHash = "$($ServerBatchScriptsHash)"
    ServerHashPlatformVersion = "$($ServerHashPlatformVersion)"
	}
$resultvalue


  } -ArgumentList $MasterHashSetupCI, $MasterHashRunccCI, $MasterHashSetupCIPy, $MasterHashSetUp, $MasterHashCoreAuthSetup, $MasterHashRunccCoreAuth, $MasterHashCoreIssueAboutDSL, $MasterHashCoreAuthAboutDSL, $MasterDSLsHash, $MasterBatchScriptsHash, $MasterPlatformVersionHash
}Catch{
Write-Host "ERROR in $PSComuotername"
}

$Result #| Format-Table

#$Result | Where-Object {$_.ServerName -eq "CCSVCE1PERFB30"}

#Read-Host "Type"

if($ServerList.Count -eq $ExpectedServerCount)
{
    $Outputreport += "</Table>
    <font color =""#4682B4"" face=""Microsoft Tai le"">
   <H2>  File Comparision - $($ServerType.ToUpper()) - Server Count $($ServerList.count) </H2></font>"


}else{
$Outputreport += "</Table>
                 <font color =""#CD5C5C"" face=""Microsoft Tai le"">
                    <H2>  File Comparision - $($ServerType.ToUpper()) - Server Count $($ServerList.count) is not matching with expected count $ExpectedServerCount </H2></font>"
}




   $Outputreport += "<Table border=1 cellpadding=0 cellspacing=0>
   <TR bgcolor=gray align=center>
     <TD><B>Server Name</B></TD>
     <TD><B>SetupCI.bat</B></TD>
     <TD><B>RunccCI.bat</B></TD>
     <TD><B>SetupCIPy.ini</B></TD>
     <TD><B>SetUp.py</B></TD>
     <TD><B>CoreAuthSetup.bat</B></TD>
     <TD><B>RunccCoreAuth.bat</B></TD>
     <TD><B>CoreIssue About.DSL</B></TD>
     <TD><B>CoreAuth About.DSL</B></TD>
     <TD><B>*.DSLs</B></TD>
     <TD><B>*.BAT</B></TD>
     <TD><B>Platform Version</B></TD>
     </TR>"



  Foreach($ServerEntry in $ServerList) 

    { try{
    $Entry = $NULL

   $Entry =  $Result | Where-Object {$_.ServerName -eq $ServerEntry}

           if(  [Boolean]::Parse($Entry.ServerHashSetupCI) `
           -and [Boolean]::Parse($Entry.ServerHashRunccCI) `
           -and [Boolean]::Parse($Entry.ServerHashSetupCIPy) `
           -and [Boolean]::Parse($Entry.ServerHashSetUp) `
           -and [Boolean]::Parse($Entry.ServerHashCoreAuth) `
           -and [Boolean]::Parse($Entry.ServerHashRunccCoreAuth) `
           -and [Boolean]::Parse($Entry.ServerHashCoreIssueAboutDSL) `
           -and [Boolean]::Parse($Entry.ServerHashCoreAuthAboutDSL) `
           -and [Boolean]::Parse($Entry.ServerDSLsHash) `
           -and [Boolean]::Parse($Entry.ServerBatchScriptsHash) `
           -and [Boolean]::Parse($Entry.ServerHashPlatformVersion))
           {
           $Outputreport += "<TR align=center>" 
           }else{
           $Outputreport += "<TR bgcolor=LightSalmon align=center>"
           }
           $Outputreport += "<TD>$ServerEntry</TD>
                             <TD>$($Entry.ServerHashSetupCI)</TD>
                             <TD>$($Entry.ServerHashRunccCI)</TD>
                             <TD>$($Entry.ServerHashSetupCIPy)</TD>
                             <TD>$($Entry.ServerHashSetUp)</TD>
                             <TD>$($Entry.ServerHashCoreAuth)</TD>
                             <TD>$($Entry.ServerHashRunccCoreAuth)</TD>
                             <TD>$($Entry.ServerHashCoreIssueAboutDSL)</TD>
                             <TD>$($Entry.ServerHashCoreAuthAboutDSL)</TD>
                             <TD>$($Entry.ServerDSLsHash)</TD>
                             <TD>$($Entry.ServerBatchScriptsHash)</TD>
                             <TD>$($Entry.ServerHashPlatformVersion)</TD></TR>"
    
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
                             <TD>Problem</TD>
                             <TD>Problem</TD></TR>"


        }
        
        }


Clear-Variable ServerType
Clear-Variable ServerList
Clear-Variable ExpectedServerCount
Clear-Variable Result
}



$Outputreport += "</Table></BODY></HTML>" 

$ReportFile = "C:\Temp\SetupFiles_Validation_$(Get-Date -Format yyyy-MM-dd-hhmm).html"
$Outputreport | out-file "$ReportFile"
Invoke-Item $ReportFile

Clear-Variable ServerTypes
Clear-Variable ThisServer
Clear-Variable Region
Clear-Variable ShortRegion
Clear-Variable AWSVarialbes
Clear-Variable Environmentattributon
Clear-Variable EnvironmentStack
Clear-Variable MasterServerType
Clear-Variable EnvironmentName
Clear-Variable MasterHost
Clear-Variable Outputreport
Clear-Variable SetupFileList
Clear-Variable SetupCIEnvVarialbeList
Clear-Variable CoreAuthSetupEnvVarialbeList
Clear-Variable AboutDSLVarialbeList
Clear-Variable MasterHashSetupCI
Clear-Variable MasterHashRunccCI
Clear-Variable MasterHashSetupCIPy
Clear-Variable MasterHashCoreAuthAboutDSL
Clear-Variable MasterHashSetUp
Clear-Variable MasterHashCoreAuthSetup
Clear-Variable MasterHashRunccCoreAuth
Clear-Variable MasterHashCoreIssueAboutDSL
Clear-Variable MasterHashCoreAuthAboutDSL
Clear-Variable MasterDSLsHash
Clear-Variable MasterBatchScriptsHash
Clear-Variable MasterPlatformVersionHash