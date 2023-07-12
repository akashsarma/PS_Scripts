
<# To View Secret Key #>
aws secretsmanager get-secret-value --secret-id PERF/cc-pod2-ssh-pkey --region us-east-1 
Get-SECSecretValue -SecretId PERF/cc-pod2-ssh-pkey

<# To Set Trace Flags #>
$ServerListFile = "C:\Users\ccgs-app-svc\Desktop\Test\Servers.txt"
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach ($computername in $ServerList) { 
    $option = New-PSSessionOption -ProxyAccessType NoProxyServer 
    Invoke-Command -ComputerName $computername -SessionOption $option -ErrorActi6n inquire -ScriptBlock { hostname 
        D:\CC_Runtime\dt.exe -s ODBC 0
    }
}



<# To View Processes #>
$ServerListFile = "C:\Users\ccgs-app-svc\Desktop\Test\PERF-TNP-Servers.txt" 
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach ($computername in $ServerList) {
    write-host $computername 
    $processes = Get-WmiObject Win32_Process -Computer $computername -filter "Name LIKE '%rundbb_ETNP%.exe'" 
    write-host " $processes.ProcessName ($processid) "
}

<# To KILL Process#>
$ServerListFile = "C:\Users\ccgs-app-svc\Desktop\Test\PERF-TNP-Servers.txt" 
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach ($computername in $ServerList) {
    write-host $computername 
	$processes = Get-WmiObject Win32_Process -Computer $computername -filter "Name LIKE '%rundbb_ETNP%.exe'"  
    $processes.ProcessName 
    foreach ($process in $processes) { 
        $returnval = $process.terminate() 
        $processid = $process.handle 
        if ($returnval.returnvalue -eq 0) {
            write-host "THe process $ProcessName ($processid) terminated successfully" 
        } 
        else {
            write-host "THe process $ProcessName ($processid) termination has some problem" 
        } 
    } 
}


<# To START Process#>
 
$ServerListFile = "C:\Users\ccgs-app-svc\Desktop\Test\PERF-TNP-Servers.txt" 
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach ($computername in $ServerList) { 
    $option = New-PSSessionOption -ProxyAccessType NoProxyServer 
    Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock 
    {
        hostname 
        Get-ScheduledTask -TaskName "Start-TNP" | Start-ScheduledTask 
    } 
}  


<# To Install Certificate in Trusted Root#>

$ServerListFile = "C:\Temp\WCFServers.txt" 
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach ($computername in $ServerList){ 
    robocopy \\ccwcfelmockbl\C$\Temp\Cert\ \\$computername\C$\Temp\Cert\ /e 
    $option = New-PSSessionOption -ProxyAccessType NoProxyServer 
    Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock{ 
        hostnamel 
        Import-Certificate -FilePath "C:\Temp\Cert\Corelssue.cer" -CertStoreLocation 'Cert:\LocalMachine\Root' -Verbose 
    }
} 



<# To Copy files#>
$ServerListFile = "C:\Temp\WCFServers.txt1"
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach ($computername in $ServerList){ 
    robocopy \\ccwcfelmockbl\D$\WebServer\WCF\configuration\ \\$computername\D$\WebServer\WCF\configuration\ /e 
    robocopy \\ccQcfelmockbl\D$\WebServer\CoreCardServices\ \\$computername\D$\WebServer\CoreCardServices\ /e 
    robocopy \\ccwcfelmockbl\C$\Temp\host\ \\$computername\C$\Windows\System32\drivers\etc\ /e
}




<# Create Sceduled Job #>
$ServerListFile = "C:\Users\ccgs-app-svc\Desktop\Test\PERF-SVC-Servers2.txt" 
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach ($computername in $ServerList) {
    $option = New-PSSessionOption -ProxyAccessType NoProxyServer 
    Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock {
        hostname 
        try { 
            $in_domain = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain 
            $process_active = Get-Process rundbb -ErrorAction SilentlyContinue 
            Write-Output "[DEBUG] in_domain: $in_domain" 
            Write-Output "[DEBUG] process_active: $process_active" 
            if (($in_domain -eq $true) -and ($process_active -eq $null)) { 
                Write-Output "[DEBUG] Configuring Service Server"
                # Add-OdbcDsn -Name LISTPLAT -DriverName "ODBC Driver 17 for SQL Server" -DsnType System -Platform "32-bit" -SetPropertyValue @("Server=CCAppSQLAG1", "Description=CCAppSQLAG1", "Encrypt=No", "TrustServerCertificate=No", "Trusted_Connection=Yes", "MultiSubnetFailover=Yes") 

                # Read-53Object -BucketName corecard-pod2-perf-us-east-l-config-files -Key AppConfig/SetupCl.bat -File D:\DBBSetup\BatchScripts\Corelssue\SetupCl.bat 
                $SecretObj = (Get-SECSecretValue -Secretid "PERF/app-service-secret") 
                $Secret = $SecretObj.SecretString | ConvertFrom-Json 

                $A = New-ScheduledTaskAction -Execute "D:\DBBSetup\BatchScripts\CoreIssue\2.CIAppServerServices.bat" -WorkingDirectory "D:\DBBSetup\BatchScripts \Corelssue" -Argument "-passthru -NoNewWindow" 
                $T = New-ScheduledTaskTrigger -AtStartup 
                $P = New-ScheduledTaskPrincipal -Userid $Secret.username 
                $S = New-ScheduledTaskSettingsSet 
                $D = New-ScheduledTask -Action $A -Trigger $T -Principal $P -Settings $S
                Register-ScheduledTask -InputObject $D -Password $Secret.password -TaskName Start-svc -User $Secret.username 
                #Start-ScheduledTask -TaskName "Start-svc" -AsJobl Write-Output "[DEBUG] Completed Service Server" 
            }
            else { 
                Write-Output "[DEBUG] Domain value is $in_domain and process is $process_active (null)" 
            } 
        }
        Catch {
            Write-Error "[DEBUG] Unable to Start Core-Services" 
        } 
    } 

}



