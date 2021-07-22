# Script to query the registry for a given VALUE, located at a given PATH (set initial variables)
# If the value is found, contents are modified according to specs given
# This is set up to disable automatic updating Lenovo's ThinkVantage System Update app (TVSU)
# App was applying BIOS and other updates randomly on users' PCs, during business hours


# Define some initial variables
$registryPath = "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Lenovo\System Update\Preferences\UserSettings\Scheduler"
$valueName = "SchedulerAbility"
$newValue = "NO"


# Clear the $Error variable
$Error.Clear()


# Define the query function
Function CheckRegistryValueExists() {

    # Define the string parameters that this function requires
    Param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        #[AllowEmptyString()]
        [string]$Path,
        [string]$Value
    )

    try
        {
            # Get the reg value's current contents
            $valueContents = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction Stop | Select-Object -ExpandProperty $valueName
            Write-Host Current value: $valueContents

            # Check the reg value contents, and update them if not already set to desired value
            if ($valueContents -ne "NO")
                {
                    Write-Host Setting value to $newValue
                    Set-ItemProperty -Path $registryPath -Name $valueName -Value $newValue
                    
                    $newValueContents = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction Stop | Select-Object -ExpandProperty $valueName
                    Write-Host New value: $newValueContents. Script was successful. Exiting...
                }
            else
                {
                    Write-Host Value is aready set to $newValue. Exiting...
                }

            exit
        } # End try block

    catch [System.Management.Automation.PSArgumentException]
        {
            Write-Host The $valueName value was NOT found at $registryPath
            exit
        }

    catch [System.Management.Automation.ItemNotFoundException]
        {
            Write-Host The query failed. Double-check your REGISTRY PATH input.
            exit
        }

    catch
        {
            Write-Host Something terrible happened while executing the registry query.
            Write-Host Specific exception type: $Error[0].Exception.GetType().FullName
            exit
        }

} # End function CheckRegistryValueExists



# Execute the query function, using the expanded variables as parameters
CheckRegistryValueExists -Path $registryPath -Value $valueName
