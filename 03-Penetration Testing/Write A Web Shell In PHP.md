# Penetration Testing: Write a Web Shell in PHP

---

## Objectives
- Understand how an authenticated PHP-based web shell can be used to execute arbitrary commands, list files, and upload/download files on a compromised web server.
- Practice deploying and interacting with a web shell in a fully isolated local lab environment.
- Demonstrate the file-upload and command-execution capabilities a web shell provides once access is obtained.

---

## Tools
- **Kali Linux (VM)** — lab environment.
- **XAMPP/LAMPP (Apache)** — local web server used to host the PHP files.
- A locally hosted PHP web shell (password-protected) — used strictly within the isolated lab.
- A small placeholder shell script and a sample "confidential" text file — used as test files for the upload/download demo.

---

## Files Used

[Download the folder: solution_3](./Documentation/)

- `webshell.php` — the password-protected web shell, deployed to the Apache web root.
- `malicious_script.sh` — placeholder shell script used to demonstrate the upload + execute flow.
- `info.txt` — sample "confidential" text file used to demonstrate the download flow.

---

## Steps
1. Created a lab working directory with restricted permissions (`chmod 711` on the parent folder, `chmod 777` on the working folder) to contain the test files for the exercise.
2. Prepared two small test files in that directory: `malicious_script.sh` (used later to demonstrate uploading and executing a file) and `info.txt`, a sample text file with dummy "confidential" data (used later to demonstrate downloading a file).
3. Placed `webshell.php`, the password-protected web shell file, in the Apache web root (`/opt/lampp/htdocs/`).
4. Started Apache via XAMPP and opened the web shell page in a browser.
   -Start **Apache** from XAMPP.

   -Open your browser and go to:

   - http://localhost/webshell.php
   
5. Tested the authentication: confirmed an incorrect password was rejected, then logged in with the correct password to reach the web shell interface.
   -Enter a wrong password first.

   -Expected result:
   -Invalid password

   -Then enter the correct password:
   -password123

   -You should now see the web shell homepage.

6. Used the web shell's command field to list the contents of the current directory, confirming command execution worked.
    -In the Enter command field, type:
    ```bash ls ```
   
    -Click Execute.

    -The output shows the current directory files.

7. Used the web shell's upload feature to upload `malicious_script.sh` from the local machine.

    -Click Choose File.

   -Select malicious_script.sh from your computer.

   -Click Upload File.

   -A success message should appear, confirming that the file was uploaded successfully.

8. Executed the uploaded script through the web shell's command field and confirmed its output appeared.
 
   -In the Enter command field, type:

   ```bash sh /home/sunflower/lab/malicious_script.sh ```
   
   -Click Execute.

   -The output shows "This is a simulated malicious script."
   
9. Used the web shell's download feature to retrieve `info.txt` back to the local machine, demonstrating the exfiltration capability a web shell provides.

     -Use the command:

    ```bash /home/sunflower/lab/info.txt ```
   
    -Click Download

---

## My Solution:

[View My Solution:](https://youtu.be/GnJRmP9yvVI)

---
