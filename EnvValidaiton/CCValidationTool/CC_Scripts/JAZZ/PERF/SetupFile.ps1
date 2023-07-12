#################################################Application Values######################################################
$PlatformVersion = "4.2.42.16"
$ApplicationVersion = "16.00.09.03.01"
$ODBCName = "LISTPLAT"
$DBServer = "CCAPPSQLAG1"
$CoreIsseDB = "CCJAZZ_CoreIssue"
$CoreAuthDB = "CCJAZZ_CoreAuth"
$CoreCreditDB = "CCJAZZ_CoreCredit"
$CoreLibraryDB = "CCJAZZ_CoreLibrary"
$CoreAppDB = "CCJAZZ_CoreApp"
$CoreCollectDB = "CCJAZZ_CoreCollect"
$KMSDB = "CCJAZZ_KMS"
$WCFSSLCert = "wcf.perf.cc-pod3.marcusinfra.nimbus.gs.com"
$CoreCreditSSLCert = "corecredit.perf.cc-pod3.marcusinfra.nimbus.gs.com"
$CoreIssueSSLCert = "ci.perf.cc-pod3.marcusinfra.nimbus.gs.com"
$ServicesSSLCert = "service.perf.cc-pod3.marcusinfra.nimbus.gs.com"
$ReportServicesSSLCert = "report.perf.cc-pod3.marcusinfra.nimbus.gs.com"
################################################SetupCI and CoreAuthSetup Variable########################################
$SCALE_SERVER_HOST = "CCWEBE1PERFB1"
$ExperianSetup = "ExperianSetup=Testing"
$Enviroment = "Enviroment=Testing"
$Environment = "JAZZ"
$emPassword = "rd@PRODr03CC"
$PlatPIIHubEnv = "PlatPIIHubEnv=PERFPROD"
$PlatPIIHubTokenEnv = "PlatPIIHubTokenEnv=PERFPROD" 
$PlatAutoRewardRedeem = "PlatAutoRewardRedeem=PERFPROD"
$RelaxIssueStatusCheckForActivation = "RelaxIssueStatusCheckForActivation=TEST"
$TokenRefreshCall = "TokenRefreshCall=1"
$TLS12Required = ""
$KMS = "qaKMS01 qaKMS02"
$MIPTestRequired = "NO"
$MIPEndPoint = "perf.hsm.infra.marcus.com"
$MIPPort = "1500"
$HSMEndPoint = "perf.hsm.infra.marcus.com"
$HSMPort = "1500"
#############################################ICA AND GSI Number Value In All Environments#################################
# ICA Number in PLAT All Environments=019800 | All JAZZ Environment=021190
# GSINumber Number in PLAT-DEV, QA UAT, PERF and PROD=19805 | PATUAT=525363 | PATQA=547895 | All JAZZ Environment=31190
#############################################SetupCI and CoreAuthSetup Variable###########################################
$ICANumber = "021190"
$GSINumber = "31190"
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