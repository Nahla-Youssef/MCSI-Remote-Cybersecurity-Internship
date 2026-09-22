# Secure Software Development: Write A Web Application That Detects And Blocks Automated Input Submission Tools

---

## Objectives
- Provide **five different forms** that unauthenticated users can access and submit.
- Add a **JavaScript-assisted challenge-response mechanism** (CAPTCHA) to each form to distinguish human users from automated bots.
- Ensure the CAPTCHA is verified **server-side** (not just in JavaScript), so automated tools cannot bypass it by skipping client-side checks.
- Demonstrate that the application **detects and blocks** automated attacks from OWASP ZAP and Burp Suite Spider.

---

## Tools
- **Kali Linux**
- **Apache2** (web server) + **PHP**
- **OWASP ZAP** (automated scanning / fuzzing)
- **Burp Suite Community Edition ≤ 1.7.36** (Spider feature was moved to paid tiers after this version)
- **curl** (baseline testing from the terminal)

---

## Steps

### 1. Confirm Apache is running
```bash
sudo systemctl status apache2
```

### 2. Create the project folder
```bash
sudo mkdir -p /var/www/html/captcha-task
cd /var/www/html/captcha-task
```

### 3. Create captcha_helper.php (shared CAPTCHA logic)
```bash
sudo tee /var/www/html/captcha-task/captcha_helper.php > /dev/null << 'EOF'
<?php
session_start();

function generateCaptcha() {
    $num1 = rand(1, 10);
    $num2 = rand(1, 10);
    $_SESSION['captcha_answer'] = $num1 + $num2;
    return "$num1 + $num2";
}

function verifyCaptcha($userAnswer) {
    if (!isset($_SESSION['captcha_answer'])) {
        return false;
    }
    $valid = ((int)$userAnswer === (int)$_SESSION['captcha_answer']);
    unset($_SESSION['captcha_answer']);
    return $valid;
}
EOF
```

### 4. Create index.php (landing page linking to the five forms)
```bash
sudo tee /var/www/html/captcha-task/index.php > /dev/null << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Public Forms</title></head>
<body>
    <h2>Available Forms</h2>
    <ul>
        <li><a href="form1.php">1. Contact Us</a></li>
        <li><a href="form2.php">2. Newsletter Signup</a></li>
        <li><a href="form3.php">3. Feedback Form</a></li>
        <li><a href="form4.php">4. Support Request</a></li>
        <li><a href="form5.php">5. Event Registration</a></li>
    </ul>
</body>
</html>
EOF
```

### 5. Create the five forms
Each form generates a random math CAPTCHA question, includes a basic client-side JavaScript check (UX only, not the real protection), and posts to the shared processor.

```bash
# Form 1 - Contact Us
sudo tee /var/www/html/captcha-task/form1.php > /dev/null << 'EOF'
<?php
require 'captcha_helper.php';
$question = generateCaptcha();
?>
<!DOCTYPE html>
<html>
<head><title>Contact Us</title></head>
<body>
    <h2>Contact Us</h2>
    <form method="POST" action="process_form.php" onsubmit="return validateForm()">
        <input type="hidden" name="form_name" value="Contact Us">
        <input type="text" name="name" placeholder="Your Name" required><br><br>
        <input type="email" name="email" placeholder="Your Email" required><br><br>
        <textarea name="message" placeholder="Your Message" required></textarea><br><br>
        <label>Solve: <?php echo $question; ?> = </label>
        <input type="text" name="captcha" id="captcha" required><br><br>
        <button type="submit">Submit</button>
    </form>
    <script>
        function validateForm() {
            const val = document.getElementById('captcha').value;
            if (val.trim() === '') {
                alert('Please solve the challenge before submitting.');
                return false;
            }
            return true;
        }
    </script>
</body>
</html>
EOF

# Form 2 - Newsletter Signup
sudo tee /var/www/html/captcha-task/form2.php > /dev/null << 'EOF'
<?php
require 'captcha_helper.php';
$question = generateCaptcha();
?>
<!DOCTYPE html>
<html>
<head><title>Newsletter Signup</title></head>
<body>
    <h2>Newsletter Signup</h2>
    <form method="POST" action="process_form.php" onsubmit="return validateForm()">
        <input type="hidden" name="form_name" value="Newsletter Signup">
        <input type="email" name="email" placeholder="Your Email" required><br><br>
        <label>Solve: <?php echo $question; ?> = </label>
        <input type="text" name="captcha" id="captcha" required><br><br>
        <button type="submit">Subscribe</button>
    </form>
    <script>
        function validateForm() {
            const val = document.getElementById('captcha').value;
            if (val.trim() === '') {
                alert('Please solve the challenge before submitting.');
                return false;
            }
            return true;
        }
    </script>
</body>
</html>
EOF

# Form 3 - Feedback Form
sudo tee /var/www/html/captcha-task/form3.php > /dev/null << 'EOF'
<?php
require 'captcha_helper.php';
$question = generateCaptcha();
?>
<!DOCTYPE html>
<html>
<head><title>Feedback Form</title></head>
<body>
    <h2>Feedback Form</h2>
    <form method="POST" action="process_form.php" onsubmit="return validateForm()">
        <input type="hidden" name="form_name" value="Feedback Form">
        <select name="rating" required>
            <option value="">Rate our service</option>
            <option value="5">Excellent</option>
            <option value="3">Average</option>
            <option value="1">Poor</option>
        </select><br><br>
        <textarea name="comments" placeholder="Comments"></textarea><br><br>
        <label>Solve: <?php echo $question; ?> = </label>
        <input type="text" name="captcha" id="captcha" required><br><br>
        <button type="submit">Submit Feedback</button>
    </form>
    <script>
        function validateForm() {
            const val = document.getElementById('captcha').value;
            if (val.trim() === '') {
                alert('Please solve the challenge before submitting.');
                return false;
            }
            return true;
        }
    </script>
</body>
</html>
EOF

# Form 4 - Support Request
sudo tee /var/www/html/captcha-task/form4.php > /dev/null << 'EOF'
<?php
require 'captcha_helper.php';
$question = generateCaptcha();
?>
<!DOCTYPE html>
<html>
<head><title>Support Request</title></head>
<body>
    <h2>Support Request</h2>
    <form method="POST" action="process_form.php" onsubmit="return validateForm()">
        <input type="hidden" name="form_name" value="Support Request">
        <input type="text" name="subject" placeholder="Subject" required><br><br>
        <textarea name="issue" placeholder="Describe your issue" required></textarea><br><br>
        <label>Solve: <?php echo $question; ?> = </label>
        <input type="text" name="captcha" id="captcha" required><br><br>
        <button type="submit">Submit Request</button>
    </form>
    <script>
        function validateForm() {
            const val = document.getElementById('captcha').value;
            if (val.trim() === '') {
                alert('Please solve the challenge before submitting.');
                return false;
            }
            return true;
        }
    </script>
</body>
</html>
EOF

# Form 5 - Event Registration
sudo tee /var/www/html/captcha-task/form5.php > /dev/null << 'EOF'
<?php
require 'captcha_helper.php';
$question = generateCaptcha();
?>
<!DOCTYPE html>
<html>
<head><title>Event Registration</title></head>
<body>
    <h2>Event Registration</h2>
    <form method="POST" action="process_form.php" onsubmit="return validateForm()">
        <input type="hidden" name="form_name" value="Event Registration">
        <input type="text" name="fullname" placeholder="Full Name" required><br><br>
        <input type="number" name="guests" placeholder="Number of Guests" required><br><br>
        <label>Solve: <?php echo $question; ?> = </label>
        <input type="text" name="captcha" id="captcha" required><br><br>
        <button type="submit">Register</button>
    </form>
    <script>
        function validateForm() {
            const val = document.getElementById('captcha').value;
            if (val.trim() === '') {
                alert('Please solve the challenge before submitting.');
                return false;
            }
            return true;
        }
    </script>
</body>
</html>
EOF
```

