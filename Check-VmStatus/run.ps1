# Input bindings are passed in via param block.
param($Timer)

$resoureGroupName = [System.Environment]::GetEnvironmentVariable('RESOURCE_GROUP', 'Process')
$vmName = [System.Environment]::GetEnvironmentVariable('VM_NAME', 'Process')

Write-Host "PowerShell timer trigger function is triggerd! TIME: $currentUTCtime"

# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

$vmState = Get-AzVM -Name $vmName -ResourceGroupName $resoureGroupName -Status 

If ($vmState.Statuses[1].DisplayStatus -eq 'VM running') {
    Write-Host "VM is running"
} Else {
    Write-Host "VM is $($vmState.Statuses[1].DisplayStatus)"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"
