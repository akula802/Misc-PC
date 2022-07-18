# Get all of the ipv6 enabled interfaces
$ip6interfaces = Get-NetAdapterBinding | Where-Object ComponentID -EQ 'ms_tcpip6' | Where-Object Enabled -EQ $true


# Loop through the ipv6-enabled interfaces
ForEach ($interfaceName in $ip6interfaces.Name)
    {
        # Permanently disable ipv6 on each
        Disable-NetAdapterBinding -Name $interfaceName -ComponentID 'ms_tcpip6'
    }

# Finish up
Write-Host Made sure ipv6 is disabled on all interfaces.`r`n
