# Threat Hunting: Write A YARA Rule That Can Find Small Portable Executables

---

## Objectives
- Write a YARA rule that only detects files that are Portable Executables (PEs).
- The rule must only match PE files that are smaller than 500KB in size.
- Save the rule as `small_pe.yar` on the local hard drive.
- Follow the 'YARA Rules Testing' guideline and validate the rule against known positive and negative test cases.
- Confirm the rule accurately identifies small Windows PEs (< 500KB) while correctly rejecting non-PE files and larger PE files.

---

## Tools
- **OS:** Windows 10 (running inside VirtualBox)
- **YARA:** v4.5.x for Windows (64-bit), including the built-in `pe` module — [VirusTotal/yara releases](https://github.com/VirusTotal/yara/releases)
- **Command Prompt** (Administrator)
- **Notepad** (to write the rule file)
- **Windows Defender / Windows Security** (exclusion needed — YARA binaries can be flagged/removed as a false positive)

---

## Steps

### 1. Navigate to the working directory

```
cd C:\Users\nahla\Desktop\yara\small_pe_task
```

> This folder already contains `small_pe.yar` (the rule written beforehand — see rule content below).

### 2. Write the YARA rule

The rule saved as `small_pe.yar` in this folder:

```yara
import "pe"

rule Small_PE_Detector
{
    meta:
        author = "Nahla"
        description = "Detects Portable Executable (PE) files smaller than 500KB"
        date = "2026-09-05"

    condition:
        pe.is_pe and
        filesize < 500KB
}
```

**How it works:**
- `import "pe"` loads YARA's built-in PE module, which parses the file's DOS/PE headers instead of relying on manual magic-byte matching.
- `pe.is_pe` returns `true` only if the file has a valid PE structure (i.e., it's an actual Windows executable/DLL).
- `filesize < 500KB` restricts matches to files smaller than 500KB (YARA calculates `KB` as 1024 bytes).

### 3. Prepare test files (positive and negative cases)

```
copy C:\Windows\System32\notepad.exe .
echo This is a plain text file > test.txt
copy C:\Windows\explorer.exe .
```

### 4. Check file sizes to confirm expected test outcomes

```
dir *.exe *.txt
```

| File | Example size | Expected result |
|---|---|---|
| `notepad.exe` | ~196 KB |  Should match (PE, < 500KB) |
| `test.txt` | ~28 bytes |  Should NOT match (not a PE) |
| `explorer.exe` | ~5.9 MB |  Should NOT match (PE, but ≥ 500KB) |

> If Windows Defender flags or deletes `yara64.exe`/`yarac64.exe` as a false positive, add a folder exclusion:
> `Windows Security → Virus & threat protection → Manage settings → Exclusions → Add an exclusion → Folder → C:\Users\nahla\Desktop\yara`

### 5. Run the rule against the test files

```
C:\Users\nahla\Desktop\yara\yara64.exe -r small_pe.yar .
```

**Expected output:**


**Small_PE_Detector .\notepad.exe**


Only `notepad.exe` should be listed — `test.txt` and `explorer.exe` should not appear.

### 6. Test against a real, larger dataset (System32)

```
cd C:\Users\nahla\Desktop\yara
yara64.exe small_pe_task\small_pe.yar C:\Windows\System32
```

This produces a long list of matches — every PE file under 500KB found in `System32`.

### 7. Count the number of matches

```
yara64.exe small_pe_task\small_pe.yar C:\Windows\System32 | find /c /v ""
```

**Result:** 3,400 matches — 3,400 files in `System32` were correctly identified as PE files smaller than 500KB.

---

## My Solution:

[View My Solution:](https://youtu.be/UkrQ_lPOGXw)

---
