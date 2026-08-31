# Cyber Defence: Write a PS Script to Turn On Windows Defender

---

## Objectives
- Write a PowerShell script that checks whether Windows Defender's real-time protection is enabled, and enables it if not — both locally and on one or more remote machines.
- Validate the script against multiple starting states (already on, and off) both locally and remotely.

---

## Environment
- **VM1** (Windows 10)
- **VM2** (Windows 10)
- **PC-Local** (Windows 10) — runs the script against itself and both VMs.

---

## Files Used

[Download the file: enable-defender.ps1](./Documentation/)

- `enable-defender.ps1` — located on the Desktop of PC-Local.

---

## Steps

### VM1 — Test case: Defender already ON

Settings: **Windows Security → Virus & threat protection → Manage settings → Tamper Protection → Off**, then **Real-time protection → On**.

```
ipconfig
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
winrm quickconfig -Force
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "IP_PC-Local"
Set-Item -force WSMan:\localhost\Client\AllowUnencrypted $true
Set-Item -force WSMan:\localhost\Client\Auth\Digest $true
Set-Item -force WSMan:\localhost\Service\Auth\Basic $true
```

Verify:
```
Get-MpPreference | Select-Object DisableRealtimeMonitoring
```
Result: `False`

### VM2 — Test case: Defender OFF

Settings: **Tamper Protection → Off**, then **Real-time protection → Off**.

```
ipconfig
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
winrm quickconfig -Force
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "IP_PC-Local"
Set-Item -force WSMan:\localhost\Client\AllowUnencrypted $true
Set-Item -force WSMan:\localhost\Client\Auth\Digest $true
Set-Item -force WSMan:\localhost\Service\Auth\Basic $true
```

Verify:
```
Get-MpPreference | Select-Object DisableRealtimeMonitoring
```
Result: `True`

### PC-Local — Prepare remoting to both VMs
```
ipconfig
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
winrm quickconfig -Force
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "IP_VM1,IP_VM2"
Set-Item -force WSMan:\localhost\Client\AllowUnencrypted $true
Set-Item -force WSMan:\localhost\Client\Auth\Digest $true
Set-Item -force WSMan:\localhost\Service\Auth\Basic $true
```

Settings: **Tamper Protection → Off** (on PC-Local as well).

Test the remote connections:
```
Enter-PSSession -ComputerName IP_VM1 -Authentication Basic -Credential (Get-Credential)
exit
Enter-PSSession -ComputerName IP_VM2 -Authentication Basic -Credential (Get-Credential)
exit
```

### PC-Local — Run the script: local, already enabled
Settings: PC-Local Real-time protection = **On**.
```
cd C:\Users\YourUser\Desktop
.\enable-defender.ps1
```
Input: `localhost` → Output: "already enabled"

### PC-Local — Run the script: local, currently off
Settings: PC-Local Real-time protection = **Off**.
```
.\enable-defender.ps1
```
Input: `localhost`

### PC-Local — Run the script: remote, both VMs
```
.\enable-defender.ps1
```
Input: `IP_VM1,IP_VM2`

---

## My Solution:

[View My Solution:](https://youtu.be/wfEvun4UDWw)

---