<# To list all EC2 instances#>
aws ec2 describe-instances --filters "Name=tag:Name,Values=*mock*" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].{Instance:InstanceId,IpAddress:PrivateIpAddress,Name:Tags[?Key=='Name']|[0].Value} --region us-east-1 --output table 


<# To STOP IIS #>

$ServerListFile = "C:\Users\ccgsconfig\Desktop\Test\WCF\WCF_A.txt"
$ServerList = Get-Content $ServerListFile -ErrorAction inquire
ForEach($computername in $ServerList){
    write-host  $computername
    $option = New-PSSessionOption -ProxyAccessType NoProxyServer 
    Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock{ 
IISRESET /STOP }
}



$ServerListFile = "C:\Users\ccgs-app-svc\Desktop\Test\Web-Servers.txt" 
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach ($computername in $ServerList) { 
    $option = New-PSSessionOption -ProxyAccessType NoProxyServer 
    Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock 
    {
        hostname 
        Stop-IISSite -Name "CoreCreditSiteName" 
    } 
}  




$ServerListFile = "C:\Users\ccgsconfig\Desktop\Test\Servers.txt"  
$ServerList = Get-Content $ServerListFile -ErrorAction SilentlyContinue 
ForEach($computername in $ServerList) 
{
    $option = New-PSSessionOption -ProxyAccessType NoProxyServer 
    Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction Inquire -ScriptBlock {hostname
D:\CC_Runtime\dt.exe -s VirtualTime "Value"
}
}

<# To Set Application pool user #>

$ServerListFile = "C:\Users\ccgs-app-svc\Desktop\Test\WCF-Servers.txt" 
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach ($computername in $ServerList) { 
    $option = New-PSSessionOption -ProxyAccessType NoProxyServer 
    Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock 
    {
        write-host  $computername
        Import-Module WebAdministration
        $userName="CC-POD2-PERF\ccgs-app-svc"
        $password="password"      
        Set-ItemProperty "IIS:\AppPools\WCF" -name processModel -value @{userName=$userName;password=$password;identitytype=3}
        Set-ItemProperty "IIS:\AppPools\CoreCardServices" -name processModel -value @{userName=$userName;password=$password;identitytype=3}
    }
}


<# To Set user in Basic Setting of Website and Applications #>

$ServerListFile = "C:\Users\ccgs-app-svc\Desktop\Test\WCF-Servers.txt" 
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach ($computername in $ServerList) { 
    $option = New-PSSessionOption -ProxyAccessType NoProxyServer 
    Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock 
    {
        write-host  $computername
        $userName="CC-POD2-PERF\ccgs-app-svc"
        $password="password"
        
        Set-WebConfiguration "/system.applicationHost/sites/site[@name='Webserver']/application[@path='/']/VirtualDirectory[@path='/']" -Value @{userName=$userName;password=$password}
        Set-WebConfiguration "/system.applicationHost/sites/site[@name='Webserver']/application[@path='/WCF']/VirtualDirectory[@path='/']" -Value @{userName=$userName;password=$password}
        Set-WebConfiguration "/system.applicationHost/sites/site[@name='Webserver']/application[@path='/CoreCardServices']/VirtualDirectory[@path='/']" -Value @{userName=$userName;password=$password}
    }
}






____________________________________________________________________________________________________________________
STOP   SERVICES
____________________________________________________________________________________________________________________
	$ServerListFile = "C:\Users\ccgsconfig\Desktop\Test\WEBServers\WebServers3.txt"  
	$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
	ForEach($computername in $ServerList) 
	{
	write-host  $computername
	$services = Get-WmiObject Win32_Service -Computer $computername -filter "Name = 'DbbScaleService'" 
	$services 
	foreach ($service in $services) {
	$service.stopservice()
	}
	}

____________________________________________________________________________________________________________________
KILL PROCESSES
____________________________________________________________________________________________________________________

