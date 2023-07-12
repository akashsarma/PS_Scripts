Clear-Host
#Run below command first if ExecutionPolicy is restricted
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

Write-Host "Finding IP Address of Machine"
$IPAddress = (Resolve-DnsName $env:COMPUTERNAME | Where-Object {$_.Type -eq "A" -and  ($_.IpAddress -Match "10.2" -or $_.IpAddress -Match "172.1")}).IPAddress
Write-Host "IP Address:" $IPAddress

If($IPAddress -match "10.2")
{
Write-Host "Location : Bhopal"

$IPAddress

$PackagePath = "\\VMPACKAGE03\PLAT_SETUP_PACKAGE"

$DomainUsername = "NEWVISIONSOFT\configuser"

$DomainUserpassword = "C0nf!gus3r"

$SQLServer = "Xeon-S9"

}

ElseIf($IPAddress -match "172.1")
{
$IPAddress

Write-Host "Location : Mumbai"

$PackagePath = "\\172.16.0.173\PLAT_SETUP_PACKAGE"

$DomainUsername = "NEWVISIONSOFTM\configuser"

$DomainUserpassword = "Welcome@123"

$SQLServer = "XEON-M2"
}
else{Write-Host "Invalid Location or IP"
Break Script
}




$WebServerPath = "D:\WebServer"

$WebLogsPath = "D:\LOGs"

$PrerequisitesPath = "D:\Prerequisites"

$DBBSetupPath = "D:\DBBSetup"

$DBBTracePath = "D:\TraceFiles"

$DBBPlatformPath = "D:\CC_Runtime"

$CCPythonPath = "D:\CC_Python"





#Add configuser in local administrator group
Write-Host "Adding Configuser in Administrators"
If((Get-LocalGroupMember -Name Administrators | Where-Object Name -eq $DomainUsername) -eq $NULL){
Add-LocalGroupMember -Group "Administrators" -Member $DomainUsername
}



#$IPAddress = (Resolve-DnsName $env:COMPUTERNAME | Where-Object {$_.Type -eq "A" -and  ($_.IpAddress -Match "10.2" -or $_.IpAddress -Match "172.1")}).IPAddress

#$IPAddress = (Resolve-DnsName $env:COMPUTERNAME | Where-Object Type -eq "A" |  Where-Object IpAddress -Match "10.2").IpAddress

# Stop Processes if running
Write-Host "Stopping DBB processes if running"
$ProcessTasksListNames  = 'DbbAppServer*', 'Rundbb*', 'tview*'
Get-Process -Name $ProcessTasksListNames | Stop-Process -Force


#Directory Structure
Write-Host "Deleting Setup folders if already exists"
if(!(Test-Path -Path $PackagePath)){Write-Host "Unable to access package folder, please verify manually and try again - " $PackagePath
Break Script}

if(Test-Path -Path $WebServerPath){Remove-Item -Force -Path $WebServerPath -Recurse}
if(Test-Path -Path $WebLogsPath){Remove-Item -Force -Path $WebLogsPath -Recurse}
if(Test-Path -Path $PrerequisitesPath){Remove-Item -Force -Path $PrerequisitesPath -Recurse}
if(Test-Path -Path $DBBSetupPath){Remove-Item -Force -Path $DBBSetupPath -Recurse}
if(Test-Path -Path $DBBTracePath){Remove-Item -Force -Path $DBBTracePath -Recurse}
if(Test-Path -Path $DBBPlatformPath){Remove-Item -Force -Path $DBBPlatformPath -Recurse}
if(Test-Path -Path $CCPythonPath){Remove-Item -Force -Path $CCPythonPath -Recurse}

if((Test-Path -Path $WebServerPath) -or (Test-Path -Path $WebLogsPath) -or (Test-Path -Path $PrerequisitesPath) -or (Test-Path -Path $DBBSetupPath) -or (Test-Path -Path $DBBTracePath) -or (Test-Path -Path $DBBPlatformPath) -or (Test-Path -Path $CCPythonPath)){Write-Host "Unable to delete the folders, please remove manually and try again - "`n $WebLogsPath `n $PrerequisitesPath `n $DBBSetupPath `n $DBBTracePath `n $DBBPlatformPath `n $CCPythonPath
Break Script}

