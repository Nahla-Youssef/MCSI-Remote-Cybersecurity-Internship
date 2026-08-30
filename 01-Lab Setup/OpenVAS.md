# Lab Setup: OpenVAS
___

# Vulnerability Assessment — OpenVAS on Docker (Kali Linux)

---

## Objectives:
Set up a working vulnerability scanning environment using OpenVAS (Greenbone Community Edition) on Kali Linux.

Get familiar with running OpenVAS both as a native Kali install and as a Docker container, and compare the two approaches.

Practice diagnosing and resolving real installation errors (SCAP data not imported, incomplete GVM installation) instead of just following a clean happy-path guide.

Confirm a fully working setup by reaching the "installation is OK" state and accessing the web interface.

---

## Tools:
Kali Linux — base operating system.

Docker (docker.io) — container runtime used to run the mikesplain/openvas image.

Greenbone Community Edition (GVM/OpenVAS) — gvm, openvas packages installed natively via apt.

gvmd / gsad — GVM daemon and Greenbone Security Assistant (web UI) services.

PostgreSQL — backing database for gvmd, queried directly to check database size.

systemctl / ss / ps — used for service management and diagnosing what's running on which port.

Web browser (127.0.0.1:9392) — to access the OpenVAS/Greenbone web interface.

---

## Steps:

### 1. Install Docker on Kali Linux:

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
docker --version
```

### 2. Install OpenVAS natively on Kali Linux:

```bash
sudo apt update
sudo apt install gvm
sudo apt install openvas
```

### 3. Pull and run OpenVAS via Docker (mikesplain image):

```bash
sudo docker pull mikesplain/openvas
sudo docker run -d -p 443:443 -p 9392:9392 --name openvas mikesplain/openvas
sudo -E -u _gvm -g _gvm gvmd --user=admin --new-password=admin
sudo gvm-start
sudo gvm-setup
sudo gvm-check-setup
```

Once the setup reports it's ok, open 127.0.0.1:9392 in a web browser to reach the Greenbone web interface.


### 4. Troubleshoot: SCAP data not imported:

Error: SCAP files exist on disk (/var/lib/gvm/scap-data) but were not yet imported into gvmd's database.

```bash 
sudo systemctl stop gvmd
sudo -u _gvm gvmd --rebuild-scap
sudo tail -f /var/log/gvm/gvmd.log
ps aux | grep postgres | grep gvmd
sudo -u postgres psql -d gvmd -c "SELECT pg_size_pretty(pg_database_size('gvmd'));"
sudo systemctl start gvmd
sudo gvm-check-setup
```

### 5. Troubleshoot: incomplete GVM installation:

Error: ERROR: Your GVM-25.04.0 installation is not yet complete!

```bash
docker ps -a
docker stop openvas
docker rm openvas
sudo ss -tulpn | grep -E '443|9392'
sudo systemctl start gsad
sudo gvm-check-setup
```

Expected result: OK: gsad service is active. ... It seems like your GVM-25.04.0 installation is OK.

---

## My Solution:

[View My Solution:](https://youtu.be/xjD0QJ0cXbs)

---
