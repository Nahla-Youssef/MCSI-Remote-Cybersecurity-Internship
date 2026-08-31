# Penetration Testing: Create Google search queries to identify webpages and publicly available documents

---

## Objectives
- Practice Google dorking (advanced search operators) as a passive OSINT technique against a real target website.
- Learn to combine operators (`site:`, `intitle:`, `filetype:`, `intext:`, exact-phrase quotes, exclusion `-`, date filters) to narrow search results precisely.
- Validate that "zero results" and "no exact match" outcomes are meaningful findings, not errors, by using backup/proof queries on a different site.
- Practice restricting results by time range (past month / past year) to find recent content.

---

## Tools
- **Web browser** (Firefox/Chrome) — no VM or Kali required.
- **Google Search** — using advanced search operators.
- **Screen recording tool** — to document the session.
- Target website: **krebsonsecurity.com**

---

## Steps

### Setup
Open 11 browser tabs, each on google.com — one query per tab.

### Tab 1 — Find all indexed pages on the target site
```
site:krebsonsecurity.com
```
Expected result: a long list of pages, all from krebsonsecurity.com. Validation: open the first result and confirm the URL belongs to krebsonsecurity.com.

### Tab 2 — Pages containing the keyword "ransom"
```
site:krebsonsecurity.com ransom
```
Expected result: articles containing the word "ransom" somewhere in the text. Validation: open the first result, use Cmd+F, search "ransom" to confirm it appears.

### Tab 3 — Pages containing the exact phrase "ransom payment"
```
site:krebsonsecurity.com "ransom payment"
```
Expected result: fewer results than Tab 2, since this matches the exact consecutive phrase. Validation: open a result, Cmd+F for "ransom payment" to confirm the exact phrase exists.

### Tab 4 — Keyword "ransom" appearing in the page title
```
site:krebsonsecurity.com intitle:ransom
```
Expected result: results where "ransom" appears in the blue title link itself. Validation: confirm the word "ransom" is visible in each result's title.

### Tab 5 — Pages about phishing, excluding ransomware
```
site:krebsonsecurity.com phishing -ransomware
```
Expected result: articles about phishing that do NOT mention "ransomware". Validation: open a result, Cmd+F for "ransomware" — it should not appear (or be rare).

### Tab 6 — Find PDF files hosted on the site
```
site:krebsonsecurity.com filetype:pdf
```
Expected result: results labeled [PDF]. Validation: open a result and confirm a PDF file opens (not a webpage).

### Tab 7 — Find Word documents hosted on the site
```
site:krebsonsecurity.com (filetype:doc OR filetype:docx)
```
Expected result on krebsonsecurity.com: zero results (normal — it's a news blog, not a document repository).

Proof/backup query (to validate the search syntax itself is correct):
```
site:harvard.edu (filetype:doc OR filetype:docx)
```
This should return real results, proving the query syntax works correctly and the zero result on the target is due to the site's content, not a syntax error.

### Tab 8 — Find Excel files hosted on the site
```
site:krebsonsecurity.com (filetype:xls OR filetype:xlsx)
```
Expected result on krebsonsecurity.com: a `.xlsx` file.

### Tab 9 — Find PDF files containing the word "password"
```
site:krebsonsecurity.com filetype:pdf intext:password
```
Expected result on krebsonsecurity.com: zero results (normal for a news blog).

Proof/backup query (confirmed working):
```
site:harvard.edu filetype:pdf intext:password
```
Validation: open the PDF, use Cmd+F, search "password" inside the document to confirm it highlights.

### Tab 10 — "windows defender" posts in the last month
```
site:krebsonsecurity.com "windows defender"
```
Then: click **Tools → Any time → Past month**.

Important note on the actual result: Google shows *"No results found for site:krebsonsecurity.com 'windows defender'. Results for site:krebsonsecurity.com windows defender (without quotes):"* — this is a correct and meaningful result, not an error. It proves that:
- The exact phrase "windows defender" (as consecutive words) does not appear literally anywhere on the site.
- Removing the quotes returns results where the words appear separately.

### Tab 11 — "cyber espionage" posts in the last year
```
site:krebsonsecurity.com "cyber espionage"
```
Then: click **Tools → Any time → Past year**.

Expected result: results with visible publish dates (e.g. May 18 2026, Jan 26 2026, Nov 26 2025, Nov 2 2025) — all correctly within the past 12 months (reference date: July 24, 2026). Validation: confirm each result's date falls within the last year, and that "cyber espionage" appears bolded in the snippet.

---

## My Solution:

[View My Solution:](https://youtu.be/ADGl69ZRrlM)

---
