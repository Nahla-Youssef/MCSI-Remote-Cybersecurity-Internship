# Threat Hunting: Write a YARA rule that can find itself

---

## Objectives
- Write a YARA rule that detects the string `"I love YARA"`.
- Save the rule as `self_rule.yar` on the local hard drive.
- Use YARA to scan the hard drive and identify files containing the string `"I love YARA"`, using the rule created above.
- Validate that YARA successfully detects and lists `self_rule.yar` itself, since the rule file contains the exact string it searches for.

---

## Tools
- **OS:** Windows 10 (running inside VirtualBox)
- **YARA:** v4.5.x for Windows (64-bit) — [VirusTotal/yara releases](https://github.com/VirusTotal/yara/releases)
- **Command Prompt** (Administrator)
- **Notepad** (to write the rule file)

---

## Steps

### 1. Install YARA

1. Download the `win64` YARA zip from the official releases page:
   `https://github.com/VirusTotal/yara/releases`
2. Extract the archive to a working folder, e.g.:
   ```
   C:\Users\nahla\Desktop\yara
   ```
3. Confirm `yara64.exe` and `yarac64.exe` are present in that folder.
4. Verify the installation:
   ```
   yara64.exe --version
   ```

### 2. Create the working directory structure

```
cd C:\Users\nahla\Desktop\yara
mkdir rules
```

### 3. Write the YARA rule

Open Notepad to create the rule file:

```
notepad rules\self_rule.yar
```

Paste the following rule, then save and close:

```yara
rule Self_Rule
{
    meta:
        author = "Nahla"
        description = "Rule that detects the string I love YARA, including in this rule file itself"
        date = "2026-09-05"

    strings:
        $love_yara = "I love YARA"

    condition:
        $love_yara
}
```

### 4. Verify the rule file was saved correctly

```
type rules\self_rule.yar
```

Confirm the line `$love_yara = "I love YARA"` is present exactly as written.



### 5. Scan the hard drive 

To satisfy the "scan your hard drive" requirement, run a recursive scan on a real directory on disk (not just a single file). Scanning the whole `C:\` drive or the full user profile can take a very long time and will hit many locked system/cache files (e.g. browser cache, `AppData`), which produce harmless `could not open file` errors. To avoid this noise and long runtime, scan a real folder (e.g. the Desktop) and suppress error output:

```
yara64.exe -r C:\Users\nahla\Desktop\yara\rules\self_rule.yar C:\Users\nahla\Desktop\ 2>nul
```

- `-r` — recursive scan (includes all subfolders)
- `2>nul` — suppresses `could not open file` errors from locked/system files, showing only real matches

---

## My Solution:

[View My Solution:](https://youtu.be/n2glGEdWwCU)

---
