# Ensure the script is running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator!" -ForegroundColor Red
    exit
}

function Check-And-Enable-Defender {
    param (
        [string[]]$RemoteComputers
    )

    foreach ($computer in $RemoteComputers) {
        Write-Host "Processing: $computer" -ForegroundColor Cyan

        try {
            if ($computer -eq "localhost") {
                # Check and enable Defender on the local machine
                Process-Local-Defender
            } else {
                # Check and enable Defender on a remote machine
                $credentials = Get-Credential
                Process-Remote-Defender -ComputerName $computer -Credential $credentials
            }
        } catch {
            Write-Host "Error processing $computer" -ForegroundColor Red
        }
    }
}

function Process-Local-Defender {
    try {
        # Ensure the Defender service is running
        $service = Get-Service -Name WinDefend -ErrorAction Stop
        if ($service.Status -ne "Running") {
            Write-Host "Starting Windows Defender service locally..." -ForegroundColor Yellow
            Set-Service -Name WinDefend -StartupType Automatic
            Start-Service -Name WinDefend
        }

        # Check and enable real-time protection
        $DefenderStatus = Get-MpPreference
        if ($DefenderStatus.DisableRealtimeMonitoring -eq $false) {
            Write-Host "Windows Defender real-time protection is already enabled." -ForegroundColor Green
        } else {
            Write-Host "Enabling Windows Defender real-time protection locally..." -ForegroundColor Yellow
            Set-MpPreference -DisableRealtimeMonitoring $false
            Write-Host "Real-time protection enabled." -ForegroundColor Green

            # Force Windows Defender to update itself
            Write-Host "Updating Windows Defender signatures locally..." -ForegroundColor Yellow
            Update-MpSignature
            Write-Host "Windows Defender has been enabled and updated successfully." -ForegroundColor Green
        }

    } catch {
        Write-Host "Error enabling Defender locally" -ForegroundColor Red
    }
}

function Process-Remote-Defender {
    param (
        [string]$ComputerName,
        [pscredential]$Credential
    )
    try {
        # Create a remote session with Basic authentication
        $session = New-PSSession -ComputerName $ComputerName -Credential $Credential -Authentication Basic -ErrorAction Stop

        # Check Defender status on the remote machine
        Invoke-Command -Session $session -ScriptBlock {
            try {
                # Get Defender status
                $DefenderStatus = Get-MpPreference

                # Check real-time protection
                if ($DefenderStatus.DisableRealtimeMonitoring -eq $false) {
                    Write-Host "Real-time protection is already enabled on $env:COMPUTERNAME." -ForegroundColor Green
                } else {
                    Write-Host "Real-time protection is disabled on $env:COMPUTERNAME. Enabling now..." -ForegroundColor Yellow
                    Set-MpPreference -DisableRealtimeMonitoring $false
                    Write-Host "Real-time protection enabled on $env:COMPUTERNAME." -ForegroundColor Green

                    # Force Windows Defender to update itself
                    Write-Host "Updating Windows Defender signatures on $env:COMPUTERNAME..." -ForegroundColor Yellow
                    Update-MpSignature
                    Write-Host "Windows Defender has been enabled and updated successfully on $env:COMPUTERNAME." -ForegroundColor Green
                }

                # Check cloud-delivered protection
                if ($DefenderStatus.MAPSReporting -eq 2) {
                    Write-Host "Cloud-delivered protection is already enabled on $env:COMPUTERNAME." -ForegroundColor Green
                } else {
                    Write-Host "Cloud-delivered protection is not fully enabled on $env:COMPUTERNAME. Enabling now..." -ForegroundColor Yellow
                    Set-MpPreference -MAPSReporting Advanced
                    Write-Host "Cloud-delivered protection enabled on $env:COMPUTERNAME." -ForegroundColor Green
                }

            } catch {
                Write-Host "Error checking or enabling Defender status on $env:COMPUTERNAME" -ForegroundColor Red
            }
        }

        # Remove the session
        Remove-PSSession -Session $session
    } catch {
        Write-Host "Error enabling Defender on $ComputerName" -ForegroundColor Red
    }
}

# Main script logic
Write-Host "Windows Defender Management Script" -ForegroundColor Cyan
Write-Host "Enter a list of computer names or IP addresses (separated by commas):"
$inputComputers = Read-Host "Example: localhost, 192.168.1.10, RemotePC"

# Parse input into array
$computerList = $inputComputers -split ',' | ForEach-Object { $_.Trim() }

# Check and enable Defender
Check-And-Enable-Defender -RemoteComputers $computerList