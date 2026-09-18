# Secure Software Development: Write A Web Application That Prevents Clickjacking

---

## Objectives
- Prevent the target page from being loaded inside an `<iframe>` on another site (Clickjacking protection).
- Implement protection using the standard `X-Frame-Options: DENY` HTTP header sent from the server.
- Add a second, independent layer of protection in JavaScript (frame-busting) in case the header is ever missing or stripped.
- Build a dedicated test page that attempts to frame the target page, to verify the protection is actually working.
- Confirm the header is sent correctly using `curl`, and confirm the behavior visually in the browser (Network tab + Console).

---

## Tools
- **Apache2** (web server) running on a local machine
- **PHP** (to set the response header)
- **HTML / CSS / JavaScript**
- **curl** (to inspect response headers from the terminal)
- **Browser DevTools** (Network tab and Console, to confirm the header and the blocked iframe)

---

## Steps

### 1. Confirm Apache is running
```bash
sudo systemctl status apache2
```

### 2. Create the project folder
```bash
sudo mkdir -p /var/www/html/clickjack-task
cd /var/www/html/clickjack-task
```

### 3. Create the main page `index.php` (with JS detection)
Copy `index.php` from this repo into `/var/www/html/clickjack-task/index.php`, or recreate it directly:
```bash
sudo tee /var/www/html/clickjack-task/index.php > /dev/null << 'EOF'
<?php
// Set the X-Frame-Options header to prevent the page from being framed
header("X-Frame-Options: DENY");
?>
<!DOCTYPE html>
<html>
<head>
    <title>Clickjacking Protection Demo</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            text-align: center;
            padding-top: 50px;
        }
        .container {
            background: white;
            display: inline-block;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        button {
            background-color: #2563eb;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }
        #status {
            margin-top: 15px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Secure Application</h1>
        <p>This page is protected against clickjacking.</p>
        <button onclick="document.getElementById('status').innerText='Button clicked successfully! You interacted with the real page.'">
            Click Me
        </button>
        <p id="status"></p>
    </div>

    <script>
        // JavaScript-based clickjacking detection (defense-in-depth,
        // in addition to the server-side X-Frame-Options header)
        if (window.top !== window.self) {
            // The page is loaded inside an iframe/frame
            document.body.innerHTML =
                "<h1 style='color:red; text-align:center; margin-top:50px;'>" +
                "Warning: This page cannot be displayed in a frame for security reasons." +
                "</h1>";
            // Attempt to break out of the frame
            window.top.location = window.self.location;
        } else {
            console.log("Page loaded normally (not inside an iframe).");
        }
    </script>
</body>
</html>
EOF
```

### 4. Set permissions
```bash
sudo chown -R www-data:www-data /var/www/html/clickjack-task
```

### 5. Create the test file `clickjack-test.html`
This file tries to load the target page inside an `<iframe>` to prove the protection is active.
```bash
sudo tee /var/www/html/clickjack-task/clickjack-test.html > /dev/null << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Clickjack Test Page</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; }
        iframe {
            width: 600px;
            height: 400px;
            border: 3px solid red;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <h2>Clickjacking Test</h2>
    <p>This page attempts to load the target application inside an iframe below.</p>
    <p>If the target application is properly protected, the iframe should remain blank or blocked by the browser.</p>

    <iframe src="http://localhost/clickjack-task/index.php"></iframe>
</body>
</html>
EOF
```

### 6. Confirm the header is sent correctly (terminal test)
```bash
curl -I http://localhost/clickjack-task/index.php
```
Expected output should include:
```
X-Frame-Options: DENY
```

### 7. Test the original page normally (without iframe)
```bash
curl -s http://localhost/clickjack-task/index.php | head -20
```
Expected: the page content is returned normally with no issues.

### 8. Real test from the browser
- Open `http://localhost/clickjack-task/index.php` directly.
- Confirm the page displays normally and the **"Click Me"** button works and shows the success message.

### 9. Inspect the header from DevTools
- Press **F12** → **Network** tab.
- Refresh the page (**Ctrl+R**).
- Click the first request in the list (`index.php`).
- Go to the **Headers** (Response Headers) tab.
- Look for `X-Frame-Options` and confirm its value is `DENY`.

### 10. Test the Clickjack test page
- Open `http://localhost/clickjack-task/clickjack-test.html`.
- Expected: the `<iframe>` stays completely empty, or the browser shows a blocking message (e.g. "refused to connect" / "blocked by X-Frame-Options").
- Open **DevTools → Console** on the same page. You should see a browser error message similar to:
  ```
  Refused to display 'http://localhost/...' in a frame because it set 'X-Frame-Options' to 'deny'.
  ```

---

## My Solution:

[View My Solution:](https://youtu.be/1FTxvZ0K7Bs)

---
