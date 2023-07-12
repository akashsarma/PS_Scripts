##########################################################################################
If (!(Test-Path .\Logs\))
{ mkdir .\Logs\
}	
$DATE = Get-date -Format MM-dd-yyyy-HH-mm-ss
Start-Transcript -Path .\Logs\DiskSpaceCheck_$DATE.log
###########################################################################################
$ServerListFile = "C:\Users\CCGSCONFIG\Documents\server.txt"
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach ($computername in $ServerList) { 
    $option = New-PSSessionOption -ProxyAccessType NoProxyServer 
    Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock { hostname 
        Get-CimInstance -Class Win32_LogicalDisk |
Select-Object -Property DeviceID, VolumeName, @{Label='FreeSpace (Gb)'; expression={($_.FreeSpace/1GB).ToString('F2')}},
@{Label='Total (Gb)'; expression={($_.Size/1GB).ToString('F2')}},
@{label='FreePercent'; expression={[Math]::Round(($_.freespace / $_.size) * 100, 2)}}|ft
    }
}

Stop-Transcript