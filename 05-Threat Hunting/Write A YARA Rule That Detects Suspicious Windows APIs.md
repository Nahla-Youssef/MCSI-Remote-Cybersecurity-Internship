# Threat Hunting: Write A YARA Rule That Detects Suspicious Windows APIs

---

## Objectives
- For each malware behavior category, compile a list of at least 10 suspicious Windows APIs associated with that behavior.
- Write five separate YARA rules, each detecting one behavior category:
  1. Anti-debugging techniques
  2. Local and network enumeration (processes, user accounts, file shares)
  3. Code injection techniques
  4. Spyware (keylogging, microphone recording)
  5. Ransomware
- Test all rules against the malware dataset.
- Validate that each rule accurately detects its category by manually confirming the presence of the associated APIs in flagged samples.

---

## Tools
- YARA (`yara64.exe`)
- Windows Command Prompt (`cmd.exe`)
- PE Studio (`pestudio.exe`) — for manual import-table verification
- Malware sample dataset (`Malware_Dataset`)

---

## Steps

### 1. Write the YARA Rule Files

```cmd
mkdir C:\Users\nahla\Desktop\yara\rule_task\malware_behavior_rules
notepad C:\Users\nahla\Desktop\yara\rule_task\malware_behavior_rules\anti_debugging.yar
notepad C:\Users\nahla\Desktop\yara\rule_task\malware_behavior_rules\enumeration.yar
notepad C:\Users\nahla\Desktop\yara\rule_task\malware_behavior_rules\code_injection.yar
notepad C:\Users\nahla\Desktop\yara\rule_task\malware_behavior_rules\spyware.yar
notepad C:\Users\nahla\Desktop\yara\rule_task\malware_behavior_rules\ransomware.yar
```

Rule contents:

```yara
rule Anti_Debugging_Techniques
{
    meta:
        description = "Detects malware using anti-debugging techniques via suspicious Windows API usage"
        author = "Nahla"
        date = "2026-09-06"
        version = "1.0"
        category = "Anti-Debugging"
    strings:
        $api1  = "IsDebuggerPresent" ascii wide nocase
        $api2  = "CheckRemoteDebuggerPresent" ascii wide nocase
        $api3  = "NtQueryInformationProcess" ascii wide nocase
        $api4  = "NtSetInformationThread" ascii wide nocase
        $api5  = "OutputDebugStringA" ascii wide nocase
        $api6  = "OutputDebugStringW" ascii wide nocase
        $api7  = "NtQuerySystemInformation" ascii wide nocase
        $api8  = "FindWindowA" ascii wide nocase
        $api9  = "FindWindowW" ascii wide nocase
        $api10 = "QueryPerformanceCounter" ascii wide nocase
        $api11 = "DebugActiveProcess" ascii wide nocase
        $api12 = "ZwQueryInformationProcess" ascii wide nocase
    condition:
        uint16(0) == 0x5A4D and 4 of ($api*)
}
```
```yara
rule Local_Network_Enumeration
{
    meta:
        description = "Detects malware performing local and network enumeration (processes, users, shares)"
        author = "Nahla"
        date = "2026-09-06"
        version = "1.0"
        category = "Enumeration"
    strings:
        $api1  = "CreateToolhelp32Snapshot" ascii wide nocase
        $api2  = "Process32First" ascii wide nocase
        $api3  = "Process32Next" ascii wide nocase
        $api4  = "NetUserEnum" ascii wide nocase
        $api5  = "NetShareEnum" ascii wide nocase
        $api6  = "NetWkstaGetInfo" ascii wide nocase
        $api7  = "WNetOpenEnumA" ascii wide nocase
        $api8  = "WNetEnumResourceA" ascii wide nocase
        $api9  = "GetLogicalDrives" ascii wide nocase
        $api10 = "NetLocalGroupEnum" ascii wide nocase
        $api11 = "LookupAccountSidA" ascii wide nocase
        $api12 = "GetAdaptersInfo" ascii wide nocase
    condition:
        uint16(0) == 0x5A4D and 4 of ($api*)
}
```
```yara
rule Code_Injection_Techniques
{
    meta:
        description = "Detects malware using code injection techniques targeting remote processes"
        author = "Nahla"
        date = "2026-09-06"
        version = "1.0"
        category = "Code Injection"
    strings:
        $api1  = "VirtualAllocEx" ascii wide nocase
        $api2  = "WriteProcessMemory" ascii wide nocase
        $api3  = "CreateRemoteThread" ascii wide nocase
        $api4  = "NtCreateThreadEx" ascii wide nocase
        $api5  = "SetWindowsHookExA" ascii wide nocase
        $api6  = "QueueUserAPC" ascii wide nocase
        $api7  = "ResumeThread" ascii wide nocase
        $api8  = "OpenProcess" ascii wide nocase
        $api9  = "VirtualProtectEx" ascii wide nocase
        $api10 = "NtMapViewOfSection" ascii wide nocase
        $api11 = "ZwUnmapViewOfSection" ascii wide nocase
        $api12 = "RtlCreateUserThread" ascii wide nocase
    condition:
        uint16(0) == 0x5A4D and 4 of ($api*)
}
```
```yara
rule Spyware_Keylogging_Microphone
{
    meta:
        description = "Detects spyware behavior such as keylogging and microphone/audio recording"
        author = "Nahla"
        date = "2026-09-06"
        version = "1.0"
        category = "Spyware"
    strings:
        $api1  = "SetWindowsHookExA" ascii wide nocase
        $api2  = "GetAsyncKeyState" ascii wide nocase
        $api3  = "GetKeyState" ascii wide nocase
        $api4  = "GetForegroundWindow" ascii wide nocase
        $api5  = "GetKeyboardState" ascii wide nocase
        $api6  = "waveInOpen" ascii wide nocase
        $api7  = "waveInStart" ascii wide nocase
        $api8  = "waveInAddBuffer" ascii wide nocase
        $api9  = "RegisterRawInputDevices" ascii wide nocase
        $api10 = "AttachThreadInput" ascii wide nocase
        $api11 = "GetClipboardData" ascii wide nocase
        $api12 = "MapVirtualKeyA" ascii wide nocase
    condition:
        uint16(0) == 0x5A4D and 4 of ($api*)
}
```
```yara
rule Ransomware_Detection
{
    meta:
        description = "Detects ransomware behavior via file encryption and mass file manipulation APIs"
        author = "Nahla"
        date = "2026-09-06"
        version = "1.0"
        category = "Ransomware"
    strings:
        $api1  = "CryptEncrypt" ascii wide nocase
        $api2  = "CryptAcquireContextA" ascii wide nocase
        $api3  = "CryptGenKey" ascii wide nocase
        $api4  = "CryptDeriveKey" ascii wide nocase
        $api5  = "FindFirstFileA" ascii wide nocase
        $api6  = "FindNextFileA" ascii wide nocase
        $api7  = "MoveFileA" ascii wide nocase
        $api8  = "DeleteFileA" ascii wide nocase
        $api9  = "CryptExportKey" ascii wide nocase
        $api10 = "BCryptEncrypt" ascii wide nocase
        $api11 = "ShellExecuteA" ascii wide nocase
        $api12 = "GetLogicalDrives" ascii wide nocase
    condition:
        uint16(0) == 0x5A4D and 4 of ($api*)
}
```

