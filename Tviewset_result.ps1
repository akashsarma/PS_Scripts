Clear-Host

$FlagName = Read-host "Enter the Flag name"
$FlagValue = Read-host "Enter the Flag value"
        hostname
        $ProcessName = Get-Process *Tview*
        If (!(Test-Path "C:\corecard_services\shmem.bin")) {
            Start-Process D:\CC_Runtime\rundbb.exe
        }
        if ($null -eq "$ProcessName")
        {         
            Write-Host -foregroundcolor Red "tview is not running"
            Remove-Item C:\corecard_services\shmem.bin -Force -Verbose -ErrorAction SilentlyContinue
            Start-Process D:\CC_Runtime\rundbb.exe
            D:\CC_Runtime\dt.exe -s $FlagName  "$FlagValue" 
            D:\CC_Runtime\dt.exe -p $FlagName

        } else {
            Write-Host -foregroundcolor green "tview is running" 
            Get-Process Tview | Stop-Process
            Remove-Item C:\corecard_services\shmem.bin -Force -Verbose -ErrorAction SilentlyContinue
            Start-Process D:\CC_Runtime\rundbb.exe
            D:\CC_Runtime\dt.exe -s $FlagName  "$FlagValue" 
            D:\CC_Runtime\dt.exe -p $FlagName
        }
