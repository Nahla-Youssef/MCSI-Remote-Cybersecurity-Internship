# Secure Software Development: Write A Web Application That Detects And Safely Handles Crashes And Exceptions

---

# Secure Error Handling for a Vulnerable Web Application (SQLi & Command Injection)

## Objectives

- Build a web application containing two intentional vulnerabilities:
  - A user input vulnerable to SQL Injection.
  - A user input vulnerable to Command Injection.
- Implement client-side (JavaScript) error handling to catch errors and
  exceptions that occur during user interactions.
- Implement server-side error handling that logs full error details to a
  securely stored log file, inaccessible to the public.
- Ensure users only ever see a generic error message, never raw stack
  traces, SQL errors, or system details.
- Validate the application by exploiting both vulnerabilities and
  confirming that error handling remains robust, including under
  automated fuzzing.
- Demonstrate the full workflow with a screen recording.

## Tools

- **OS**: Kali Linux
- **Web Server**: Apache2
- **Language**: PHP
- **Database**: MariaDB (MySQL)
- **Browser**: Firefox / Chromium (with Developer Tools)
- **Testing**: cURL
- **Fuzzing**: ffuf
- **Screen Recording**: Kazam / OBS Studio

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
CREATE DATABASE vuln_db;
USE vuln_db;
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2)
);
INSERT INTO products (name, price) VALUES ('Laptop', 999.99), ('Mouse', 19.99), ('Keyboard', 49.99);

CREATE USER 'vuln_user'@'localhost' IDENTIFIED BY 'VulnPass123!';
GRANT ALL PRIVILEGES ON vuln_db.* TO 'vuln_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 3. Create the Project Directory and a Protected Logs Directory

The log directory is placed **outside** the web root (`/var/www/html`) so
it can never be served over HTTP, regardless of `.htaccess` rules.

```bash
sudo mkdir -p /var/www/html/vuln-task
sudo mkdir -p /var/www/logs
sudo chown -R www-data:www-data /var/www/logs
sudo chmod 750 /var/www/logs
sudo touch /var/www/logs/app_errors.log
sudo chown www-data:www-data /var/www/logs/app_errors.log
sudo chmod 640 /var/www/logs/app_errors.log
```

### 4. Create the Database Connection File (`db.php`)

```bash
sudo tee /var/www/html/vuln-task/db.php > /dev/null << 'EOF'
<?php
$conn = new mysqli("localhost", "vuln_user", "VulnPass123!", "vuln_db");
if ($conn->connect_error) {
    error_log("DB Connection failed: " . $conn->connect_error);
    die("A system error occurred. Please try again later.");
}
EOF
```

### 5. Create the Central Error Handler (`error_handler.php`)

This file is included at the top of every page. It disables the display
of raw PHP errors, and catches uncaught exceptions, PHP errors, and fatal
errors — logging full details to the protected log file and showing the
user a generic message instead.

```bash
sudo tee /var/www/html/vuln-task/error_handler.php > /dev/null << 'EOF'
<?php
ini_set('display_errors', 0);
ini_set('log_errors', 0);
error_reporting(E_ALL);

define('LOG_FILE', '/var/www/logs/app_errors.log');

function logError($message, $context = '') {
    $timestamp = date('Y-m-d H:i:s');
    $entry = "[$timestamp] $message | Context: $context" . PHP_EOL;
    file_put_contents(LOG_FILE, $entry, FILE_APPEND | LOCK_EX);
}

function showGenericError() {
    http_response_code(500);
    echo "<h2>Something went wrong</h2><p>An unexpected error occurred. Please try again later.</p>";
    exit;
}

set_exception_handler(function ($e) {
    logError("Uncaught Exception: " . $e->getMessage(), $e->getFile() . ':' . $e->getLine());
    showGenericError();
});

set_error_handler(function ($errno, $errstr, $errfile, $errline) {
    logError("PHP Error [$errno]: $errstr", "$errfile:$errline");
    showGenericError();
});

register_shutdown_function(function () {
    $error = error_get_last();
    if ($error !== null && in_array($error['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
        logError("Fatal Error: " . $error['message'], $error['file'] . ':' . $error['line']);
        showGenericError();
    }
});
EOF
```

