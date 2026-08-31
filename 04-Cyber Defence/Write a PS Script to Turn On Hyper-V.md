# Cyber Defence: Write a PS Script to Turn On Hyper-V

---

## Objectives
- Write an interactive PowerShell script that checks whether the Hyper-V Windows feature is enabled, and if not, prompts the user to enable it (with an optional restart).

---

## Files Used

[Download the file: ManageHyperV.ps1](./Documentation/)

- `ManageHyperV.ps1` — saved to the Desktop.

---

## Steps

### 1. Save the script
Open Notepad, paste the script content, then **File → Save As**, set "Save as type" to **All Files**, name it `ManageHyperV.ps1`, and save it on the Desktop.

### 2. Show that Hyper-V is disabled
Open PowerShell as Administrator:
```
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```
Confirms `State = Disabled`.

### 3. Allow the script to run
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```
Type `Y` if prompted for confirmation.

### 4. Go to the folder where the script is saved
```
cd $env:USERPROFILE\Desktop
```

### 5. Run the script
```
.\ManageHyperV.ps1
```

### 6. Follow the script's prompts
- It reports: "Hyper-V is disabled on this system"
- It asks: "Would you like to enable Hyper-V? (Y/N)" → type `Y`
- It shows: "Enabling Hyper-V..." then "Hyper-V has been enabled"
- It asks: "Would you like to restart now? (Y/N)" → type `Y`
- It shows: "Rebooting the system..."

### 7. Extra confirmation
Open PowerShell as Administrator again:
```
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```
Confirms `State` is now `Enabled`.

---

## My Solution:

[View My Solution:](https://youtu.be/4ll0jTLX_MQ)

---
