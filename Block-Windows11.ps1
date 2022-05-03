# This script calls a re-useable, generic registry check+set function to block Windows 11
# Function queries the registry for a given VALUE, located at a given PATH (set in initial variables)
# If the value is found, contents are modified according to specs given
# If the value is not found, it is created


# Define some initial variables
$registryPath = "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

# This flag tells Windows that release targeting is desired
$regKey1_name = "TargetReleaseVersion"
$regKey1_desiredValue = "1"
$regKey1_propType = "Dword"

# This flag tells Windows which release is the target
$RegKey2_name = "TargetReleaseVersionInfo"
$regKey2_desiredValue = "21H2"
$regKey2_propType = "String"

# Added this one after reading: https://www.reddit.com/r/msp/comments/ugrhlb/windows_11_being_pushed/i72n3vu/
$RegKey3_name = "ProductVersion"
$regKey3_desiredValue = "Windows 10"
$regKey3_propType = "String"



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
            $valueContents = Get-ItemProperty -Path $Path -Name $valueName -ErrorAction Stop | Select-Object -ExpandProperty $valueName
            Write-Host Current value: $valueContents

            # Check the reg value contents, and update them if not already set to desired value
            if ($valueContents -ne $desiredValue)
                {
                    Write-Host Setting value to $desiredValue
                    Set-ItemProperty -Path $Path -Name $valueName -Value $desiredValue -ErrorAction SilentlyContinue
                    
                    # Make sure the key's value was properly set by the preceding command
                    $newValueContents = Get-ItemProperty -Path $Path -Name $valueName -ErrorAction Stop | Select-Object -ExpandProperty $valueName
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
            Write-Host The $valueName value was NOT found. Creating it now...

            # Add the key/value
            Try
                {
                    New-ItemProperty -Path $Path -Name $valueName -Value $desiredValue -PropertyType $propertyType -ErrorAction SilentlyContinue
                    Write-Host Added $valueName to the registry and set its value to $desiredValue
                    return
                }
            Catch
                {
                    Write-Host Unable to add the $valueName key!
                    Write-Host $Error
                    return
                }

            return
        } # End catch PSArgumentException

    catch [System.Management.Automation.ItemNotFoundException]
        {
            #Write-Host The query failed. Double-check your REGISTRY PATH input.
            Write-Host The WindowsUpdate key was not found, creating it now.
            # The 'Windows Update' item does not exist under the 'Windows' key
            # This has been a thing with new 21H1 installs and MDT-deployed 21H1 machines
            Try
                {
                    New-Item -Path $Path
                    New-ItemProperty -Path $Path -Name $valueName -Value $desiredValue -PropertyType $propertyType -ErrorAction SilentlyContinue
                    Write-Host Added $valueName to the registry and set its value to $desiredValue
                    return
                }
            Catch
                {
                    Write-Host Unable to add the $valueName key!
                    Write-Host $Error
                    return
                }

            return
        } # End catch itemNotFound

    catch
        {
            Write-Host Something terrible happened while executing the registry query.
            Write-Host Specific exception type: $Error[0].Exception.GetType().FullName
            Write-Host $Error
            return
        } # End general catch

} # End function SetRegistryValue



# Execute the query functions, using the expanded variables as parameters
SetRegistryValue -Path $registryPath -valueName $regKey1_name -desiredValue $regKey1_desiredValue -propertyType $regKey1_propType
SetRegistryValue -Path $registryPath -valueName $regKey2_name -desiredValue $regKey2_desiredValue -propertyType $regKey2_propType
SetRegistryValue -Path $registryPath -valueName $regKey3_name -desiredValue $regKey3_desiredValue -propertyType $regKey3_propType
