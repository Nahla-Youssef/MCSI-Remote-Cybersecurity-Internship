# Secure Software Development: Write A Web Application That Blocks Cross-Site Request Forgery

---

## Objectives
- Build a password-update page accessible only to authenticated users.
- Generate a unique CSRF token per user session.
- Include the CSRF token as a hidden field in the password change form.
- Verify the CSRF token server-side when processing the password change
  request.
- Reject the request if the token is missing or invalid, preventing
  unauthorized password changes.
- Write a CSRF exploit and confirm the protection mechanism blocks it.
- Demonstrate the full workflow with a screen recording.

---

## Tools
- **OS**: Kali Linux
- **Web Server**: Apache2
- **Language**: PHP
- **Database**: MariaDB (MySQL)
- **Browser**: Firefox / Chromium (with Developer Tools)
- **Testing**: cURL

---

## Steps

### 1. Confirm Apache and MariaDB Are Running

```bash
sudo systemctl status apache2
sudo systemctl status mariadb
```

### 2. Set Up the Database

```bash
sudo mysql -u root
```

```sql
CREATE DATABASE csrf_db;
USE csrf_db;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    password VARCHAR(255)
);

CREATE USER 'csrf_user'@'localhost' IDENTIFIED BY 'CsrfPass123!';
GRANT ALL PRIVILEGES ON csrf_db.* TO 'csrf_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 3. Create a Test User with a Hashed Password

```bash
HASH=$(php -r "echo password_hash('test123', PASSWORD_DEFAULT);")
mysql -u csrf_user -p csrf_db -e "INSERT INTO users (username, password) VALUES ('admin', '$HASH');"
```

Verify:

```bash
mysql -u csrf_user -p csrf_db -e "SELECT * FROM users;"
```

### 4. Create the Project Directory

```bash
sudo mkdir -p /var/www/html/csrf-task
cd /var/www/html/csrf-task
```

### 5. Create the Database Connection File (`db.php`)

```bash
sudo tee /var/www/html/csrf-task/db.php > /dev/null << 'EOF'
<?php
$conn = new mysqli("localhost", "csrf_user", "CsrfPass123!", "csrf_db");
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
EOF
```

### 6. Create the Login Page (`login.php`)

```bash
sudo tee /var/www/html/csrf-task/login.php > /dev/null << 'EOF'
<?php
session_start();
require 'db.php';

if (isset($_SESSION['user_id'])) {
    header("Location: change_password.php");
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = $_POST['username'];
    $password = $_POST['password'];

    $stmt = $conn->prepare("SELECT id, password FROM users WHERE username = ?");
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($row = $result->fetch_assoc()) {
        if (password_verify($password, $row['password'])) {
            session_regenerate_id(true);
            $_SESSION['user_id'] = $row['id'];
            $_SESSION['username'] = $username;
            header("Location: change_password.php");
            exit;
        }
    }
    $error = "Invalid username or password";
}
?>
<!DOCTYPE html>
<html>
<head><title>Login</title></head>
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

### 7. Create the Password Change Page with a CSRF Token (`change_password.php`)

A cryptographically random token is generated once per session and
stored server-side, then embedded as a hidden field in the form.

```bash
sudo tee /var/www/html/csrf-task/change_password.php > /dev/null << 'EOF'
<?php
session_start();

if (!isset($_SESSION['user_id'])) {
    header("Location: login.php");
    exit;
}

// Generate a unique CSRF token for this session (if not already set)
if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}

$message = isset($_GET['success']) ? "Password changed successfully!" : "";
$csrf_error = isset($_GET['csrf_error']) ? "Request blocked: Invalid or missing CSRF token." : "";
?>
<!DOCTYPE html>
<html>
<head><title>Change Password</title></head>
<body>
    <h2>Change Password</h2>
    <p>Logged in as: <?php echo htmlspecialchars($_SESSION['username']); ?></p>
    <?php if ($message) echo "<p style='color:green'>$message</p>"; ?>
    <?php if ($csrf_error) echo "<p style='color:red'>$csrf_error</p>"; ?>

    <form method="POST" action="process_password_change.php">
        <input type="hidden" name="csrf_token" value="<?php echo htmlspecialchars($_SESSION['csrf_token']); ?>">
        <input type="password" name="new_password" placeholder="New Password" required><br><br>
        <button type="submit">Change Password</button>
    </form>

    <br>
    <a href="logout.php">Logout</a>
</body>
</html>
EOF
```