Write-Host "Creating Setup Folders"
New-Item -ItemType Directory -Force -Path "$WebServerPath"
New-Item -ItemType Directory -Force -Path "$WebServerPath\DBBWEB\"
New-Item -ItemType Directory -Force -Path "$WebServerPath\WCF\"
New-Item -ItemType Directory -Force -Path "$WebServerPath\CoreCardServices\"
New-Item -ItemType Directory -Force -Path "$WebServerPath\CoreCredit\"
New-Item -ItemType Directory -Force -Path "$WebLogsPath"
New-Item -ItemType Directory -Force -Path "$WebLogsPath\ServicesHandlerLogs"
New-Item -ItemType Directory -Force -Path "$WebLogsPath\HandlerLogs"

New-Item -ItemType Directory -Force -Path "$PrerequisitesPath"

New-Item -ItemType Directory -Force -Path "$DBBSetupPath"
New-Item -ItemType Directory -Force -Path "$DBBSetupPath\DSLs"
New-Item -ItemType Directory -Force -Path "$DBBSetupPath\DSLs"
New-Item -ItemType Directory -Force -Path "$DBBTracePath"
New-Item -ItemType Directory -Force -Path "$DBBPlatformPath"
New-Item -ItemType Directory -Force -Path "$CCPythonPath"



#Copy Prerequisites
Write-Host "Copying Prerequisites"
robocopy $PackagePath\Prerequisites\ $PrerequisitesPath /e 

#IIS Installation
Write-Host "Installing IIS"
#Install-WindowsFeature -ConfigurationFilePath $PrerequisitesPath\IIS\DeploymentConfigTemplate.xml
#Install-WindowsFeature -ConfigurationFilePath $PrerequisitesPath\IIS\WCF-DeploymentConfigTemplate.xml

Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole,
IIS-WebServer,
IIS-CommonHttpFeatures,
IIS-HttpErrors,
IIS-ApplicationDevelopment,
IIS-Security,
IIS-RequestFiltering,
IIS-NetFxExtensibility45,
IIS-HealthAndDiagnostics,
IIS-HttpLogging,
IIS-Performance,
IIS-HttpCompressionDynamic,
IIS-WebServerManagementTools,
IIS-ManagementScriptingTools,
IIS-StaticContent,
IIS-DefaultDocument,
IIS-ApplicationInit,
IIS-ASPNET45,
IIS-ISAPIExtensions,
IIS-ISAPIFilter,
IIS-HttpCompressionStatic,
IIS-ManagementConsole,
IIS-ManagementService,
NetFx4-AdvSrvs,
NetFx4Extended-ASPNET45,
WAS-WindowsActivationService,
WAS-ProcessModel,
WAS-ConfigurationAPI,
WCF-Services45,
WCF-HTTP-Activation45 -NoRestart



#Prerequisites Installation
Write-Host "Installing ARR"
$ARRFilePath= "$PrerequisitesPath\ARRv3_setup_amd64_en-us.exe"
$ARRsilent= '/Q'
$ARRPSpath= "MACHINE/WEBROOT/APPHOST"
$ARRFilter= "/system.webServer/proxy"
Try{
    Write-Host "starting arr installation"
    Start-Process -FilePath $ARRFilePath -ArgumentList $ARRsilent -Wait -NoNewWindow
    Write-Host "configure arr"
    start-sleep -s 30
    Set-WebConfigurationProperty -pspath $ARRPSpath -filter $ARRFilter -name "." -value @{enabled="true"}
    Write-Host "arr installation complete"
}
Catch{
    Write-Host $_
        #Exit 1
}

Write-Host "Installing ODBC Driver 17"
Start-Process -Filepath "msiexec.exe" -ArgumentList "/i $PrerequisitesPath\Microsoft_SQL_Server_ODBC_Driver_17.3.1.1_x64.msi", "/qb", "IACCEPTMSODBCSQLLICENSETERMS=YES", "/norestart" -Wait -NoNewWindow

Write-Host "Installing VC Redistribuatable 2013"
Start-Process -FilePath $PrerequisitesPath\vcredist_x86_2013.exe -ArgumentList /Q, /norestart -Wait -NoNewWindow

Write-Host "Installing VC Redistribuatable 2015-2022"
Start-Process -FilePath $PrerequisitesPath\vc_redist.x86_2015-2022.exe -ArgumentList /Q, /norestart -Wait -NoNewWindow

Write-Host "Installing ODBC Driver 13"
Start-Process -Filepath "msiexec.exe" -ArgumentList "/i $PrerequisitesPath\msodbcsql_ODBC_Driver_13_X64.msi", "/qb", "IACCEPTMSODBCSQLLICENSETERMS=YES", "/norestart" -Wait -NoNewWindow

