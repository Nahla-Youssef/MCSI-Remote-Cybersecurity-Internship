# Threat Hunting: Write A YARA Rule That Can Find Improperly Signed Executables

---

## Objectives
- Write a YARA rule that generically detects executables carrying a digital signature that fails Authenticode verification, using the `pe.signatures` module.
- Save the rule as `improperly_signed_executables.yar`.
- Test the rule against the malware dataset and a clean system baseline.
- Validate a detected sample manually in PE Studio to confirm the signature is indeed invalid.

---

## Tools
- YARA (`yara64.exe`) — built with PE module support
- Windows Command Prompt (`cmd.exe`)
- PE Studio (`pestudio.exe`) — for manual signature verification
- Malware sample dataset (`Malware_Dataset`)
- Windows system directory (`C:\Windows\System32`) — used as a clean-file baseline

---

## Steps

### 1. Write the YARA Rule

```cmd
notepad C:\Users\nahla\Desktop\yara\rule_task\improperly_signed_executables.yar
```

Rule content:

```yara
import "pe"

rule improperly_signed_executables
{
    meta:
        description = "Generically detects executables carrying a digital signature that fails Authenticode verification"
        author = "Nahla"
        date = "2026-09-06"
        version = "1.0"

    condition:
        pe.number_of_signatures > 0 and
        for any i in (0 .. pe.number_of_signatures - 1) : (
            not pe.signatures[i].verified
        )
}
```

**Rule logic:**
- `pe.number_of_signatures > 0` ensures the file carries at least one Authenticode signature (excludes unsigned files — this rule only targets files that claim to be signed).
- `pe.signatures[i].verified` is a boolean provided by YARA's PE module reflecting whether that signature passes Authenticode chain verification.
- `for any i in (...)` flags the file if **any** of its signatures fails verification (expired certificate, broken chain, tampered file, revoked/untrusted cert, etc.), making the detection generic and not tied to any specific issuer or malware family.

### 2. Run the Rule Against the Malware Dataset

```cmd
cd C:\Users\nahla\Desktop\yara

yara64.exe -r "C:\Users\nahla\Desktop\yara\rule_task\improperly_signed_executables.yar" "C:\Users\nahla\Desktop\Malware_Dataset" 2>nul > C:\Users\nahla\Desktop\yara\signed_results.txt
```

Count the matches:

```cmd
find /c /v "" C:\Users\nahla\Desktop\yara\signed_results.txt
```

**Result:** 8 files matched.

### 3. Run the Rule Against a Clean Baseline (System32)

```cmd
yara64.exe -r "C:\Users\nahla\Desktop\yara\rule_task\improperly_signed_executables.yar" "C:\Windows\System32" 2>nul > C:\Users\nahla\Desktop\yara\signed_results_system32.txt
```

```cmd
find /c /v "" C:\Users\nahla\Desktop\yara\signed_results_system32.txt
```

**Result:** 7 files matched (a small, expected number — some legitimate third-party or older system components may carry certificates that no longer verify, e.g. due to expiration).

### 4. Manual Validation in PE Studio

```cmd
notepad C:\Users\nahla\Desktop\yara\signed_results.txt
```

Selected sample:
```
C:\Users\nahla\Desktop\Malware_Dataset\InQuest-malware-samples\2023-06-MysticStealer\7c185697d3d3a544ca0cef987c27e46b20997c7ef69959c720a8d2e8a03cd5dc
```

Steps performed in PE Studio:
1. Opened the file via **File → Open**.
2. Navigated to the **certificate** section in the left-hand tree.
3. Confirmed the following details:

| Field | Value |
|---|---|
| name | Microsoft Corporation |
| **signature-info** | **"The digital signature of the object did not verify."** |
| valid-to | Sun May 03 2020 (expired) |
| program-name | Visual Studio setup bootstrapper |

**Conclusion:** PE Studio explicitly confirms the signature failed verification, and the certificate had expired years before the sample date. The file also masquerades as a "Visual Studio setup bootstrapper" while actually being a MysticStealer malware sample — a classic masquerading technique paired with an invalid/stolen signature.

---

## My Solution:

[View My Solution:](https://youtu.be/06Kb12c9bTE)

---