### 6. Create the Home Page with Client-Side (JavaScript) Error Handling (`index.php`)

```bash
sudo tee /var/www/html/vuln-task/index.php > /dev/null << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Vulnerable Demo App</title></head>
<body>
    <h2>Product Search (SQL Injection Demo)</h2>
    <form method="GET" action="search.php">
        <input type="text" name="product" placeholder="Enter product name">
        <button type="submit">Search</button>
    </form>

    <h2>Ping Tool (Command Injection Demo)</h2>
    <form method="GET" action="ping.php">
        <input type="text" name="host" placeholder="Enter hostname or IP">
        <button type="submit">Ping</button>
    </form>

    <div id="client-error-banner" style="display:none; color:red; margin-top:20px;">
        An unexpected error occurred on this page. Our team has been notified.
    </div>

    <script>
        window.onerror = function (message, source, lineno, colno, error) {
            fetch('log_js_error.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    message: message,
                    source: source,
                    line: lineno
                })
            }).catch(() => {});

            document.getElementById('client-error-banner').style.display = 'block';
            return true;
        };

        try {
            document.querySelector('form').addEventListener('submit', function (e) {
                try {
                    // Any client-side validation/processing logic would go here
                } catch (err) {
                    window.onerror(err.message, 'form-submit-handler', 0, 0, err);
                    e.preventDefault();
                }
            });
        } catch (err) {
            window.onerror(err.message, 'init-script', 0, 0, err);
        }
    </script>
</body>
</html>
EOF
```

### 7. Create the SQL Injection Vulnerable Endpoint (`search.php`)

```bash
sudo tee /var/www/html/vuln-task/search.php > /dev/null << 'EOF'
<?php
require 'error_handler.php';
require 'db.php';

try {
    $product = $_GET['product'] ?? '';

    // INTENTIONALLY VULNERABLE: raw string concatenation, no sanitization
    $query = "SELECT * FROM products WHERE name = '$product'";
    $result = $conn->query($query);

    if ($result === false) {
        throw new Exception("Query failed: " . $conn->error);
    }

    echo "<h3>Results:</h3>";
    while ($row = $result->fetch_assoc()) {
        echo htmlspecialchars($row['name']) . " - $" . htmlspecialchars($row['price']) . "<br>";
    }
} catch (Exception $e) {
    logError("SQLi endpoint error: " . $e->getMessage(), $_SERVER['QUERY_STRING'] ?? '');
    showGenericError();
}
EOF
```

### 8. Create the Command Injection Vulnerable Endpoint (`ping.php`)

```bash
sudo tee /var/www/html/vuln-task/ping.php > /dev/null << 'EOF'
<?php
require 'error_handler.php';

try {
    $host = $_GET['host'] ?? '';

    if (empty($host)) {
        throw new Exception("No host provided");
    }

    // INTENTIONALLY VULNERABLE: user input passed directly to shell_exec
    $output = shell_exec("ping -c 2 " . $host . " 2>&1");

    if ($output === null) {
        throw new Exception("Command execution failed");
    }

    echo "<h3>Ping Output:</h3><pre>" . htmlspecialchars($output) . "</pre>";
} catch (Exception $e) {
    logError("Command Injection endpoint error: " . $e->getMessage(), $_SERVER['QUERY_STRING'] ?? '');
    showGenericError();
}
EOF
```

### 9. Create the Client-Side Error Logging Endpoint (`log_js_error.php`)

Receives JavaScript error reports sent via `fetch()` from `index.php` and
writes them to the same protected log file.

