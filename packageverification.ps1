Clear-Host

#32 Files Should be present in the package-
$package = read-host "Enter the package path" 
$folders = Get-ChildItem -Path $package -Directory | Select-Object -ExpandProperty Name 
write-host -ForegroundColor Yellow "Folder list:" 
$folders
echo "----------------------------"
$folderCounts = $folders.Length
Write-Host "Folder Counts: $folderCounts"

$expectedFolders = @(
    "BatchScripts",
    "CC_Python",
    "Corecard_Services",
    "CoreCredit",
    "DSLs",
    "PlatformCode",
    "ReportDelivery",
    "ReportServer",
    "TraceFiles",
    "Translate",
    "WCFServer",
    "WebServer"
)

$containsAllFolders = $expectedFolders | ForEach-Object {
    $folders -contains $_
}

if ($folderCounts -eq 15 -and $containsAllFolders) {
    Write-Host -ForegroundColor Green "All expected folders are present."
} else {
    Write-Host -ForegroundColor Red "One or more expected folders are missing."
}


echo "**************************************************************************"
#Batchscripts
Write-Host -ForegroundColor Yellow "Batchscripts/Setup.bat-" 
Write-host "emKMSdefaultMachines tag of coreauthsetup.config file-"
$Coreauthsetup = (Select-String -Path "$package\BatchScripts\CoreAuth\CoreAuthSetup.bat" -Pattern "SET emKMSdefaultMachines").ToString().Split('=')[1]
$CoreIssuesetup = (Select-String -Path "$package\BatchScripts\CoreIssue\SetupCI.bat" -Pattern "SET emKMSdefaultMachines").ToString().Split('=')[1]

if ($Coreauthsetup -match "CCKMS<SHORTREGION><ENV><STACK>*")
{
    Write-Host -ForegroundColor Green "KMS value of Coreauthsetup :$Coreauthsetup"
}
else
{
    Write-Host -ForegroundColor Red "Need to check value of KMS servers"
}

if ($CoreIssuesetup -match "CCKMS<SHORTREGION><ENV><STACK>*")
{
    Write-Host -ForegroundColor Green "KMS value of Coreissuesetup :$CoreIssuesetup"
}
else
{
    Write-Host -ForegroundColor Red "Need to check value of KMS servers"
}

Clear-Variable Coreauthsetup
Clear-Variable CoreIssuesetup

echo "**************************************************************************"
#SetupCIPy.ini
$SetupCIPy = (Select-String -Path "$package\BatchScripts\CoreIssue\SetupCIPy.ini" -Pattern "POD = ").ToString().Split('=')[1] -replace '[" >]',''
$emKMSdefaultMachines = (Select-String -Path "$package\BatchScripts\CoreIssue\SetupCIPy.ini" -Pattern "emKMSdefaultMachines")[0].ToString().Split('=')[1]
$emKMSdefaultMachinesDR = (Select-String -Path "$package\BatchScripts\CoreIssue\SetupCIPy.ini" -Pattern "emKMSdefaultMachinesDR").ToString().Split('=')[1]
$SetupPy = (Select-String -Path "$package\BatchScripts\CoreIssue\SetUp.py" -Pattern "POD = ")[1].ToString().Split('=')[1] -replace '[" >]',''

Write-Host -ForegroundColor Yellow "Batchscripts/SetupCIPy.ini"

Write-Host "Define POD number (according to the POD) .ie. POD = 2-"

if (($SetupCIPy -match "2") -or ($SetupCIPy -match "3")){
    Write-Host -ForegroundColor Green "Define POD number of SetupCIPy :$SetupCIPy"}
else{Write-Host -ForegroundColor Red "Need to check Define POD number"}

if (($emKMSdefaultMachinesDR -match "CCKMSw2*") -and ($emKMSdefaultMachines -match "CCKMSe1*"))  {

Write-Host -ForegroundColor Yellow "emKMSdefaultMachine:"
Write-Host -ForegroundColor Green "$emKMSdefaultMachines"
Write-Host -ForegroundColor Yellow "emKMSdefaultMachineDR:" 
Write-Host -ForegroundColor Green "$emKMSdefaultMachinesDR"

}else
{
    Write-Host -ForegroundColor Red "Need to check emKMSdefaultMachines"
}

