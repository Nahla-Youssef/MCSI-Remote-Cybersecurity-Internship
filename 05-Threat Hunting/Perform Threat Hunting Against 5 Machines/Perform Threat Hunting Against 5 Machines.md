# Threat Hunting: Perform Threat Hunting Against 5 Machines

---

**Hosts in scope:** `CRW167SL`, `PXA949WW`, `RDL208NS`, `RDL794WW`, `UMI895SB`

## Files in this submission
| File | Description |
|---|---|
| `Threat_Hunting_Task2.ipynb` | Jupyter notebook containing the full analysis (source of all commands below) |
| `Threat_Hunting_Task2_Final.pdf` | Notebook exported to PDF (code + outputs + observations) |
| `Threat_Hunting_5_Machines_Report.pdf` | Full write-up: Executive Summary, IOC explanations, Recommendations, Limitations, Assumptions |

---

## Objectives
- Review process, account, persistence, service, and scheduled-task artifacts collected from five Windows endpoints.
- Identify which **two** of the five machines show evidence of compromise.
- Document the supporting Indicators of Compromise (IOCs) with host-specific, side-by-side evidence.

**Methodology**
1. Load the domain user/group mapping to establish which accounts and privilege levels are expected/legitimate in this environment.
2. Compare logged-on users and local/domain account privileges across all five hosts, looking for accounts that don't fit the baseline.
3. Review running processes for SYSTEM-level or user-writable-path anomalies.
4. Review services, scheduled tasks, and persistence artifacts (registry/file) for signs of masquerading or backdoors.
5. Correlate every finding back to specific hosts and build the final IOC list.

---

## Tools
- **Python 3**
- **pandas** — loading and filtering Parquet artifacts
- **os** / **glob** — walking the dataset directory and batch-loading per-host Parquet files
- **Jupyter Notebook** — analysis environment (`Threat_Hunting_Task2.ipynb`)

---

## Steps

### Setup — Load the dataset and inspect its structure

```python
import pandas as pd

dataset_path = r'C:\Users\nahla\Desktop\threat_hunt_task\003d1fc2-1f7e-4a11-a011-b684a313f9fa'
df = pd.read_parquet(dataset_path + '/domain_users.parquet')
print(df.head())
print(df)
```

```python
import os

for root, dirs, files in os.walk(dataset_path):
    for f in files:
        print(os.path.join(root, f))
```

### Load every artifact category for all five hosts

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

processes         = load_all('w32processes')
processes_memory  = load_all('w32processes-memorysections')
services          = load_all('w32services')
tasks             = load_all('w32tasks')
drivers           = load_all('w32drivers')
persistence_reg   = load_all('w32persistence-registryitems')
persistence_files = load_all('w32persistence-fileitems')
persistence_svc   = load_all('w32persistence-serviceitems')
logged_users      = load_all('loggedonusers')
user_accounts     = load_all('useraccounts')

print(processes.shape, processes_memory.shape, services.shape, tasks.shape)
print(sorted(processes['hostname'].unique()))
```

### Step 1 — Baseline the domain accounts and check for anomalous logons

Check who is logged on across the fleet and flag anything involving privileged/admin accounts, since that's the fastest way to spot lateral movement or privilege escalation.

```python
domain_users = pd.read_parquet(dataset_path + '/domain_users.parquet')
domain_users
```

```python
print(logged_users.columns.tolist())
logged_users
```

```python
logged_users[logged_users.astype(str).apply(
    lambda row: row.str.contains('admin', case=False, na=False)
).any(axis=1)]
```

### Step 2 — Hunt for SYSTEM-privileged processes running from user-writable paths

A process running as `NT AUTHORITY\SYSTEM` from inside a normal user's folder (`Users\...`) is a strong sign of privilege escalation.

```python
system_procs = processes[processes['username'].astype(str).str.contains('SYSTEM', case=False, na=False)]
print(system_procs.shape)
system_procs[['hostname', 'name', 'path', 'pid']]
```

```python
system_procs[system_procs.astype(str).apply(
    lambda row: row.str.contains(r'Users\\', case=False, na=False)
).any(axis=1)]
```

### Step 3 — Hunt for processes launched from Temp/AppData/ProgramData/WindowsApps

```python
suspicious = processes[processes.astype(str).apply(
    lambda row: row.str.contains('Temp|AppData|ProgramData|WindowsApps', case=False, na=False)
).any(axis=1)]
suspicious[['hostname', 'name', 'path', 'username']]
```

### Step 4 — Full per-host process listing

With no anomalies found in the fast, targeted searches, pull the complete process listing for each host individually to manually review process ownership and paths.

```python
for h in ['CRW167SL', 'PXA949WW', 'RDL208NS', 'RDL794WW', 'UMI895SB']:
    print(f"--- {h} ---")
    print(processes[processes['hostname'] == h][['name', 'path', 'username']].to_string())
    print()
