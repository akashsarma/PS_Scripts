$ExeuteWFName = Read-Host "Enter the wF name"
$ScheduledTaskname = Read-Host "Enter the schedule task name"
$ServerListFile = "D:\As.txt" 
$ServerList = Get-Content $ServerListFile -ErrorAction inquire 
ForEach ($computername in $ServerList) { 
$option = New-PSSessionOption -ProxyAccessType NoProxyServer 

Invoke-Command -ComputerName $computername -SessionOption $option -ErrorAction inquire -ScriptBlock{

$Action = New-ScheduledTaskAction -WorkingDirectory D:\DBBSetup\BatchScripts\CoreIssue -Execute $ExeuteWFName 

$Trigger = New-ScheduledTaskTrigger -AtStartup

$Principal = New-ScheduledTaskPrincipal -UserId cc-jazz-qa\gmsa-batch-svc$ -LogonType Password -RunLevel Highest

Register-ScheduledTask $ScheduledTaskname -Action $Action -Trigger $Trigger -Principal $Principal

}
}