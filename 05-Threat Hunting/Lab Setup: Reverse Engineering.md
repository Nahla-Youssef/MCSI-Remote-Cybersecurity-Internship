# Threat Hunting:- Lab Setup: Reverse Engineering

---

## Objectives
- Download and install the necessary tools for reverse engineering and malware analysis
- Verify that each tool is correctly installed and operational
- Organize all tools into a dedicated, well-structured directory for documentation purposes

---

## Tools
- **Windows 10/11**
- **PowerShell** (built-in command-line shell)
- **winget** (Windows Package Manager)
- **DumpIt** — memory acquisition tool
- **Ghidra** — NSA reverse engineering suite (requires Java JDK)
- **IDA Free 8.4** — Hex-Rays disassembler/decompiler (free edition)
- **PE Studio** — static malware triage tool
- **Process Explorer** — Sysinternals process monitoring tool
- **Python 2.7** and **Python ≥3.6**
- **Strings / Strings64** — Sysinternals string extraction tool
- **Volatility3** — memory forensics framework (Python-based)
- **WinDbg** — Microsoft debugger
- **Wireshark** — network protocol analyzer

---

## Steps

### 1. Create the Tools Directory

```powershell
mkdir C:\Users\<username>\Desktop\RE_Tools
cd C:\Users\<username>\Desktop\RE_Tools
```

Portable tools (no installer) are unzipped/copied here. Installer-based tools (Python, WinDbg, IDA Free, Wireshark) install to their default system locations, with a shortcut added to this folder for documentation purposes.

### 2. Install Python (both versions required)

**Python 3 (latest):**
```powershell
winget install --id Python.Python.3.12 -e
python --version
```

**Python 2.7** (legacy, not available via winget):
Download the MSI installer directly from the official archive:
```
https://www.python.org/ftp/python/2.7.18/python-2.7.18.amd64.msi
```
Install with default settings, then verify using the Python Launcher:
```powershell
py -0
py -2.7 --version
```
> Note: On newer Python Launcher versions, the shorthand `py -2` may not be recognized. Use `py -2.7` or `py -V:2.7` instead — both confirm the same thing.

### 3. Install Strings (Sysinternals)

Download:
```
https://download.sysinternals.com/files/Strings.zip
```

Check system architecture:
```powershell
[Environment]::Is64BitOperatingSystem
```

Copy to System32 (rename if 64-bit), running PowerShell as Administrator:
```powershell
Copy-Item "C:\path\to\strings64.exe" "C:\Windows\System32\strings.exe"
```

Verify:
```powershell
strings --help
```

### 4. Install Process Explorer

```powershell
winget install --id Microsoft.Sysinternals.ProcessExplorer -e
```

Verify by locating and running `procexp64.exe`, confirming the live process list appears.

### 5. Install WinDbg

```powershell
winget install --id Microsoft.WinDbg -e
```

If a User Account Control (UAC) prompt appears, confirm the publisher is **Microsoft Corporation** before allowing it.

Verify installation:
```powershell
winget list --id Microsoft.WinDbg
```

Launch directly to confirm it opens:
```powershell
Start-Process "windbg:"
```

> Note: WinDbg installs as a Microsoft Store (MSIX/UWP) application and cannot be copied as a standalone `.exe`. For documentation purposes, download the `.appinstaller` reference file instead:
> ```
> https://aka.ms/windbg/download
> ```

### 6. Install Wireshark

```powershell
winget install --id WiresharkFoundation.Wireshark -e
```
Accept the Npcap installation prompt during setup (required for packet capture). Verify by launching Wireshark and confirming network interfaces are listed.

### 7. Install Ghidra

Install Java JDK (Ghidra dependency):
```powershell
winget install --id EclipseAdoptium.Temurin.17.JDK -e
```

Download Ghidra:
```
https://ghidra-sre.org/
```

Extract the ZIP to `RE_Tools\ghidra`, then launch:
```
ghidraRun.bat
```

### 8. Install Volatility3

```powershell
pip install volatility3
```

Verify:
```powershell
vol -h
```

> Note: Warnings about optional plugins failing to load (e.g. `yarascan`, `hashdump`) are expected and do not indicate a failed installation — the command completing and showing the usage/help output confirms Volatility3 is working correctly.

### 9. Install PE Studio

Portable tool, no installer required:
```
https://www.winitor.com/
```
Download the ZIP, extract to `RE_Tools\pestudio`, and run `pestudio.exe` directly.

### 10. Install IDA Free 8.4

Attempted via winget:
```powershell
winget install --id Hex-Rays.IDA.Free --exact --version 8.4
```

> Note: As of the current Hex-Rays website structure, IDA Free is no longer distributed via a direct `.exe` download link. Distribution now requires creating a free account through the official download center:
> ```
> https://my.hex-rays.com/dashboard/download-center
> ```
> Register for a free account, then download the installer from the account dashboard. Only use the official Hex-Rays domain — do not use third-party file-sharing mirrors, as these cannot be verified as safe or unmodified.

After installation, verify:
```powershell
winget list --id Hex-Rays.IDA.Free
```

### 11. Install DumpIt

Direct download:
```
https://storage.googleapis.com/cyber-platform-prod.appspot.com/tools/DumpIt.exe
```

> Note: DumpIt performs low-level memory access and may be flagged by Windows Defender due to its elevated privilege requirements (not because it is malicious). If needed, add a scoped exclusion limited to the DumpIt file/folder only:
> ```powershell
> Add-MpPreference -ExclusionPath "C:\Users\<username>\Desktop\RE_Tools\DumpIt"
> ```
> Verify the exclusion:
> ```powershell
> Get-MpPreference | Select-Object -ExpandProperty ExclusionPath
> ```

Run as Administrator and confirm the memory dump process starts without error.

### 12. Final Verification

Confirm all tools are present and organized:
```powershell
Get-ChildItem C:\Users\<username>\Desktop\RE_Tools
```

---

## My Solution:

[View My Solution:](https://youtu.be/P31bhDlnHQM)

---
