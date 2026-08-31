# PowerShell script to detect and disable LLMNR on local or remote machines

# Function to check LLMNR status
function Get-LLMNRStatus {
    param (
        [string]$ComputerName = $env:COMPUTERNAME
    )

    try {
        $llmnrRegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"
        $llmnrStatus = Get-ItemProperty -Path $llmnrRegPath -Name "EnableMulticast" -ErrorAction Stop | Select-Object -ExpandProperty EnableMulticast
        if ($llmnrStatus -eq 0) {
            Write-Output "LLMNR is currently disabled on $ComputerName."
            return $false
        }
        else {
            Write-Output "LLMNR is currently enabled on $ComputerName."
            return $true
        }
    } catch {
        Write-Output "LLMNR is not configured on $ComputerName. Defaulting to enabled."
        return $true
    }
}

# Function to disable LLMNR
function Disable-LLMNR {
    param (
        [string]$ComputerName = $env:COMPUTERNAME
    )

    $llmnrRegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"
    if (!(Test-Path $llmnrRegPath)) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT" -Name "DNSClient" -Force | Out-Null
    }

    Set-ItemProperty -Path $llmnrRegPath -Name "EnableMulticast" -Value 0 -Force
    Write-Output "LLMNR has been disabled on $ComputerName."
}

# Main script execution
Write-Output "Select an option:"
Write-Output "1 - Detect and disable LLMNR on the local machine"
Write-Output "2 - Detect and disable LLMNR on a remote machine"
$choice = Read-Host -Prompt "Enter your choice (1 or 2)"

if ($choice -eq "1") {
    # Local machine operation
    $llmnrEnabled = Get-LLMNRStatus -ComputerName $env:COMPUTERNAME
    if ($llmnrEnabled) {
        Disable-LLMNR -ComputerName $env:COMPUTERNAME
    }
} elseif ($choice -eq "2") {
    # Remote machine operation
    $remoteComputer = Read-Host -Prompt "Enter the remote computer name or IP address"
    try {
        $llmnrEnabled = Invoke-Command -ComputerName $remoteComputer -ScriptBlock {
            param ($remoteComputer)
            & {
                function Get-LLMNRStatus {
                    param ([string]$ComputerName)
                    $llmnrRegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"
                    try {
                        $llmnrStatus = Get-ItemProperty -Path $llmnrRegPath -Name "EnableMulticast" -ErrorAction Stop | Select-Object -ExpandProperty EnableMulticast
                        if ($llmnrStatus -eq 0) {
                            Write-Output "LLMNR is currently disabled on $ComputerName."
                            return $false
                        } else {
                            Write-Output "LLMNR is currently enabled on $ComputerName."
                            return $true
                        }
                    } catch {
                        Write-Output "LLMNR is not configured on $ComputerName. Defaulting to enabled."
                        return $true
                    }
                }
                Get-LLMNRStatus -ComputerName $using:remoteComputer
            }
        } -ArgumentList $remoteComputer

        # Print the status line(s) coming back from the remote machine
        $llmnrEnabled | Where-Object { $_ -is [string] } | ForEach-Object { Write-Output $_ }
        $llmnrEnabled = [bool]($llmnrEnabled | Where-Object { $_ -is [bool] } | Select-Object -Last 1)

        if ($llmnrEnabled) {
            Invoke-Command -ComputerName $remoteComputer -ScriptBlock {
                function Disable-LLMNR {
                    $llmnrRegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"
                    if (!(Test-Path $llmnrRegPath)) {
                        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT" -Name "DNSClient" -Force | Out-Null
                    }
                    Set-ItemProperty -Path $llmnrRegPath -Name "EnableMulticast" -Value 0 -Force
                }
                Disable-LLMNR
            }
            Write-Output "LLMNR has been disabled on $remoteComputer."
        } else {
            Write-Output "LLMNR is already disabled on $remoteComputer."
        }
    } catch {
        Write-Output "Failed to connect to $remoteComputer. Ensure that the remote machine is accessible and PowerShell remoting is enabled."
    }
} else {
    Write-Output "Invalid input. Please enter 1 or 2."
}
