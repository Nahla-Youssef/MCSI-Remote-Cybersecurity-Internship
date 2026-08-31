# Cyber Defence: Write a PS Script to Turn On Automatic Sample Submission

---

## Objectives
- Write a PowerShell script that enables Windows Defender's Automatic Sample Submission setting on a local machine and/or one or more remote machines.
- Validate the change by checking the setting before and after running the script, both locally and remotely.

---

## Environment
- **PC-A** (Windows 10) — local machine, runs the script.
- **PC-B** (Windows 10) — remote target machine — `192.168.1.9`

---

## Files Used

[Download the file: autosamplesubmission.ps1](./Documentation/)

- `autosamplesubmission.ps1` — located at `C:\Users\nahla\Desktop`.

---

## Steps

### On PC-B — Get IP and disable the setting (baseline)

Get the IP address:
```
ipconfig
```
Result: `192.168.1.9`

Disable Automatic Sample Submission (so the script's effect can be tested later):
```
Set-MpPreference -SubmitSamplesConsent 2
```

### On PC-A — Prepare remoting

Allow script execution:
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Configure WinRM:
```
winrm quickconfig -Force
```

Enable PowerShell Remoting:
```
Enable-PSRemoting -Force
```

Add PC-B as a trusted host:
```
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "192.168.1.9"
```

Allow unencrypted traffic (client side):
```
Set-Item -force WSMan:\localhost\Client\AllowUnencrypted $true
```

Enable Digest authentication:
```
Set-Item -force WSMan:\localhost\Client\Auth\Digest $true
```

Enable Basic authentication (service side):
```
Set-Item -force WSMan:\localhost\Service\Auth\Basic $true
```

Test the remote connection:
```
Enter-PSSession -ComputerName 192.168.1.9 -Authentication Basic -Credential (Get-Credential)
```
Enter PC-B's username and password when prompted.

Exit the remote session:
```
exit
```

### On PC-A — Disable the setting locally too (baseline)
```
Set-MpPreference -SubmitSamplesConsent 2
```

### On PC-A — Run the script

Navigate to the script location:
```
cd C:\Users\nahla\Desktop
```

Run the script, targeting both the local and remote machine:
```
.\autosamplesubmission.ps1
```
When prompted, enter:
```
localhost,192.168.1.9
```
Enter PC-B's credentials when asked.

Verify locally:
```
Get-MpPreference | Select-Object SubmitSamplesConsent
```
Result: `1`

### On PC-B — Verify the setting was updated remotely
```
Get-MpPreference | Select-Object SubmitSamplesConsent
```
Result: `1`

---

## My Solution:

[View My Solution:](https://youtu.be/DFRPAGfAWKU)

---
