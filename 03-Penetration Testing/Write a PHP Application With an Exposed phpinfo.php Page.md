# Penetration Testing: Write a PHP Application With an Exposed phpinfo.php Page

---

## Objectives
- Demonstrate a common information-disclosure misconfiguration: leaving a `phpinfo()` page publicly accessible.
- Show how an exposed `phpinfo.php` page reveals PHP version, loaded modules, environment variables, and server configuration to any visitor.

---

## Tools
- **XAMPP / LAMPP** — local web server stack (Apache + PHP).
- **macOS** — used to host the local web server for this exercise (via `/opt/lampp/htdocs/`).

---

## Steps

### 1. Navigate to the web application directory
- Windows (XAMPP): `C:\xampp\htdocs\`
- Linux/macOS (LAMPP): `/opt/lampp/htdocs/`

### 2. Create `homepage.php`
```php
<?php
// index.php
echo "<h1>Welcome to the Simple PHP Web Application</h1>";
echo "<p>This is the homepage of the web application.</p>";
echo "<p>Enter phpinfo.php at the end of the URL to access the PHP info page.</p>";
?>
```

### 3. Create `phpinfo.php`
```php
<?php
// phpinfo.php
// Exposing the PHP version, modules, environment variables and server configuration
phpinfo();
?>
```

### 4. Access the web application
Open your browser and go to:
```
http://localhost/homepage.php
```
Then visit:
```
http://localhost/phpinfo.php
```
to view the exposed PHP configuration page.

---

## My Solution:

[View My Solution:](https://youtu.be/m4wjLHKI5F4)

---
