# Write A PS Script To Turn On Hyper-V

# Store PowerShell cmdlet with parameters into a variable
$hyperVStatus = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All

# Function to enable Hyper-V
function Enable-HyperV {
    Write-Host "Enabling Hyper-V..." -ForegroundColor Yellow
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart
    Write-Host "Hyper-V has been enabled." -ForegroundColor Green
    # Ask if the user wants to reboot now
    $reboot = Read-Host "Would you like to restart now? (Y/N)"
    if ($reboot -eq "Y" -or $reboot -eq "y") {
        Write-Host "Rebooting the system..." -ForegroundColor Cyan
        Restart-Computer -Force
    } else {
        Write-Host "You can restart the system later for changes to take effect." -ForegroundColor Cyan
    }
}

# Check the current status of Hyper-V and act accordingly
if ($hyperVStatus.State -eq "Enabled") {
    Write-Host "Hyper-V is already enabled on this system." -ForegroundColor Green
} else {
    Write-Host "Hyper-V is disabled on this system." -ForegroundColor Red
    $enable = Read-Host "Would you like to enable Hyper-V? (Y/N)"
    if ($enable -eq "Y" -or $enable -eq "y") {
        Enable-HyperV
    } else {
        Write-Host "Hyper-V will remain disabled." -ForegroundColor Yellow
    }
}