# Script to get path to an .exe and allow it though the Windows Firewall
# Created for a client's '8x8' telephony app, which requires Admin approval for firewall exceptions at every update
# The users at this client are NOT local Administrators on their machines
# This app runs as an .exe (not a service) out of each users' AppData folder (a problem in itself)
# And the path to the .exe changes with each update, as the folder name is formatted like 8x8_n.n.n
# This script runs as a computer startup script via GPO



# Get the path(s) to the app, and return only the current one
# Current app has the highest number in the path string (e.g. 3.2.4 > 2.9.7)
Try
    {
        $Error.Clear()
        $appPath = (Get-Childitem "C:\Users\*\AppData\Local\8x8-work\*\8x8 work.exe" | Sort-Object -Descending | Select-Object -First 1).ToString()
    }

Catch [System.Management.Automation.RuntimeException]
    {
        # This exception is thrown for not found and sort issues
        Write-Host The executable was not found on this machine.
        exit
    }

Catch
    {
        # In the case of an unexpected exception, return the type so it can be added to a catch block later
        Write-Host An exception occurred while trying to find the executable.
        Write-Host Specific exception type: $Error[0].Exception.GetType().FullName
        exit
    }



# Exit the script if the app is not found
if ($Path)
    {
        Write-Host Current app is at: $appPath
    }
else
    {
        Write-Host App not found!
        exit
    }



# Check for the existence of a firewall rule allowing the app to accept unsolicited inbound traffic
$fwRuleName = "Allow8x8"

Try
    {
        $Error.Clear()
        $checkRule = Get-NetFirewallRule -Name $fwRuleName -ErrorAction SilentlyContinue
        if ($Error)
            {
                # Rule was not found, create it
                Write-Host Firewall rule $fwRuleName was not found. Creating it...
                
                Try
                    {
                        New-NetFirewallRule -Name $fwRuleName -DisplayName $fwRuleName -Profile Domain, Private -Direction Inbound -Program $appPath -Enabled True | Out-Null
                        Write-Host Firewall rule created: $fwRuleName
                        exit
                    }

                Catch
                    {
                        # In the case of an unexpected exception, return the type so it can be added to a catch block later
                        Write-Host An exception occurred while trying to find the firewall rule by name.
                        Write-Host Specific exception type: $Error[0].Exception.GetType().FullName
                        exit
                    }

            } # end if

        else
            {
                # Rule WAS found, make sure it has current app path
                Write-Host The $fwRuleName rule is present`, making sure it`'s current.
                $fwRule = Get-NetFirewallRule -Name $fwRuleName
                $fwRuleAppPath =  (Get-NetFirewallRule -Name $fwRuleName | Get-NetFirewallApplicationFilter).AppPath.ToString()
                #Write-Host Path: $fwRuleAppPath

                # Rule allows the current app path. Ensure it's enabled.
                if ($fwRule.Enabled -eq "False")
                    {
                        Write-Host Rule is disabled`. Enabling...
                        Set-NetFirewallRule -Name $fwRuleName -Enabled True
                    }
                
                if ($fwRuleAppPath -eq $appPath)
                    {
                        # Ideal condition. Rule is present and enabled, and app path is current
                        Write-Host We`'re all good here! Exiting...
                        exit
                    }
                else
                    {
                        # Rule is present and enabled, but app path is not correct. Update it.
                        Write-Host Rule is present and enabled`, but app path is not current. Updating...
                        Try
                            {
                                $fwAppFilterObject = Get-NetFirewallRule -Name $fwRuleName | Get-NetFirewallApplicationFilter
                                Set-NetFirewallApplicationFilter -InputObject $fwAppFilterObject -Program $appPath
                                Write-Host Done! We`'re all set here.
                                exit
                            }

                        Catch
                            {
                                Write-Host Unable to update the app path in the $fwRuleName rule!
                                exit
                            }

                        exit

                    } # end else
                
                exit

            } # End else

    } # End Try

Catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        # This is the exception thrown when the rule isn't found by name, but it never hits the Catch part?
        # So it's also handled in the 'if' block in the preceding 'try' block
        Write-Host The rule was not found.
        exit
    }

Catch
    {
        # In the case of an unexpected exception, return the type so it can be added to a catch block later
        Write-Host An exception occurred while trying to find the firewall rule by name.
        Write-Host Specific exception type: $Error[0].Exception.GetType().FullName
        exit
    }
