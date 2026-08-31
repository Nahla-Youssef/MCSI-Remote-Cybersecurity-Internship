# Penetration Testing: Write a Tool to Brute-Force Authentication Pages

---

## Objectives
- Understand how weak or predictable authentication systems can be tested against brute-force attacks, and how CSRF tokens and session cookies factor into automating such an attack.
- Practice setting up a local, disposable test environment with many auto-generated accounts, then evaluating it against both vertical (one user, many passwords) and horizontal (one password, many users) brute-force approaches.

---

## Tools
- **XAMPP** — local web server stack (Apache + MySQL/PHP).
- **phpMyAdmin** — used to inspect the generated test database.
- **Python** — used to build the brute-force testing script.
- Browser DevTools — used to inspect CSRF token behavior and session cookies.

---

## Files Used

[Download the folder: Brute_Auth_Pages](./Documentation/)

- `setup.php` — auto-generates the test user accounts and database.
- `login.php` — the login page (includes the CSRF token).
- `authenticate.php` — handles login validation.
- `bruteforce.py` — the Python brute-force testing script.
- `browser_cookie.txt` — file used to record the captured session cookie name/value.

---

## Steps

### 1. Set up the environment:
Start XAMPP and confirm Apache and MySQL services are running.
In the XAMPP htdocs directory, create a folder named bruteauth.
Add the three files: setup.php, login.php, authenticate.php (from the linked scripts folder).

### 2. Generate the test user accounts:
Open a browser and navigate to localhost.
Access setup.php first — this auto-generates 1000 user accounts with sequential usernames (1, 2, 3, ...) and corresponding passwords.

### 3. Verify the database was created:
Navigate to phpMyAdmin via localhost.
Refresh if needed and confirm the brute_auth_pages database with the Users table now exists.
Manually mix up a handful of the generated passwords in the table to add realism (so not every account follows a predictable pattern).

### 4. Build the brute-force script:
Create a Python file named bruteforce.py that will perform the login attempts against login.php/authenticate.php.

### 5. Inspect CSRF token behavior:
Open the login page's HTML source (or DevTools) and locate the hidden CSRF token field.
Refresh the page and confirm the token value changes each time — this confirms a fresh, random CSRF token is generated per request.

### 6. Capture session cookie info:
In DevTools, open the Storage tab and find the site's cookie.
Record the cookie name and value into a file named browser_cookie.txt.

### 7. Run the vertical brute-force attack:
Launch bruteforce.py and select the Vertical attack mode (one username, many passwords).

### 8. Run the horizontal brute-force attack:
Then run the script again and select the Horizontal attack mode (one password across many usernames).

---

## My Solution:

[View My Solution:](https://youtu.be/vZwKhkXUSIw)

---
