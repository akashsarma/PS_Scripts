write-host -foregroundcolor green ======================================================================
Write-Host "Share Path Verification"
write-host -foregroundcolor green ======================================================================
""
$ServerType = "CCSVC","CCAUTH","CCWCF"
$ServerType = $ServerType.ToLower()
ForEach ($SpltServers in $ServerType) {
$GetServers = (aws ec2 describe-instances --query "Reservations[*].Instances[*].{Name:Tags[?Key=='Name']|[0].Value}" --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values='*$SpltServers*'" "Name=availability-zone,Values='*'" | ConvertFrom-Json).Name
ForEach ($Servers in $GetServers) {
write-host -foregroundcolor Darkcyan "========================================="
If (!(Test-Path "\\$Servers\c$")) {
    write-host -foregroundcolor green "C Drive is not Accessible"
} else {

    write-host -foregroundcolor Red "C Drive is Accessible"

}
If (!(Test-Path "\\$Servers\d$")) {
    write-host -foregroundcolor green "D Drive is not Accessible"
} else {

    write-host -foregroundcolor Red "D Drive is Accessible"

}
write-host -foregroundcolor Darkcyan "========================================="


Pause