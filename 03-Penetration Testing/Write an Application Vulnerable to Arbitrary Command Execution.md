# Penetration Testing: Write an Application Vulnerable to Arbitrary Command Execution

---

## Objectives
- Understand how passing unsanitized user input directly into a shell-execution function creates an OS command injection vulnerability.
- Practice standing up a local, intentionally vulnerable web application in an isolated lab and confirming that arbitrary commands can be executed through it.

---

## Tools
- **Kali Linux (VM)** — lab environment.
- **XAMPP** — local web server stack (Apache + PHP), installed from the official XAMPP Linux installer.
- A small PHP form-based application that takes user input and passes it to a shell-execution function without sanitization.

---

## Files Used

[Download the file: vuln.php](./Documentation/)

- `xampp-linux-installer.run` — the XAMPP installer downloaded to the Kali VM.
- `vuln.php` — the vulnerable PHP application deployed to the web root.

---

## Steps

1. Downloaded and verified the XAMPP Linux installer (`xampp-linux-installer.run`), confirming it was a valid ELF 64-bit executable.

   ```bash
   cd ~/Downloads
   wget https://sourceforge.net/projects/xampp/files/XAMPP%20Linux/8.2.12/xampp-linux-x64-8.2.12-0-installer.run/download -O xampp-linux-installer.run
   file xampp-linux-installer.run
   ```

   → must show "ELF 64-bit" (not PE32)
   
3. Installed and started XAMPP, then confirmed the local web server was reachable at `http://localhost`.

   ```bash
   chmod +x xampp-linux-installer.run
   sudo ./xampp-linux-installer.run
   sudo /opt/lampp/lampp start
   ```

   → check http://localhost in browser

4. Deployed a small PHP application (`vuln.php`) to the web root — a simple form that accepts a text command from the user and displays the result of running it on the server.
5. Set standard file permissions on `vuln.php`.

  ```bash
  sudo chmod 644 /opt/lampp/htdocs/vuln.php
  ```

5. Opened the application in a browser and confirmed the form was reachable: http://localhost/your_file.php
6. Submitted a series of basic diagnostic commands (e.g., listing files, showing the hostname, showing system/network information, listing running processes) through the form and confirmed each one's output was returned directly in the page — demonstrating that arbitrary commands supplied through the input field are executed on the server.

   ```bash
   ls -la
   hostname
   uname -a
   ifconfig
   ps aux
   ```
   
8. Stopped XAMPP once testing was complete.

   ```bash
   sudo /opt/lampp/lampp stop
   ```
   
---

## My Solution:

[View My Solution:](https://youtu.be/PToWc5Z2w5I)

---
