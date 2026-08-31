# Cyber Defence: Write a PS Script to Turn On the Windows Firewall

---

## Objectives
- Write a PowerShell script that checks whether the Windows Firewall is enabled, and enables it if not — both locally and on one or more remote machines.
- Validate the script against multiple starting states (already enabled, disabled) both locally and remotely.

---

## Environment
3 machines, all Windows 10:
- **PC-Local** — saves and runs the script.
- **VM1** — firewall stays enabled (test case 1).
- **VM2** — firewall stays disabled (test case 2).

---

## Files Used

[Download the file: check-firewall.ps1](./Documentation/)

- `check-firewall.ps1` — saved on PC-Local.

---

## Steps

### PC-Local — Setup
Open PowerShell as Administrator:
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
winrm quickconfig -Force
Enable-PSRemoting -Force
```
Save the script as `check-firewall.ps1`.

### PC-Local — Local Test 1 (Firewall Enabled)
Turn Windows Firewall On (all profiles) via Windows Security settings.
```
.\check-firewall.ps1
```
Choose `1` (local machine). Confirm output: *"Windows Firewall is already enabled on localhost."*

### PC-Local — Local Test 2 (Firewall Disabled)
Turn Windows Firewall Off (all profiles) via Windows Security settings.
```
.\check-firewall.ps1
```
Choose `1` (local machine). Confirm output: *"Windows Firewall has been enabled on localhost."*

### VM1 — Setup (Firewall Enabled)
Get IP address:
```
ipconfig
```
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
winrm quickconfig -Force
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "IP_PC-Local"
Set-Item -force WSMan:\localhost\Client\AllowUnencrypted $true
Set-Item -force WSMan:\localhost\Service\AllowUnencrypted $true
Set-Item -force WSMan:\localhost\Client\Auth\Digest $true
Set-Item -force WSMan:\localhost\Service\Auth\Basic $true
```
If needed, fix network type:
```
Set-NetConnectionProfile -InterfaceAlias "Ethernet" -NetworkCategory Private
```
Turn Windows Firewall On manually.

### VM2 — Setup (Firewall Disabled)
Get IP address:
```
ipconfig
```
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
winrm quickconfig -Force
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "IP_PC-Local"
Set-Item -force WSMan:\localhost\Client\AllowUnencrypted $true
Set-Item -force WSMan:\localhost\Service\AllowUnencrypted $true
Set-Item -force WSMan:\localhost\Client\Auth\Digest $true
Set-Item -force WSMan:\localhost\Service\Auth\Basic $true
```
If needed, fix network type:
```
Set-NetConnectionProfile -InterfaceAlias "Ethernet" -NetworkCategory Private
```
Turn Windows Firewall Off manually.

### PC-Local — Final Remote Run
Add both VMs as trusted hosts:
```
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "IP_VM1,IP_VM2"
```
```
.\check-firewall.ps1
```
Choose `2` (remote machines). Enter IPs (no spaces): `IP_VM1,IP_VM2`. Enter credentials when prompted.

Confirm output:
```
Windows Firewall is already enabled on IP_VM1.
Windows Firewall has been enabled on IP_VM2.
```

---

## My Solution:

[View My Solution:](https://youtu.be/iULwrXYDzIk)

---
