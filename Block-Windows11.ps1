# This script calls a re-useable, generic registry check+set function to block Windows 11
# Function queries the registry for a given VALUE, located at a given PATH (set in initial variables)
# If the value is found, contents are modified according to specs given
# If the value is not found, it is created
# Saved on 10/11/2021 to:   https://github.com/akula802/Misc-PC/blob/main/Block-Windows11.ps1



# Define some initial variables
$registryPath = "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

# This flag tells Windows that release targeting is desired
$regKey1_name = "TargetReleaseVersion"
$regKey1_desiredValue = "1"
$regKey1_propType = "Dword"

# This flag tells Windows which release is the target
$RegKey2_name = "TargetReleaseVersionInfo"
$regKey2_desiredValue = "21H1"
$regKey2_propType = "String"



# Clear the $Error variable
$Error.Clear()



# Defines the query and edit/add function
Function SetRegistryValue() {

    # Define the string parameters that this function requires
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        #[AllowEmptyString()]
        [string]$Path,
        [string]$valueName,
        [string]$desiredValue,
        [ValidateSet('Dword', 'Qword', 'String', 'MultiString', 'ExpandedString', 'Binary', 'Unknown')]
        [string]$propertyType
    )

    try
        {
            # Clear the error variable at each run of the function
            $Error.Clear()

            # Get the reg value's current contents
            $valueContents = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction Stop | Select-Object -ExpandProperty $valueName
            Write-Host Current value: $valueContents

            # Check the reg value contents, and update them if not already set to desired value
            if ($valueContents -ne $desiredValue)
                {
                    Write-Host Setting value to $desiredValue
                    Set-ItemProperty -Path $registryPath -Name $valueName -Value $desiredValue
                    
                    # Make sure the key's value was properly set by the preceding command
                    $newValueContents = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction Stop | Select-Object -ExpandProperty $valueName
                    if ($newValueContents -eq $desiredValue)
                        {
                            Write-Host New value: $newValueContents. Function was successful.
                            return
                        }
                    else
                        {
                            Write-Warning Unable to set the value of $valueName to $desiredValue
                            Write-Host $Error
                            return
                        }
                }
            else
                {
                    Write-Host Value is aready set to $desiredValue.
                    return
                }

            exit
        } # End try block

    catch [System.Management.Automation.PSArgumentException]
        {
            # The key does not exist, create it and set the value
            Write-Host The $valueName value was NOT found at $registryPath. Creating it now...

            # Add the key/value
            Try
                {
                    New-ItemProperty -Path $registryPath -Name $valueName -Value $desiredValue -PropertyType $propertyType -ErrorAction SilentlyContinue
                    Write-Host Added $valueName to the registry and set its value to $desiredValue
                    return
                }
            Catch
                {
                    Write-Host Unable to add the $valueName key!
                    Write-Host $Error
                    return
                }

            Write-Host

            return
        }

    catch [System.Management.Automation.ItemNotFoundException]
        {
            Write-Host The query failed. Double-check your REGISTRY PATH input.
            return
        }

    catch
        {
            Write-Host Something terrible happened while executing the registry query.
            Write-Host Specific exception type: $Error[0].Exception.GetType().FullName
            return
        }

} # End function SetRegistryValue



# Execute the query functions, using the expanded variables as parameters
SetRegistryValue -Path $registryPath -valueName $regKey1_name -desiredValue $regKey1_desiredValue -propertyType $regKey1_propType
SetRegistryValue -Path $registryPath -valueName $regKey2_name -desiredValue $regKey2_desiredValue -propertyType $regKey2_propType
