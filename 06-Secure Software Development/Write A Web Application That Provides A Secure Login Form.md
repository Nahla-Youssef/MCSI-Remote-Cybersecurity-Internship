# Secure Software Development: Write A Web Application That Provides A Secure Login Form

---

## Objectives
- Store passwords using **SHA256** hashing (with a unique per-user salt).
- Apply the **Secure** and **HttpOnly** flags to all session cookies.
- Implement an **account lockout** mechanism triggered after **5 failed login attempts**.
- Restrict **usernames to alphanumeric characters only**.
- Enforce a strong **password policy**: minimum 12 characters, including uppercase, lowercase, numbers, and special characters.
- **Blacklist the top 100 most common passwords** at registration time.
- Deploy the application over **HTTPS**.

---

## Tools
- **Kali Linux**
- **Apache2** (web server, with `mod_ssl`/`mod_rewrite`)
- **PHP** + `php-mysql` extension
- **MariaDB / MySQL** (user storage)
- **OpenSSL** (self-signed TLS certificate for local HTTPS testing)
- **curl** / Browser DevTools (validation)

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
sudo mysql_secure_installation
```

### 4. Create the database and a dedicated DB user
```bash
sudo mysql -u root -p
```
Inside the MySQL shell:
```sql
CREATE DATABASE secure_login_db;
CREATE USER 'secure_login_user'@'localhost' IDENTIFIED BY 'ChangeThisPassword123!';
GRANT ALL PRIVILEGES ON secure_login_db.* TO 'secure_login_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 5. Import the schema
```bash
sudo mysql -u root -p secure_login_db < schema.sql
```

### 6. Deploy the application files
```bash
sudo mkdir -p /var/www/html/secure-login-task
sudo cp -r ./* /var/www/html/secure-login-task/
sudo chown -R www-data:www-data /var/www/html/secure-login-task
```

> Update `config/db.php` with the DB username/password you created in step 4 if different from the defaults.

### 7. Generate a self-signed TLS certificate (for local HTTPS testing)
```bash
sudo mkdir -p /etc/ssl/secure-login
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/secure-login/apache.key \
  -out /etc/ssl/secure-login/apache.crt \
  -subj "/C=EG/ST=Faiyum/L=Faiyum/O=SecureLoginTask/CN=localhost"
```

### 8. Create an Apache virtual host for HTTPS
```bash
sudo tee /etc/apache2/sites-available/secure-login-ssl.conf > /dev/null << 'EOF'
<VirtualHost *:443>
    ServerName localhost
    DocumentRoot /var/www/html/secure-login-task

    SSLEngine on
    SSLCertificateFile /etc/ssl/secure-login/apache.crt
    SSLCertificateKeyFile /etc/ssl/secure-login/apache.key

    <Directory /var/www/html/secure-login-task>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
```

### 9. Enable the site and redirect HTTP to HTTPS
```bash
sudo a2ensite secure-login-ssl.conf

sudo tee /etc/apache2/sites-available/000-default.conf > /dev/null << 'EOF'
<VirtualHost *:80>
    ServerName localhost
    Redirect permanent / https://localhost/
</VirtualHost>
EOF

sudo systemctl restart apache2
```

### 10. Verify the site is reachable over HTTPS
```bash
curl -Ik https://localhost/secure-login-task/login.php
```
Expected: `HTTP/1.1 200 OK` (the `-k` flag ignores the self-signed cert warning locally).

---

## Secure Deployment Validation

### A. Register a new account and test the password policy
1. Open `https://localhost/secure-login-task/register.php`.
2. Try a **short password** (e.g. `abc123`) → should be rejected.
3. Try a password **missing a required character type** (e.g. all lowercase) → should be rejected.
4. Try a **blacklisted password** (e.g. `password123`) → should be rejected with a "too common" message.
5. Try a **special-character username** (e.g. `user@!`) → should be rejected.
6. Finally, register with a valid strong password, e.g. `MyStr0ng!Passw0rd`.

### B. Confirm the password is stored hashed (not plaintext)
```bash
sudo mysql -u root -p -e "SELECT username, password_hash, salt FROM secure_login_db.users;"
```
Expected: `password_hash` is a 64-character SHA256 hex digest, not the plaintext password.

### C. Trigger the account lockout mechanism
1. Go to `https://localhost/secure-login-task/login.php`.
2. Enter the correct username with a **wrong password 5 times**.
3. Confirm the message shows remaining attempts, then locks the account after the 5th failure.
4. Confirm login with the correct password is refused while locked.

### D. Confirm cookie flags in browser DevTools
1. Log in successfully.
2. Open **DevTools → Application (or Storage) → Cookies**.
3. Confirm the `PHPSESSID` cookie has both **Secure** and **HttpOnly** checked.

Or from the terminal:
```bash
curl -Ik https://localhost/secure-login-task/login.php -c cookies.txt
cat cookies.txt
```

### E. Confirm successful login works normally
1. Log in with the correct username/password.
2. Confirm redirect to `dashboard.php` and the welcome message appears.

---

## My Solution:

[View My Solution:](https://youtu.be/ajWQe7ywgHk)

---