### 2. Run Each Rule Against the Malware Dataset

```cmd
cd C:\Users\nahla\Desktop\yara

yara64.exe -r "C:\Users\nahla\Desktop\yara\rule_task\malware_behavior_rules\anti_debugging.yar" "C:\Users\nahla\Desktop\Malware_Dataset" 2>nul > C:\Users\nahla\Desktop\yara\results_anti_debugging.txt

yara64.exe -r "C:\Users\nahla\Desktop\yara\rule_task\malware_behavior_rules\enumeration.yar" "C:\Users\nahla\Desktop\Malware_Dataset" 2>nul > C:\Users\nahla\Desktop\yara\results_enumeration.txt

yara64.exe -r "C:\Users\nahla\Desktop\yara\rule_task\malware_behavior_rules\code_injection.yar" "C:\Users\nahla\Desktop\Malware_Dataset" 2>nul > C:\Users\nahla\Desktop\yara\results_code_injection.txt

yara64.exe -r "C:\Users\nahla\Desktop\yara\rule_task\malware_behavior_rules\spyware.yar" "C:\Users\nahla\Desktop\Malware_Dataset" 2>nul > C:\Users\nahla\Desktop\yara\results_spyware.txt

yara64.exe -r "C:\Users\nahla\Desktop\yara\rule_task\malware_behavior_rules\ransomware.yar" "C:\Users\nahla\Desktop\Malware_Dataset" 2>nul > C:\Users\nahla\Desktop\yara\results_ransomware.txt
```

### 3. Count Matches Per Rule

```cmd
find /c /v "" C:\Users\nahla\Desktop\yara\results_anti_debugging.txt
find /c /v "" C:\Users\nahla\Desktop\yara\results_enumeration.txt
find /c /v "" C:\Users\nahla\Desktop\yara\results_code_injection.txt
find /c /v "" C:\Users\nahla\Desktop\yara\results_spyware.txt
find /c /v "" C:\Users\nahla\Desktop\yara\results_ransomware.txt
```

**Results:**

| Rule | Matches |
|---|---|
| Anti_Debugging_Techniques | 35 |
| Local_Network_Enumeration | 12 |
| Code_Injection_Techniques | 5 |
| Spyware_Keylogging_Microphone | 27 |
| Ransomware_Detection | 20 |

### 4. Manual Validation in PE Studio

For each rule, one matched sample was opened in PE Studio, and the **imports** section was inspected to confirm at least 4 of the rule's listed APIs are genuinely present in the file's import table.

---

## My Solution:

[View My Solution:](https://youtu.be/TyiqYAk77QM)

---
