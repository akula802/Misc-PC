# Saving for my own later reference and use in other scripts
# A series of functions to encode and hash strings



# Function to hash strings
Function Hash-String() {

    # Define the string parameters that this function requires
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$RawString,
        [ValidateSet('SHA1', 'SHA256')]
        [string]$Algorithm
    )

    # Create a memory stream from the string
    $mystream = [IO.MemoryStream]::new([byte[]][char[]]$RawString)

    # Hash the string from the stream
    $hashed = Get-FileHash -InputStream $mystream -Algorithm $Algorithm

    # Return the result
    return ($hashed).Hash

} # End function Hash-String



# Function to base64 encode strings
Function Base64Encode-String() {

    # Define the string parameters that this function requires
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$RawString
    )

    # Do the encoding
    $string64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($RawString))

    # Return the result
    return $string64

} # End function Base64Encode-String



# Function to URL-encode strings
Function UrlEncode-String() {

    # Define the string parameters that this function requires
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$RawString
    )

    # First you need to add the System.Web type
    Add-Type -AssemblyName System.Web

    # Do the encoding
    $stringUrl = [System.Web.HTTPUtility]::UrlEncode("$RawString")
    
    # Return the result
    return $stringUrl

} # End function UrlEncode-String



# Try it out, get some string inputs
$stringToHash = Read-Host Enter a string you want to hash
$stringToBase64 = Read-Host Enter a string you want to base64 encode
$stringtoUrlEncode = Read-Host Enter a string you want to URL-encode


# Call the functions
Hash-String -RawString $stringToHash -Algorithm SHA256
Base64Encode-String -RawString $stringToBase64
UrlEncode-String -RawString $stringtoUrlEncode


