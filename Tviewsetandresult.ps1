Clear-Host
$ServerListFile = "F:\server\server.txt"  
$ServerList = Get-Content $ServerListFile -ErrorAction SilentlyContinue 

    $option = New-PSSessionOption -ProxyAccessType NoProxyServer 
   Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction Inquire -ScriptBlock { 

$FlagName = Read-host "Enter the Flag name"
$FlagValue = Read-host "Enter the Flag value"

        hostname      
        if ($process = Get-Process tview*)
        {         
            Write-Host -foregroundcolor Red "tview is running" 
            $process | Stop-Process  
            Write-Host "tview terminated"
        }
        else                         
        {
            Write-Host -foregroundcolor green "tview is not running" 
        }

        If (Test-Path "C:\corecard_services\shmem.bin") 
        {
           Write-Host -foregroundcolor Red "shmem.bin is avialable"
           Remove-Item C:\corecard_services\shmem.bin -Verbose
        }
        else 
        {
            Write-Host -foregroundcolor green "shmem.bin is not avialable"
        }
        Start-Sleep -Seconds 3
        Start-Process D:\CC_Runtime\rundbb.exe
        Start-Sleep -Seconds 5
        D:\CC_Runtime\dt.exe -s $FlagName  "$FlagValue" 
        D:\CC_Runtime\dt.exe -p $FlagName 

    }
