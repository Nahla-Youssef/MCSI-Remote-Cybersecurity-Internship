# Function to interpret product state and determine if AV is enabled based on SecurityCenter2
function Get-AntiVirusStatus {
    param(
        [int]$productState
    )
    # Check if the product is enabled by inspecting the second nibble of productState
    $enabled = ($productState -band 0x10) -ne 0
    return $enabled
}

# Function to get antivirus information using SecurityCenter2
function Get-AntiVirusInfo {
    param(
        [string]$ComputerName = $env:COMPUTERNAME
    )
    try {
        # Query SecurityCenter2 for antivirus products
        $antivirusInfo = Get-WmiObject -Namespace "Root\SecurityCenter2" -Class AntiVirusProduct -ComputerName $ComputerName

        # Exclude Windows Defender's leftover SecurityCenter2 entry so only the
        # actively managing third-party product (AVG / Avast) is reported.
        $antivirusInfo = $antivirusInfo | Where-Object { $_.displayName -notmatch "Windows Defender" }

        if ($antivirusInfo) {
            foreach ($av in $antivirusInfo) {
                Write-Host "Anti-Virus Software: $($av.displayName)" -ForegroundColor Magenta
            }
        } else {
            Write-Host "No anti-virus software detected in SecurityCenter2." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error retrieving anti-virus information from SecurityCenter2. Checking services as fallback." -ForegroundColor Red
    }
}

# Fallback function to check for installed antivirus services status
function Check-AntiVirusServiceStatus {
    param(
        [string]$ComputerName = $env:COMPUTERNAME
    )
    try {
        # Only match the actual installed AV product's services (AVG here,
        # use "Avast" on the remote machine) so unrelated services (Xbox,
        # AVCTP/Bluetooth, disabled Defender services) are not counted.
        $services = Get-Service -ComputerName $ComputerName | Where-Object { $_.DisplayName -match "AVG" }

        if ($services) {
            $allRunning = $true  # Initialize flag to track if all services are running

            foreach ($service in $services) {
                Write-Host "Service: $($service.DisplayName) - Status: $($service.Status)" -ForegroundColor Gray
                if ($service.Status -ne "Running") {
                    $allRunning = $false  # Set flag to false if any service is not running
                }
            }

            # Output the Real-Time Protection status after checking all services
            if ($allRunning) {
                Write-Host "Real-Time Protection: Enabled" -ForegroundColor Green
            } else {
                Write-Host "Real-Time Protection: Disabled" -ForegroundColor Red
            }
        } else {
            Write-Host "No antivirus services found." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error retrieving antivirus service status." -ForegroundColor Red
    }
}

# Prompt user for local or remote machine choice
$choice = Read-Host "Choose an option: 1 for Local Machine, 2 for Remote Machine"

if ($choice -eq "1") {
    Write-Host "Running on local machine..." -ForegroundColor Yellow
    Get-AntiVirusInfo
    Check-AntiVirusServiceStatus
} elseif ($choice -eq "2") {
    $remoteMachine = Read-Host "Enter the name or IP address of the remote machine"
    Write-Host "Running on remote machine: $remoteMachine..." -ForegroundColor Yellow
    Get-AntiVirusInfo -ComputerName $remoteMachine
    Check-AntiVirusServiceStatus -ComputerName $remoteMachine
} else {
    Write-Host "Invalid input. Please choose option 1 or 2." -ForegroundColor Red
}