Write-Host -ForegroundColor Yellow "Batchscripts/Setup.Py"
if (($SetupPy -match "2") -or ($SetupPy -match "3")){
    Write-Host -ForegroundColor Green "Define POD number of SetupPy :$SetupPy"}
else{Write-Host -ForegroundColor Red "Need to check Define POD number"}

Clear-Variable SetupCIPy
Clear-Variable SetupPy
Clear-Variable emKMSdefaultMachines
Clear-Variable emKMSdefaultMachinesDR

echo "**************************************************************************"
#CC_Python

Write-Host -ForegroundColor Yellow "CC_Python"
#$CC_Pythonfiles = Get-ChildItem -Path $package\CC_Python\ | Select-Object -ExpandProperty Name
#$CC_Pythonfiles

$PythonfilesCounts = $CC_Pythonfiles.Length
write-host -ForegroundColor Green "Pythonfiles Counts: $PythonfilesCounts"

$CC_Pythonverion = (Get-Command $package\CC_Python\python.exe).FileVersionInfo.FileVersion

write-host -ForegroundColor Green "Python Verion: $CC_Pythonverion"

echo "**************************************************************************"
#CoreCredit
Write-Host  -ForegroundColor Yellow "Corecredit JSFileVersion"
$JSFileVersion = (Select-String -Path "$package\CoreCredit\Web.config" -Pattern "JSFileVersion").ToString().Split('=')[2] -replace '[" />]',''
$JSFileVersion

write-host -ForegroundColor Yellow "Report server Url placeholder name"
$ReportServerPath = (Select-String -Path "$package\CoreCredit\Web.config" -Pattern "ReportServerPath").ToString().Split('=')[2] -replace '[" />]',''
$ReportServerPath

$LetterServerPath = (Select-String -Path "$package\CoreCredit\Web.config" -Pattern "LetterServerPath").ToString().Split('=')[2] -replace '[" />]',''
$LetterServerPath


write-host -ForegroundColor Yellow "WCF Url placeholder name on the web.config"
$WCFCUSTOMERSERVICEURL = (Select-String -Path "$package\CoreCredit\Web.config" -Pattern "endpoint address")[0].ToString().Split('"')[1] -replace '["]'
$WCFCUSTOMERSERVICEURL

$WCFDBBSERVICEURL = (Select-String -Path "$package\CoreCredit\Web.config" -Pattern "endpoint address")[1].ToString().Split('"')[1] -replace '["]'
$WCFDBBSERVICEURL
write-host -ForegroundColor Yellow " APIUser placeholder name on the web.config"
$APIUserID = (Select-String -Path "$package\CoreCredit\Web.config" -Pattern "APIUserID")[0].ToString().Split('=')[2] -replace '[" />]',''
$APIUserID

$APIUserPassword = (Select-String -Path "$package\CoreCredit\Web.config" -Pattern "APIUserPassword").ToString().Split('=')[2] -replace '[" />]',''
$APIUserPassword
write-host -ForegroundColor Yellow " Access-Control-Allow-Origin placeholder name on the web.config"
$AccessControlAllowOrigin = (Select-String -Path "$package\CoreCredit\Web.config" -Pattern "Access-Control-Allow-Origin")[0].ToString().Split('=')[2] -replace '[" />]',''
$AccessControlAllowOrigin

#Samlsso.config
write-host -ForegroundColor Yellow "Samlsso placeholder name on the web. config"
$ServiceProvider = (Select-String -Path "$package\CoreCredit\samlsso.config" -Pattern "ServiceProvider Name")[0].ToString().Split('=')[1]  -replace '[" >]',''
$ServiceProvider
$TrustedIdentityProvider = (Select-String -Path "$package\CoreCredit\samlsso.config" -Pattern "TrustedIdentityProvider Name")[0].ToString().Split('=')[1]  -replace '[" >]',''
$TrustedIdentityProvider

#CreditCloudStatementing
write-host -ForegroundColor Yellow "wfKafkaStatementing version"
$wfKafkaStatementingversion = (Get-Command $package\CreditCloudStatementing\wfKafkaStatementing\wfKafkaStatementing.exe).FileVersionInfo.FileVersion
$wfKafkaStatementingversion

#DataBasePackage_Core
write-host -ForegroundColor Yellow "DataBasePackage_Core version"
$DataBasePackage_Core =(Select-String -Path "F:\Package\DataBasePackage_Core\1\Core\DataBaseServer\3.Updates\4.CoreIssue\Version.Sql" -Pattern "pr_version_ins")

