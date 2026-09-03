# Threat Hunting:- Lab Setup: Threat Hunting With YARA

---

## Objectives

- Install YARA and confirm `yara64.exe` is available on the host machine.
- Stand up three separate Windows virtual machines — Windows 10, Windows 7 (#1), and Windows 7 (#2) — to serve as sources for a known-safe dataset.
- Create a shared folder named `known-safe` accessible by all three VMs.
- Collect at least 15GB of known-good files by copying each VM's C: drive into the shared folder.
- Install the HxD Hex Editor for manual hex-level file analysis.

---

## Tools

- [YARA](https://github.com/VirusTotal/yara/releases) — pattern-matching engine used to identify and classify malware.
- [YARA (SourceForge mirror)](https://sourceforge.net/projects/yara.mirror/) — alternate source for YARA releases.
- [HxD](https://mh-nexus.de/en/hxd/) — freeware hex editor and disk editor.
- VirtualBox (or similar hypervisor) — used to run the Windows virtual machines.
- Windows 10 ISO + two Windows 7 ISOs — legitimate installers used to build the three VMs (Windows 10, Windows7_1, Windows7_2).

---

## Steps

### 1. Download and set up YARA
1. Go to the [YARA releases page](https://github.com/VirusTotal/yara/releases).
2. Download the latest Windows release archive (contains `yara64.exe`).
3. Extract it to a working directory, e.g. `C:\Tools\YARA\`.
4. Verify the install:
   ```
   cd C:\Tools\YARA
   yara64.exe --version
   ```

### 2. Download Windows ISO installers
1. Download a legitimate Windows 10 ISO from Microsoft's official site.
2. Download two legitimate Windows 7 ISOs (used for `Windows7_1` and `Windows7_2`) from Microsoft or an official archive.
3. Save all ISOs to a working folder, e.g. `C:\ISOs\`.

### 3. Install the virtual machines
1. Open VirtualBox and create three VMs named: `Windows10`, `Windows7_1`, `Windows7_2`.
2. Allocate appropriate resources per VM (e.g., 2–4GB RAM, 40–60GB disk).
3. Attach the corresponding ISO as the boot medium and complete the OS installation for all three VMs.
4. Install VirtualBox Guest Additions on each VM (required for shared folders).

### 4. Create the shared folder
1. On the host machine, create a folder named `known-safe`, e.g. `C:\known-safe\`.
2. In VirtualBox, for each VM go to **Settings > Shared Folders** and add:
   - Folder Path: `C:\known-safe`
   - Folder Name: `known-safe`
   - Enable **Auto-mount** and **Make Permanent**.
3. Start each VM and confirm the shared folder appears (typically under `\\VBOXSVR\known-safe`).

### 5. Copy each VM's C: drive into the known-safe folder
1. On each VM, open File Explorer and navigate to `C:\`.
2. Select all files/folders (Ctrl+A) and copy them.
3. Paste into the mapped `known-safe` shared folder, using a subfolder per VM to keep sets separate:
   ```
   known-safe\Windows10\
   known-safe\Windows7_1\
   known-safe\Windows7_2\
   ```
4. Repeat for all three VMs.
5. Confirm total dataset size is at least 15GB:
   ```
   dir known-safe /s
   ```
   or check folder properties in File Explorer.

### 6. Install HxD Hex Editor
1. Download HxD from the [official site](https://mh-nexus.de/en/hxd/).
2. Run the installer and complete setup on the host machine.
3. Launch HxD and confirm it opens correctly.

---

## My Solution:

[View My Solution:](https://youtu.be/MsIKrV5mR7o)

---
