# Set folder permissions for SYSPRO directories
# Modify $clientFolderPath and $programFolderPath as needed for other stuff
# http://www.tomsitpro.com/articles/powershell-manage-file-system-acl,2-837.html
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-acl?view=powershell-6


# Clear the built-in $Error variable
$Error.Clear()


# Get the computer name as a string, in case it's needed later
$pcName = $env:COMPUTERNAME


# Define the folder paths for use later
$clientFolderPath = "C:\SYSPRO7Client"
$programFolderPath = "C:\ProgramData\Syspro"


# Before doing anything, see if those folders even exist
if ((!(Test-Path $clientFolderPath)) -and (!(Test-Path $programFolderPath)))
    {
        Write-Host $pcName does not have the Syspro folders. Nothing to do.
        exit
    }


# Get the current ACL objects for the folders in question
#$clientFolderAcl = Get-Acl -Path $clientFolderPath
#$programFolderAcl = Get-Acl -Path $programFolderPath


# Define the new Acl rule giving full control to the local machine's Users group, force inheritance for sub-objects
#$newLocalUsersAcl = New-Object System.Security.AccessControl.FileSystemAccessRule("Users","FullControl","ContainerInherit,ObjectInherit","None","Allow")


# Define the new Acl rule giving full control to the domain's Users group, force inheritance for sub-objects
# This will fail if trust relationship is broken
#$newDomainUsersAcl = New-Object System.Security.AccessControl.FileSystemAccessRule("<domain>\Users","FullControl","ContainerInherit,ObjectInherit","None","Allow")


# Add the new Acl rules to the Acl objects grabbed earlier
# Does not work in Windows 7 / Server 2008
<#try
    {
        $clientFolderAcl.SetAccessRule($newLocalUsersAcl)
        $clientFolderAcl.SetAccessRule($newDomainUsersAcl)
        $programFolderAcl.SetAccessRule($newLocalUsersAcl)
        $programFolderAcl.SetAccessRule($newDomainUsersAcl)
    }
catch
    {
        Write-Host Failed to set Acl objects.
        Write-Host $Error
        exit
    }
#>


# Reorder the permissions
try
    {
        icacls "C:\ProgramData\Syspro" /verify /T > NULL
        icacls "C:\SYSPRO7Client" /verify /T > NULL
        Write-Host Re-ordered permissions.`r`n
    }
catch
    {
        Write-Host Failed to re-order permissions!`r`n
        exit
    }


# Finally, apply the new ACL to the folders

# This PS doesn't work on Server 2008 / Windows 7
#Set-Acl -Path $clientFolderPath -AclObject $clientFolderAcl -ErrorAction SilentlyContinue
#Set-Acl -Path $programFolderPath -AclObject $programFolderAcl -ErrorAction SilentlyContinue

# Use icacls to cover Server 2008 and Windows 7 machines
try
    {
        icacls "C:\SYSPRO7Client" /grant:r "Domain Users":"(OI)(CI)F" /t > NULL
        icacls "C:\ProgramData\Syspro" /grant:r "Domain Users":"(OI)(CI)F" /t > NULL
        Write-Host Finished setting ACLs.`r`n
        exit
    }
catch
    {
        Write-Host Failed to apply permissions!`r`n
        Write-Host $Error
        exit
    }


<#
# Finish up and report any errors
if ($Error)
    {
        Write-Host Something bad happened.`r`n
        Write-Host $Error
        exit
    }
else
    {
        Write-Host Finished setting ACLs.
        exit
    }
#>
