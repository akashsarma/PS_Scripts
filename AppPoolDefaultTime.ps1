$ServerListFile = "D:\CC_Scripts\Server.txt" 
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach ($computername in $ServerList) {

 

$option = New-PSSessionOption -ProxyAccessType NoProxyServer 
$appPoolName='Services'
write-host  $computername
    Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock {
        
        Import-Module WebAdministration
        
        #Set-ItemProperty IIS:\apppools\$using:appPoolName -Name enable32BitAppOnWin64 -Value 'true'
        #Set-ItemProperty IIS:\apppools\$using:appPoolName -Name processModel.maxProcesses -Value 32
        
        Set-ItemProperty IIS:\apppools\$using:appPoolName -Name Recycling.PeriodicRestart.time -Value 04:00:00
        Get-ItemProperty -Path "IIS:\AppPools\Services" -Name recycling.periodicRestart.time
         }}