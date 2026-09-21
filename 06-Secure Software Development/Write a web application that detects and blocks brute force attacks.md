# Secure Software Development:Write a web application that detects and blocks brute force attacks

---

## Objectives
- Build an **authentication mechanism** (username + password) for **at least 300** sequentially numbered accounts (`0001`, `0002`, ... `0300`).
- **Detect and temporarily block** the following attack patterns:
  - **Horizontal brute force** — few passwords tried across many usernames.
  - **Vertical brute force** — many passwords tried against one username.
  - **Mixed brute force** — both patterns from the same source at once.
  - **Account lockout policy abuse** — an attacker deliberately triggering lockouts to deny a legitimate user access.
  - **Slow-paced brute force** — the same patterns spread out over time (e.g. one attempt per minute) to evade short-window detection.

---

## Tools
- **Kali Linux**
- **Apache2** (web server, with `mod_ssl`)
- **PHP** + `php-mysql` extension
- **MariaDB / MySQL** (accounts, attempt logs, locks)
- **OpenSSL** (self-signed TLS certificate for local HTTPS testing)
- **curl** (used to simulate attack traffic against the app's own local deployment, for testing/demo purposes only)

---

## Steps

### 1. Update system and install required packages
```bash
sudo apt update
sudo apt install -y apache2 php php-mysql mariadb-server libapache2-mod-php openssl
```

### 2. Enable required Apache modules
```bash
sudo a2enmod ssl
sudo a2enmod rewrite
sudo a2enmod headers
sudo systemctl restart apache2
```

### 3. Start and secure MariaDB
```bash
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo mariadb-secure-installation
```

### 4. Create the database and a dedicated DB user
```bash
sudo mysql -u root -p
```
```sql
CREATE DATABASE bf_defense_db;
CREATE USER 'bf_defense_user'@'localhost' IDENTIFIED BY 'ChangeThisPassword123!';
GRANT ALL PRIVILEGES ON bf_defense_db.* TO 'bf_defense_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 5. Create the project folder and deploy the files
```bash
sudo mkdir -p /var/www/html/brute-force-defense-task
sudo cp -r ./* /var/www/html/brute-force-defense-task/
```
> Update `config/db.php` with the DB username/password from step 4 if different from the defaults.

### 6. Import the schema
```bash
sudo mysql -u root -p bf_defense_db < /var/www/html/brute-force-defense-task/schema.sql
```

### 7. Generate the 300 user accounts
```bash
cd /var/www/html/brute-force-defense-task
sudo php seed_users.php
```
This creates accounts `0001`–`0300` with random passwords and writes them to `credentials.txt` (local testing use only).

### 8. Set permissions
```bash
sudo chown -R www-data:www-data /var/www/html/brute-force-defense-task
sudo chmod 600 /var/www/html/brute-force-defense-task/credentials.txt
```

### 9. Generate a self-signed TLS certificate
```bash
sudo mkdir -p /etc/ssl/brute-force-defense-task
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/brute-force-defense-task/apache.key \
  -out /etc/ssl/brute-force-defense-task/apache.crt \
  -subj "/C=EG/ST=Faiyum/L=Faiyum/O=BruteForceDefenseTask/CN=localhost"
```

### 10. Create an Apache virtual host for HTTPS
```bash
sudo tee /etc/apache2/sites-available/brute-force-defense-ssl.conf > /dev/null << 'EOF'
<VirtualHost *:443>
    ServerName localhost
    DocumentRoot /var/www/html/brute-force-defense-task

    SSLEngine on
    SSLCertificateFile /etc/ssl/brute-force-defense-task/apache.crt
    SSLCertificateKeyFile /etc/ssl/brute-force-defense-task/apache.key

    <Directory /var/www/html/brute-force-defense-task>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
```

### 11. Enable the site
```bash
sudo a2ensite brute-force-defense-ssl.conf
sudo a2dissite default-ssl.conf 2>/dev/null
sudo systemctl restart apache2
```

### 12. Verify the site is reachable
```bash
curl -Ik https://127.0.0.1/login.php
```
Expected: `HTTP/1.1 200 OK`.

---

## How Detection Works

All login attempts (success and failure) are logged in `login_attempts` with the username, source IP, and timestamp. After each failed attempt, `runDetection()` checks:

| Attack type | Detection rule | Mitigation |
|---|---|---|
| **Vertical** | ≥5 failed attempts on one username from one IP within 10 minutes | Lock the (username, IP) pair for 15 minutes |
| **Horizontal** | ≥8 distinct usernames failed from one IP within 10 minutes | Block the IP entirely for 15 minutes |
| **Mixed** | Both vertical and horizontal conditions triggered by the same IP at once | Lock the account **and** block the IP |
| **Slow-paced** | ≥10 failed attempts on one username from one IP within 24 hours (even if the short-window vertical rule wasn't triggered) | Lock the (username, IP) pair for 60 minutes |
| **Account lockout policy abuse** | N/A — mitigated by design | Locks are scoped to **(username, IP)**, not the account globally, so an attacker on a different IP cannot deny the real owner access |

---

## Secure Deployment / Attack Simulation (for local testing only)

Run these against your own deployment (`https://127.0.0.1`) to validate detection. Use a real account and password from `credentials.txt` to confirm normal login still works first.

### Successful login
```bash
curl -sk -X POST https://127.0.0.1/login.php -d "username=0001&password=<real_password>"
```

### Vertical brute force
```bash
for i in {1..6}; do
  curl -sk -X POST https://127.0.0.1/login.php \
    -d "username=0001&password=wrong${i}" -o /dev/null -w "Attempt $i: %{http_code}\n"
done
sudo mysql -u root -e "SELECT * FROM bf_defense_db.account_locks WHERE username='0001' ORDER BY id DESC LIMIT 1;"
```

### Horizontal brute force
```bash
for i in {2..10}; do
  user=$(printf "%04d" $i)
  curl -sk -X POST https://127.0.0.1/login.php \
    -d "username=${user}&password=123456" -o /dev/null -w "User $user: %{http_code}\n"
done
sudo mysql -u root -e "SELECT * FROM bf_defense_db.ip_blocks ORDER BY id DESC LIMIT 1;"
```

### Mixed brute force
```bash
for i in {1..6}; do curl -sk -X POST https://127.0.0.1/login.php -d "username=0001&password=x${i}" -o /dev/null; done
for i in {2..10}; do user=$(printf "%04d" $i); curl -sk -X POST https://127.0.0.1/login.php -d "username=${user}&password=x" -o /dev/null; done
sudo mysql -u root -e "SELECT * FROM bf_defense_db.account_locks WHERE reason='mixed_brute_force' ORDER BY id DESC LIMIT 1;"
```

### Account lockout policy abuse
```bash
for i in {1..6}; do
  curl -sk -X POST https://127.0.0.1/login.php -d "username=0003&password=wrong${i}" -o /dev/null
done
sudo mysql -u root -e "SELECT username, ip_address, reason FROM bf_defense_db.account_locks WHERE username='0003' ORDER BY id DESC LIMIT 1;"
```
Confirm `ip_address` is set to the attacking IP (not `NULL`/global) — this is what stops an attacker from denying the real owner access from a different IP.

### Slow-paced brute force
```bash
for i in {1..11}; do
  curl -sk -X POST https://127.0.0.1/login.php -d "username=0004&password=wrong${i}" -o /dev/null -w "Attempt $i: %{http_code}\n"
  sleep 60
done
sudo mysql -u root -e "SELECT * FROM bf_defense_db.account_locks WHERE reason='slow_paced_brute_force' ORDER BY id DESC LIMIT 1;"
```

### Reset between tests
```bash
sudo mysql -u root -e "DELETE FROM bf_defense_db.account_locks; DELETE FROM bf_defense_db.ip_blocks; DELETE FROM bf_defense_db.login_attempts;"
```

---

## My Solution:

[View My Solution:](https://youtu.be/2fxeeix0W7U)

---
