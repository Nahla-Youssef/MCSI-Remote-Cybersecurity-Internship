# Cyber Defence: Write a PS Script That Copies Sysmon to Remote Machines and Installs It With a Given Configuration File

---

## Objectives
- Write a PowerShell script that copies Sysmon to a remote machine and installs it with a custom configuration file.
- Configure Sysmon to capture: unauthorized READ/WRITE access to `lsass.exe`, process command-line execution arguments, loaded drivers, and DLLs loaded by processes.
- Validate the deployment by generating test events and reviewing them in the Sysmon event log.

---

## Environment
- **PC-A** — Controller machine (Windows 10) — `192.168.1.10`
- **PC-B** — Target/remote machine (Windows 10) — `192.168.1.9`

> Note: If WinRM firewall exceptions don't work, one of the network connection types may be set to **Public** — change the network profile to **Private** first.

---

## Files Used

[Download the folder: Sysmon](./Documentation/)

- `Sysmon64.exe` — Sysmon executable (from Microsoft Sysinternals).
- `sysmon-config.xml` — custom Sysmon configuration file.
- `DeploySysmon.ps1` — deployment script that copies and installs Sysmon on the remote machine.

---

## Steps

### Part 1 — Enable PowerShell Remoting

**On PC-A (Controller):**
```
winrm quickconfig -Force
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "192.168.1.9"
Set-Item -force WSMan:\localhost\Client\AllowUnencrypted $true
Set-Item -force WSMan:\localhost\Client\Auth\Basic $true
```

**On PC-B (Target):**
```
winrm quickconfig -Force
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "192.168.1.10"
Set-Item -force WSMan:\localhost\Service\AllowUnencrypted $true
Set-Item -force WSMan:\localhost\Service\Auth\Basic $true
```

Fix the network profile if needed:
```
Get-NetConnectionProfile
Set-NetConnectionProfile -InterfaceAlias "Ethernet" -NetworkCategory Private
```

Test the connection from PC-A:
```
Enter-PSSession -ComputerName 192.168.1.9 -Authentication Basic -Credential (Get-Credential)
exit
```

### Part 2 — Prepare Files on PC-A

**2.1 Download Sysmon**

Download Sysmon from Microsoft Sysinternals, extract it, and copy `Sysmon64.exe` into `C:\Sysmon`. Verify:
```
Get-ChildItem C:\Sysmon
```
Expected output: `Sysmon64.exe` and `sysmon-config.xml`.

**2.2 Create the Sysmon configuration file**
```
notepad C:\Sysmon\sysmon-config.xml
```
Save the configuration content (capturing lsass.exe access, process creation with command-line arguments, driver loads, and DLL/image loads) and close.

**2.3 Create the deployment script**
```
notepad C:\Sysmon\DeploySysmon.ps1
```
Save the deployment script content, which:
1. Prompts for credentials.
2. Establishes a remote PowerShell session with Basic Authentication.
3. Copies the Sysmon executable and configuration file to the remote machine's `C:\Windows` directory.
4. Installs Sysmon remotely with the provided configuration.

**2.4 Allow the script to run (PC-A)**
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### Part 3 — Run the Deployment (from PC-A)
```
cd C:\Sysmon
.\DeploySysmon.ps1 -remoteMachine "192.168.1.9"
```
Expected output:
```
-> Establishing session with 192.168.1.9
-> Copying Sysmon executable and configuration file to the remote machine's C:\Windows directory
-> Installing Sysmon on 192.168.1.9
Installing Sysmon with new configuration...
-> Sysmon installation complete on 192.168.1.9
```

### Part 4 — Validate the Installation (on PC-B)
```
Get-Service Sysmon64
```
Expected output: `Status: Running`

### Part 5 — Generate Test Events (on PC-B)

Generate a Process Create event with command-line arguments:
```
cmd.exe /c whoami
```

Generate Image Load events (a program that loads DLLs) — close Notepad after it opens:
```
notepad.exe
```

### Part 6 — View the Captured Logs (on PC-B)

Via PowerShell:
```
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 20 | Format-Table TimeCreated, Id, Message -Wrap
```

Or via Event Viewer:
```
eventvwr.msc
```
Navigate to: **Applications and Services Logs → Microsoft → Windows → Sysmon → Operational**

---

## My Solution:

[View My Solution:](https://youtu.be/5OxMmBG826c)

---
