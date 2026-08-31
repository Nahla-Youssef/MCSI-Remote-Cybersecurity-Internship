# Cyber Defence: Write a PS Script That Detects Installed Anti-Virus Software

---

## Objectives
- Write a PowerShell script that retrieves information about installed anti-virus software on a local Windows machine.
- Enhance the script to support running it against a remote Windows machine as well.
- Use WMI/CIM (via SecurityCenter2) to identify installed anti-virus software, with a fallback that checks AV-related Windows services and their running status.
- Display clear, descriptive output: the anti-virus product name and its status (enabled/disabled via Real-Time Protection).

---

## Environment
- **Local VM** (Windows 10) — AVG AntiVirus Free installed.
- **Remote VM** (Windows 10) — Avast Free AntiVirus installed.

---

## Tools
- **PowerShell** (`Get-WmiObject`, `Get-Service`) — used to query antivirus product info and service status.
- **WMI `Root\SecurityCenter2`** — Windows' built-in security product registry, queried for the `AntiVirusProduct` class.
- **AVG AntiVirus Free** — installed on the local machine for testing.
- **Avast Free AntiVirus** — installed on the remote machine for testing.
- **PowerShell Remoting (WinRM)** — used to run the script against the remote machine.

---

## Files Used

[Download the file: detect-antivirus.ps1](./Documentation/)

- `detect-antivirus.ps1` — saved on the local Windows 10 VM. Contains:

---

## Steps

### 1. Save the script
Save the PowerShell script content as `detect-antivirus.ps1` on the local Windows 10 VM.

### 2. Allow the script to run (if needed)
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### 3. Enable PowerShell Remoting between the local and target VMs
Get the IP address of the target remote machine, then trust it on the local machine:
```
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "the_other_Windows_IP_Address"
winrm quickconfig -Force
Enable-PSRemoting -Force
```

### 4. Install anti-virus software on both machines (test prerequisite)
- On the local machine: download and install **AVG AntiVirus Free**.
- On the remote machine: download and install **Avast Free AntiVirus**.

### 5. Run the script against the local machine
```
cd <path to detect-antivirus.ps1>
.\detect-antivirus.ps1
```
Choose option `1` (local machine). Confirm the script correctly detects AVG AntiVirus Free and reports its Real-Time Protection status.

### 6. Run the script against the remote machine
```
.\detect-antivirus.ps1
```
Choose option `2` (remote machine), then enter the remote machine's IP address when prompted. Confirm the script correctly detects Avast Free AntiVirus on the remote machine and reports its Real-Time Protection status.

---

## My Solution:

[View My Solution:](https://youtu.be/dv5c4BCfzDk)

---
