# Penetration Testing: Write a Web Application Penetration Testing Checklist

---

## Objectives
- Build a comprehensive, reusable web application penetration testing checklist grounded in industry standards.
- Cover at least 50 distinct, testable vulnerabilities mapped to recognized frameworks.
- Organize the checklist so testing progress and results can be tracked and reported over time.

---

## Tools
- **OWASP Top 10 (2021)** and **OWASP Web Security Testing Guide (WSTG)** — reference frameworks used to identify and categorize vulnerabilities.
- **Microsoft Excel** — used to build the checklist, dashboard, and formulas.
- AI tools — used to assist with research and drafting.

---

## Steps
1. Researched common web application vulnerabilities and mapped them to the OWASP Top 10 (2021) and the OWASP Web Security Testing Guide (WSTG).
2. Identified 63 unique vulnerabilities (above the 50-item minimum).
3. Grouped the vulnerabilities into 13 logical categories (e.g., Injection, Authentication, Access Control, XSS, CSRF, Misconfiguration, Cryptography, File Handling, Business Logic, API, SSRF, DoS, Logging).
4. Assigned a unique ID to each category (e.g., INJ, AUTH, AC) and to each individual vulnerability within it (e.g., INJ-01, AUTH-02) for easy reference and tracking.
5. Built the checklist as a table in Excel, with one row per vulnerability.
6. Added a tick-box column to mark whether each vulnerability has been tested.
7. Added a column listing the tools that can be used to test each group of vulnerabilities (e.g., sqlmap, Burp Suite, ffuf, testssl.sh).
8. Added a column to record whether the test was actually performed (Yes / No / N/A).
9. Added a column for the test result (Pass / Fail / Partial / N/A) with automatic color coding, plus a remarks column for observations.
10. Added a Dashboard sheet that automatically summarizes testing progress and results per category using formulas.
11. Formatted the workbook professionally (headers, colors, frozen panes, filters) so it can be reused as a long-term reference tool.
12. Exported the final checklist to PDF, included the student ID, and prepared this summary of the steps taken.

---

## My Solution:

[View My Solution: Download the PDF file: Web_App_Pentest_Checklist.pdf](./Documentation/)

# Note: If you're going to use the PDF, please make sure to change the name and student ID.

---
