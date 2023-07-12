######################################################################################################################
# Security Test Runner | DEVELOPED BY:: Siddhartha Chaurasia
# Version 1.0 | Initial Release | Date:: 10-August-2022
######################################################################################################################
Set-ExecutionPolicy -Scope Process Bypass
$Path = Split-Path $MyInvocation.MyCommand.Path
$Drive = (Get-Item $Path).Root.Name
Remove-Variable -Force HOME
Set-Variable HOME $Path
###########################################Call PowerShell Variable File##############################################
. "$HOME\ConfigFile.ps1"
######################################################################################################################
If ((!(Test-Path ".\Logs\")) -and (".\Logs\Archive")) {
mkdir .\Logs\
mkdir .\Logs\Archive
} else {
    Move-Item .\Logs\*.* .\Logs\Archive\
}
$DATE = Get-date -Format MM-dd-yyyy-HH-mm-ss
$ErrorDATE = Get-date -Format MM-dd-yyyy-HH
Start-Transcript -Path .\Logs\SecurityTestRunner_$DATE.log
######################################################################################################################
$line = '========================================================='
do {
   
    Clear-Host
    Write-Host $line
    Write-Host '************** Modules **************'
    Write-Host $line
    Write-Host ' 1', ' - ', 'Verify SSL, TLS and Ciphers Configuration - AWS'
    Write-Host ' 2', ' - ', 'Check the Current Status of Ciphers - AWS'
    Write-Host ' 3', ' - ', 'Verify SSL, TLS and Ciphers Configuration - On-Premises'
    Write-Host ' 4', ' - ', 'Check the Current Status of Ciphers - On-Premises'
    Write-Host ' 0', ' - ', 'Quit'
    Write-Host $line
    $input = Read-Host 'Select'
    Switch ($input) {0 {exit}

'1'
{
Clear-Host
write-host -foregroundcolor green '==============================Security Test Runner=============================='
""
write-host -foregroundcolor green ======================================================================
Write-Host "SSL, TLS and Cipers Verification - AWS"
write-host -foregroundcolor green ======================================================================
""
$ServerType = $ServerType.ToLower()
ForEach ($SpltServers in $ServerType) {
$GetServers = (aws ec2 describe-instances --query "Reservations[*].Instances[*].{Name:Tags[?Key=='Name']|[0].Value}" --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values='*$SpltServers*'" "Name=availability-zone,Values='*'" | ConvertFrom-Json).Name
ForEach ($Servers in $GetServers) {
write-host -foregroundcolor Darkcyan "========================================="
Write-Host Verifying SSL, TLS and Cipers on $Servers...
$option = New-PSSessionOption -ProxyAccessType NoProxyServer
Invoke-Command -ComputerName $Servers -SessionOption $option -ErrorAction inquire -ScriptBlock {
$HostName = HostName
$RegisteryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"
$WeakEncryption = "SSL 2.0","SSL 3.0","TLS 1.0","TLS 1.1"
$StrongEncryption = "TLS 1.2"
ForEach ($SpltWeakEnc in $WeakEncryption) {

If ((!(Test-Path "$RegisteryPath\$SpltWeakEnc\Server")) -and ("$RegisteryPath\$SpltWeakEnc\Client")) {
$Null
} Else {
    $GetServerValue = (Get-ItemProperty -Path "$RegisteryPath\$SpltWeakEnc\Server").DisabledByDefault
    $GetClientValue = (Get-ItemProperty -Path "$RegisteryPath\$SpltWeakEnc\Client").DisabledByDefault
} 
If (($GetServerValue -eq "1") -and ($GetClientValue -eq "1")) {
    Write-Host -ForegroundColor Green "SUCCESS:: $SpltWeakEnc is not enabled on $HostName"
} else {
    Write-Host -ForegroundColor Red "ERROR:: $SpltWeakEnc is not disabled on $HostName" 
}
}
ForEach ($SpltStrongEnc in $StrongEncryption) {

If ((!(Test-Path "$RegisteryPath\$SpltStrongEnc\Server")) -and ("$RegisteryPath\$SpltStrongEnc\Client")) {
$Null
} Else {
    $GetServerValue = (Get-ItemProperty -Path "$RegisteryPath\$SpltStrongEnc\Server").DisabledByDefault
    $GetClientValue = (Get-ItemProperty -Path "$RegisteryPath\$SpltStrongEnc\Client").DisabledByDefault
} 
If (($GetServerValue -eq "0") -and ($GetClientValue -eq "0")) {
    Write-Host -ForegroundColor Green "SUCCESS:: $SpltStrongEnc is enabled on $HostName"
} else {
    Write-Host -ForegroundColor Red "ERROR:: $SpltStrongEnc is not enabled on $HostName" 
}
}
$StrongCipers = "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256","TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
$WeakCipers = "*TLS_AES*","*TLS_DHE*","*TLS_RSA*","*TLS_PSK*"
ForEach ($SpltStrongCipers in $StrongCipers) {
    #$TLSCipers = Get-TlsCipherSuite | Format-Table -Property Name
    $TLSCipers = (Get-TlsCipherSuite).Name
If ($TLSCipers -contains $SpltStrongCipers) {
    Write-Host -ForegroundColor Green "SUCCESS:: Server $HostName Supports Strong Cipers $SpltStrongCipers"
} Else {
    Write-Host -ForegroundColor Red "ERROR:: Server $HostName Does not Supports Strong Cipers like $SpltStrongCipers" 
}
}
ForEach ($SpltWeakCipers in $WeakCipers) {
    $TLSCipers = (Get-TlsCipherSuite).Name
If ($TLSCipers -like $SpltWeakCipers) {
    Write-Host -ForegroundColor Red "ERROR:: Server $HostName Supports Weak Cipers like $SpltWeakCipers"
}
}
}
}
}
write-host -foregroundcolor green '===================================Completed==================================='
write-host -foregroundcolor green 'Press any key to return to Main Menu'
[void][System.Console]::ReadKey($true)
cls
}
#End
'2'
{
Clear-Host
write-host -foregroundcolor green '==============================Security Test Runner=============================='
""
write-host -foregroundcolor green ======================================================================
Write-Host "Current Status of Ciphers - AWS"
write-host -foregroundcolor green ======================================================================
""
$ServerType = $ServerType.ToLower()
ForEach ($SpltServers in $ServerType) {
$GetServers = (aws ec2 describe-instances --query "Reservations[*].Instances[*].{Name:Tags[?Key=='Name']|[0].Value}" --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values='*$SpltServers*'" "Name=availability-zone,Values='*'" | ConvertFrom-Json).Name
ForEach ($Servers in $GetServers) {
Write-host -foregroundcolor Darkcyan "========================================="
Write-Host Fetching Current Support Cipers on $Servers...
$option = New-PSSessionOption -ProxyAccessType NoProxyServer
Invoke-Command -ComputerName $Servers -SessionOption $option -ErrorAction inquire -ScriptBlock {
$HostName = HostName
    $TLSCipers = Get-TlsCipherSuite | Format-Table -Property CipherSuite, Exchange, Name
    $TLSCipers 
}
}
}
write-host -foregroundcolor green '===================================Completed==================================='
write-host -foregroundcolor green 'Press any key to return to Main Menu'
[void][System.Console]::ReadKey($true)
cls
}
#End
'3'
{
Clear-Host
write-host -foregroundcolor green '==============================Security Test Runner=============================='
""
write-host -foregroundcolor green ======================================================================
Write-Host "SSL, TLS and Cipers Verification - On-Premies"
write-host -foregroundcolor green ======================================================================
""
$Servers = Read-Host "Please Specify the Path and Name of Servers List File"
$ServerListFile = $Servers
$ServerList = Get-Content $ServerListFile -ErrorAction inquire
ForEach ($Servers in $ServerList) {
write-host -foregroundcolor Darkcyan "========================================="
Write-Host Verifying SSL, TLS and Cipers on $Servers...
$option = New-PSSessionOption -ProxyAccessType NoProxyServer
Invoke-Command -ComputerName $Servers -SessionOption $option -ErrorAction inquire -ScriptBlock {
$HostName = HostName
$RegisteryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"
$WeakEncryption = "SSL 2.0","SSL 3.0","TLS 1.0","TLS 1.1"
$StrongEncryption = "TLS 1.2"
ForEach ($SpltWeakEnc in $WeakEncryption) {

If ((!(Test-Path "$RegisteryPath\$SpltWeakEnc\Server")) -and ("$RegisteryPath\$SpltWeakEnc\Client")) {
$Null
} Else {
    $GetServerValue = (Get-ItemProperty -Path "$RegisteryPath\$SpltWeakEnc\Server").DisabledByDefault
    $GetClientValue = (Get-ItemProperty -Path "$RegisteryPath\$SpltWeakEnc\Client").DisabledByDefault
} 
If (($GetServerValue -eq "1") -and ($GetClientValue -eq "1")) {
    Write-Host -ForegroundColor Green "SUCCESS:: $SpltWeakEnc is not enabled on $HostName"
} else {
    Write-Host -ForegroundColor Red "ERROR:: $SpltWeakEnc is not disabled on $HostName" 
}
}
ForEach ($SpltStrongEnc in $StrongEncryption) {

If ((!(Test-Path "$RegisteryPath\$SpltStrongEnc\Server")) -and ("$RegisteryPath\$SpltStrongEnc\Client")) {
$Null
} Else {
    $GetServerValue = (Get-ItemProperty -Path "$RegisteryPath\$SpltStrongEnc\Server").DisabledByDefault
    $GetClientValue = (Get-ItemProperty -Path "$RegisteryPath\$SpltStrongEnc\Client").DisabledByDefault
} 
If (($GetServerValue -eq "0") -and ($GetClientValue -eq "0")) {
    Write-Host -ForegroundColor Green "SUCCESS:: $SpltStrongEnc is enabled on $HostName"
} else {
    Write-Host -ForegroundColor Red "ERROR:: $SpltStrongEnc is not enabled on $HostName" 
}
}
$StrongCipers = "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256","TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
$WeakCipers = "*TLS_AES*","*TLS_DHE*","*TLS_RSA*","*TLS_PSK*"
ForEach ($SpltStrongCipers in $StrongCipers) {
    #$TLSCipers = Get-TlsCipherSuite | Format-Table -Property Name
    $TLSCipers = (Get-TlsCipherSuite).Name
If ($TLSCipers -contains $SpltStrongCipers) {
    Write-Host -ForegroundColor Green "SUCCESS:: Server $HostName Supports Strong Cipers $SpltStrongCipers"
} Else {
    Write-Host -ForegroundColor Red "ERROR:: Server $HostName Does not Supports Strong Cipers like $SpltStrongCipers" 
}
}
ForEach ($SpltWeakCipers in $WeakCipers) {
    $TLSCipers = (Get-TlsCipherSuite).Name
If ($TLSCipers -like $SpltWeakCipers) {
    Write-Host -ForegroundColor Red "ERROR:: Server $HostName Supports Weak Cipers like $SpltWeakCipers"
}
}
}
}
write-host -foregroundcolor green '===================================Completed==================================='
write-host -foregroundcolor green 'Press any key to return to Main Menu'
[void][System.Console]::ReadKey($true)
cls
}
#End
'4'
{
Clear-Host
write-host -foregroundcolor green '==============================Security Test Runner=============================='
""
write-host -foregroundcolor green ======================================================================
Write-Host "Current Status of Ciphers - On-Premies"
write-host -foregroundcolor green ======================================================================
""
$Servers = Read-Host "Please Specify the Path and Name of Servers List File"
$ServerListFile = $Servers
$ServerList = Get-Content $ServerListFile -ErrorAction inquire
ForEach ($Servers in $ServerList) {
Write-host -foregroundcolor Darkcyan "========================================="
Write-Host Fetching Current Support Cipers on $Servers...
$option = New-PSSessionOption -ProxyAccessType NoProxyServer
Invoke-Command -ComputerName $Servers -SessionOption $option -ErrorAction inquire -ScriptBlock {
$HostName = HostName
    $TLSCipers = Get-TlsCipherSuite | Format-Table -Property CipherSuite, Exchange, Name
    $TLSCipers 
}
}
write-host -foregroundcolor green '===================================Completed==================================='
write-host -foregroundcolor green 'Press any key to return to Main Menu'
[void][System.Console]::ReadKey($true)
cls
}
#End
default {
            Write-Host -foregroundcolor Red 'Incorrect Option, Please enter the correct number!!'
            [void][System.Console]::ReadKey($true)
        }
	
    }
    Select-String -Path ".\Logs\*SecurityTestRunner_$ErrorDATE*.log" -Pattern "ERROR::" | Select line | Out-File ".\Logs\SecurityTestRunner_ERRORS_$DATE.log" -append
    Write-Host "Please Check SecurityTestRunner_ERRORS_$DATE.log for All Errors."
    Start-Sleep -Seconds 1.5
} 
while ($input -ne '0')
Stop-Transcript
pause