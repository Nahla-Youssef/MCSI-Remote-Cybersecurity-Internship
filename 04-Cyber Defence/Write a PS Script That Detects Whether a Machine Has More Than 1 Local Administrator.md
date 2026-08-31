# Cyber Defence: Write a PS Script That Detects Whether a Machine Has More Than 1 Local Administrator

---

## Objectives
- Write a PowerShell script that detects whether a machine has more than one local Administrator (including administrators nested inside groups), both locally and on a remote machine.
- Validate the script against a realistic test setup with multiple test groups and accounts nested into the Administrators group.

---

## Environment
- **PC-Local** (Windows 10)
- **VM-Remote** (Windows 10)

---

## Files Used

[Download the file: check-admins.ps1](./Documentation/)

- `check-admins.ps1` — located at `C:\Users\nahla\Desktop` on PC-Local.

---

## Steps

### 1. PC-Local (PowerShell as Administrator) — build the test scenario
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
winrm quickconfig -Force
Enable-PSRemoting -Force
net localgroup TestGroup1 /add
net localgroup Administrators "TestGroup1" /add
net localgroup TestGroup2 /add
net localgroup Administrators "TestGroup2" /add
net user tempadmin1 pw123 /add
net localgroup TestGroup1 tempadmin1 /add
net user tempadmin2 pw123 /add
net localgroup TestGroup2 tempadmin2 /add
net localgroup Administrators
cd C:\Users\nahla\Desktop
.\check-admins.ps1
```
Choose `1` (local).

### 2. VM-Remote (PowerShell as Administrator) — build a larger test scenario
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
winrm quickconfig -Force
Enable-PSRemoting -Force
ipconfig
net localgroup TestGroup1 /add
net localgroup Administrators "TestGroup1" /add
net localgroup TestGroup2 /add
net localgroup Administrators "TestGroup2" /add
net user tempadmin1 pw123 /add
net localgroup TestGroup1 tempadmin1 /add
net user tempadmin2 pw123 /add
net localgroup TestGroup2 tempadmin2 /add
net user tempadmin3 pw123 /add
net localgroup Administrators tempadmin3 /add
net user tempadmin4 pw123 /add
net localgroup Administrators tempadmin4 /add
net localgroup Administrators
```

### 3. PC-Local (PowerShell as Administrator) — run against the remote machine
```
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "IP_VM-Remote"
Enter-PSSession -ComputerName IP_VM-Remote -Credential (Get-Credential)
exit
.\check-admins.ps1
```
Choose `2` (remote), then enter `IP_VM-Remote` when prompted.

### 4. Cleanup (after recording)

**PC-Local (PowerShell as Administrator):**
```
net user tempadmin1 /delete
net user tempadmin2 /delete
net localgroup TestGroup1 /delete
net localgroup TestGroup2 /delete
```

**VM-Remote (PowerShell as Administrator):**
```
net user tempadmin1 /delete
net user tempadmin2 /delete
net user tempadmin3 /delete
net user tempadmin4 /delete
net localgroup TestGroup1 /delete
net localgroup TestGroup2 /delete
```

---

## My Solution:

[View My Solution:](https://youtu.be/_PK4yVW1xGQ)

---
