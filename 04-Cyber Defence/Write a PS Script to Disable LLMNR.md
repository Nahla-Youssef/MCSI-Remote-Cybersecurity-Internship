# Cyber Defence: Write a PS Script to Disable LLMNR

---

## Objectives
- Write a PowerShell script that sets the `EnableMulticast` registry value to control LLMNR (Link-Local Multicast Name Resolution), a protocol commonly abused for network credential-relay attacks.
- Apply and verify the change on both a local and a remote machine.

---

## Environment
Machine 1 (Windows 10) — local.
Machine 2 (Windows 10) — remote.

---

## Files Used

[Download the file: disableLLMNR.ps1](./Documentation/)

- `disableLLMNR.ps1`

---

## Steps
Run on each machine (Windows 10) as Administrator.

### 1. Save the script
Save the PowerShell script content as `disableLLMNR.ps1` on the local Windows 10 VM.

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

### 4. Enable LLMNR on the local machine (baseline, so the script has something to detect/disable)
```
$llmnrRegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"
if (!(Test-Path $llmnrRegPath)) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT" -Name "DNSClient" -Force | Out-Null
}
Set-ItemProperty -Path $llmnrRegPath -Name "EnableMulticast" -Value 1 -Force
```
Verify:
```
Get-ItemProperty -Path $llmnrRegPath -Name "EnableMulticast"
```
Expected output: `EnableMulticast : 1`

> Note: this can equally be done via Registry Editor (`regedit`) by navigating to `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient` and creating/setting the `EnableMulticast` DWORD value manually. The `(Default)` entry with type `REG_SZ` can be ignored — it's a standard placeholder that appears automatically when a new key is created.

### 5. Run the script against the local machine
```
cd <path to disableLLMNR.ps1>
.\disableLLMNR.ps1
```
Choose option `1` (local machine). Confirm it correctly detects that LLMNR is enabled and then disables it.

### 6. Enable LLMNR on the remote machine (baseline)
Run this against the remote VM (locally on that machine, or via `Invoke-Command` from the local VM):
```
$llmnrRegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"
if (!(Test-Path $llmnrRegPath)) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT" -Name "DNSClient" -Force | Out-Null
}
Set-ItemProperty -Path $llmnrRegPath -Name "EnableMulticast" -Value 1 -Force
```

### 7. Run the script against the remote machine
```
.\disableLLMNR.ps1
```
Choose option `2` (remote machine), then enter the remote computer's name or IP address when prompted. Confirm it correctly detects that LLMNR is enabled on the remote machine and then disables it there via `Invoke-Command`.

---

## My Solution:

[View My Solution:](https://youtu.be/bhAjNp_S584)

---
