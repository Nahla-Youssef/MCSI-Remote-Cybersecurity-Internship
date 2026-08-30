# Security Tools: Use Automated Tools to Capture Open Source Intelligence Using Domain Names

---

## Objectives
- Practice passive OSINT collection against real public domains using automated reconnaissance tools.
- Compare results from two different OSINT/subdomain-enumeration tools (theHarvester and subfinder) against the same targets.
- Organize raw output (JSON/TXT) into a structured spreadsheet format for analysis.

---

## Tools
- **theHarvester** — OSINT tool that pulls data from multiple public sources (crt.sh, CertSpotter, DuckDuckGo, OTX, HackerTarget, RapidDNS, ThreatCrowd, Wayback Archive, Yahoo, urlscan).
- **subfinder** — fast passive subdomain enumeration tool.
- Target domains: **eff.org** and **sans.edu**.

---

## Steps

### 1. Prepare the Kali VM
```
sudo apt update
sudo apt install theharvester
sudo apt install subfinder
mkdir recon_findings
cd recon_findings
```

### 2. Run reconnaissance against Target 1 — eff.org

theHarvester:
```
theHarvester -d eff.org -b crtsh,certspotter,duckduckgo,otx,hackertarget,rapiddns,threatcrowd,waybackarchive,yahoo,urlscan -n -f eff_theharvester
```

subfinder:
```
subfinder -d eff.org -o eff_subfinder.txt -v
```

### 3. Run reconnaissance against Target 2 — sans.edu

theHarvester:
```
theHarvester -d sans.edu -b crtsh,certspotter,duckduckgo,otx,hackertarget,rapiddns,threatcrowd,waybackarchive,yahoo,urlscan -n -f sans_theharvester
```

subfinder:
```
subfinder -d sans.edu -o sans_subfinder.txt -v
```

### 4. Consolidate results
Convert the resulting JSON and TXT output files into `.xlsx` format for structured review.

---

## My Solution:

[View My Solution:](https://youtu.be/0jvtR7ICF74)

---
