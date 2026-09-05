# Threat Hunting: Write A YARA Rule That Is Professionally Documented

---

## Objectives
- Create a YARA rule using either legitimate or bogus (mock) malware data.
- Professionally document the rule by including all required metadata fields:
  - Author
  - Author's email
  - Example MD5 hash of a known malware sample
  - Date of creation
  - Version number
  - Reference URL
  - Type of malware

---

## Tools
- **OS:** Windows 10 (running inside VirtualBox)
- **YARA:** v4.5.x for Windows (64-bit) — [VirusTotal/yara releases](https://github.com/VirusTotal/yara/releases)
- **Command Prompt** (Administrator)
- **certutil** (built-in Windows tool, used to generate an MD5 hash)
- **Notepad** (to write the rule file)

---

## Steps

### 1. Create a working directory for this task

```
cd C:\Users\nahla\Desktop\yara
mkdir documented_rule_task
cd documented_rule_task
```

### 2. Generate mock malware data

Rather than downloading real malware (which carries risk), a mock file is created to represent a sample malicious file for this exercise:

```
echo This is mock malware content for YARA rule testing - FAKE_MALWARE_STRING_12345 > mock_malware.exe
```

### 3. Generate an example MD5 hash for the mock sample

```
certutil -hashfile mock_malware.exe MD5
```

**Output:**
```
MD5 hash of mock_malware.exe:
d24121a8bf2e4d1e0e25b83828fc4431
CertUtil: -hashfile command completed successfully.
```

This hash is used as the "example MD5 hash" metadata field in the rule.

### 4. Write the professionally documented YARA rule

```
notepad documented_rule.yar
```

Rule content:

```yara
rule Documented_Malware_Rule
{
    meta:
        author = "Nahla"
        author_email = "nahla@example.com"
        md5_example = "d24121a8bf2e4d1e0e25b83828fc4431"
        date = "2026-09-05"
        version = "1.0"
        reference = "https://attack.mitre.org/software/"
        malware_type = "Trojan"
        description = "Mock rule created for educational purposes to demonstrate professional YARA documentation. Uses bogus/mock malware data, not a real malicious sample."

    strings:
        $mock_string = "FAKE_MALWARE_STRING_12345"

    condition:
        $mock_string
}
```

**Metadata mapping (per task requirements):**

| Required metadata | Field in rule | Value |
|---|---|---|
| Author | `author` | `Nahla` |
| Author's email | `author_email` | `nahla@example.com` |
| Example MD5 hash | `md5_example` | `d24121a8bf2e4d1e0e25b83828fc4431` |
| Date of creation | `date` | `2026-09-05` |
| Version number | `version` | `1.0` |
| Reference URL | `reference` | `https://attack.mitre.org/software/` |
| Type of malware | `malware_type` | `Trojan` |

Save and close Notepad.

### 5. Verify the rule file was saved correctly

```
type documented_rule.yar
```

Confirm all seven metadata fields are present and correctly written.

### 6. Test the rule against the mock malware sample (positive case)

```
C:\Users\nahla\Desktop\yara\yara64.exe documented_rule.yar mock_malware.exe
```

**Expected output:**
```
Documented_Malware_Rule mock_malware.exe
```

### 7. Create a clean file for negative testing

```
echo This is a clean harmless file > test_clean.txt
```

### 8. Test the rule against the clean file (negative case)

```
C:\Users\nahla\Desktop\yara\yara64.exe documented_rule.yar test_clean.txt
```

**Expected output:** No output (no match) — confirms the rule does not produce false positives.

---

## My Solution:

[View My Solution:]
<img width="982" height="831" alt="Solution" src="https://github.com/user-attachments/assets/a9c6f1a4-2bf1-437a-b4ec-605d90bbab88" />


---
