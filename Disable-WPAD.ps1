# Script to disable WPAD on Windows systems
# https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/disable-http-proxy-auth-features



# Define some variables
$path_prefix = "Microsoft.PowerShell.Core\Registry::"

$registry_key_path_wpad = $path_prefix + "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp"
$value_name_wpad = "DisableWpad"
$new_value_wpad = "1"

$registry_key_path_autoProxy = $path_prefix + "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinHttpAutoProxySvc"
$value_name_autoProxy = "Start"
$new_value_autoProxy = "4"



# Clear the $Error variable
$Error.Clear()



# Define the configurable, reusable query function
Function ChangeRegistryValue() {

    # Define the string parameters that this function requires
    Param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        #[AllowEmptyString()]
        [string]$Path,
        [string]$ValueName,
        [string]$DesiredValueSetting,
        [ValidateSet('REG_SZ', 'DWORD')]
        [string]$ValueType
    )


    # If the value type is a DWORD, change the desired value given to an integer
    if ($ValueType -eq 'DWORD') {
        try {
            $DesiredValueSetting_processed = [int]$DesiredValueSetting
        }

        catch [System.Management.Automation.RuntimeException] {
            # Unable to convert the supplied value to an integer
            Write-Host `r`nYou cannot create or modify a DWORD value with a string `($ValueName`).
            exit
        }
    }

    else {
    # Nothing to do, the value being created/modified is a string (REG_SZ). Leave $DesiredValueSetting as a string.
        $DesiredValueSetting_processed = $DesiredValueSetting
    }


    # Now check the registry value and update (or create) the value if needed.
    try {
        # Get the reg value's current contents
        $current_value_setting = Get-ItemProperty -Path $Path -Name $ValueName -ErrorAction Stop | Select-Object -ExpandProperty $ValueName
        Write-Host `r`nCurrent value: $current_value_setting

        # Check the reg value contents, and update them if not already set to desired value
        if ($current_value_setting -ne $DesiredValueSetting) {
            Write-Host Setting value to $DesiredValueSetting
            Set-ItemProperty -Path $Path -Name $ValueName -Value $DesiredValueSetting_processed
                    
            $newValueContents = Get-ItemProperty -Path $Path -Name $valueName -ErrorAction Stop | Select-Object -ExpandProperty $valueName
            Write-Host `r`nNew value: $newValueContents. Script was successful.
        }
        else {
            Write-Host Value is aready set to $DesiredValueSetting
        }

    } # End try block


    catch [System.Management.Automation.PSArgumentException] {
        Write-Host `r`nThe $ValueName value was NOT found at $Path
        Write-Host Creating it now...
        Get-Item -Path $Path | New-ItemProperty -Name $ValueName -Value $DesiredValueSetting_processed | Out-Null
        Write-Host `r`nCreated item `'$ValueName`' with a value: $DesiredValueSetting
    }

    catch [System.Management.Automation.ItemNotFoundException] {
        Write-Host `r`nThe query failed. Double-check your REGISTRY PATH input.
        exit
    }

    catch {
        Write-Host `r`nSomething terrible happened while executing the registry query.
        Write-Host Specific exception type: $Error[0].Exception.GetType().FullName
        exit
    }

} # End function CheckRegistryValueExists




# Execute the function, using the expanded variables as parameters
ChangeRegistryValue -Path $registry_key_path_wpad -ValueName $value_name_wpad -DesiredValueSetting $new_value_wpad -ValueType DWORD
ChangeRegistryValue -Path $registry_key_path_autoProxy -ValueName $value_name_autoProxy -DesiredValueSetting $new_value_autoProxy -ValueType DWORD
