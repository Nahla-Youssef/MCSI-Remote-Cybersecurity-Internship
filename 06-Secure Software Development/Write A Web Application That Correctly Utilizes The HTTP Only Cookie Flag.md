# Secure Software Development: Write A Web Application That Correctly Utilizes The HTTP Only Cookie Flag

---

## Objectives
- Build a web application with an authentication mechanism (username and password) that allows users to log in.
- Use a server-side language (PHP) to manage user sessions.
- Upon successful authentication, generate a session token and store it in an HTTP cookie.
- Ensure the session cookie is configured with the `HTTPOnly` flag enabled, preventing client-side scripts (JavaScript) from accessing it.
- Validate the configuration using browser developer tools.
- Demonstrate the full workflow with a screen recording.

---

## Tools
- **OS**: Kali Linux
- **Web Server**: Apache2
- **Language**: PHP
- **Database**: MariaDB (MySQL)
- **Browser**: Firefox / Chromium (with Developer Tools)
- **Testing**: cURL
- **Screen Recording**: Kazam / OBS Studio

---

## Steps

### 1. Confirm Apache and MariaDB Are Running

```bash
sudo systemctl status apache2
sudo systemctl status mariadb
```

Start them if needed:

```bash
sudo systemctl start apache2
sudo systemctl start mariadb
```

### 2. Set Up the Database

Log in to MySQL:

```bash
sudo mysql -u root
```

Create the database, table, and a dedicated application user:

```sql
CREATE DATABASE httponly_db;
USE httponly_db;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    password VARCHAR(255)
);

CREATE USER 'httponly_user'@'localhost' IDENTIFIED BY 'HttpPass123!';
GRANT ALL PRIVILEGES ON httponly_db.* TO 'httponly_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 3. Create a Test User with a Hashed Password

Generate the hash:

```bash
HASH=$(php -r "echo password_hash('test123', PASSWORD_DEFAULT);")
echo $HASH
```

Insert the test user:

```bash
mysql -u httponly_user -p httponly_db -e "INSERT INTO users (username, password) VALUES ('admin', '$HASH');"
```

Verify the record:

```bash
mysql -u httponly_user -p httponly_db -e "SELECT * FROM users;"
```

### 4. Create the Project Directory

```bash
sudo mkdir -p /var/www/html/httponly-task
cd /var/www/html/httponly-task
```

### 5. Create the Database Connection File (`db.php`)

```bash
sudo tee /var/www/html/httponly-task/db.php > /dev/null << 'EOF'
<?php
// Database connection file
$conn = new mysqli("localhost", "httponly_user", "HttpPass123!", "httponly_db");
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
EOF
```

### 6. Create the Login Page with HTTPOnly Cookie Configuration (`login.php`)

```bash
sudo tee /var/www/html/httponly-task/login.php > /dev/null << 'EOF'
<?php
// Configure session cookie parameters BEFORE starting the session
session_set_cookie_params([
    'lifetime' => 3600,
    'path' => '/',
    'domain' => '',
    'secure' => false,    // No SSL required for this task
    'httponly' => true,   // Prevents JavaScript access to the cookie (required flag)
    'samesite' => 'Lax'
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

### 7. Set File Permissions

```bash
sudo chown -R www-data:www-data /var/www/html/httponly-task
```

### 8. Test the Application via cURL

```bash
curl -v -X POST -d "username=admin&password=test123" http://localhost/httponly-task/login.php
```

Expected output includes:

```
< Set-Cookie: PHPSESSID=...; path=/; HttpOnly; SameSite=Lax
<h2>Login successful</h2><p>Session ID: ...</p>
```

The presence of `HttpOnly` in the `Set-Cookie` header confirms the flag is correctly set.

### 9. Verify in the Browser

1. Open `http://localhost/httponly-task/login.php` in the browser.
2. Log in with:
   - Username: `admin`
   - Password: `test123`
3. Confirm the "Login successful" message and Session ID are displayed.

### 10. Inspect the Session Cookie with Developer Tools

1. Open Developer Tools (`F12`, or right-click → **Inspect**).
2. Go to the **Storage** tab (Firefox) or **Application** tab (Chrome).
3. Expand **Cookies** → select `http://localhost`.
4. Locate the `PHPSESSID` cookie and confirm the **HttpOnly** column is set to `true`.

---

## My Solution:

[View My Solution:](https://youtu.be/GLr-6GI6mYA)

---
