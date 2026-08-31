# Define a function to check and enable Windows Firewall
function Enable-WindowsFirewall {
    param (
        [string]$ComputerName = "localhost",
        [pscredential]$Credential = $null
    )

    if ($ComputerName -eq "localhost") {
        # Check current status first
        $profiles = Get-NetFirewallProfile
        $allEnabled = ($profiles | Where-Object { $_.Enabled -eq $false }).Count -eq 0

        if ($allEnabled) {
            Write-Output "Windows Firewall is already enabled on $ComputerName."
        } else {
            if (Get-Command Set-NetFirewallProfile -ErrorAction SilentlyContinue) {
                Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
            } else {
                netsh advfirewall set allprofiles state on
            }
            Write-Output "Windows Firewall has been enabled on $ComputerName."
        }
    } else {
        try {
            $result = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
                $profiles = Get-NetFirewallProfile
                $allEnabled = ($profiles | Where-Object { $_.Enabled -eq $false }).Count -eq 0

                if ($allEnabled) {
                    "ALREADY_ENABLED"
                } else {
                    if (Get-Command Set-NetFirewallProfile -ErrorAction SilentlyContinue) {
                        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
                    } else {
                        netsh advfirewall set allprofiles state on
                    }
                    "NOW_ENABLED"
                }
            }

            if ($result -eq "ALREADY_ENABLED") {
                Write-Output "Windows Firewall is already enabled on $ComputerName."
            } else {
                Write-Output "Windows Firewall has been enabled on $ComputerName."
            }
        } catch {
            Write-Output "Failed to enable Windows Firewall on $ComputerName."
        }
    }
}

# Main script logic
Write-Output "Choose an option:"
Write-Output "1. Perform task on local machine"
Write-Output "2. Perform task on remote machines"
$choice = Read-Host "Enter your choice (1 or 2)"

# Option handling
switch ($choice) {
    "1" {
        # Check and enable firewall on the local machine
        Enable-WindowsFirewall
    }
    "2" {
        # Get the list of remote machine names or IP addresses
        $remoteMachines = Read-Host "Enter a comma-separated list of remote machine names or IP addresses"
        $remoteMachinesArray = $remoteMachines -split ','

        # Prompt for credentials once to use for all remote machines
        $credential = Get-Credential

        # Loop through each remote machine
        foreach ($machine in $remoteMachinesArray) {
            $trimmedMachine = $machine.Trim()
            Enable-WindowsFirewall -ComputerName $trimmedMachine -Credential $credential
        }
    }
    default {
        Write-Output "Invalid choice. Please enter either 1 or 2."
    }
}