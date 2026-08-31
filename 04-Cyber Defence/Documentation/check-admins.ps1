# Define function to check local administrator accounts on a machine
function Check-LocalAdmin {
    param (
        [string]$MachineName
    )

    Write-Host "Checking local administrator accounts on $MachineName..."  # Debug line

    # Get local group memberships via WMI
    $adminsGroup = Get-WmiObject -Class Win32_Group -Filter "LocalAccount = TRUE AND Name = 'Administrators'" -ComputerName $MachineName
    $adminMembers = Get-WmiObject -Class Win32_GroupUser -ComputerName $MachineName | Where-Object { $_.GroupComponent -like "*$($adminsGroup.Name)*" }

    # Initialize an array to hold admin users and groups
    $adminUsersAndGroups = @()

    # Add users directly in the Administrators group
    foreach ($admin in $adminMembers) {
        $userName = $admin.PartComponent -replace '.*Domain="([^"]+)".*Name="([^"]+)".*', '$2'

        # Check if it's a user
        $userObject = Get-WmiObject -Class Win32_UserAccount -ComputerName $MachineName | Where-Object { $_.Name -eq $userName }
        
        if ($userObject) {
            # If it's a user, add to the list with (user)
            $adminUsersAndGroups += "$userName (user)"
        } else {
            # It's not a user, so it's likely a group (skip this item)
        }
    }

    # Now check for nested groups
    foreach ($admin in $adminMembers) {
        $groupName = $admin.PartComponent -replace '.*Domain="([^"]+)".*Name="([^"]+)".*', '$2'

        # Check if it's a group (skip processing nested groups if the group is not an actual user)
        $groupObject = Get-WmiObject -Class Win32_Group -ComputerName $MachineName | Where-Object { $_.Name -eq $groupName }

        if ($groupObject) {
            # Now list the users in the nested group
            Write-Host "Nested Group: $groupName"  # Optional debug line
            $nestedGroupMembers = Get-WmiObject -Class Win32_GroupUser -ComputerName $MachineName | Where-Object { $_.GroupComponent -like "*$groupName*" }
            foreach ($nestedMember in $nestedGroupMembers) {
                $nestedUser = $nestedMember.PartComponent -replace '.*Domain="([^"]+)".*Name="([^"]+)".*', '$2'
                # Filter out groups (we only want actual user accounts)
                $nestedUserObject = Get-WmiObject -Class Win32_UserAccount -ComputerName $MachineName | Where-Object { $_.Name -eq $nestedUser }
                if ($nestedUserObject) {
                    Write-Host "  Nested User: $nestedUser"  # Output the nested user
                    $adminUsersAndGroups += "$nestedUser (user)"
                }
            }
        }
    }

    # Remove duplicates from the list
    $adminUsersAndGroups = $adminUsersAndGroups | Sort-Object -Unique

    # Count the total number of local administrator accounts
    $adminCount = $adminUsersAndGroups.Count

    # Alert if there is more than one local admin account
    if ($adminCount -gt 1) {
        Write-Warning "Alert: There are $adminCount local administrator accounts!"
    } else {
        Write-Host "There is $adminCount local administrator account."
    }

    # Display all the local admin users with machine name
    Write-Host "The Local Administrator Accounts on $MachineName are:"
    foreach ($adminUserOrGroup in $adminUsersAndGroups) {
        Write-Host "-> $adminUserOrGroup"  # Display each user with an arrow before it
    }
}

# Main script logic
$choice = Read-Host "Choose 1 for local machine or 2 for remote machine (Invalid input will be rejected)"

# Ensure valid input for machine type
if ($choice -eq "1") {
    # Check local machine
    Check-LocalAdmin -MachineName $env:COMPUTERNAME
} elseif ($choice -eq "2") {
    # Get list of remote machines (IP or hostnames)
    $remoteMachines = Read-Host "Enter a comma-separated list of remote machine names or IP addresses" 
    $remoteMachinesArray = $remoteMachines.Split(',')

    # Loop through the list of remote machines and check for local admins
    foreach ($machine in $remoteMachinesArray) {
        Write-Host "Checking local admins on $machine..."
        Check-LocalAdmin -MachineName $machine.Trim()
    }
} else {
    Write-Host "Invalid choice. Please enter 1 for local or 2 for remote."
}