Write-Host "Installing SQL Server Native Client 11"
Start-Process -Filepath "msiexec.exe" -ArgumentList "/i $PrerequisitesPath\SQLServer_Native_Client_11.0_X64.msi", "/qb", "IACCEPTSQLNCLILICENSETERMS=YES", "/norestart" -Wait -NoNewWindow

Write-Host "Removing ODBC DSNs"
Remove-OdbcDsn  -Name "*" -DsnType System

Remove-OdbcDsn -Name "*" -DsnType "System" -Platform "32-bit"

Remove-OdbcDsn -Name "*" -DsnType "System" -Platform "64-bit"

Write-Host "Adding ODBC DSNs"
Add-OdbcDsn -Name $SQLServer -DriverName "ODBC Driver 17 for SQL Server" -DsnType System -Platform "32-bit" -SetPropertyValue @("Server=$SQLServer", "Description=$SQLServer", "Encrypt=No", "TrustServerCertificate=No", "Trusted_Connection=Yes", "MultiSubnetFailover=Yes")



#Certificate Import
Write-Host "Importing Certificate"
$certificate = Import-PfxCertificate -FilePath "$PrerequisitesPath\Certificate\corecard.in.pfx" -Exportable -Password (ConvertTo-SecureString "!QA2ws11" -AsPlainText -Force) -CertStoreLocation  "Cert:\LocalMachine\My"


#Add Entry in Host file
Write-Host "Adding entry in host file"
$HostEntry = "$IPAddress	$env:COMPUTERNAME.corecard.in" 
"$HostEntry`r`n" | Out-File "C:\Windows\System32\drivers\etc\hosts" -Encoding ascii -Append




# User Inputs
#$LabelLocation = "\\xeon-s8\Labels_PlatAndJazz\Plat_S83_22.6.1_PLAT"
Write-Host "User Inputs"

$Project = $NULL
$Project = Read-Host "Type PLAT or JAZZ and press enter"

$LabelLocation = $NULL
$LabelLocation = Read-Host "Type / Copy Label Location and Press enter (Like \\xeon-s8\Labels_PlatAndJazz\Plat_S83_22.6.1_PLAT)"

$KMSServersName = $NULL
$KMSServersName = Read-Host "Type KMS Servers Name (space sepatated if multiple) - (Like IOJAZZQAKMS01)"


$SQLServer = $NULL
$SQLServer = Read-Host "Type SQL Server Name (Like Xeon-S9)"

$CurrentUser = whoami

Read-Host "Please make sure USER $CurrentUser have sufficent permission in $SQLServer SQL Server to create and restore Database and then press enter"

If ($Project.ToUpper() -eq "PLAT"){$ClientNameValue = "Plat-Cookie"}
elseIf ($Project.ToUpper() -eq "JAZZ"){$ClientNameValue = "Jazz-Card"}

#File Copy
Write-Host "Copying Package and Label"
robocopy $PackagePath\DBBSetup\ D:\DBBSetup\ /e

robocopy $PackagePath\TraceFiles\ $DBBTracePath\ /e

robocopy $PackagePath\CC_Runtime\ $DBBPlatformPath\ /e

robocopy $PackagePath\CC_Python\ $CCPythonPath\ /e

robocopy $LabelLocation\Application\DSL\ $DBBSetupPath\DSLs\ /e 

robocopy $PackagePath\WebServer\ D:\WebServer\ /e

robocopy $LabelLocation\Application\PublishCode\CoreServices\ D:\WebServer\WCF\ /e 

robocopy $LabelLocation\Application\PublishCode\CoreCardServices\ D:\WebServer\CoreCardServices\ /e 

robocopy $LabelLocation\Application\PublishCode\CoreCredit\ D:\WebServer\CoreCredit\ /e 

robocopy "$PrerequisitesPath\PowerShell_Modules\" "C:\Program Files\WindowsPowerShell\Modules" /e

Write-Host "Renaming FULL config files"

if(Test-Path -Path $WebServerPath\WCF\Web_FULL.config){Move-Item -Path "$WebServerPath\WCF\Web_FULL.config" -Destination "$WebServerPath\WCF\Web.config" -Force} 

if(Test-Path -Path $WebServerPath\WCF\log4net_FULL.config){Move-Item -Path "$WebServerPath\WCF\log4net_FULL.config" -Destination "$WebServerPath\WCF\log4net.config" -Force}

if(Test-Path -Path $WebServerPath\WCF\configuration\appSettings_FULL.config){Move-Item -Path "$WebServerPath\WCF\configuration\appSettings_FULL.config" -Destination "$WebServerPath\WCF\configuration\appSettings.config" -Force}