$DataBasePackage_Core

#DSLs
write-host -ForegroundColor Yellow "DSL version-"
$DSLverioncoreissue = (Select-String -Path "$package\DSLs\CI\About.DSL" -Pattern "CreditProcessing")[0].ToString().Split('"')[1]
Write-host "CoreIssue DSL version: $DSLverion"
$DSLverioncoreauth = (Select-String -Path "$package\DSLs\CoreAuth\About.DSL" -Pattern "CreditProcessing").ToString().Split('"')[1]
Write-host "CoreAuth DSL version: $DSLverion"
write-host -ForegroundColor Yellow "Platform version-"
$platfromverion = (Select-String -Path "$package\PlatformCode\appsys30.dsl" -Pattern "Application Release")[0].ToString().Split('"')[1]
$platfromverion

$pemfiles = (Get-ChildItem F:\Package\PlatformCode\*.pem).name
Write-host -ForegroundColor Yellow "Pem files count-"
$pemfiles
$pemfilescount = $pemfiles.Count
write-host -ForegroundColor Yellow "Pem File counts: $pemfilescount"

write-host -ForegroundColor Yellow "Rundbb exe counts-"
$DbbAppServer = (Get-ChildItem $package\PlatformCode\DbbAppServer*)
$DbbAppServercounts= $DbbAppServer.Length
Write-Host "DbbAppServer exe counts: $DbbAppServercounts"


$Rundbb = (Get-ChildItem $package\PlatformCode\Rundbb*)
$Rundbbcounts = $Rundbb.Length
Write-Host "Rundbb exe counts: $Rundbbcounts"

#ReleaseItem
#ReportDelivery
write-host -ForegroundColor Yellow "ReportDelivery version-"
$ReportDeliveryversion = (Get-Command $package\ReportDelivery\ReportDelivery\WFRunReports.exe).FileVersionInfo.FileVersion
$ReportDeliveryversion

write-host -ForegroundColor Yellow "data feeds and data reports-"
$DataFeed = Get-ChildItem F:\Package\ReportDelivery\DataFeed\*.vbs
$DataFeedcounts = $DataFeed.Length
Write-Host "DataFeed file counts: $DataFeedcounts"

$DataReports = (Get-ChildItem F:\Package\ReportDelivery\DataReports\*.bat)
$DataReportscounts = $DataReports.Length
Write-Host "DataReports file counts: $DataReportscounts"

write-host -ForegroundColor Yellow "RDLs files-"
$RDLCoreCreditReports = (Get-ChildItem F:\Package\ReportServer\CoreCreditReports -Directory)
$RDLCoreCreditReportscounts = $RDLCoreCreditReports.Length
Write-Host "RDL CoreCreditReports file counts: $RDLCoreCreditReportscounts"

$RDLCoreIssueReports = (Get-ChildItem F:\Package\ReportServer\CoreIssueReports -Directory)
$RDLCoreIssueReportscounts = $RDLCoreIssueReports.Length
Write-Host "RDL CoreIssueReports file counts: $RDLCoreIssueReportscounts"

#CoreCardServicesversion
write-host -ForegroundColor Yellow "CoreCardServices version-"
$CoreCardServicesversion = (Get-Command F:\Package\WCFServer\CoreCardServices\bin\CC.HP.Api.dll).FileVersionInfo.FileVersion
$CoreCardServicesversion

#WCF
write-host -ForegroundColor Yellow "WCF version-"

$wcfesversion = (Get-Command F:\Package\WCFServer\WCF\bin\CC.CoreServices.Web.dll).FileVersionInfo.FileVersion
$wcfesversion
write-host -ForegroundColor Yellow "KMSDefaultMachines value in appSettings.config-"
$wcfKMSDefaultMachines = (Select-String -Path "F:\Package\WCFServer\WCF\configuration\appSettings.config" -Pattern "KMSDefaultMachines").ToString().Split('=')[2]  -replace '[" /]',''
$wcfKMSDefaultMachines
write-host -ForegroundColor Yellow "dbbHandlerRoot value in appSettings.config-"
$wcfdbbHandlerRoot = (Select-String -Path "F:\Package\WCFServer\WCF\configuration\appSettings.config" -Pattern "dbbHandlerRoot").ToString().Split('=')[2]  -replace '[" /]',''
$wcfdbbHandlerRoot

