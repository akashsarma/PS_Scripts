$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path $PSScriptRoot\Log\PoolStatus_$($(Get-Date).tostring(“dd-MM-yyyy-hh-mm-ss”)).txt -append
  
 Write-Host 'Please Choose the option'-ForegroundColor green



while(($yes = Read-Host -Prompt "1.CCGS__PoolChange 3.POOLSTART\RESTART 4.EXIT " ) -ne "5"){



switch($yes){
   
		  2{
      $srvlist = Read-Host -Prompt 'Enter the file name having servers list'
	  $SERVERS = get-content "$PSScriptRoot\$srvlist" 
		  foreach ($SERVER in $SERVERS)
          {
          Write-host "$SERVER"-ForegroundColor Yellow
          Invoke-Command -ComputerName $SERVER -ScriptBlock { 
          Import-Module WebAdministration
          $userName="PROD-PLAT\ccgsconfig";
          $password="jXG7v:yG/&";

          $pool1=get-item "IIS:\Sites\webserver\wcf" | foreach { $_.applicationPool; Get-WebApplication -Site $_.Name | foreach { $_.applicationPool } }
          $pool2=get-item "IIS:\Sites\webserver\CoreCardServices" | foreach { $_.applicationPool; Get-WebApplication -Site $_.Name | foreach { $_.applicationPool } }

          Set-ItemProperty "IIS:\AppPools\$pool1" processModel -value @{userName=$userName;password=$password;identitytype=3}
          Set-ItemProperty "IIS:\AppPools\$pool2" processModel -value @{userName=$userName;password=$password;identitytype=3}

          if((Get-WebAppPoolState -Name $pool1).Value -eq 'Stopped'){
          Start-WebAppPool -Name "$pool1" 
          Write-host "$pool1 is started" -ForegroundColor green
           }
          else
           {
            ReStart-WebAppPool -Name "$pool1" 
            Write-host "$pool1 pool is restarted" -ForegroundColor green
            }
         
           if((Get-WebAppPoolState -Name $pool2).Value -eq 'Stopped'){
          Start-WebAppPool -Name "$pool2"
          Write-host "$pool2 pool is started" -ForegroundColor green
           }
          else
           {
            ReStart-WebAppPool -Name "$pool1" 
            Write-host "$pool1 restarted" -ForegroundColor green
            }
          Write-host "$pool1 ,$pool2  is set with $userName" -ForegroundColor green
          }
          }
		  }
  
   3 {
      $srvlist = Read-Host -Prompt 'Enter the file name having servers list'
	  $SERVERS = get-content "$PSScriptRoot\$srvlist" 
     foreach ($SERVER in $SERVERS)
          {
          Write-host "$SERVER"-ForegroundColor Yellow
          Invoke-Command -ComputerName $SERVER -ScriptBlock { 
          Import-Module WebAdministration
          $pool1=get-item "IIS:\Sites\webserver\wcf" | foreach { $_.applicationPool; Get-WebApplication -Site $_.Name | foreach { $_.applicationPool } }
          $pool2=get-item "IIS:\Sites\webserver\CoreCardServices" | foreach { $_.applicationPool; Get-WebApplication -Site $_.Name | foreach { $_.applicationPool } }
          if((Get-WebAppPoolState -Name $pool1).Value -eq 'Stopped'){
           Start-WebAppPool -Name "$pool1"
          Write-host "$pool1 pool is started" -ForegroundColor green
           }
          else
          {
          ReStart-WebAppPool -Name "$pool1"
          Write-host "$pool1 pool is started" -ForegroundColor green
           }
         if((Get-WebAppPoolState -Name $pool2).Value -eq 'Stopped'){
           Start-WebAppPool -Name "$pool2"
          Write-host "$pool2 pool is started" -ForegroundColor green
           }
          else
          {
          ReStart-WebAppPool -Name "$pool2"
          Write-host "$pool2 pool is started" -ForegroundColor green
           }
           }
          }
   }
     
   4 {"End"}
   default {"Invalid selection"}
   }
}
