# March 2021 - Microsoft updates cause PCs to blue-screen when users print stuff. Super fun.
# https://www.windowslatest.com/2021/03/10/windows-10-kb5000802-march-update-is-crashing-pcs-with-bsod/


# Preflight - make sure we're not hitting Servers or non-W10/8.1 devices
$OS = (Gwmi win32_operatingsystem | select Caption).Caption
if ($OS -notmatch "Windows 10")
    {
        Write-Host This is not for you - not w10.
    }
elseif ($OS -notmatch "Windows 8.1")
    {
        Write-Host This is not for you - not w8.
        exit
    }


# Preflight make sure OS is 64-bit. I hate that it's even a question in 2021.
$OSarch = (Get-CimInStance Win32_OperatingSystem).OSArchitecture
if ($OSarch -notmatch "64-Bit")
    {
        Write-Host This is not for x86 neanderthals.
        exit
    }


##################################################
######### FIRST, ENABLE DIRECT PRINTING ##########
##################################################


# Get all the printer names
$printers = Get-Printer
$names = New-Object Collections.Generic.List[String]

ForEach ($printer in $printers)
    {
        $names += $printer.Name
    }

ForEach ($name in $names)
    {
        Try
            {
                $error.Clear()
                rundll32 printui.dll,PrintUIEntry /Xs /n "$name" attributes +direct
            }
        catch
            {
                Write-Host Failed spectacularly while enabling direct printing.
                Write-Host $error
            }
    }

Write-Host Enabled direct printing for all applicable printers.




################################################
#### THEN, DOWNLOAD AND INSTALL THE HOTFIX #####
################################################


# Some initial URL variables for the hotfixes
$downloadPath = "C:\ProgramData\IIT\March2021-printerHotfix.msu"

$url_19041or2 = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2021/03/windows10.0-kb5001567-x64_e3c7e1cb6fa3857b5b0c8cf487e7e16213b1ea83.msu"

$url_18363 = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2021/03/windows10.0-kb5001566-x64_b52b66b45562d5a620a6f1a5e903600693be1de0.msu"

#$url_18362 = "N/A apparently"

$url_17763 = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2021/03/windows10.0-kb5001568-x64_cbfb9504eda6bf177ad678c64b871a3e294514ce.msu"

$url_17134 = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2021/03/windows10.0-kb5001565-x64_18a2f1393a135d9c3338f35dedeaeba5a2b88b19.msu"

$url_windows81 = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2021/03/windows8.1-kb5001640-x64_7aa82103f5e37a9d3c2ce2b608c903ed0855ac3b.msu"


# Get the Windows version
$version = (gwmi win32_operatingsystem | select Version).Version
$version = $version.Substring($version.length -5, 5)


# Check the Windows version and download the appropriate hotfix
if (($version -eq 19042) -or ($version -eq 19041)) #20H2 or 2004
    {
        Try
            {
                $error.Clear()
                $client = New-Object System.Net.WebClient
                $client.DownloadFile($url_19041or2, $downloadPath)
                wusa.exe $downloadPath /quiet /norestart
                Write-Host Installed the hotfix.
                exit
            }
        catch
            {
                Write-Host Script FAILED!!!
                Write-Host $error
                exit
            }
    }

elseif ($version -eq 18363) #1909
    {
        Try
            {
                $error.Clear()
                $client = New-Object System.Net.WebClient
                $client.DownloadFile($url_18363, $downloadPath)
                wusa.exe $downloadPath /quiet /norestart
                Write-Host Installed the hotfix.
                exit
            }
        catch
            {
                Write-Host Script FAILED!!!
                Write-Host $error
                exit
            }
    }

elseif ($version -eq 17763) #1809
    {
        Try
            {
                $error.Clear()
                $client = New-Object System.Net.WebClient
                $client.DownloadFile($url_17763, $downloadPath)
                wusa.exe $downloadPath /quiet /norestart
                Write-Host Installed the hotfix.
                exit
            }
        catch
            {
                Write-Host Script FAILED!!!
                Write-Host $error
                exit
            }
    }

elseif ($version -eq 17134) #1803
    {
        Try
            {
                $error.Clear()
                $client = New-Object System.Net.WebClient
                $client.DownloadFile($url_17134, $downloadPath)
                wusa.exe $downloadPath /quiet /norestart
                Write-Host Installed the hotfix.
                exit
            }
        catch
            {
                Write-Host Script FAILED!!!
                Write-Host $error
                exit
            }
    }

elseif ((gwmi win32_operatingsystem | select Version).Version -eq "6.3.9600") #Windows 8.1
    {
        Try
            {
                $error.Clear()
                $client = New-Object System.Net.WebClient
                $client.DownloadFile($url_windows81, $downloadPath)
                wusa.exe $downloadPath /quiet /norestart
                Write-Host Installed the hotfix.
                exit
            }
        catch
            {
                Write-Host Script FAILED!!!
                Write-Host $error
                exit
            }
    }

else
    {
        Write-Host This OS is not covered by this hotfix!
        exit
    }


