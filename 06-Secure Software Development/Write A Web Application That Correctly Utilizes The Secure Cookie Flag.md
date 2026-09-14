# Secure Software Development: Write A Web Application That Correctly Utilizes The Secure Cookie Flag

---

## Objectives
- Build a web application with secure authentication functionality that allows users to log in.
- Deploy the application over SSL (HTTPS).
- Generate a session token upon successful authentication.
- Store the session token securely in the user's cookies.
- Configure the session ID cookie with the `Secure` flag set, ensuring it is only transmitted over HTTPS connections.
- Validate the secure deployment using browser developer tools.
- Demonstrate the full workflow with a screen recording.

---

## Tools
- **OS**: Kali Linux
- **Web Server**: Apache2
- **Language**: PHP
- **Database**: MariaDB (MySQL)
- **SSL**: OpenSSL (self-signed certificate for local testing)
- **Browser**: Firefox / Chromium (with Developer Tools)
- **Testing**: cURL
- **Screen Recording**: Kazam / OBS Studio

---

## Steps

### 1. Install Required Packages

```bash
sudo apt update
sudo apt install apache2 php libapache2-mod-php php-mysqli mariadb-server openssl -y
```

Start and enable the services:

```bash
sudo systemctl start apache2
sudo systemctl start mariadb
sudo systemctl enable apache2
sudo systemctl enable mariadb
```

Verify they are running:

```bash
sudo systemctl status apache2
sudo systemctl status mariadb
```

### 2. Set Up the Database

Log in to MySQL:

```bash
sudo mysql -u root
```

Create the database and table:

```sql
CREATE DATABASE task_db;
USE task_db;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    password VARCHAR(255)
);
```

Create a dedicated application database user (avoid using `root` in application code):

```sql
CREATE USER 'task_user'@'localhost' IDENTIFIED BY 'TaskPass123!';
GRANT ALL PRIVILEGES ON task_db.* TO 'task_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

Generate a hashed password for a test user:

```bash
HASH=$(php -r "echo password_hash('test123', PASSWORD_DEFAULT);")
echo $HASH
```

Insert the test user using the generated hash:

```bash
mysql -u task_user -p task_db -e "INSERT INTO users (username, password) VALUES ('admin', '$HASH');"
```

Verify the record:

```bash
mysql -u task_user -p task_db -e "SELECT * FROM users;"
```

### 3. Create the Project Directory

```bash
sudo mkdir -p /var/www/html/secure-task
cd /var/www/html/secure-task
```

### 4. Create the Database Connection File (`db.php`)

```bash
sudo tee /var/www/html/secure-task/db.php > /dev/null << 'EOF'
<?php
// Database connection file
$conn = new mysqli("localhost", "task_user", "TaskPass123!", "task_db");
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
EOF
```

### 5. Create the Login Page with Secure Session Cookie Configuration (`login.php`)

```bash
sudo tee /var/www/html/secure-task/login.php > /dev/null << 'EOF'
<?php
// Configure session cookie parameters BEFORE starting the session
session_set_cookie_params([
    'lifetime' => 3600,
    'path' => '/',
    'domain' => '',
    'secure' => true,     // Cookie will only be sent over HTTPS
    'httponly' => true,   // Prevents JavaScript access to the cookie
    'samesite' => 'Strict'
]);
session_start();

require 'db.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = $_POST['username'];
    $password = $_POST['password'];

    $stmt = $conn->prepare("SELECT id, password FROM users WHERE username = ?");
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($row = $result->fetch_assoc()) {
        if (password_verify($password, $row['password'])) {
            $_SESSION['user_id'] = $row['id'];
            $_SESSION['username'] = $username;
            echo "<h2>Login successful</h2>";
            echo "<p>Session ID: " . session_id() . "</p>";
            exit;
        }
    }
    $error = "Invalid username or password";
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Login Page</title>
</head>
<body>
    <h2>Login</h2>
    <?php if (isset($error)) echo "<p style='color:red'>$error</p>"; ?>
    <form method="POST">
        <input type="text" name="username" placeholder="Username" required><br><br>
        <input type="password" name="password" placeholder="Password" required><br><br>
        <button type="submit">Login</button>
    </form>
</body>
</html>
EOF
```

### 6. Set File Permissions

```bash
sudo chown -R www-data:www-data /var/www/html/secure-task
```

### 7. Generate a Self-Signed SSL Certificate

```bash
sudo mkdir -p /etc/apache2/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/apache2/ssl/apache.key \
  -out /etc/apache2/ssl/apache.crt
```

> When prompted, set the **Common Name (CN)** to `localhost`.

### 8. Enable SSL on Apache

```bash
sudo a2enmod ssl
sudo a2ensite default-ssl
```

Configure the SSL virtual host:

```bash
sudo tee /etc/apache2/sites-available/default-ssl.conf > /dev/null << 'EOF'
<IfModule mod_ssl.c>
<VirtualHost _default_:443>
    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile    /etc/apache2/ssl/apache.crt
    SSLCertificateKeyFile /etc/apache2/ssl/apache.key

    <FilesMatch "\.(cgi|shtml|phtml|php)$">
        SSLOptions +StdEnvVars
    </FilesMatch>
    <Directory /usr/lib/cgi-bin>
        SSLOptions +StdEnvVars
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/ssl_access.log combined
</VirtualHost>
</IfModule>
EOF
```

Validate the configuration syntax, then restart Apache:

```bash
sudo apache2ctl configtest
sudo systemctl restart apache2
sudo systemctl status apache2
```

### 9. Test the Application via cURL

```bash
curl -v -X POST -d "username=admin&password=test123" https://localhost/secure-task/login.php -k
```

Expected output includes:

```
< Set-Cookie: PHPSESSID=...; path=/; secure; HttpOnly; SameSite=Strict
<h2>Login successful</h2><p>Session ID: ...</p>
```

The presence of `secure` in the `Set-Cookie` header confirms the `Secure` flag is correctly set.

### 10. Verify in the Browser

1. Open `https://localhost/secure-task/login.php` in the browser.
2. Accept the self-signed certificate warning (expected for local testing).
3. Log in with:
   - Username: `admin`
   - Password: `test123`
4. Confirm the "Login successful" message and Session ID are displayed.

### 11. Inspect the Session Cookie with Developer Tools

1. Open Developer Tools (`F12`, or right-click → **Inspect**).
2. Go to the **Storage** tab (Firefox) or **Application** tab (Chrome).
3. Expand **Cookies** → select `https://localhost`.
4. Locate the `PHPSESSID` cookie and confirm the **Secure** column is set to `true`.

---

## My Solution:

[View My Solution:](https://youtu.be/pcv8CPLrJ2w)

---
