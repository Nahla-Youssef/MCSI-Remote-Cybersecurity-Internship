# Secure Software Development: Write a web application that automatically logs out users after 5 minutes of inactivity

---

## Objectives
- Build a web application with an authentication mechanism (username and password) that allows users to log in.
- Use a server-side language (PHP) to manage user sessions.
- Upon successful authentication, generate a session token and store it in a secure HTTP cookie.
- Automatically expire the session 5 minutes after the last user activity.
- Protect application resources so they are inaccessible after the session has expired or the user has logged out.
- Validate the behavior with browser developer tools and a live inactivity test.
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
CREATE DATABASE timeout_db;
USE timeout_db;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    password VARCHAR(255)
);

CREATE USER 'timeout_user'@'localhost' IDENTIFIED BY 'TimeoutPass123!';
GRANT ALL PRIVILEGES ON timeout_db.* TO 'timeout_user'@'localhost';
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
mysql -u timeout_user -p timeout_db -e "INSERT INTO users (username, password) VALUES ('admin', '$HASH');"
```

Verify the record:

```bash
mysql -u timeout_user -p timeout_db -e "SELECT * FROM users;"
```

### 4. Create the Project Directory

```bash
sudo mkdir -p /var/www/html/timeout-task
cd /var/www/html/timeout-task
```

### 5. Create the Database Connection File (`db.php`)

```bash
sudo tee /var/www/html/timeout-task/db.php > /dev/null << 'EOF'
<?php
$conn = new mysqli("localhost", "timeout_user", "TimeoutPass123!", "timeout_db");
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
EOF
```

### 6. Create the Login Page (`login.php`)

```bash
sudo tee /var/www/html/timeout-task/login.php > /dev/null << 'EOF'
<?php
session_set_cookie_params([
    'lifetime' => 0,
    'path' => '/',
    'domain' => '',
    'secure' => false,
    'httponly' => true,
    'samesite' => 'Lax'
]);
session_start();

require 'db.php';

// If already logged in, redirect to dashboard
if (isset($_SESSION['user_id'])) {
    header("Location: dashboard.php");
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
            $_SESSION['LAST_ACTIVITY'] = time();
            header("Location: dashboard.php");
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
    <?php if (isset($_GET['timeout'])) echo "<p style='color:orange'>You have been logged out due to 5 minutes of inactivity.</p>"; ?>
    <form method="POST">
        <input type="text" name="username" placeholder="Username" required><br><br>
        <input type="password" name="password" placeholder="Password" required><br><br>
        <button type="submit">Login</button>
    </form>
</body>
</html>
EOF
```

### 7. Create the Shared Session-Check Logic (`session_check.php`)

This file is included at the top of every protected page. It verifies the
user is authenticated and checks whether more than 5 minutes (300 seconds)
have passed since the last recorded activity. If so, it destroys the
session and redirects to the login page.

```bash
sudo tee /var/www/html/timeout-task/session_check.php > /dev/null << 'EOF'
<?php
session_set_cookie_params([
    'lifetime' => 0,
    'path' => '/',
    'domain' => '',
    'secure' => false,
    'httponly' => true,
    'samesite' => 'Lax'
]);
session_start();

$timeout_duration = 300; // 5 minutes in seconds

// Check if user is not logged in
if (!isset($_SESSION['user_id'])) {
    header("Location: login.php");
    exit;
}

// Check for inactivity timeout
if (isset($_SESSION['LAST_ACTIVITY']) && (time() - $_SESSION['LAST_ACTIVITY'] > $timeout_duration)) {
    session_unset();
    session_destroy();
    header("Location: login.php?timeout=1");
    exit;
}

// Update last activity time on every request
$_SESSION['LAST_ACTIVITY'] = time();
EOF
```

### 8. Create the Protected Dashboard Page with a Countdown Timer (`dashboard.php`)

```bash
sudo tee /var/www/html/timeout-task/dashboard.php > /dev/null << 'EOF'
<?php
require 'session_check.php';
$remaining = 300 - (time() - $_SESSION['LAST_ACTIVITY']);
?>
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard - Protected Page</title>
</head>
<body>
    <h2>Welcome, <?php echo htmlspecialchars($_SESSION['username']); ?>!</h2>
    <p>This is a protected resource. You are logged in.</p>
    <p>Session ID: <?php echo session_id(); ?></p>
    <p>Time remaining before auto-logout: <span id="countdown"><?php echo $remaining; ?></span> seconds</p>
    <a href="logout.php">Logout</a>

    <script>
        let timeLeft = <?php echo $remaining; ?>;
        const countdownEl = document.getElementById('countdown');
        const timer = setInterval(() => {
            timeLeft--;
            countdownEl.textContent = timeLeft;
            if (timeLeft <= 0) {
                clearInterval(timer);
                window.location.href = "login.php?timeout=1";
            }
        }, 1000);
    </script>
</body>
</html>
EOF
```

### 9. Create the Logout Page (`logout.php`)

```bash
sudo tee /var/www/html/timeout-task/logout.php > /dev/null << 'EOF'
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
sudo chown -R www-data:www-data /var/www/html/timeout-task
```

### 11. Test the Login Flow via cURL

```bash
curl -v -c cookies.txt -b cookies.txt -d "username=admin&password=test123" http://localhost/timeout-task/login.php -L
```

Expected: a `302 Found` redirect to `dashboard.php`, followed by the
dashboard's HTML content showing "Welcome, admin!" and the countdown timer.

### 12. Confirm Protected Pages Reject Unauthenticated Requests

```bash
curl -v http://localhost/timeout-task/dashboard.php
```

Expected: a `302 Found` redirect to `login.php` (no valid session cookie
was sent).

### 13. Verify in the Browser

1. Open `http://localhost/timeout-task/login.php`.
2. Log in with:
   - Username: `admin`
   - Password: `test123`
3. Confirm you are redirected to `dashboard.php`, showing your username,
   session ID, and a countdown timer starting at 300 seconds.

### 14. Inspect the Session Cookie with Developer Tools

1. Open Developer Tools (`F12`, or right-click → **Inspect**).
2. Go to the **Storage** tab (Firefox) or **Application** tab (Chrome).
3. Expand **Cookies** → select `http://localhost`.
4. Locate the `PHPSESSID` cookie and confirm its value matches the
   Session ID shown on the dashboard.

### 15. Verify Automatic Logout After 5 Minutes of Inactivity

1. Leave the dashboard page open without interacting with it.
2. Watch the countdown timer decrease every second.
3. When it reaches zero, confirm the page automatically redirects to
   `login.php?timeout=1`, showing an inactivity logout message.
4. Try navigating back to `dashboard.php` (e.g., using the browser's Back
   button). Confirm access is denied and you are redirected back to
   `login.php`.

---

## My Solution:

[View My Solution:](https://youtu.be/Iha3q8G1sOY)

---
