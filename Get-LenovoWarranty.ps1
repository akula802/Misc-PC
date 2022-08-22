# Query Lenovo API and get warranty status by S/N


# Build the query params
$lookup_base_url = "https://supportapi.lenovo.com/v2.5/warranty?Serial"
$serial_number = (gwmi win32_computersystemproduct | select IdentifyingNumber).IdentifyingNumber
$client_id = "<get one from your sales rep or account manager>"


# Build the header - auth is via a 'ClientId' value in the header
# The ClientId is the token you get from your lenovo rep
$headers = @{
    'ClientId' = $client_id
}


# Send the request and store the result in a variable
$request_result = Invoke-RestMethod -Uri "$lookup_base_url=$serial_number" -Headers $headers


# Instead of calling by position, loop the .Warranty list for the proper values
# Some computers return 1, 2, or 3 items here, probably in varying order
$warranty_item_count = $request_result.Warranty.Count

ForEach ($item in $request_result.Warranty) {

    # get the battery warranty info first
    if ($item.Description -match 'Battery') {
        $battery_warranty_end_date = ([DateTime]$item.End).ToString('MM-dd-yyyy')
    }

    # Then get the PC warranty
    else {
        $pc_warranty_start_date = ([DateTime]$item.Start).ToString('MM-dd-yyyy')
        $pc_warranty_end_date = ([DateTime]$item.End).ToString('MM-dd-yyyy')
    }

} # End ForEach $item in $request_result.Warranty



# Parse the results
$now = Get-Date
$warranty_active_bool = $request_result.InWarranty
$pc_approx_age = [Math]::Round((((New-TimeSpan -Start $pc_warranty_start_date -End $now).Days / 31) / 12), 2)
$pc_ship_date = ([DateTime]$request_result.Shipped).ToString('MM-dd-yyyy')


# Display some info about the number of warranty items returned
if ($warranty_item_count -eq '1') {
    Write-Host `r`nTotal Warranty Items: $warranty_item_count `(typical`)
}
elseif ($warranty_item_count -eq '2') {
    Write-Host `r`nTotal Warranty Items: $warranty_item_count `(typical`, PC and battery have separate terms`)
}
elseif ($warranty_item_count -eq '3') {
    Write-Host `r`nTotal Warranty Items: $warranty_item_count `(non-typical`, may have an add-on warranty`)
}


# Show RAW results, for testing
#$request_result


# Display results to console
Write-Host `r`nActive Warranty: $warranty_active_bool
Write-Host PC Age in Years `(approx`): $pc_approx_age 
Write-Host PC Ship Date: $pc_ship_date
Write-Host PC Warranty Start Date: $pc_warranty_start_date
Write-Host PC Warranty End Date: $pc_warranty_end_date
Write-Host Battery Warranty End Date: $battery_warranty_end_date

