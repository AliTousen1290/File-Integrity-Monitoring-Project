
Write-Host ""
Write-Host "What would you like to do?"
Write-Host "A) Collect new Baseline?"
Write-Host "B) Begin Monitoring files with saved Baseline?"
Write-Host ""

$response = Read-Host -Prompt "Please enter 'A' or 'B'"
Write-Host ""

Function Calculate-File-Hash($filepath) {
   $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
   return $filehash
}

Function Erase-duplicate-baseline() {
    $baselineExists = Test-Path -Path .\baseline.txt

    if ($baselineExists) {
        # #Deletes baseline
        Remove-Item -Path .\baseline.txt
    }

}

if ($response -eq "A".ToUpper()) {
    # Delete baseline.txt if it already exists
    Erase-duplicate-baseline
    # Calculate Hash from the target files and store in baseline.txt

    # Collect all files in the target folder
    $files = Get-ChildItem -Path .\fim

    #For each file, calculate the hash and write to baseline.txt
    foreach ($f in $files) {
      $hash = Calculate-File-Hash $f.FullName
      "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
    }

}
elseif ($response -eq "B".ToUpper()) {

    $fileHashDictionary = @{}

    # Load file|hash from baseline.txt and store them in a dictionary
    $filePathsAndHashes = Get-Content -Path .\baseline.txt

    foreach ($f in $filePathsAndHashes) {
        $fileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
    }

    # Begin monitoring files with saved Baseline
    while ($true) {
        Start-Sleep -Seconds 1

        $files = Get-ChildItem -Path .\Files

        # For each file, calculate the hash and write to baseline.txt
        foreach ($f in $files) {
            $hash = Calculate-File-Hash $f.FullName
            #"$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append

            # Notify if a new file has been created.
            if ($fileHashDictionary[$hash.Path] -eq $null) {
                # A new file has been created
                Write-Host "$($hash.Path) has been created!" -ForegroundColor Green
            }

            else {
            # Notify if a new file has been changed
                if ($fileHashDictionary[$hash.Path] -eq $hash.Hash) {
                    #The file has not been changed
                }
                else {
                # File has been compromised! Notify User
                Write-Host "$($hash.Path) has changed!!!" -ForegroundColor Red
                }

            }
        }
    }
}
