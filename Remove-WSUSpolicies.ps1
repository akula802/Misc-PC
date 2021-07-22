# Very basic script to remove WSUS settings


# Check status of the Windows Update service
$serviceName = "wuauserv"
$status = (get-service -name $serviceName).Status


# Stop the Windows Update service if it is running
if ($status -eq "Stopped")
    { Write-Host The $serviceName service is already stopped.}
else
    {
        Stop-Service $serviceName
        Write-Host Stopped the $serviceName service.
    }


# Remove the WSUS registry items
Remove-Item HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Recurse
Write-Host Removed the WSUS registry items.


# Restart the Windows Update service
Start-Service wuauserv
Write-Host The WSUS policies have been removed.
