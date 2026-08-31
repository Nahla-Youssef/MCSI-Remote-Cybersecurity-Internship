# PowerShell Script to Enable LSA Protection for lsass.exe
# Compatible with Windows Vista and later

# Constants
$lsaKeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$lsaValueName = "RunAsPPL"
$enabledValue = 1

# Function to enable LSA protection on the local machine
function Enable-LsaProtectionLocal {
    if ((Get-ItemProperty -Path $lsaKeyPath -Name $lsaValueName -ErrorAction SilentlyContinue).$lsaValueName -eq $enabledValue) {
        Write-Output "LSA protection is already enabled on the local machine."
    } else {
        Set-ItemProperty -Path $lsaKeyPath -Name $lsaValueName -Value $enabledValue
        Write-Output "LSA protection has been enabled for lsass.exe on the local machine."
    }
}

# Function to enable LSA protection on a remote machine
function Enable-LsaProtectionRemote {
    param (
        [string]$remoteComputer
    )

    if (Test-Connection -ComputerName $remoteComputer -Count 1 -Quiet) {
        try {
            $remoteValue = Invoke-Command -ComputerName $remoteComputer -ScriptBlock {
                param ($lsaKeyPath, $lsaValueName)
                (Get-ItemProperty -Path $lsaKeyPath -Name $lsaValueName -ErrorAction SilentlyContinue).$lsaValueName
            } -ArgumentList $lsaKeyPath, $lsaValueName

            if ($remoteValue -eq $enabledValue) {
                Write-Output "LSA protection is already enabled on $remoteComputer."
            } else {
                Invoke-Command -ComputerName $remoteComputer -ScriptBlock {
                    param ($lsaKeyPath, $lsaValueName, $enabledValue)
                    Set-ItemProperty -Path $lsaKeyPath -Name $lsaValueName -Value $enabledValue
                } -ArgumentList $lsaKeyPath, $lsaValueName, $enabledValue

                Write-Output "LSA protection has been enabled for lsass.exe on $remoteComputer."
            }
        } catch {
            Write-Output "An error occurred while trying to enable LSA protection on ${remoteComputer}: $_"
        }
    } else {
        Write-Output "Cannot reach $remoteComputer. Please check the network connection or machine name."
    }
}

# Main script logic
Write-Output "Choose an option:"
Write-Output "1. Enable LSA protection on the local machine"
Write-Output "2. Enable LSA protection on a remote machine"
$choice = Read-Host "Enter your choice (1 or 2)"

switch ($choice) {
    1 {
        Enable-LsaProtectionLocal
    }
    2 {
        $remoteComputer = Read-Host "Enter the name or IP address of the remote machine"
        Enable-LsaProtectionRemote -remoteComputer $remoteComputer
    }
    default {
        Write-Output "Invalid input. Please restart the script and choose 1 or 2."
    }
}