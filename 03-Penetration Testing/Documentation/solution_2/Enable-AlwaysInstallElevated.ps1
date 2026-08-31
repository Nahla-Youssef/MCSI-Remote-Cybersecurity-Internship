# PowerShell script to enable the AlwaysInstallElevated registry key

# Ensure the Installer registry key exists (created manually if missing)
New-Item -Path "HKLM:SOFTWARE\Policies\Microsoft\Windows\Installer" -Force | Out-Null
New-Item -Path "HKCU:SOFTWARE\Policies\Microsoft\Windows\Installer" -Force | Out-Null

# Enable AlwaysInstallElevated for Local Machine
$regPathLM = "HKLM:SOFTWARE\Policies\Microsoft\Windows\Installer"
Set-ItemProperty -Path $regPathLM -Name "AlwaysInstallElevated" -Value 1 -Force

# Enable AlwaysInstallElevated for Current User
$regPathCU = "HKCU:SOFTWARE\Policies\Microsoft\Windows\Installer"
Set-ItemProperty -Path $regPathCU -Name "AlwaysInstallElevated" -Value 1 -Force

Write-Host "AlwaysInstallElevated has been enabled for both HKLM and HKCU."
