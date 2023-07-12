Clear-Host

$ServerTypes = 'svc', 'wf', 'src'
$ThisServer = (Hostname).ToLower()
if($ThisServer -match 'e1')
{$Region = "us-east-1"
$ShortRegion = 'e1'
} elseif($ThisServer -match 'w2')
{$Region = "us-west-2"
$ShortRegion = 'w2'
}

$AWSVarialbes = (aws ec2 describe-instances --query "Reservations[*].Instances[*].{AvailabilityZone:Placement.AvailabilityZone,IpAddress:PrivateIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name,Environment:Tags[?Key=='environment']|[0].Value,Status:State.environment,Stack:Tags[?Key=='stack']|[0].Value,Status:State.stack,Attribution:Tags[?Key=='attribution']|[0].Value,Status:State.attribution}" --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values='$ThisServer'" "Name=availability-zone,Values='*'" --region $Region | ConvertFrom-Json)

$EnvironmentName = $AWSVarialbes.Environment.ToLower()
$EnvironmentName
$Environmentattributon = $AWSVarialbes.Attribution.ToLower()
$Environmentattributon
$EnvironmentStack = ($AWSVarialbes.Stack.ToLower())[0]
$EnvironmentStack
$ServerList = $NULL
ForEach($ServerType in $ServerTypes) {
$ServerType
    $ServerListDetails = (aws ec2 describe-instances --query "Reservations[*].Instances[*].{AvailabilityZone:Placement.AvailabilityZone,IpAddress:PrivateIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}" --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values='*$ServerType$ShortRegion$EnvironmentName$EnvironmentStack*'" "Name=availability-zone,Values='*'" --region $Region | ConvertFrom-Json)
    $ServerList += ($ServerListDetails | Select-Object @{n = "Name"; e = { $_.Name } }, @{n = "serial"; e = { [double]($_.Name -split "$EnvironmentName$EnvironmentStack")[1] } } | Sort-Object -Property serial).Name
 
 }

$ServerList


$Outputreport = "<HTML><TITLE> Process Validation Report </TITLE>
                 <BODY background-color:peachpuff>
                 <font color =""#4682B4"" face=""Microsoft Tai le"">
                 <H2>$($EnvironmentName.ToUpper()) -PROCESS COUNT</H2></font>
                 <Table border=1 cellpadding=0 cellspacing=0>
                 <TR bgcolor=gray align=center>
                 <TD><B>Process Nae</B></TD>
                   <TD><B>Process Count</B></TD>
                   
                   </TR>"

$option = New-PSSessionOption -ProxyAccessType NoProxyServer -OpenTimeout 20000
$Outputreport += Invoke-Command -ComputerName $Serverlist -SessionOption $option -ErrorAction Continue -HideComputerName -ScriptBlock{
$OutputreportVarVal = $NULL

$AppServer = (get-process DbbApp*, rundbb_*)


$computername = hostname

$eachapp = $Null
$runningprocess = $null



foreach ($eachapp in $AppServer){
 
$Processname = @($eachapp).name
$processcount =@($eachapp).count




$OutputreportVarVal += "<TR align=center>"
$OutputreportVarVal += "<TD>$($Processname)</TD>
                    <TD>$("$processcount")</TD>
                    
                                      
                   </TR>"


$OutputreportVarVal


}

}

$Outputreport += "</Table></BODY></HTML>" 

 

$Outputreport += "<HTML><TITLE> Process Validation Report </TITLE>
                 <BODY background-color:peachpuff>
                 <font color =""#4682B4"" face=""Microsoft Tai le"">
                 <H2>$($EnvironmentName.ToUpper()) - Current Running Processes</H2></font>
                 <Table border=1 cellpadding=0 cellspacing=0>
                 <TR bgcolor=gray align=center>
                 <TD><B>Server Name</B></TD>
                   <TD><B>Process Name</B></TD>
                   <TD><B>Proces ID</B></TD>
                   <TD><B>Start Time</B></TD>
                   </TR>"

$option = New-PSSessionOption -ProxyAccessType NoProxyServer -OpenTimeout 20000
$Outputreport += Invoke-Command -ComputerName $Serverlist -SessionOption $option -ErrorAction Continue -HideComputerName -ScriptBlock{
$OutputreportVarVal = $NULL


$AppServer = @(get-process DbbApp*, rundbb_*)


$computername = hostname

$eachapp = $Null
$runningprocess = $null


foreach ($eachapp in $AppServer){


$runningprocess = @($eachapp).name
$runningprocessID =@($eachapp).ID
$runningprocessTime =@($eachapp).Starttime


$OutputreportVarVal += "<TR align=center>"
$OutputreportVarVal += "<TD>$($computername)</TD>
                    <TD>$("$runningprocess")</TD>
                    <TD>$("$runningprocessID")</TD>
                    <TD>$("$runningprocessTime")</TD>
                                      
                   </TR>"



$OutputreportVarVal

}
}



$Outputreport += "</Table></BODY></HTML>" 

 
$ReportFile = "C:\temp\Process_Validation.html"
$Outputreport | out-file "$ReportFile"




