#################################################Application Values######################################################
$PlatformVersion = "4.2.42.16"
$ApplicationVersion = "16.00.09.03.01"
$ODBCName = "LISTPLAT"
$DBServer = "CCAPPSQLAG1"
$CoreIsseDB = "CCGS_CoreIssue"
$CoreAuthDB = "CCGS_CoreAuth"
$CoreCreditDB = "CCGS_CoreCredit"
$CoreLibraryDB = "CCGS_CoreLibrary"
$CoreAppDB = "CCGS_CoreApp"
$CoreCollectDB = "CCGS_CoreCollect"
$KMSDB = "CCGS_KMS"
$WCFSSLCert = "wcf.PROD.cc-pod2.marcusinfra.nimbus.gs.com"
$CoreCreditSSLCert = "corecredit.prod.cc-pod2.marcusinfra.nimbus.gs.com"
$CoreIssueSSLCert = "ci.prod.cc-pod2.marcusinfra.nimbus.gs.com"
$ServicesSSLCert = "service.prod.cc-pod2.marcusinfra.nimbus.gs.com"
$ReportServicesSSLCert = "report.prod.cc-pod2.marcusinfra.nimbus.gs.com"
################################################SetupCI and CoreAuthSetup Variable########################################
$SCALE_SERVER_HOST = "CCWEBE1PRODB1"
$ExperianSetup = "ExperianSetup=Production"
$Enviroment = "Enviroment=Production"
$PlatPIIHubEnv = "PlatPIIHubEnv=PROD"
$PlatPIIHubTokenEnv = "PlatPIIHubTokenEnv=PROD" 
$PlatAutoRewardRedeem = "PlatAutoRewardRedeem=PROD"
$RelaxIssueStatusCheckForActivation = "RelaxIssueStatusCheckForActivation=PROD"
$TokenRefreshCall = "TokenRefreshCall=1"
$TLS12Required = "YES"
$KMS = "cckmse1prodb1 cckmse1prodb2 cckmse1prodb1 cckmse1prodb2 cckmse1prodb1 cckmse1prodb2 cckmse1prodb2"
$MIPTestRequired = "NO"
$MIPEndPoint = "prod.hsm.infra.marcus.com"
$MIPPort = "1500"
$HSMEndPoint = "prod.hsm.infra.marcus.com"
$HSMPort = "1500"
#############################################ICA AND GSI Number Value In All Environments#################################
# ICA Number in PLAT All Environments=019800 | All JAZZ Environment=021190
# GSINumber Number in PLAT-DEV, QA UAT, PERF and PROD=19805 | PATUAT=525363 | PATUAT=547895 | All JAZZ Environment=31190
#############################################SetupCI and CoreAuthSetup Variable###########################################
$ICANumber = "019800"
$GSINumber = "19805"
$NetworkManagementInformationCode = "061"
###################################################AZ Wise ScaleFile Name ################################################
$AZWiseScaleVerification = "YES"
$ZoneA = "us-east-1a"
$ZoneC = "us-east-1c"
$ZoneD = "us-east-1d"
####Put ScaleFile Name without Extension####
$ServicesScaleName_ZoneA = "scale_appServices_STD-Group1"
$ServicesScaleName_ZoneC = "scale_appServices_STD-Group2"
$ServicesScaleName_ZoneD = "scale_appServices_STD-Group3"

$CoreIssueScaleName_ZoneA = "scale_appCoreIssue_STD-Group1"
$CoreIssueScaleName_ZoneC = "scale_appCoreIssue_STD-Group2"
$CoreIssueScaleName_ZoneD = "scale_appCoreIssue_STD-Group3"

$CoreAuthScaleName_ZoneA = "scale_appCoreAuth_STD-Group1"
$CoreAuthScaleName_ZoneC = "scale_appCoreAuth_STD-Group2"
$CoreAuthScaleName_ZoneD = "scale_appCoreAuth_STD-Group3"

$MCScaleName_ZoneA = "Scale_MC_STD-1"
$MCScaleName_ZoneC = "Scale_MC_STD-2"
$MCScaleName_ZoneD = "Scale_MC_STD-3"
##########################################################################################################################