```

### Step 5 — Review account privileges per host

Pull the full logged-on-users and user-accounts tables to compare privilege levels (domain-admin, local-admin) across every account on every host.

```python
logged_users
```

```python
user_accounts
```

**Finding:** two unexplained local administrator accounts stand out — `zBMIahqYKPEfTT` on `CRW167SL` and `dEkSarQLRvDfhPA` on `PXA949WW`. Both are `local-admin=True`, `local-user=True`, but `domain-user=False` and `domain-admin=False`, and both break the environment's `firstname.lastnameNN` naming convention.

### Step 6 — Confirm process/task volume is otherwise unremarkable

```python
print(processes['name'].value_counts())
```

```python
tasks['hostname'].value_counts()
```

```python
for h in ['CRW167SL', 'PXA949WW', 'RDL208NS', 'RDL794WW', 'UMI895SB']:
    t = tasks[tasks['hostname'] == h]
    print(f"--- {h}: {len(t)} tasks ---")
```

### Step 7 — Isolate and confirm the two suspicious accounts

```python
user_accounts[user_accounts['username'].str.contains('zBMI|dEkS', case=False, na=False)]
```

**Confirmed:** `zBMIahqYKPEfTT` exists only on `CRW167SL`; `dEkSarQLRvDfhPA` exists only on `PXA949WW`. Both hold local administrator rights on their respective host with no domain identity whatsoever.

### Step 8 — Check persistence artifacts and services on the two flagged hosts

```python
for h in ['CRW167SL', 'PXA949WW']:
    print(f"=== {h} — Registry Persistence ===")
    print(persistence_reg[persistence_reg['hostname'] == h].to_string())
    print(f"=== {h} — File Persistence ===")
    print(persistence_files[persistence_files['hostname'] == h].to_string())
```

```python
for h in ['CRW167SL', 'PXA949WW']:
    print(f"=== {h} — All Processes ===")
    print(processes[processes['hostname'] == h][['name', 'path', 'username']].to_string())
```

```python
for h in ['CRW167SL', 'PXA949WW']:
    print(f"=== {h} — Services ===")
    print(services[services['hostname'] == h].to_string())
```

**Finding — malicious service masquerading as a kernel driver (`hidinterrupt`):** on `CRW167SL`, the `hidinterrupt` service (`SERVICE_KERNEL_DRIVER`) points to `C:\Public\run.vbs` instead of a compiled `.sys` driver, MD5 `e7311e22f0d28d15d7f4b489bdc5c752`. On `PXA949WW`, the same-named service correctly points to `C:\Windows\System32\drivers\hidinterrupt.sys` (the genuine Windows HID driver), MD5 `365cf57198f5e4c24fd2fc2a5450a794` — a completely different file and hash.

### Step 9 — Rule out the domain-admin service account and re-check the "Public" folder lead

```python
processes[processes['username'].astype(str).str.contains('svc_em', case=False, na=False)]
```

```python
services[services.astype(str).apply(
    lambda row: row.str.contains('svc_em', case=False, na=False)
).any(axis=1)]
```

```python
persistence_files[persistence_files.astype(str).apply(
    lambda row: row.str.contains('Public', case=False, na=False)
).any(axis=1)]
```

**Result:** `svc_em` (domain-admin service account) is not running any process or service on any host — ruled out. The fleet-wide `"Public"` search returns only `mbaeapipublic.dll` on `RDL794WW` — a benign Malwarebytes DLL, unrelated to `C:\Public\run.vbs`.

### Step 10 — Check whether the two backdoor accounts show up as actively logged on

```python
logged_users[logged_users['username'].isin(['zBMIahqYKPEfTT', 'dEkSarQLRvDfhPA'])]
```

**Observation:** neither account appears in the logged-on-users table at collection time — consistent with a dormant backdoor account that exists and holds admin rights but doesn't need an active session.

---

## Findings Summary

| Host | Finding | Evidence |
|---|---|---|
| `CRW167SL` | Unexplained local admin account **&** Service masquerading (persistence) | `zBMIahqYKPEfTT` — random alphanumeric name, `local-admin=True`, no domain identity (`domain-user=False`). Also, the `hidinterrupt` service was repointed from the genuine driver to `C:\Public\run.vbs`; different MD5 than the legitimate service on `PXA949WW`. |
| `PXA949WW` | Unexplained local administrator account | `dEkSarQLRvDfhPA` — same random-name pattern, `local-admin=True`, no domain identity |

`RDL208NS`, `RDL794WW`, and `UMI895SB` were reviewed against every check above and showed no equivalent anomalies.

---

## My Solution:

[View My Solution: Download the submission folder and the dataset folder](./Documentation/)

---