```bash
sudo tee /var/www/html/vuln-task/log_js_error.php > /dev/null << 'EOF'
<?php
require 'error_handler.php';

$data = json_decode(file_get_contents('php://input'), true);

if ($data && isset($data['message'])) {
    $message = $data['message'];
    $source = $data['source'] ?? 'unknown';
    $line = $data['line'] ?? 'unknown';
    logError("Client-side JS Error: $message", "Source: $source, Line: $line");
}

http_response_code(200);
echo json_encode(['status' => 'logged']);
EOF
```

### 10. Set File Permissions

```bash
sudo chown -R www-data:www-data /var/www/html/vuln-task
```

### 11. Test Baseline (Normal) Behavior

```bash
curl "http://localhost/vuln-task/search.php?product=Laptop"
curl "http://localhost/vuln-task/ping.php?host=127.0.0.1"
```

Both should return normal, expected output.

### 12. Exploit the SQL Injection Vulnerability

Boolean-based injection (returns all records):

```bash
curl -G "http://localhost/vuln-task/search.php" --data-urlencode "product=nonexistent' OR '1'='1"
```

Injection that breaks SQL syntax (triggers error handling):

```bash
curl -G "http://localhost/vuln-task/search.php" --data-urlencode "product='"
```

Expected: a generic `Something went wrong` message, with no SQL details
exposed.

### 13. Exploit the Command Injection Vulnerability

```bash
curl "http://localhost/vuln-task/ping.php?host=127.0.0.1;whoami"
```

Expected: the ping output followed by the output of `whoami` (e.g.
`www-data`), confirming successful command execution.

### 14. Confirm the Log File Is Not Publicly Accessible

```bash
curl -I http://localhost/logs/app_errors.log
```

Expected: `404 Not Found`, since the log directory lives entirely outside
the web root.

### 15. Inspect the Log File Contents (Server-Side Only)

```bash
sudo cat /var/www/logs/app_errors.log
```

Expected: full technical error details (SQL errors, command execution
failures, JS errors) — visible only from the server terminal, never to
end users.

### 16. Verify Client-Side JavaScript Error Handling in the Browser

1. Open `http://localhost/vuln-task/index.php`.
2. Open Developer Tools (`F12`) → **Console**.
3. Run:
   ```js
   setTimeout(function() { undefinedFunction(); }, 100);
   ```
4. Confirm the generic red banner appears on the page:
   "An unexpected error occurred on this page. Our team has been notified."
5. Confirm the error was logged:
   ```bash
   sudo tail -1 /var/www/logs/app_errors.log
   ```
   Expected: a `Client-side JS Error` entry with the error message and
   source.

### 17. Fuzz the Vulnerable Inputs

Install `ffuf` if needed:

```bash
which ffuf || sudo apt install ffuf -y
```

Create a payload list:

```bash
cat > ~/payloads.txt << 'EOF'
' OR '1'='1
' UNION SELECT 1,2--
'; DROP TABLE products--
<script>alert(1)</script>
../../../etc/passwd
; whoami
| id
&& cat /etc/passwd
`id`
$(whoami)
EOF
```

Fuzz the SQL injection field:

```bash
ffuf -u "http://localhost/vuln-task/search.php?product=FUZZ" -w ~/payloads.txt -mc all -fc 404
```

Fuzz the command injection field:

```bash
ffuf -u "http://localhost/vuln-task/ping.php?host=127.0.0.1FUZZ" -w ~/payloads.txt -mc all -fc 404
```

Expected: every request returns either a normal result, an exploited
result, or the generic error message (HTTP 200 or 500) — never a raw
stack trace or database error, and never a 404 crash.

### 18. Confirm All Fuzzing Attempts Were Logged

```bash
sudo wc -l /var/www/logs/app_errors.log
sudo tail -20 /var/www/logs/app_errors.log
```

---

## My Solution:

[View My Solution:](https://youtu.be/rrvPm2fw7A4)

---
