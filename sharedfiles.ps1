
#computerNames = ''
#$computerNames = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name

$sum = $computerNames.Count
$index = 0
$errorIndex=0


foreach ($computerName in $computerNames) {
    $index++
    Write-Host "Total number of computers: $sum"
    Write-Host "Number of computers worked on: $index"

    try {
        $smbShares = Get-SmbShare -CimSession $computerName -ErrorAction Stop
         $errorIndex++
         Write-Host "Number of computers giving errors: $errorIndex"
        if ($smbShares) {
            foreach ($smbShare in $smbShares) {
                $sharedWith = (Get-SmbShareAccess -Name $smbShare.Name -CimSession $computerName).AccountName -join ','

                $files = Get-ChildItem -Path $smbShare.Path -File -ErrorAction Stop
                if ($files) {
                    foreach ($file in $files) {
                        $fileInfo = [PSCustomObject] @{
                            'ComputerName' = $computerName
                            'ShareName' = $smbShare.Name
                            'File name' = $file.Name
                            'SharedWith' = $sharedWith
                        }
                        $fileInfo | Export-Csv -Path "output.csv" -NoTypeInformation -Append
                        Write-Host "Computer Name: $computerName, Share Name: $($smbShare.Name), File Name: $($file.Name), Shared With: $sharedWith"
                    }
                }
                else {
                    $fileInfo = [PSCustomObject] @{
                        'ComputerName' = $computerName
                        'ShareName' = $smbShare.Name
                        'File name' = 'No files found'
                        'SharedWith' = $sharedWith
                    }
                    $fileInfo | Export-Csv -Path "output.csv" -NoTypeInformation -Append
                    Write-Host "No files found for Computer Name: $computerName, Share Name: $($smbShare.Name), Shared With: $sharedWith"
                }
            }
        }
    }
    catch {
   

        $errorInfo = [PSCustomObject] @{
            'ComputerName' = $computerName
            'ShareName' = 'Error'
            'File name' = 'Error'
            'SharedWith' = 'Error'
        }
        $errorInfo | Export-Csv -Path "output.csv" -NoTypeInformation -Append
        Write-Host "Error occurred for Computer Name: $computerName"
    }
}
 Write-Host "Script is completed"