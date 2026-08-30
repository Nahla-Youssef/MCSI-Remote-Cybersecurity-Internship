# Security Tools: Use Metasploit to Identify a Machine Vulnerable to MS17-010

---

## Objectives
- Confirm network reachability and open ports on a Windows 7 target before attempting exploitation.
- Use Metasploit's auxiliary SMB scanner module to safely check whether the target is vulnerable to MS17-010 (EternalBlue) without exploiting it.

---

## Tools
- **VirtualBox** — hosts the Windows 7 target and Kali attacker VMs.
- **Nmap** — full-port scan of the target.
- **Metasploit Framework (`msfconsole`)** — running the `auxiliary/scanner/smb/smb_ms17_010` module.

---

## Steps

### 1. Target machine (Windows 7 VM)
```
sudo apt update
ipconfig
```
Note the target machine's IP address.

### 2. Attacker machine (Kali VM)
```
sudo apt update
sudo ping -c5 <target IP address>
sudo nmap -p- <target IP address>
```

### 3. Check for MS17-010 vulnerability with Metasploit
```
msfconsole
use auxiliary/scanner/smb/smb_ms17_010
set RHOST <target IP address>
run
```

---

## My Solution:

[View My Solution:](https://youtu.be/MM049K4sGpg)

---