$ServerListFile = "C:\Users\ccgsconfig\Desktop\Test\WEBServers\WebServers3.txt"  
$ServerList = Get-Content $ServerListFile -ErrorAction inquire
ForEach($computername in $ServerList) 
{
write-host  $computername
$Processes = Get-WmiObject Win32_Process -Computer $computername -filter "Name = 'dbbScaleService.exe'" 
$Processes 
foreach ($process in $processes) {
  $returnval = $process.terminate()
  $processid = $process.handle

if($returnval.returnvalue -eq 0) {
  write-host "The process $ProcessName `($processid`) terminated successfully"
}
else {
  write-host "The process $ProcessName `($processid`) termination has some problems"
}
}

}



$ServerListFile = "C:\Users\ccgsconfig\Desktop\Test\WEBServers\WebServers3.txt"  
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach($computername in $ServerList) 
{
write-host  $computername
$services = Get-WmiObject Win32_Service -Computer $computername -filter "Name = 'DbbScaleService'" 
$services 
foreach ($service in $services) {
$service.startservice()
}
$option = New-PSSessionOption -ProxyAccessType NoProxyServer 
Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock {hostname
IISRESET}
}




<# To cceck site binding #>

$ServerListFile = "C:\Users\ccgs-app-svc\Desktop\Test\WCF-Servers.txt" 
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach ($computername in $ServerList) { 
    $option = New-PSSessionOption -ProxyAccessType NoProxyServer 
    Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock 
    {
        write-host  $computername
        Import-Module WebAdministration
        Get-Children -Path IIS:\Sites | findstr 'CoreCredit'
}


<# To cceck site binding #>

$ServerListFile = "C:\Users\ccgs-app-svc\Desktop\Test\WCF-Servers.txt" 
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach ($computername in $ServerList) { 
    $option = New-PSSessionOption -ProxyAccessType NoProxyServer 
    Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock 
    {
        write-host  $computername
        Import-Module WebAdministration
        Stop-IISSite -Name "Default Web Site"
}



<# To check all all IIS bindings #>

$ServerListFile = "C:\Users\ccgs-app-svc\Desktop\Test\WCF-Servers.txt" 
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach ($computername in $ServerList) { 
    $option = New-PSSessionOption -ProxyAccessType NoProxyServer 
    Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock    {
        write-host  $computername
        Import-Module -Name WebAdministration

        Get-ChildItem -Path IIS:SSLBindings | ForEach-Object -Process `
        {
            if ($_.Sites)
            {
                $certificate = Get-ChildItem -Path CERT:LocalMachine/My |
                    Where-Object -Property Thumbprint -EQ -Value $_.Thumbprint
        
                [PsCustomObject]@{
                    Sites                        = $_.Sites.Value
                    CertificateFriendlyName      = $certificate.FriendlyName
                    CertificateDnsNameList       = $certificate.DnsNameList
                    CertificateNotAfter          = $certificate.NotAfter
                    CertificateIssuer            = $certificate.Issuer
                }
            }
        }
}
}


<# To verify app pool identity #>

$ServerListFile = "C:\Users\jayesh.dholi\Desktop\Alert\server\server.txt"
$ServerList = Get-Content $ServerListFile -ErrorAction inquire
ForEach ($computername in $ServerList) {
    $option = New-PSSessionOption -ProxyAccessType NoProxyServer
    write-host  $computername
    Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock {
       
        Import-Module WebAdministration
    
        Get-ItemProperty IIS:\AppPools\WCF|select -ExpandProperty processModel | select -expand userName
       }        
     }"

# To Set the item propert of the app pool- enable 32 bit application to true
$ServerListFile = "C:\Users\jayesh.dholi\Desktop\Alert\server\server.txt" 
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach ($computername in $ServerList) {

 

$option = New-PSSessionOption -ProxyAccessType NoProxyServer 
$appPoolName='Dashboard'
write-host  $computername
    Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock {
        
        Import-Module WebAdministration
        
        Set-ItemProperty IIS:\apppools\$using:appPoolName -Name enable32BitAppOnWin64 -Value 'true'

         }}

 
 
 
 # To Get the item propert of the app pool- enable 32 bit application to true
$ServerListFile = "C:\Users\jayesh.dholi\Desktop\Alert\server\server.txt" 
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach ($computername in $ServerList) {
$option = New-PSSessionOption -ProxyAccessType NoProxyServer 
$appPoolName='Dashboard'
write-host  $computername
    Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock {
        
        Import-Module WebAdministration
        
        Get-ItemProperty IIS:\AppPools\$using:appPoolName | select *

         }}

 

 <# To set Custome log in site #>

$ServerListFile = "C:\Users\ccgs-app-svc\Desktop\Test\WCF-Servers.txt" 
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach ($computername in $ServerList) { 
    write-host  $computername
    $option = New-PSSessionOption -ProxyAccessType NoProxyServer 
    Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock 
    {
        Import-Module WebAdministration
        New-ItemProperty 'IIS:\Sites\Services' -Name logfile.customFields.collection -Value @{logFieldName='X-Request-ID';sourceType='RequestHeader';sourceName='X-Request-ID'}
        
}        