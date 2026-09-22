# Red Teaming: Clone The Authentication Web Page Of A Bank And Steal User Credentials

---

## Objectives
* Build a controlled local spear-phishing awareness training environment.
* Create a fictional login page for security-awareness testing.
* Demonstrate secure handling of submitted training data.
* Prevent plaintext password storage by redacting passwords in logs.
* Verify user submissions through a local Flask application.
* Document the lab setup, execution, and verification process.

---

## Tools
* **Kali Linux** — Used as the security testing and lab environment.
* **Python 3** — Used to develop and run the local Flask application.
* **Flask** — Used to create the local web application and handle form submissions.
* **HTML5** — Used to build the fictional security-awareness login page.
* **CSS3** — Used to style and format the training login page.
* **Linux Command Line** — Used to create files and directories, run the application, manage logs, and verify file permissions.

---

## Steps

### 1. Create the Lab Directory

Create the main project directory:

```bash
mkdir -p ~/spear-phishing-lab
cd ~/spear-phishing-lab
```

Verify the current directory:

```bash
pwd
```

Expected output:

```text
/home/kali/spear-phishing-lab
```

### 2. Create the Project Directories

Create the required directories:

```bash
mkdir -p templates static logs
```

Verify the directory structure:

```bash
ls -la
```

### 3. Create the Submission Log

Create the submission log file:

```bash
touch logs/submissions.txt
```

Verify that the file exists:

```bash
ls -la logs
```

The output should contain:

```text
submissions.txt
```

### 4. Create the Flask Application

Create the application file:

```bash
nano app.py
```

Add the following code:

```python
from flask import Flask, render_template, request, redirect
from datetime import datetime

app = Flask(__name__)

LOG_FILE = "logs/submissions.txt"

@app.route("/")
def login():
    return render_template("login.html")

@app.route("/submit", methods=["POST"])
def submit():
    username = request.form.get("username", "")

    with open(LOG_FILE, "a") as f:
        f.write(
            f"{datetime.now().isoformat()} | "
            f"username={username} | "
            f"password=[REDACTED]\n"
        )

    return redirect("https://example.com")

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000)
```

Save and exit:

```text
Ctrl + O
Enter
Ctrl + X
```

### 5. Create the Training Login Page

Create the HTML file:

```bash
nano templates/login.html
```

Add:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SecureBank Demo - Security Awareness Lab</title>
    <link rel="stylesheet" href="/static/style.css">
</head>

<body>

<div class="container">

    <h1>SecureBank Demo</h1>

    <p class="warning">
        Security Awareness Training Environment
    </p>

    <form action="/submit" method="POST">

        <label for="username">Username</label>
        <input
            type="text"
            id="username"
            name="username"
            required
        >

        <label for="password">Training Password</label>
        <input
            type="password"
            id="password"
            name="password"
            required
        >

        <button type="submit">Sign In</button>

    </form>

    <p class="notice">
        This is a fictional training environment.
        Do not enter real credentials.
    </p>

</div>

</body>
</html>
```

Save and exit:

```text
Ctrl + O
Enter
Ctrl + X
```

### 6. Create the CSS File

Create the stylesheet:

```bash
nano static/style.css
```

Add:

```css
body {
    font-family: Arial, sans-serif;
    background: #f4f4f4;
    margin: 0;
    padding: 0;
}

.container {
    width: 360px;
    margin: 100px auto;
    padding: 30px;
    background: white;
    border-radius: 8px;
    box-shadow: 0 0 10px rgba(0,0,0,0.1);
}

h1 {
    text-align: center;
}

.warning {
    text-align: center;
    font-weight: bold;
}

label {
    display: block;
    margin-top: 15px;
}

input {
    width: 100%;
    padding: 10px;
    margin-top: 5px;
    box-sizing: border-box;
}

button {
    width: 100%;
    padding: 10px;
    margin-top: 20px;
    cursor: pointer;
}

.notice {
    margin-top: 20px;
    font-size: 12px;
    text-align: center;
}
```

Save and exit:

```text
Ctrl + O
Enter
Ctrl + X
```

### 7. Install Flask

Install Flask if it is not already installed:

```bash
python3 -m pip install flask --break-system-packages
```

Verify the installation:

```bash
python3 -c "import flask; print(flask.__version__)"
```

### 8. Start the Flask Application

Navigate to the project directory:

```bash
cd ~/spear-phishing-lab
```

Start the application:

```bash
python3 app.py
```

Expected output:

```text
* Serving Flask app 'app'
* Debug mode: off
* Running on http://127.0.0.1:5000
```

Keep this terminal running.


### 9. Access the Training Environment

Open a browser in Kali Linux and navigate to:

```text
http://127.0.0.1:5000
```

The fictional **SecureBank Demo** training page should appear.

Use only fictional training data.

Example username:

```text
training_user
```

Example training password:

```text
TrainingPassword123
```

Click **Sign In**.

The application should process the submission and redirect to:

```text
https://example.com
```

### 10. Verify the Submission Log

Open a new terminal while the Flask application is still running:

```bash
cd ~/spear-phishing-lab
```

Display the submission log:

```bash
cat logs/submissions.txt
```

Expected output:

```text
... | username=training_user | password=[REDACTED]
```

This confirms that the submission was successfully logged while the password was redacted.


### 11. Protect the Log File

Restrict access to the submission log:

```bash
chmod 600 logs/submissions.txt
```

Verify the permissions:

```bash
ls -l logs/submissions.txt
```

---

## My Solution:

[View My Solution:](https://youtu.be/Cl84ph_xQ9U)

---
