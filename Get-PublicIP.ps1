# Just a one-liner I've been using lately, saving here for future reference

$publicIP4 = (Invoke-WebRequest -uri "https://api.ipify.org/").Content
Write-Host $publicIP4

