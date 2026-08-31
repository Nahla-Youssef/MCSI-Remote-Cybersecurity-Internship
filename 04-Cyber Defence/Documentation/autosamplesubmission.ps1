# Enable Automatic Sample Submission on Windows Defender
function Enable-AutomaticSampleSubmission {
    param (
        [string[]]$RemoteComputers = @(),
        [pscredential]$Credential = $null
    )

    if ($RemoteComputers -contains "localhost") {
        # Local machine
        Write-Host "Checking and enabling Automatic Sample Submission on the local machine..." -ForegroundColor Yellow
        try {
            $currentSetting = (Get-MpPreference).SubmitSamplesConsent
            if ($currentSetting -ne 1) {
                Set-MpPreference -SubmitSamplesConsent 1
                Write-Host "Automatic Sample Submission has been enabled on the local machine." -ForegroundColor Green
            } else {
                Write-Host "Automatic Sample Submission is already enabled on the local machine." -ForegroundColor Green
            }
        } catch {
            Write-Host "Error on local machine: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # Remote machines
    $remoteMachines = $RemoteComputers | Where-Object { $_ -ne "localhost" }
    if ($remoteMachines.Count -gt 0) {
        foreach ($computer in $remoteMachines) {
            Write-Host "Checking and enabling Automatic Sample Submission on $computer..." -ForegroundColor Yellow
            try {
                # Test connection to the remote machine
                Test-Connection -ComputerName $computer -Count 1 -Quiet -ErrorAction Stop | Out-Null

                # Create a remote session with Basic Authentication
                $session = New-PSSession -ComputerName $computer -Credential $Credential -Authentication Basic -ErrorAction Stop
                $currentSetting = Invoke-Command -Session $session -ScriptBlock { (Get-MpPreference).SubmitSamplesConsent }
                if ($currentSetting -ne 1) {
                    Invoke-Command -Session $session -ScriptBlock { Set-MpPreference -SubmitSamplesConsent 1 }
                    Write-Host "Automatic Sample Submission has been enabled on $computer." -ForegroundColor Green
                } else {
                    Write-Host "Automatic Sample Submission is already enabled on $computer." -ForegroundColor Green
                }
                Remove-PSSession -Session $session
            } catch {
                Write-Host "Error on ${computer}: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

# Main script logic
do {
    # Prompt for machine names
    $machinesInput = Read-Host "Enter machine names or IP addresses (comma-separated). Type 'localhost' for local machine"
    $machinesArray = $machinesInput -split "," | ForEach-Object { $_.Trim() }

    if ($machinesArray.Count -eq 0) {
        Write-Host "You must provide at least one machine. Please try again."
    }
} while ($machinesArray.Count -eq 0)

# Determine if localhost is included
if ($machinesArray -contains "localhost") {
    # Perform tasks on local machine
    Enable-AutomaticSampleSubmission -RemoteComputers @("localhost")
}

# Handle remote machines
$remoteMachines = $machinesArray | Where-Object { $_ -ne "localhost" }
if ($remoteMachines.Count -gt 0) {
    $credential = Get-Credential -Message "Enter credentials for the remote machines"
    Enable-AutomaticSampleSubmission -RemoteComputers $remoteMachines -Credential $credential
}