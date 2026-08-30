# Security Tools:Perform A TCP Port Scan Using Nmap

---

## Objectives:

- Set up a simple two-machine lab (target + attacker) inside VirtualBox to practice active reconnaissance.
- Stand up real, common network services (a web server and an SSH server) on the target so there is something meaningful to discover.
- Use Nmap from the attacker machine to perform different types of TCP scans (connect scan, SYN scan, service/version detection, aggressive scan, and a full-port scan) against the target.
- Understand what each Nmap scan type reveals about open ports, running services, and the target's overall attack surface.

---

## Tools:

- **VirtualBox** — hosts both the target and attacker virtual machines.
- **Ubuntu VM** — target machine, running Apache2 (web server) and OpenSSH (SSH server).
- **Kali Linux VM** — attacker machine, used to run Nmap scans.
- **Apache2** — web server installed on the target to expose port 80.
- **OpenSSH Server** — SSH service installed on the target to expose port 22.
- **Nmap** — network scanning tool used to enumerate open ports and services on the target.
- **ping** — used to confirm basic network reachability of the target before scanning.

---

## Steps

### 1. Prepare the target machine (Ubuntu VM)
```
sudo apt update
sudo apt install apache2
sudo systemctl start apache2
sudo systemctl status apache2
sudo apt install openssh-server
sudo systemctl start ssh
sudo systemctl status ssh
ip a
```
Note the target machine's IP address from the `ip a` output — it is needed for every scan from the attacker machine.

### 2. Prepare the attacker machine (Kali VM)
```
sudo apt update
```

### 3. Confirm connectivity to the target
```
sudo ping -c5 <target IP address>
```

### 4. Run a TCP Connect scan
```
sudo nmap -sT <target IP address>
```

### 5. Run a TCP SYN (stealth) scan
```
sudo nmap -sS <target IP address>
```

### 6. Run a service/version detection scan
```
sudo nmap -sV <target IP address>
```

### 7. Run an aggressive scan
```
sudo nmap -A <target IP address>
```

### 8. Run a full-port scan (all 65535 ports)
```
sudo nmap -p- <target IP address>
```

---

## My Solution:

[View My Solution:](https://youtu.be/KteAKqIrulw)

---