### 8. Create the Password Change Handler with CSRF Verification (`process_password_change.php`)

```bash
sudo tee /var/www/html/csrf-task/process_password_change.php > /dev/null << 'EOF'
<?php
session_start();
require 'db.php';

if (!isset($_SESSION['user_id'])) {
    header("Location: login.php");
    exit;
}

// Verify CSRF token
$submitted_token = $_POST['csrf_token'] ?? '';

if (empty($submitted_token) || empty($_SESSION['csrf_token']) || !hash_equals($_SESSION['csrf_token'], $submitted_token)) {
    header("Location: change_password.php?csrf_error=1");
    exit;
}

// Token is valid - proceed with password change
$new_password = $_POST['new_password'] ?? '';

if (empty($new_password)) {
    header("Location: change_password.php");
    exit;
}

$hashed = password_hash($new_password, PASSWORD_DEFAULT);
$stmt = $conn->prepare("UPDATE users SET password = ? WHERE id = ?");
$stmt->bind_param("si", $hashed, $_SESSION['user_id']);
$stmt->execute();

// Regenerate the CSRF token after use (good practice)
$_SESSION['csrf_token'] = bin2hex(random_bytes(32));

header("Location: change_password.php?success=1");
exit;
EOF
```

### 9. Create the Logout Page (`logout.php`)

```bash
sudo tee /var/www/html/csrf-task/logout.php > /dev/null << 'EOF'
<?php
session_start();
session_unset();
session_destroy();
header("Location: login.php");
exit;
EOF
```

### 10. Set File Permissions

```bash
sudo chown -R www-data:www-data /var/www/html/csrf-task
```

### 11. Write the CSRF Exploit (`csrf_exploit.html`)

This file simulates a malicious external page. It auto-submits a form to
the password change endpoint without including a valid CSRF token,
relying only on the victim's browser automatically sending their session
cookie.

```bash
cat > ~/csrf_exploit.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Totally Harmless Page</title></head>
<body>
    <h2>You just won a prize! Click below to claim it.</h2>
    <form id="evilForm" action="http://localhost/csrf-task/process_password_change.php" method="POST">
        <input type="hidden" name="new_password" value="hacked123">
    </form>
    <script>
        document.getElementById('evilForm').submit();
    </script>
</body>
</html>
EOF
```

### 12. Test the Legitimate Login and Password Change Flow via cURL

```bash
curl -c ~/cookies.txt -d "username=admin&password=test123" http://localhost/csrf-task/login.php -L -s -o /dev/null
curl -b ~/cookies.txt http://localhost/csrf-task/change_password.php | grep csrf_token
```

Copy the token value from the output, then submit a legitimate request:

```bash
curl -b ~/cookies.txt -d "csrf_token=PASTE_TOKEN_HERE&new_password=newpass123" http://localhost/csrf-task/process_password_change.php -L
```

Expected: `Password changed successfully!`

### 13. Simulate a CSRF Attack via cURL (No Token)

```bash
curl -b ~/cookies.txt -d "new_password=hacked123" http://localhost/csrf-task/process_password_change.php -L
```

Expected: `Request blocked: Invalid or missing CSRF token.`

### 14. Verify in the Browser

1. Open `http://localhost/csrf-task/login.php` and log in.
2. On the `change_password.php` page, open Developer Tools → Inspector,
   search (`Ctrl+F`) for `csrf_token`, and confirm the hidden input field
   and its value.
3. Open the exploit file directly in the browser:
   ```
   file:///home/sunflower/csrf_exploit.html
   ```
4. Confirm the auto-submitting form is blocked, and the resulting page
   shows: `Request blocked: Invalid or missing CSRF token.`

---

## My Solution:

[View My Solution:](https://youtu.be/3cEImvd-f9A)

---
