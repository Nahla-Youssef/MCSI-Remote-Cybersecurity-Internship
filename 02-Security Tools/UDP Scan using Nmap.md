# Security Tools: Perform A UDP Port Scan Using Nmap

---

## Objectives:
- Configure an SNMP service on the target machine so a real UDP service is available to scan.
- Use Nmap to perform UDP-specific scans (basic UDP scan, UDP scan with version detection, and a full UDP port scan) from the attacker machine.
- Troubleshoot common UDP scanning issues: a port not appearing due to a firewall block, and a port reporting as "closed" due to SNMP misconfiguration.

---

## Tools:
- **VirtualBox** — hosts the target (Ubuntu) and attacker (Kali) VMs.
- **snmp / snmpd** — SNMP service installed and enabled on the target to expose UDP port 161.
- **Nmap** — used for UDP scanning (`-sU`) from the attacker machine.
- **ufw** (Uncomplicated Firewall) — used on the target to allow/verify UDP port 161.
- **ss / lsof** — used on the target to confirm what is actually listening on UDP port 161.

---

## Steps:

### 1. Prepare the target machine (Ubuntu VM)
```
sudo apt update
sudo apt install snmp
sudo systemctl enable snmpd
sudo systemctl status snmpd
ip a
```

### 2. Prepare the attacker machine (Kali VM) and confirm connectivity
```
sudo apt update
sudo ping -c5 <target IP address>
```

### 3. Run the UDP scans
```
sudo nmap -sU <target IP address>
sudo nmap -sU -sV <target IP address>
sudo nmap -sU -p- <target IP address>
```

### 4. Troubleshoot — Error: Port 161/UDP does not appear in the Kali scan results
On the target (Ubuntu) machine:
```
sudo ufw allow 161/udp
sudo ufw enable
sudo ufw status
sudo ufw reload
```

### 5. Troubleshoot — Error: Port 161/UDP shows as closed in the Kali scan results
On the target (Ubuntu) machine:
```
sudo nano /etc/snmp/snmpd.conf
```
Find the `agentaddress` line and change it to:
```
agentaddress udp:161
```
Save with `Ctrl+O`, then `Enter`, then `Ctrl+X` to exit. Then:
```
sudo grep -i agentaddress /etc/snmp/snmpd.conf
sudo systemctl restart snmpd
sudo ss -tulnp | grep 161
sudo lsof -i udp:161
```

---

## My Solution:

[View My Solution:](https://youtu.be/sQlbyyw_pj4)

---