if(Test-Path -Path $WebServerPath\WCF\configuration\connectionStrings_FULL.config){Move-Item -Path "$WebServerPath\WCF\configuration\connectionStrings_FULL.config" -Destination "$WebServerPath\WCF\configuration\connectionStrings.config" -Force}

if(Test-Path -Path $WebServerPath\CoreCardServices\connectionStrings_FULL.config){Move-Item -Path "$WebServerPath\CoreCardServices\connectionStrings_FULL.config" -Destination "$WebServerPath\CoreCardServices\connectionStrings.config" -Force}

if(Test-Path -Path $WebServerPath\CoreCardServices\Web_FULL.config){Move-Item -Path "$WebServerPath\CoreCardServices\Web_FULL.config" -Destination "$WebServerPath\CoreCardServices\Web.config" -Force}

if(Test-Path -Path $WebServerPath\CoreCredit\log4net_FULL.config){Move-Item -Path "$WebServerPath\CoreCredit\log4net_FULL.config" -Destination "$WebServerPath\CoreCredit\log4net.config" -Force}

if(Test-Path -Path $WebServerPath\CoreCredit\Web_FULL.config){Move-Item -Path "$WebServerPath\CoreCredit\Web_FULL.config" -Destination "$WebServerPath\CoreCredit\Web.config" -Force}




#IIS Sites Configuration
Write-Host "IIS Sites Configuration"

Import-Module WebAdministration

Remove-Website -Name "*" 
Remove-WebAppPool -Name "*"
New-WebAppPool -Name "WebServer" -Force
Set-ItemProperty "IIS:\AppPools\WebServer" -name managedRuntimeVersion "v4.0"
Set-ItemProperty "IIS:\AppPools\WebServer" -name managedPipelineMode "Integrated"
Set-ItemProperty "IIS:\AppPools\WebServer" -name processModel -value @{userName = $DomainUsername; password = $DomainUserpassword; identitytype = 3 }
Set-ItemProperty "IIS:\AppPools\WebServer" -Name enable32BitAppOnWin64 -Value 'false'

New-WebSite -Name "WebServer" -Port 80 -PhysicalPath $WebServerPath -ApplicationPool WebServer -IPAddress $IPAddress
New-WebBinding -Name "WebServer" -IPAddress $IPAddress -Port 443 -Protocol https -SslFlags 0
$binding = (Get-WebBinding -Name "WebServer" -Protocol "https")
$binding.AddSslCertificate($certificate.Thumbprint, "My") 
Set-WebConfigurationProperty system.webServer/security/authentication/anonymousauthentication -PSPath 'IIS:\' -Location "Webserver" -Name userName -Value "" -Verbose

New-WebAppPool -Name "DBBWEB" -Force
Set-ItemProperty "IIS:\AppPools\DBBWEB" -name managedRuntimeVersion "v4.0"
Set-ItemProperty "IIS:\AppPools\DBBWEB" -name managedPipelineMode "Integrated"
Set-ItemProperty "IIS:\AppPools\DBBWEB" -name processModel -value @{userName = $DomainUsername; password = $DomainUserpassword; identitytype = 3 }
Set-ItemProperty "IIS:\AppPools\DBBWEB" -Name enable32BitAppOnWin64 -Value 'false'
New-WebApplication -Name "DBBWEB" -Site "WebServer" -PhysicalPath "$WebServerPath\DBBWEB" -ApplicationPool "DBBWEB" 
Set-WebConfigurationProperty system.webServer/security/authentication/anonymousauthentication -PSPath 'IIS:\' -Location "Webserver/DBBWEB" -Name userName -Value "" -Verbose

New-WebAppPool -Name "WCF" -Force
Set-ItemProperty "IIS:\AppPools\WCF" -name managedRuntimeVersion "v4.0"
Set-ItemProperty "IIS:\AppPools\WCF" -name managedPipelineMode "Integrated"
Set-ItemProperty "IIS:\AppPools\WCF" -name processModel -value @{userName = $DomainUsername; password = $DomainUserpassword; identitytype = 3 }
Set-ItemProperty "IIS:\AppPools\WCF" -Name enable32BitAppOnWin64 -Value 'false'
New-WebApplication -Name "WCF" -Site "WebServer" -PhysicalPath "$WebServerPath\WCF" -ApplicationPool "WCF"
Set-WebConfigurationProperty system.webServer/security/authentication/anonymousauthentication -PSPath 'IIS:\' -Location "Webserver/WCF" -Name userName -Value "" -Verbose

