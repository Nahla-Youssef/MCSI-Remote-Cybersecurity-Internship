# Secure Software Development: Write A Web Application That Enforces A Strong Password Policy And Displays A Password Strength Meter

---

## Objectives
- Build **registration**, **login**, and **password update** pages.
- Enforce a **password policy** requiring a minimum of **10 characters**.
- Add a **password strength meter** on the registration and password update pages.
- Have the meter **visually indicate** password strength (weak, moderate, strong).
- Show the user an **estimated time for an adversary to crack** the selected password.

---

## Tools
- **Kali Linux**
- **Apache2** (web server, with `mod_ssl`)
- **PHP** + `php-mysql` extension
- **MariaDB / MySQL** (user storage)
- **OpenSSL** (self-signed TLS certificate for local HTTPS testing)
- **zxcvbn.js** (client-side password strength estimation library, loaded via CDN)
- Browser DevTools / `curl` (validation)

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
Answer the prompts:
- Enter root password → **Enter** (blank)
- Switch to unix_socket authentication → **n**
- Change the root password? → **n**
- Remove anonymous users? → **y**
- Disallow root login remotely? → **y**
- Remove test database and access to it? → **y**
- Reload privilege tables now? → **y**

### 4. Create the database and a dedicated DB user
```bash
sudo mysql -u root -p
```
Inside the MySQL shell:
```sql
CREATE DATABASE pw_strength_db;
CREATE USER 'pw_strength_user'@'localhost' IDENTIFIED BY 'ChangeThisPassword123!';
GRANT ALL PRIVILEGES ON pw_strength_db.* TO 'pw_strength_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 5. Create the project folder
```bash
sudo mkdir -p /var/www/html/password-strength-task
cd /var/www/html/password-strength-task
```

### 6. Import the schema
```bash
sudo mysql -u root -p pw_strength_db < schema.sql
```

### 7. Deploy the application files
```bash
sudo cp -r ./* /var/www/html/password-strength-task/
sudo chown -R www-data:www-data /var/www/html/password-strength-task
```

> Update `config/db.php` with the DB username/password you created in step 4 if different from the defaults.

### 8. Generate a self-signed TLS certificate (for local HTTPS testing)
```bash
sudo mkdir -p /etc/ssl/password-strength-task
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/password-strength-task/apache.key \
  -out /etc/ssl/password-strength-task/apache.crt \
  -subj "/C=EG/ST=Faiyum/L=Faiyum/O=PasswordStrengthTask/CN=localhost"
```

### 9. Create an Apache virtual host for HTTPS
```bash
sudo tee /etc/apache2/sites-available/password-strength-ssl.conf > /dev/null << 'EOF'
<VirtualHost *:443>
    ServerName localhost
    DocumentRoot /var/www/html/password-strength-task

    SSLEngine on
    SSLCertificateFile /etc/ssl/password-strength-task/apache.crt
    SSLCertificateKeyFile /etc/ssl/password-strength-task/apache.key

    <Directory /var/www/html/password-strength-task>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
```

### 10. Enable the site (and disable the default SSL site to avoid conflicts)
```bash
sudo a2ensite password-strength-ssl.conf
sudo a2dissite default-ssl.conf 2>/dev/null
sudo systemctl restart apache2
```

### 11. Verify the site is reachable over HTTPS
```bash
curl -Ik https://localhost/register.php
```
Expected: `HTTP/1.1 200 OK`.

---

## Secure Deployment Validation

### A. Register with passwords of varying complexity and observe the strength meter
1. Open `https://localhost/register.php`.
2. Register with a **weak** password (10+ characters, low complexity), e.g. `abcdefghij` → meter shows **Weak**.
3. Register with a **moderate** password, e.g. `ABcdef1234` → meter shows **Moderate**.
4. Register with a **strong** password, e.g. `Tr@il#9xQm!2026` → meter shows **Strong / Very Strong**.
5. For each password, note the **estimated crack time** displayed under the meter.

### B. Verify the 10-character minimum policy is enforced
1. Try registering with a password shorter than 10 characters, e.g. `Abc12!`.
2. Expected: the registration is rejected with `"Password must be at least 10 characters long."` and no account is created.

### C. Confirm the strength meter also works on the password update page
1. Log in with an existing account.
2. From the dashboard, click **Update Password**.
3. Enter the current password and type a new password — confirm the same strength meter, color indicator, and crack-time estimate appear.
4. Submit and confirm `"Password updated successfully."`.

### D. Confirm the password was actually updated
1. Log out.
2. Try logging in with the **old** password → should be rejected.
3. Try logging in with the **new** password → should succeed and land on the dashboard.

---

## My Solution:

[View My Solution:](https://youtu.be/DlJhCFLT3Uw)

---