### 6. Create process_form.php (shared processor — the real security check)
```bash
sudo tee /var/www/html/captcha-task/process_form.php > /dev/null << 'EOF'
<?php
require 'captcha_helper.php';

$formName = htmlspecialchars($_POST['form_name'] ?? 'Unknown Form');
$submittedCaptcha = $_POST['captcha'] ?? '';

if (!verifyCaptcha($submittedCaptcha)) {
    http_response_code(403);
    echo "<h2>Submission Rejected</h2>";
    echo "<p>The challenge-response verification failed. Automated or invalid submissions are not allowed.</p>";
    echo "<a href='index.php'>Back to forms</a>";
    exit;
}

echo "<h2>Success</h2>";
echo "<p>Your submission to \"$formName\" was received successfully.</p>";
echo "<a href='index.php'>Back to forms</a>";
EOF
```

### 7. Set permissions
```bash
sudo chown -R www-data:www-data /var/www/html/captcha-task
```

---

## Secure Deployment Validation

### A. Baseline test — legitimate submission (from a browser or curl)
```bash
curl -c ~/cookies.txt -s http://localhost/captcha-task/form1.php -o ~/form1.html
cat ~/form1.html | grep -A1 "Solve:"
```
Note the question shown, compute the answer, then submit it:
```bash
curl -b ~/cookies.txt -d "form_name=Contact Us&name=Test User&email=test@test.com&message=Hello&captcha=<answer>" \
  http://localhost/captcha-task/process_form.php
```
Expected: `"Success ... Your submission to Contact Us was received successfully."`

### B. Bot simulation — wrong/guessed CAPTCHA value
```bash
curl -c ~/cookies2.txt -s http://localhost/captcha-task/form1.php -o /dev/null
curl -b ~/cookies2.txt -d "form_name=Contact Us&name=Bot&email=bot@bot.com&message=spam&captcha=99999" \
  http://localhost/captcha-task/process_form.php
```
Expected: `"Submission Rejected ... challenge-response verification failed."`

### C. OWASP ZAP automated attack
1. Launch ZAP: `zaproxy &`
2. Target URL: `http://localhost/captcha-task/`
3. Run **Attack** (Spider + Active Scan).
4. Check the **Alerts** / **History** tabs: every submission ZAP makes to `process_form.php` should come back with `"Submission Rejected"`, since ZAP cannot solve the randomly generated math question.

### D. Burp Suite Spider (Community Edition ≤ 1.7.36)
1. Download from PortSwigger's release archive: `https://portswigger.net/burp/releases/professional-community-1-7-36`
2. Install and launch Burp, set the browser proxy to `127.0.0.1:8080`.
3. Browse the five forms once through the proxied browser so Burp records them in **Site map**.
4. Right-click the host in **Target → Site map** → **"Spider this host"**.
5. Check the **Logger** / **HTTP history**: every automated submission attempt should be met with `"Submission Rejected"`.

---

## My Solution:

[View My Solution:](https://youtu.be/l-9r-G0hKCI)

---
