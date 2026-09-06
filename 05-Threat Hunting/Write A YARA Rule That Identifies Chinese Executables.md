# Threat Hunting: Write A YARA Rule That Identifies Chinese Executables

---

## Objectives
- Write a YARA rule that only detects Portable Executable (PE) files.
- The rule must further narrow detection to PE files configured with a Chinese language identifier (`0x04` or `0x004`), using the `pe` module.
- Save the rule as `chinese_exe.yar`.
- Test the rule against the malware dataset and a system baseline.
- Confirm, via manual inspection, that files flagged by the rule genuinely contain Chinese language-tagged resources.

---

## Tools
- YARA (`yara64.exe`) — built with PE module support
- Windows Command Prompt (`cmd.exe`)
- PE Studio (`pestudio.exe`) — for manual resource/language verification
- Malware sample dataset (`Malware_Dataset`)
- Windows system directory (`C:\Windows\System32`) — used as a comparison baseline

---

## Steps

### 1. Write the YARA Rule

```cmd
notepad C:\Users\nahla\Desktop\yara\rule_task\chinese_exe.yar
```

Rule content:

```yara
import "pe"

rule chinese_exe
{
    meta:
        description = "Detects PE files with Chinese language identifiers (0x04 or 0x004)"
        author = "Nahla"
        date = "2026-09-06"
        version = "1.0"

    condition:
        // Ensure the file is a PE and has Chinese language identifier
        pe.is_pe and
        (pe.language(0x04) or pe.language(0x004))
}
```

**Rule logic:**
- `pe.is_pe` restricts detection to Portable Executable files only, satisfying the "PE-only" requirement.
- `pe.language(0x04)` / `pe.language(0x004)` check whether any resource in the PE is tagged with the specified language identifier. Note: `0x04` and `0x004` are numerically identical in hexadecimal (leading zeros do not change the value), so this condition effectively checks the same language ID twice, as specified in the exercise wording.

### 2. Run the Rule Against the Malware Dataset

```cmd
cd C:\Users\nahla\Desktop\yara

yara64.exe -r "C:\Users\nahla\Desktop\yara\rule_task\chinese_exe.yar" "C:\Users\nahla\Desktop\Malware_Dataset" 2>nul > C:\Users\nahla\Desktop\yara\chinese_results_malware.txt
```

Count the matches:

```cmd
find /c /v "" C:\Users\nahla\Desktop\yara\chinese_results_malware.txt
```

**Result:** 3 files matched.

### 3. Run the Rule Against System32 (Baseline Comparison)

```cmd
yara64.exe -r "C:\Users\nahla\Desktop\yara\rule_task\chinese_exe.yar" "C:\Windows\System32" 2>nul > C:\Users\nahla\Desktop\yara\chinese_results_system32.txt
```

```cmd
find /c /v "" C:\Users\nahla\Desktop\yara\chinese_results_system32.txt
```

**Result:** 106 files matched (expected, since many Windows system components ship with multi-language resource sections that include Chinese locales as part of built-in internationalization support).

### 4. Manual Validation in PE Studio

```cmd
notepad C:\Users\nahla\Desktop\yara\chinese_results_malware.txt
```

Selected sample:
```
C:\Users\nahla\Desktop\Malware_Dataset\Malware-Feed\2020.09.29_Symantec-Palmerworm_Espionage_Gang\9e3ecda0f8e23116e1e8f2853cf07837dd5bc0e2e4a70d927b37cfe4f6e69431
```

Steps performed in PE Studio:
1. Opened the file via **File → Open**.
2. Navigated to **resources (language > flag)** in the left-hand tree.
3. Reviewed the **language** column in the resulting resource table.

**Result:** Multiple resource entries were explicitly labeled:
```
chinese-simplified (0x...)
chinese-traditional (0x...)
```

---

## My Solution:

[View My Solution:](https://youtu.be/0jVHz9Eqbv0)

---
