$ServerListFile = "C:\Users\ccgsconfig\Desktop\list\Servers.txt"  
$ServerList = Get-Content $ServerListFile -ErrorAction inquire
ForEach($computername in $ServerList) 
{
write-host  $computername
$Processes = Get-WmiObject Win32_Process -Computer $computername -filter "Name = 'Rundbb_TNP.exe'" 
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