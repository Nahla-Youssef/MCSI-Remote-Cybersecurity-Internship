# Threat Hunting: Perform Threat Hunting Against 2 Machines.md

---

## Objectives
- Download and work with a real threat hunting dataset covering two Windows hosts (forensic triage artifacts).
- Use Python and Pandas to analyze the dataset and identify which machine is compromised.
- Perform the analysis inside a Jupyter Notebook and submit it as a PDF.
- Submit a comprehensive report covering:
  - Executive Summary
  - Compromised Machines (with evidence)
  - Indicators of Compromise (IOCs) explained in plain language
  - Recommendations
  - Limitations and Constraints
  - Assumptions

---

## Tools
- **OS:** Windows 10 (running inside VirtualBox)
- **Python 3.12** + **pip**
- **Pandas** + **PyArrow** (to read `.parquet` files)
- **JupyterLab**
- **Dataset format:** Parquet files organized by artifact category (processes, services, tasks, drivers, persistence items, logged-on users, user accounts, domain users)

---

## Steps

### 1. Set up the working folder and move the dataset into the VM

```
mkdir C:\Users\nahla\Desktop\threat_hunt_task
cd C:\Users\nahla\Desktop\threat_hunt_task
```

The dataset folder (a UUID-named folder containing all `.parquet` files/subfolders) was copied into this directory using a VirtualBox shared folder / drag-and-drop, so the full path became:

```
C:\Users\nahla\Desktop\threat_hunt_task\3d276079-8448-42c6-a394-bd54c981eedc
```

### 2. Install Python dependencies

```
pip install pandas jupyterlab pyarrow matplotlib
```

### 3. Launch JupyterLab

```
cd C:\Users\nahla\Desktop\threat_hunt_task
jupyter lab
```

This starts a local server and prints a URL with an access token, e.g.:

```
http://localhost:8888/lab?token=<token>
```

Open that exact URL (including the token) in the browser. Create a new **Python 3 Notebook**.

### 4. Load a sample file to confirm the dataset is readable

```python
import pandas as pd

dataset_path = r'C:\Users\nahla\Desktop\threat_hunt_task\3d276079-8448-42c6-a394-bd54c981eedc'
df = pd.read_parquet(dataset_path + '/domain_users.parquet')
print(df.head())
```

### 5. Explore the full dataset structure

```python
import os

for root, dirs, files in os.walk(dataset_path):
    for f in files:
        print(os.path.join(root, f))
```

This revealed one file per host inside subfolders such as `loggedonusers`, `useraccounts`, `w32processes`, `w32services`, `w32tasks`, `w32drivers`, `w32persistence-fileitems`, `w32persistence-registryitems`, `w32persistence-serviceitems`, and `w32processes-memorysections` — one `.parquet` file per hostname (`0000DQQEE`, `0001LXQEN`) in each folder.

### 6. Build a helper function to load and combine all per-host files

```python
import glob

def load_all(folder_name):
    files = glob.glob(dataset_path + f'/{folder_name}/*.parquet')
    dfs = []
    for f in files:
        d = pd.read_parquet(f)
        d['hostname'] = os.path.basename(f).replace('.parquet', '')
        dfs.append(d)
    return pd.concat(dfs, ignore_index=True) if dfs else pd.DataFrame()
```

### 7. Load every artifact category into a Pandas DataFrame

```python
processes = load_all('w32processes')
processes_memory = load_all('w32processes-memorysections')
services = load_all('w32services')
tasks = load_all('w32tasks')
drivers = load_all('w32drivers')
persistence_reg = load_all('w32persistence-registryitems')
persistence_files = load_all('w32persistence-fileitems')
persistence_svc = load_all('w32persistence-serviceitems')
logged_users = load_all('loggedonusers')
user_accounts = load_all('useraccounts')

print(processes.shape, processes_memory.shape, services.shape, tasks.shape)
```

### 8. Check which privileged accounts were logged on to which host

```python
print(logged_users.columns.tolist())
logged_users
```

```python
logged_users[logged_users.astype(str).apply(
    lambda row: row.str.contains('timotlopez|Administrator', case=False, na=False)
).any(axis=1)]
```