New-WebAppPool -Name "CoreCardServices"
Set-ItemProperty "IIS:\AppPools\CoreCardServices" -name managedRuntimeVersion "v4.0"
Set-ItemProperty "IIS:\AppPools\CoreCardServices" -name managedPipelineMode "Integrated"
Set-ItemProperty "IIS:\AppPools\CoreCardServices" -name processModel -value @{userName = $DomainUsername; password = $DomainUserpassword; identitytype = 3 }
Set-ItemProperty "IIS:\AppPools\CoreCardServices" -Name enable32BitAppOnWin64 -Value 'false'
New-WebApplication -Name "CoreCardServices" -Site "WebServer" -PhysicalPath "$WebServerPath\CoreCardServices" -ApplicationPool "CoreCardServices"
Set-WebConfigurationProperty system.webServer/security/authentication/anonymousauthentication -PSPath 'IIS:\' -Location "Webserver/CoreCardServices" -Name userName -Value "" -Verbose

New-WebAppPool -Name "CoreCredit" -Force
Set-ItemProperty "IIS:\AppPools\CoreCredit" -name managedRuntimeVersion "v4.0"
Set-ItemProperty "IIS:\AppPools\CoreCredit" -name managedPipelineMode "Integrated"
Set-ItemProperty "IIS:\AppPools\CoreCredit" -name processModel -value @{userName = $DomainUsername; password = $DomainUserpassword; identitytype = 3 }
Set-ItemProperty "IIS:\AppPools\CoreCredit" -Name enable32BitAppOnWin64 -Value 'false'
New-WebApplication -Name "CoreCredit" -Site "WebServer" -PhysicalPath "$WebServerPath\CoreCredit" -ApplicationPool "CoreCredit" 
Set-WebConfigurationProperty system.webServer/security/authentication/anonymousauthentication -PSPath 'IIS:\' -Location "Webserver/CoreCredit" -Name userName -Value "" -Verbose

#Get-ItemProperty "IIS:\AppPools\DBBWEB" -name processModel 



#Create DBs and Restore
Write-Host "Creating Databases"
$masterDB = "master"
$DataBaseName = $env:COMPUTERNAME
$CoreAuthDB = $DataBaseName +"_CoreAuth"
$CoreIssueDB = $DataBaseName +"_CoreIssue"
$CoreLibraryDB = $DataBaseName +"_CoreLibrary"
$CoreCreditDB = $DataBaseName +"_CoreCredit"
$CoreAppDB = $DataBaseName +"_CoreApp"



If((Invoke-Sqlcmd -ServerInstance $SQLServer -Database $masterDB -Query ("SELECT Name FROM sys.databases where Name = '$CoreAuthDB';")) -ne $NULL ){
$CoreAuthDBCheck = Read-Host "$CoreAuthDB Database already Exist. Do you want to continue? Press Y to continue or press N and enter (Default : Y)"
If($CoreAuthDBCheck -eq "N"){Break Script}
}else{Invoke-Sqlcmd -ServerInstance $SQLServer -Database $masterDB -Query ("CREATE DATABASE $CoreAuthDB;")}

If((Invoke-Sqlcmd -ServerInstance $SQLServer -Database $masterDB -Query ("SELECT Name FROM sys.databases where Name = '$CoreIssueDB';")) -ne $NULL ){
$CoreIssueDBCheck = Read-Host "$CoreIssueDB Database already Exist. Do you want to continue? Press Y to continue or press N and enter (Default : Y)"
If($CoreIssueDBCheck -eq "N"){Break Script}
}else{Invoke-Sqlcmd -ServerInstance $SQLServer -Database $masterDB -Query ("CREATE DATABASE $CoreIssueDB;")}

If((Invoke-Sqlcmd -ServerInstance $SQLServer -Database $masterDB -Query ("SELECT Name FROM sys.databases where Name = '$CoreLibraryDB';")) -ne $NULL ){
$CoreLibraryDBCheck = Read-Host "$CoreLibraryDB Database already Exist. Do you want to continue? Press Y to continue or press N and enter (Default : Y)"
If($CoreLibraryDBCheck -eq "N"){Break Script}
}else{Invoke-Sqlcmd -ServerInstance $SQLServer -Database $masterDB -Query ("CREATE DATABASE $CoreLibraryDB;")}

If((Invoke-Sqlcmd -ServerInstance $SQLServer -Database $masterDB -Query ("SELECT Name FROM sys.databases where Name = '$CoreCreditDB';")) -ne $NULL ){
$CoreCreditDBCheck = Read-Host "$CoreCreditDB Database already Exist. Do you want to continue? Press Y to continue or press N and enter (Default : Y)"
If($CoreCreditDBCheck -eq "N"){Break Script}
}else{Invoke-Sqlcmd -ServerInstance $SQLServer -Database $masterDB -Query ("CREATE DATABASE $CoreCreditDB;")}

