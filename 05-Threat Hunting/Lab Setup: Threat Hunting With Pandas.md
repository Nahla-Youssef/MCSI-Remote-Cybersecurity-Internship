# Threat Hunting:- Lab Setup: Threat Hunting With Pandas

---

## Objectives
- Install Python and the required libraries (Pyarrow, Pandas, Jupyter Notebook) needed for data manipulation and analysis.
- Use Redline to collect forensic data (process listing) from a Windows endpoint.
- Convert the collected XML audit data into a Parquet file for analysis.
- Load the Parquet dataset into a Pandas DataFrame using Jupyter Notebook.
- Demonstrate basic data manipulation tasks (searching, sorting, selecting columns, and filtering) on the collected process data as part of a threat hunting workflow.

---

## Tools
- **OS:** Windows 10/11 (Redline is Windows-only; a VM is recommended for isolation)
- **Redline** — FireEye/Mandiant forensic collection tool
- **Python** (version >= 3.6)
- **pip** — Python package manager
- **Jupyter Notebook**
- **Python Libraries:** `pandas`, `pyarrow`, `lxml`
- **PowerShell** (run as Administrator where noted)
- Online converter: [dataconverter.io](https://dataconverter.io/convert/xml-to-parquet/) (XML → Parquet)

---

## Steps

### 1. Install Python

Download and install Python (>= 3.6) from [python.org](https://www.python.org/downloads/).

> During installation, make sure to check **"Add python.exe to PATH"**.

Verify the installation:
```powershell
python --version
```

### 2. Install Required Libraries

Open PowerShell (as Administrator) and run:

```powershell
python -m pip install notebook
python -m pip install lxml pandas pyarrow
```

Verify installation:
```powershell
python -m pip show pandas pyarrow notebook
```

> Note: If `pip` or `jupyter` commands are not recognized (PATH issue), use `python -m pip` and `python -m notebook` instead.

### 3. Install and Set Up Redline

1. Download and install **Redline** from the [FireEye Market](https://fireeye.market/apps/211364).
2. Open Redline and go to **Collect Data** → **Create a Standard Collector**.
3. Choose the target platform, then click **Edit your script**.
4. Configure the script:
   -  Keep **Process Listing** enabled
   -  Disable **Drivers Enumeration**
   -  Disable **Hook Detection**
5. Click **OK**, then choose a folder to save the collector (e.g. `C:\RedlineCollector`).

### 4. Run the Redline Audit

In PowerShell, navigate to the collector folder and run the audit script:

```powershell
cd C:\RedlineCollector
.\RunRedLineAudit.bat
```

This creates a `Sessions` folder containing an `AnalysisSession` subfolder with an `Audits` folder holding the generated XML files.

Verify the output files:
```powershell
dir C:\RedlineCollector\Sessions\AnalysisSession1\Audits
```

The relevant file is the largest XML file containing the process listing data, e.g.:
```
w32processes-API.urn_uuid_xxxxxxxx.xml
```

### 5. Convert XML to Parquet

1. Open [dataconverter.io/convert/xml-to-parquet](https://dataconverter.io/convert/xml-to-parquet/)
2. Upload the `w32processes-API...xml` file
3. Download the converted `.parquet` file
4. (Optional) Rename it for convenience:

```powershell
Rename-Item "C:\Users\<username>\Downloads\<downloaded-name>.parquet" "redlineauditsample.parquet"
```

### 6. Launch Jupyter Notebook

```powershell
python -m notebook
```

This opens a local server; open the provided `localhost` URL in a browser, then create a new notebook via **New → Python 3**.

### 7. Verify Library Installation (inside the Notebook)

```python
import pandas as pd
import pyarrow as pa
print("pandas version:", pd.__version__)
print("pyarrow version:", pa.__version__)
```

### 8. Load the Parquet Dataset into a Pandas DataFrame

```python
# MRCI - Threat Hunting with Pandas

# import dependencies
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq

# convert Parquet file into a dataset
# use forward slashes in the path to avoid Unicode escape errors
processes_dataset = pq.ParquetDataset('C:/Users/<username>/Downloads/redlineauditsample.parquet')

# convert dataset into pandas
w32processes = processes_dataset.read().to_pandas()
```

Display the contents:
```python
w32processes.head()
```

Inspect structure (optional but useful):
```python
w32processes.shape
w32processes.columns.tolist()
```

### 9. Basic Data Manipulation

**Search for a specific value:**
```python
w32processes['name'].unique()

search_results = w32processes[w32processes['name'].str.contains('svchost', case=False, na=False)]
search_results
```

**Sort data:**
```python
sorted_processes = w32processes.sort_values(by='pid', ascending=False)
sorted_processes
```

**Select specific columns:**
```python
selected_columns = w32processes[['name', 'pid', 'Username', 'path']]
selected_columns
```

**Filter specific data elements:**
```python
filtered_processes = w32processes[w32processes['name'] == 'explorer.exe']
filtered_processes
```

---

## My Solution:

[View My Solution:](https://youtu.be/1nytYRxpw1k)

---