**Finding:** `timotlopez` (a domain admin) is logged on to both hosts, but `Administrator` (also domain admin) is logged on **only** to `0001LXQEN` — not present on `0000DQQEE` at all.

### 9. Search for processes running from suspicious, user-writable paths

```python
print(processes.columns.tolist())
processes[['hostname'] + [c for c in processes.columns if 'name' in c.lower() or 'path' in c.lower()]]
```

```python
suspicious = processes[processes.astype(str).apply(
    lambda row: row.str.contains('Temp|AppData|ProgramData', case=False, na=False)
).any(axis=1)]
suspicious
```

**Finding:** Alongside two expected/benign `OneDrive.exe` entries, one result stands out — `cmd.exe` (PID 5612) on `0001LXQEN`, running as `NT AUTHORITY\SYSTEM`, with a command line pointing into `timotlopez`'s user profile.

### 10. Isolate the suspicious process to confirm the full command line

```python
pd.set_option('display.max_colwidth', None)
processes[processes['pid'] == 5612]
```

**Result:**
```
arguments: C:\Windows\System32\cmd.exe /C C:\Users\timotlopez\AppData\Local\Microsoft\WindowsApps\run_pd.bat
hostname:  0001LXQEN
name:      cmd.exe
pid:       5612
username:  NT AUTHORITY\SYSTEM
```

This is the key IOC: a SYSTEM-privileged shell executing a non-standard batch script (`run_pd.bat`) staged inside a directory (`AppData\Local\Microsoft\WindowsApps`) normally reserved for signed Microsoft app-execution stubs — consistent with an attacker disguising a payload as a legitimate-looking path.

### 11. Check registry and scheduled-task persistence on the affected host

```python
persistence_reg[persistence_reg['hostname'] == '0001LXQEN']
```

```python
tasks[tasks['hostname'] == '0001LXQEN']
```

### 12. Check service-based persistence as a control/cross-check

```python
if 'hostname' in persistence_svc.columns and not persistence_svc.empty:
    print(persistence_svc[persistence_svc['hostname'] == '0001LXQEN'])
else:
    print("persistence_svc table is empty - no service-based persistence data available in this dataset.")
```

**Result:** The service-based persistence table was empty for both hosts, so this category could not confirm or rule out a malicious service as the trigger for `run_pd.bat` (documented as a limitation).

```python
print(persistence_reg[persistence_reg['hostname'] == '0001LXQEN'])
print(tasks[tasks['hostname'] == '0001LXQEN'])
```

```python
print(tasks[tasks['hostname'] == '0001LXQEN'])
```

### 13. Write the comprehensive report

A separate report document was produced covering all six required sections:
- Executive Summary
- Investigation Approach (methodology, data categories reviewed, IOC term mapping)
- Compromised Machines (host `0001LXQEN`, with dataset evidence)
- Indicators of Compromise — both technical and explained in plain language
- Recommendations (isolation, credential rotation, AppLocker/WDAC, EDR/SIEM, rebuild from known-good image)
- Limitations and Constraints (no timestamps, large persistence tables, no network telemetry, empty service-persistence data)
- Assumptions (data integrity, account identity, software approval status)

The student ID was included on the report's cover page.

## Validation

Two independent, corroborating IOCs were found for host **`0001LXQEN`**:

1. **Account-based IOC:** The `Administrator` domain-admin account was active only on `0001LXQEN`, not on `0000DQQEE`.
2. **Process-based IOC:** A `NT AUTHORITY\SYSTEM`-privileged `cmd.exe` (PID 5612) executed `run_pd.bat` from inside `timotlopez`'s user profile — a non-standard, user-writable location.

No equivalent indicators were found on host `0000DQQEE`.

## Submission Files

- `Threat_Hunting_Task.ipynb` — the Jupyter Notebook containing the full Python/Pandas analysis
- `Threat_Hunting_Task_Final.pdf` — PDF export of the notebook (code + outputs)
- `Threat_Hunting_2_Machines_Report.pdf` — the comprehensive report (Executive Summary, Compromised Machines, IOCs, Recommendations, Limitations, Assumptions), including the student ID

---

## My Solution:

[View My Solution: Download the submission folder and the dataset folder](./Documentation/)

---