If((Invoke-Sqlcmd -ServerInstance $SQLServer -Database $masterDB -Query ("SELECT Name FROM sys.databases where Name = '$CoreAppDB';")) -ne $NULL ){
$CoreAppDBCheck = Read-Host "$CoreAppDB Database already Exist. Do you want to continue? Press Y to continue or press N to exit (Default : Y)"
If($CoreAppDBCheck -eq "N"){Break Script}
}else{Invoke-Sqlcmd -ServerInstance $SQLServer -Database $masterDB -Query ("CREATE DATABASE $CoreAppDB;")}



#$LabelLocation = "\\xeon-s8\Labels_PlatAndJazz\Plat_S83_22.6.1_PLAT"

#Invoke-Sqlcmd -ServerInstance $SQLServer -Database $masterDB -Query ("CREATE DATABASE $CoreAuthDB;CREATE DATABASE $CoreIssueDB;CREATE DATABASE $CoreLibraryDB;CREATE DATABASE $CoreCreditDB;CREATE DATABASE $CoreAppDB;")
Write-Host "Restoring Databases"
Invoke-Sqlcmd -ServerInstance $SQLServer -Database $masterDB -Query ("use master;exec sp_restoredb $CoreAuthDB, '<LabelLocation>\Application\DB\PLAT\CAuth.bak';exec sp_restoredb $CoreIssueDB, '<LabelLocation>\Application\DB\PLAT\CI.bak';exec sp_restoredb $CoreLibraryDB,  '<LabelLocation>\Application\DB\PLAT\CL.bak';exec sp_restoredb $CoreCreditDB,  '<LabelLocation>\Application\DB\PLAT\CoreCredit.bak';exec sp_restoredb $CoreAppDB,  '<LabelLocation>\Application\DB\PLAT\CoreApp.bak'").Replace("<LabelLocation>", $LabelLocation)

Write-Host "Executing Synonms Script"
(Get-Content $PrerequisitesPath\SQL\Synonms.sql).replace('<DataBaseName>', $DataBaseName) | Set-Content $PrerequisitesPath\SQL\Synonms.sql
Invoke-Sqlcmd -ServerInstance $SQLServer -Database $masterDB -InputFile "$PrerequisitesPath\SQL\Synonms.sql"



