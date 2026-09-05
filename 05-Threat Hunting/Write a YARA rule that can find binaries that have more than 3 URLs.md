# Threat Hunting:- Write A YARA Rule That Can Find Binaries That Have More Than 3 URLs

---

## Objectives
- Write a YARA rule that flags executable files containing a suspiciously high number of embedded URLs.
- The rule must:
  - Exclude files that are not executables (PE files only).
  - Detect files that contain the keyword `http://` at least 3 times.
  - Detect files that contain the keyword `https://` at least 3 times.
  - Detect files where the combined count of `http://` and `https://` is greater than 3.
- Test the rule against a known malware dataset and validate accuracy through manual inspection.
- Test the rule against a clean system directory to check for false positives.

---

## Tools
- YARA (`yara64.exe`)
- Windows Command Prompt (`cmd.exe`)
- PowerShell (`Select-String` for manual URL verification)
- Malware sample dataset (`Malware_Dataset`)
- Windows system directory (`C:\Windows\System32`) — used as a clean-file baseline

---

## Steps

### 1. Write the YARA Rule

Create a file named `more_than_3_urls.yar` with the following content:

```yara
rule more_than_3_urls
{
    meta:
        description = "Detects executable files with more than 3 occurrences of URLs (http:// or https://)"
        author = "Nahla"
        date = "2026-09-05"
        version = "1.0"
    strings:
        $http = "http://"
        $https = "https://"
    condition:
        uint16(0) == 0x5A4D and
        (
            #http >= 3 or
            #https >= 3 or
            (#http + #https) > 3
        )
}
```

**Rule logic:**
- `uint16(0) == 0x5A4D` checks for the `MZ` header, ensuring only PE (executable) files are scanned.
- `#http >= 3` flags files with 3 or more `http://` occurrences.
- `#https >= 3` flags files with 3 or more `https://` occurrences.
- `(#http + #https) > 3` flags files where the combined count exceeds 3, even if neither keyword alone reaches 3.

### 2. Save the Rule to Disk

```cmd
notepad C:\Users\nahla\Desktop\yara\rule_task\more_than_3_urls.yar
```

Paste the rule content above and save.

### 3. Run the Rule Against the Malware Dataset

```cmd
cd C:\Users\nahla\Desktop\yara

yara64.exe -r "C:\Users\nahla\Desktop\yara\rule_task\more_than_3_urls.yar" "C:\Users\nahla\Desktop\Malware_Dataset" 2>nul > C:\Users\nahla\Desktop\yara\scan_results.txt
```

Count the number of matches:

```cmd
find /c /v "" C:\Users\nahla\Desktop\yara\scan_results.txt
```

**Result:** 45 files matched.

### 4. Run the Rule Against a Clean Baseline (System32)

```cmd
yara64.exe -r "C:\Users\nahla\Desktop\yara\rule_task\more_than_3_urls.yar" "C:\Windows\System32" 2>nul > C:\Users\nahla\Desktop\yara\scan_results_system32.txt
```

Count the number of matches:

```cmd
find /c /v "" C:\Users\nahla\Desktop\yara\scan_results_system32.txt
```

**Result:** 1709 files matched.

### 5. Manual Validation — Malware Dataset Sample

Pick one matched file from `scan_results.txt` and verify the URL count manually:

```powershell
Select-String -Path "C:\Users\nahla\Desktop\Malware_Dataset\incarcero\collection\genus\android\DENDROID\APKBinder\bin\Debug\aapt.exe" -Pattern "https?://" -AllMatches | Select-Object -ExpandProperty Matches | ForEach-Object { $_.Value }
```

**Result:** `http://` found 9 times — confirms the rule correctly identifies the file as matching the required condition (≥ 3 occurrences).

### 6. Manual Validation — System32 Sample (False Positive Check)

Pick one matched file from `scan_results_system32.txt` and verify the URL count manually:

```powershell
Select-String -Path "C:\Windows\System32\07409496-a423-4a3e-b620-2cfb01a9318d_HyperV-ComputeNetwork.dll" -Pattern "https?://" -AllMatches | Select-Object -ExpandProperty Matches | ForEach-Object { $_.Value }
```

**Result:** `http://` found 10 times — confirms the match is technically correct, but the URLs found are legitimate XML namespace/schema references embedded in a native Windows Hyper-V component, not malicious indicators.

---

## My Solution:

[View My Solution:](https://youtu.be/fsmxRgsIigw)

---
