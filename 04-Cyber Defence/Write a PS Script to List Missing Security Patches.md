# Cyber Defence: Write a PS Script to List Missing Security Patches

---

## Objectives
- Write a PowerShell script that lists missing (and installed) security patches on a machine, supporting both a local scan and a remote scan.

---

## Environment
- **Machine 1** (Windows 10) — Local, has the script.
- **Machine 2** (Windows 10) — Remote — `192.168.1.9`

---

## Files Used

[Download the file: check-missingpatches.ps1](./Documentation/)

- `check-missingpatches.ps1`

---

## Steps

### Machine 1 — Local scan
Open PowerShell as Administrator:
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```
Type `y` to confirm.
```
.\check-missingpatches.ps1
```
Choose `L` (local). Wait for the missing + installed patches table to display.

### Machine 2 — Prepare for remote scan
Confirm `Enable-PSRemoting -Force` and `winrm quickconfig -Force` are already configured (already done and confirmed running).

### Machine 1 — Remote scan
```
.\check-missingpatches.ps1
```
Choose `R` (remote). Enter the IP: `192.168.1.9`. Wait for the missing + installed patches table to display.

---

## My Solution:

[View My Solution:](https://youtu.be/EGiOP4auF5k)

---