#Set Variables in setup and config files
Write-Host "Updating Variables in Setup/Config files"

  (Get-Content -path $DBBSetupPath\BatchScripts\CoreAuth\CoreAuthSetup.bat) `
     -replace '<PrimaryDBServerODBCNameValue>',"$SQLServer" `
     -replace '<HostMachineName>',"$env:COMPUTERNAME" `
     -replace '<KMSServersName>',"$KMSServersName" `
     -replace '<DataBaseName_CoreAuth>',"$CoreAuthDB" `
     -replace '<DataBaseName_CoreLibrary>',"$CoreLibraryDB" `
     -replace '<ENVIRONMENT_CC_VARIABLE>',"$Project.ToUpper()" `
      | Set-Content $DBBSetupPath\BatchScripts\CoreAuth\CoreAuthSetup.bat


  (Get-Content -path $DBBSetupPath\BatchScripts\CoreIssue\SetupCI.bat) `
     -replace '<PrimaryDBServerODBCNameValue>',"$SQLServer" `
     -replace '<HostMachineName>',"$env:COMPUTERNAME" `
     -replace '<KMSServersName>',"$KMSServersName" `
     -replace '<SQLServerName>',"$SQLServer" `
     -replace '<DataBaseName_CoreAuth>',"$CoreAuthDB" `
     -replace '<DataBaseName_CoreIssue>',"$CoreIssueDB" `
     -replace '<DataBaseName_CoreLibrary>',"$CoreLibraryDB" `
     -replace '<DataBaseName_CoreCredit>',"$CoreCreditDB" `
     -replace '<DataBaseName_CoreApp>',"$CoreAppDB" `
     -replace '<SQLServerReportsName>',"$SQLServer" `
     -replace '<DataBaseReportsName_CoreAuth>',"$CoreAuthDB" `
     -replace '<DataBaseReportsName_CoreIssue>',"$CoreIssueDB" `
     -replace '<DataBaseReportsName_CoreLibrary>',"$CoreLibraryDB" `
     -replace '<DataBaseReportsName_CoreCredit>',"$CoreCreditDB" `
     -replace '<DataBaseReportsName_CoreApp>',"$CoreAppDB" `
     -replace '<RptSrvrName_StlRcnValue>',"$SQLServer" `
      | Set-Content $DBBSetupPath\BatchScripts\CoreIssue\SetupCI.bat


  (Get-Content -path $DBBSetupPath\BatchScripts\CoreIssue\SetUp.py) `
     -replace '<HostMachineName>',"$env:COMPUTERNAME" `
     -replace '<SQLServerName>',"$SQLServer" `
     -replace '<DataBaseName_CoreAuth>',"$CoreAuthDB" `
     -replace '<DataBaseName_CoreIssue>',"$CoreIssueDB" `
     -replace '<DataBaseName_CoreLibrary>',"$CoreLibraryDB" `
      | Set-Content $DBBSetupPath\BatchScripts\CoreIssue\SetUp.py


  (Get-Content -path $DBBSetupPath\BatchScripts\CoreIssue\SetupCIPy.ini) `
     -replace '<PrimaryDBServerODBCNameValue>',"$SQLServer" `
     -replace '<HostMachineName>',"$env:COMPUTERNAME" `
     -replace '<KMSServersName>',"$KMSServersName" `
     -replace '<SQLServerName>',"$SQLServer" `
     -replace '<DataBaseName_CoreAuth>',"$CoreAuthDB" `
     -replace '<DataBaseName_CoreIssue>',"$CoreIssueDB" `
     -replace '<DataBaseName_CoreLibrary>',"$CoreLibraryDB" `
     -replace '<DataBaseName_CoreCredit>',"$CoreCreditDB" `
     -replace '<DataBaseName_CoreApp>',"$CoreAppDB" `
     -replace '<DataBaseName_CoreCollect>',"DataBaseName_CoreCollect" `
      | Set-Content $DBBSetupPath\BatchScripts\CoreIssue\SetupCIPy.ini


  (Get-Content -path $DBBSetupPath\ScaleFiles\Scale_MC.ini) `
     -replace '<HostMachineName>',"$env:COMPUTERNAME" `
      | Set-Content $DBBSetupPath\ScaleFiles\Scale_MC.ini



  (Get-Content -path $WebServerPath\CoreCardServices\connectionStrings.config) `
     -replace 'SQLServerName',"$SQLServer" `
     -replace 'DataBaseName_CoreAuth',"$CoreAuthDB" `
     -replace 'DataBaseName_CoreIssue',"$CoreIssueDB" `
     -replace 'DataBaseName_CoreLibrary',"$CoreLibraryDB" `
      | Set-Content $WebServerPath\CoreCardServices\connectionStrings.config



  (Get-Content -path $WebServerPath\WCF\configuration\appSettings.config) `
     -replace 'KMSServersName',"$KMSServersName" `
     -replace 'HostMachineName',"$env:COMPUTERNAME" `
     -replace 'MailServerValue',"corecard-com.mail.protection.outlook.com" `
      | Set-Content $WebServerPath\WCF\configuration\appSettings.config


  (Get-Content -path $WebServerPath\WCF\configuration\connectionStrings.config) `
     -replace 'SQLServerName',"$SQLServer" `
     -replace 'SQLServerReportsName',"$SQLServer" `
     -replace 'DataBaseName_CoreAuth',"$CoreAuthDB" `
     -replace 'DataBaseName_CoreIssue',"$CoreIssueDB" `
     -replace 'DataBaseName_CoreLibrary',"$CoreLibraryDB" `
     -replace 'DataBaseName_CoreCredit',"$CoreCreditDB" `
     -replace 'DataBaseName_CoreApp',"$CoreAppDB" `
     -replace 'DataBaseName_CoreCollect',"DataBaseName_CoreCollect" `
     -replace 'DataBaseReportsName_CoreIssue',"$CoreIssueDB" `
      | Set-Content $WebServerPath\WCF\configuration\connectionStrings.config

  (Get-Content -path $WebServerPath\CoreCredit\Web.config) `
     -replace 'REPORTSERVERURL',"$SQLServer" `
     -replace 'CoreCreditReportsFolder',("$env:COMPUTERNAME" + "_CoreCreditReports") `
     -replace 'DataBaseReportsName_CoreLibrary',"$CoreLibraryDB" `
     -replace 'DataBaseReportsName_CoreAuth',"$CoreAuthDB" `
     -replace 'DataBaseReportsName_CoreCredit',"$CoreCreditDB" `
     -replace 'HostMachineName',"$env:COMPUTERNAME" `
     -replace 'ClientNameValue',"$ClientNameValue" `
      | Set-Content $WebServerPath\CoreCredit\Web.config



     $DSLsVersion = (Select-String -Path $DBBSetupPath\DSLs\CI\About.DSL -Pattern "CreditProcessing ").ToString().Split('"')[1]
     $CC_RuntimeVersion = (Select-String -Path $DBBPlatformPath\appsys30.DSL -Pattern "Application Release ").ToString().Split('"')[1]
     $CC_PythonVersion = (Get-Command $CCPythonPath\python.exe).FileVersionInfo.FileVersion
     $WebServerVersion = (Get-Command $WebServerPath\DBBWEB\bin\dbbHandler2005.dll).FileVersionInfo.FileVersion
     $CoreCreditVersion = (Get-Command $WebServerPath\CoreCredit\bin\CoreCredit.dll).FileVersionInfo.FileVersion
     $WCFVersion = (Get-Command $WebServerPath\WCF\bin\CC.CoreServices.common.dll).FileVersionInfo.FileVersion
     $CoreCardServicesVersion = (Get-Command $WebServerPath\CoreCardServices\bin\CC.HP.Api.dll).FileVersionInfo.FileVersion
     $MSSQLVersion = (Invoke-Sqlcmd -ServerInstance $SQLServer -Database $masterDB -Query ("SELECT @@VERSION;")).Column1
     $MSSQLVersion = $MSSQLVersion.Substring(0,32)
     $CoreAuthDBVersion = (Invoke-Sqlcmd -ServerInstance $SQLServer -Database $CoreAuthDB -Query ("select top 1 AppVersion from Version order by entryid desc;")).AppVersion
     $CoreIssueDBVersion = (Invoke-Sqlcmd -ServerInstance $SQLServer -Database $CoreIssueDB -Query ("select top 1 AppVersion from Version order by entryid desc;")).AppVersion
     $CoreLibraryDBVersion = (Invoke-Sqlcmd -ServerInstance $SQLServer -Database $CoreLibraryDB -Query ("select top 1 AppVersion from Version order by entryid desc;")).AppVersion
     $CoreCreditDBVersion = (Invoke-Sqlcmd -ServerInstance $SQLServer -Database $CoreCreditDB -Query ("select top 1 AppVersion from AdminPortalVersion order by entryid desc;")).AppVersion
     $CoreAppDBVersion = (Invoke-Sqlcmd -ServerInstance $SQLServer -Database $CoreAppDB -Query ("select top 1 AppVersion from Version order by entryid desc;")).AppVersion

     

  (Get-Content -path $WebServerPath\Default.htm) `
     -replace 'HostMachineName',"$env:COMPUTERNAME" `
     -replace 'DSLsVersion',"$DSLsVersion" `
     -replace 'CC_RuntimeVersion',"$CC_RuntimeVersion" `
     -replace 'CC_PythonVersion',"$CC_PythonVersion" `
     -replace 'WebServerVersion',"$WebServerVersion" `
     -replace 'CoreCreditVersion',"$CoreCreditVersion" `
     -replace 'WCFVersion',"$WCFVersion" `
     -replace 'CoreCardServicesVersion',"$CoreCardServicesVersion" `
     -replace 'SQLServerName',"$SQLServer" `
     -replace 'MSSQLVersion',"$MSSQLVersion" `
     -replace 'DataBaseName_CoreAuth',"$CoreAuthDB" `
     -replace 'CoreAuthDBVersion',"$CoreAuthDBVersion" `
     -replace 'DataBaseName_CoreIssue',"$CoreIssueDB" `
     -replace 'CoreIssueDBVersion',"$CoreIssueDBVersion" `
     -replace 'DataBaseName_CoreLibrary',"$CoreLibraryDB" `
     -replace 'CoreLibraryDBVersion',"$CoreLibraryDBVersion" `
     -replace 'DataBaseName_CoreCredit',"$CoreCreditDB" `
     -replace 'CoreCreditDBVersion',"$CoreCreditDBVersion" `
     -replace 'DataBaseName_CoreApp',"$CoreAppDB" `
     -replace 'CoreAppDBVersion',"$CoreAppDBVersion" `
      | Set-Content $WebServerPath\Default.htm



# Start App Server

Write-Host "Starting AppServer"
CD D:\DBBSetup\BatchScripts\CoreIssue\
Start-Process D:\DBBSetup\BatchScripts\CoreIssue\DbbAppServer_CoreIssue.bat




#Open Default Page
Write-Host "Opening Website"
Start-Process "https://$env:COMPUTERNAME.corecard.in"


Set-ExecutionPolicy -ExecutionPolicy Restricted -Force