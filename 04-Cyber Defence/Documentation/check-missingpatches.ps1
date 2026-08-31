# Function to check for missing updates on a local machine
function Get-MissingUpdates {
    Write-Host "Checking for missing security updates on the local machine..." -ForegroundColor Yellow
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    $searchResult = $updateSearcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")

    $output = @()
    if ($searchResult.Updates.Count -eq 0) {
        $output += "No missing security updates found."
    } else {
        $output += "Missing security patches:"
        foreach ($update in $searchResult.Updates) {
            $severity = if ($update.MsrcSeverity) { $update.MsrcSeverity } else { "N/A" }
            $output += "KB: $($update.KBArticleIDs) - Title: $($update.Title) - Severity: $severity"
        }
    }
    $output | ForEach-Object { Write-Output $_ }
}

# Function to check installed updates on a local machine
function Get-InstalledUpdates {
    Write-Host "Listing installed security patches on the local machine..." -ForegroundColor Yellow
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    $searchResult = $updateSearcher.Search("IsInstalled=1 and Type='Software' and IsHidden=0")

    if ($searchResult.Updates.Count -eq 0) {
        Write-Output "No installed security updates found."
    } else {
        Write-Output "Installed security patches:"
        $patchList = foreach ($update in $searchResult.Updates) {
            $severity = if ($update.MsrcSeverity) { $update.MsrcSeverity } else { "N/A" }
            $kb = if ($update.KBArticleIDs -and $update.KBArticleIDs.Count -gt 0) { ($update.KBArticleIDs -join ', ') } else { "N/A" }
            [PSCustomObject]@{
                KB       = $kb
                Title    = $update.Title
                Severity = $severity
            }
        }
        $patchList | Format-Table -Property @{Label="KB";Expression={$_.KB};Width=10}, @{Label="Title";Expression={$_.Title};Width=70}, @{Label="Severity";Expression={$_.Severity};Width=12} -Wrap
    }
}

# Function to scan remote machines for missing updates with simplified output
function Get-RemoteMissingUpdates {
    param (
        [string]$ComputerName
    )

    Write-Host "Checking for missing security updates on remote machine: $ComputerName..." -ForegroundColor Yellow
    $results = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        $updateSearcher = $updateSession.CreateUpdateSearcher()
        $searchResult = $updateSearcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")

        $output = @()
        if ($searchResult.Updates.Count -eq 0) {
            $output += "No missing security updates found on $env:COMPUTERNAME."
        } else {
            $output += "Missing security patches on $env:COMPUTERNAME:"
            foreach ($update in $searchResult.Updates) {
                $severity = if ($update.MsrcSeverity) { $update.MsrcSeverity } else { "N/A" }
                $output += "KB: $($update.KBArticleIDs) - Title: $($update.Title) - Severity: $severity"
            }
        }
        return $output
    }

    # Output all results once the command completes
    $results | ForEach-Object { Write-Output $_ }
}

# Function to scan remote machines for installed updates with an organized table view
function Get-RemoteInstalledUpdates {
    param (
        [string]$ComputerName
    )

    Write-Host "Listing installed security patches on remote machine: $ComputerName..." -ForegroundColor Yellow
    $results = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        $updateSearcher = $updateSession.CreateUpdateSearcher()
        $searchResult = $updateSearcher.Search("IsInstalled=1 and Type='Software' and IsHidden=0")

        if ($searchResult.Updates.Count -eq 0) {
            return "No installed security updates found on $env:COMPUTERNAME."
        } else {
            foreach ($update in $searchResult.Updates) {
                $severity = if ($update.MsrcSeverity) { $update.MsrcSeverity } else { "N/A" }
                $kb = if ($update.KBArticleIDs -and $update.KBArticleIDs.Count -gt 0) { ($update.KBArticleIDs -join ', ') } else { "N/A" }
                [PSCustomObject]@{
                    KB       = $kb
                    Title    = $update.Title
                    Severity = $severity
                }
            }
        }
    }

    if ($results -is [string]) {
        Write-Output $results
    } else {
        Write-Output "Installed security patches on ${ComputerName}:"
        $results | Format-Table -Property @{Label="KB";Expression={$_.KB};Width=10}, @{Label="Title";Expression={$_.Title};Width=70}, @{Label="Severity";Expression={$_.Severity};Width=12} -Wrap
    }
}

# Main menu for local or remote machine scan
$choice = Read-Host "Do you want to scan a [L]ocal or [R]emote machine for missing patches? (L/R)"
if ($choice -eq 'L') {
    Get-MissingUpdates
    Get-InstalledUpdates
} elseif ($choice -eq 'R') {
    $remoteComputer = Read-Host "Enter the remote machine's name or IP address"
    Get-RemoteMissingUpdates -ComputerName $remoteComputer
    Get-RemoteInstalledUpdates -ComputerName $remoteComputer
} else {
    Write-Host "Invalid choice, please run the script again and select either 'L' or 'R'." -ForegroundColor Red
}
