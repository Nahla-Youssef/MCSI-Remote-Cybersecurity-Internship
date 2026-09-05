# Threat Hunting: Write A YARA Rule That Searches For Strings Using Hex And Wild-Cards

---

## Objectives
- Write a YARA rule that uses hexadecimal strings, wildcard bytes (`??`), and variable-length jumps (`[1-4]`).
- Save the rule as `hex_wildcard_strings.yar`.
- Test the rule against a controlled test file, the malware dataset, and a clean system baseline.
- Confirm that the rule correctly identifies matching content and investigate any false positives.

---

## Tools
- YARA (`yara64.exe`)
- Windows Command Prompt (`cmd.exe`)
- PowerShell (`Select-String` for manual byte/string-level verification)
- Malware sample dataset (`Malware_Dataset`)
- Windows system directory (`C:\Windows\System32`) — used as a clean-file baseline

---

## Steps

### 1. Write the YARA Rule

```cmd
notepad C:\Users\nahla\Desktop\yara\rule_task\hex_wildcard_strings.yar
```

Rule content:

```yara
rule HexWildcardStrings
{
    meta:
        description = "Detects patterns using hexadecimal strings, wildcards, and variable-length jumps"
        author = "Nahla"
        date = "2026-09-06"
        version = "1.0"

    strings:
        $hex_string1 = { 68 ?? 65 6C 6C 6F }      // "h" + wildcard byte + "ello"
        $hex_string2 = { 77 6F 72 [1-4] 6C 64 }   // "wor" + 1 to 4 bytes gap + "ld"

    condition:
        any of them
}
```

**Rule logic:**
- `$hex_string1` uses a single wildcard byte (`??`) between fixed hex bytes — matches any byte in place of the "?" position, e.g. `h?ello`.
- `$hex_string2` uses a variable-length jump (`[1-4]`) — matches "wor", followed by 1 to 4 arbitrary bytes, followed by "ld", e.g. `world`, `wor_ld`, `wor__ld`, etc.
- `condition: any of them` flags the file if either pattern is found.

### 2. Create a Controlled Test File

```cmd
echo hXello world > C:\Users\nahla\Desktop\yara\test_files\test_match.txt
```

### 3. Run the Rule Against the Test File

```cmd
cd C:\Users\nahla\Desktop\yara

yara64.exe "C:\Users\nahla\Desktop\yara\rule_task\hex_wildcard_strings.yar" "C:\Users\nahla\Desktop\yara\test_files\test_match.txt"
```

**Result:**
```
HexWildcardStrings C:\Users\nahla\Desktop\yara\test_files\test_match.txt
```
Confirms the rule correctly matches the intended hex/wildcard/variable-length patterns on a known, controlled input.

### 4. Run the Rule Against the Malware Dataset

```cmd
yara64.exe -r "C:\Users\nahla\Desktop\yara\rule_task\hex_wildcard_strings.yar" "C:\Users\nahla\Desktop\Malware_Dataset" 2>nul > C:\Users\nahla\Desktop\yara\hex_results.txt
```

```cmd
find /c /v "" C:\Users\nahla\Desktop\yara\hex_results.txt
```

**Result:** 37 files matched.

### 5. Run the Rule Against a Clean Baseline (System32)

```cmd
yara64.exe -r "C:\Users\nahla\Desktop\yara\rule_task\hex_wildcard_strings.yar" "C:\Windows\System32" 2>nul > C:\Users\nahla\Desktop\yara\hex_results_system32.txt
```

```cmd
find /c /v "" C:\Users\nahla\Desktop\yara\hex_results_system32.txt
```

**Result:** 13 files matched.

### 6. Manual Validation of a System32 Match

Selected sample: `C:\Windows\System32\aitstatic.exe`

```powershell
Select-String -Path "C:\Windows\System32\aitstatic.exe" -Pattern "hello|world" -AllMatches | Select-Object -ExpandProperty Matches | ForEach-Object { $_.Value }
```

```powershell
Select-String -Path "C:\Windows\System32\aitstatic.exe" -Pattern ".{15}(hello|world).{15}" -AllMatches | Select-Object -ExpandProperty Matches | ForEach-Object { $_.Value }
```

**Result:** No readable text matched either query — no literal "hello" or "world" string exists in the file.

**Interpretation:** The YARA match on this file occurred at the raw byte level, not against readable text. The wildcard pattern (`h??ello`, with a single-byte wildcard) is generic enough to coincidentally match arbitrary binary byte sequences inside compiled executable code, without any actual "hello"/"world" string being present. This is a true false positive caused by the intentionally loose pattern used to demonstrate the wildcard/variable-length syntax.

---

## My Solution:

[View My Solution:](https://youtu.be/geouhNvFNGo)

---
