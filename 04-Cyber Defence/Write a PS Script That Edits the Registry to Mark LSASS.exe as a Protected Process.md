# Cyber Defence: Write a PS Script That Edits the Registry to Mark LSASS.exe as a Protected Process

---

## Objectives
- Write a PowerShell script that enables LSA Protection (`RunAsPPL`) via the registry, both locally and on a remote machine.
- Prove the protection works by attempting a credential dump before enabling it (should succeed) and after enabling it (should fail).

---

## Environment
- **PC-A** (Windows 10) — runs the script, tested both locally and against a remote target.
- **PC-B** (Windows 10) — remote target machine.

---

## Files Used

[Download the file: Enable-LsaProtection.ps1](./Documentation/)

- `Enable-LsaProtection.ps1` — the script, located in `C:\LSA` (local run) — supports both a local mode (option 1) and a remote mode (option 2).
- `mimikatz.exe` — used only to validate (not exploit) the protection state before/after.

---

## Steps

### On PC-A — Baseline (before protection)

List the files in the LSA folder:
```
Get-ChildItem C:\LSA
```

Check the current LSA protection status (should be empty/disabled):
```
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -ErrorAction SilentlyContinue
```

Navigate to the Mimikatz folder and launch it:
```
cd C:\Mimikatz
.\mimikatz.exe
```

Inside Mimikatz, request debug privilege, then attempt to dump credentials from LSASS memory — this should succeed at this point, confirming protection is currently OFF. Exit Mimikatz when done.
```
privilege::debug
sekurlsa::logonpasswords
exit
```

### On PC-A — Enable LSA Protection (local)

Allow the script to run:
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Go to the script folder and run it, choosing **option 1 (local)**:
```
cd C:\LSA
.\Enable-LsaProtection.ps1
```

Restart the computer (required for the protection to take effect):
```
Restart-Computer
```

After restart, confirm protection is now enabled (should show `RunAsPPL : 1`):
```
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL"
```

### On PC-A — Confirm Protection Blocks Credential Dumping

Go to the Mimikatz tools folder and launch it again:
```
cd C:\Tools\Mimikatz
.\mimikatz.exe
```
Request debug privilege, then attempt a registry-based dump (expected to fail with a registry access error — not a valid protection test on its own) and a memory-based dump (should now fail — this is the real proof LSA protection is working). Exit Mimikatz when done.
```
privilege::debug
lsadump::cache
sekurlsa::logonpasswords
exit
```

**If Windows Defender blocks/deletes Mimikatz:**

Add an exclusion path for the Mimikatz folder:
```
Add-MpPreference -ExclusionPath "C:\Tools\Mimikatz"
```

Add an exclusion for the process itself:
```
Add-MpPreference -ExclusionProcess "mimikatz.exe"
```

Remove the old/corrupted folder before re-downloading, if needed:
```
Remove-Item -Path "C:\Tools\Mimikatz" -Recurse -Force -ErrorAction SilentlyContinue
```

### On PC-B — Prepare for Remote Test

Set up WinRM:
```
winrm quickconfig -Force
```

Enable PowerShell Remoting:
```
Enable-PSRemoting -Force
```

Allow WinRM through the firewall:
```
netsh advfirewall firewall set rule group="Windows Remote Management" new enable=yes
```

Check current LSA protection status (baseline before remote enable):
```
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -ErrorAction SilentlyContinue
```

Get this machine's IP address:
```
ipconfig
```

### On PC-A — Trust and Test Remote Connection

Trust PC-B's IP address for remoting:
```
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "<PC-B_IP>"
```

Test the remote connection:
```
Enter-PSSession -ComputerName <PC-B_IP> -Credential (Get-Credential)
exit
```

### On PC-A — Run the Script Remotely

Go to the script folder and run it, choosing **option 2 (remote)**, then enter PC-B's IP when prompted:
```
cd C:\LSA
.\Enable-LsaProtection.ps1
```

### On PC-B — Confirm Remote Success

Confirm LSA protection is now enabled remotely (should show `RunAsPPL : 1`):
```
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL"
```

---

## My Solution:

[View My Solution:](https://youtu.be/GGaQ-WpJwPY)

---
