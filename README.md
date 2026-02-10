# Automated Reconnaissance Tools

**Author:** Bela Agustina

**Project Category:** Cyber Security – Reconnaissance Automation

**Repository:** `recon-automation-bela`

---

## 1. Project Title & Description

**Recon-Automation-Bella** adalah tool otomasi berbasis Bash untuk mempercepat fase **Reconnaissance** pada pengujian keamanan web. Tool ini mengintegrasikan beberapa OSINT tools populer untuk menemukan subdomain dan memvalidasi host aktif secara massal dengan sistem logging dan reporting terstruktur.

### Tujuan Utama

Meningkatkan efisiensi waktu dalam proses pengumpulan aset domain selama tahap information gathering.

### Fitur Unggulan

* Instalasi tools otomatis
* Enumerasi subdomain terintegrasi
* Deduplikasi menggunakan **anew**
* Validasi host aktif menggunakan **httpx**
* Logging & error handling
* Struktur folder hasil scan otomatis
* Laporan statistik per domain dan global
  

## 2. Struktur Directory

```
recon-automation-belaagustina/
│
├── input/                       # Data awal sebelum scanning
│   └── domains.txt              # Daftar domain target
│
├── scripts/                     # Tempat script utama
│   └── recon-auto.sh            # Script automation recon
│
├── output/                      # Semua hasil scan tersimpan di sini
│   └── recon_<timestamp>/       # Folder hasil berdasarkan waktu scan
│       │
│       ├── all-subdomains.txt   # Gabungan semua subdomain unik
│       ├── all-live.txt         # Gabungan semua host aktif
│       ├── domain-summary.txt   # Statistik jumlah subdomain per domain
│       │
│       ├── example.com/         # Hasil khusus domain example.com
│       │   ├── subs.txt         # Subdomain domain tersebut
│       │   └── live.txt         # Host aktif domain tersebut
│       │
│       ├── tesla.com/           # Hasil khusus domain tesla.com
│       │   ├── subs.txt         # Subdomain domain tersebut
│       │   └── live.txt         # Host aktif domain tersebut
│       │
│       └── logs/                # Catatan proses
│           ├── progress.log     # Log aktivitas script
│           └── errors.log       # Log error jika ada masalah
│
└── README.md                    # Dokumentasi project

```
###  Penjelasan Struktur

| Path                                                                                                          | Fungsi                             |
| ------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| 📂 [`input/`](https://github.com/vold6556-coder/recon-automation-bela/tree/main/input)                        | Berisi daftar target domain        |
| 📄 [`domains.txt`](https://github.com/vold6556-coder/recon-automation-bela/blob/main/input/domains.txt)       | Input domain (1 domain per baris)  |
| 📂 [`scripts/`](https://github.com/vold6556-coder/recon-automation-bela/tree/main/scripts)                    | Folder script utama                |
| 📄 [`recon-auto.sh`](https://github.com/vold6556-coder/recon-automation-bela/blob/main/scripts/recon-auto.sh) | Engine automation recon            |
| 📂 [`output/`](https://github.com/vold6556-coder/recon-automation-bela/tree/main/output)                      | Semua hasil scan tersimpan di sini |
| 📄 `all-subdomains.txt`                                                                                       | Gabungan semua subdomain unik      |
| 📄 `all-live.txt`                                                                                             | Gabungan semua host aktif          |
| 📄 `domain-summary.txt`                                                                                       | Statistik jumlah temuan per domain |
|   📂 `example.com`                                                                                                    |Hasil Khusus Domain (example.com)               |
|   📄 `subs.txt`                                                                                       |  Hasil enumerasi subdomain khusus domain tersebut (example.com) |
|   📄 `live.txt`                                                                                       | Host aktif dari domain tersebut (example.com) |
| 📂 [`logs/`](https://github.com/vold6556-coder/recon-automation-bela/tree/main/logs)                                                                                                    | Log proses dan error               |
| 📄 `progress.log`                                                                                       | Log aktivitas script |
| 📄 `errors.log`                                                                                       | Log error kalau ada trouble |
| 📄 [`README.md`](https://github.com/vold6556-coder/recon-automation-bela/blob/main/README.md)                 | Dokumentasi project                |

Struktur ini memisahkan hasil **per target** sekaligus menyediakan **rekap global**, seperti workflow profesional di environment SOC/pentest.

---

##  3. Environment Setup

Tool ini dirancang dengan konsep **Run and Go**.

### Prasyarat

* OS berbasis Debian/Kali Linux
* Koneksi internet aktif

### Install PDTM (disarankan)

```bash
curl -fsSL https://get.pdtm.sh | bash
pdtm -install subfinder httpx
```

### Install Golang

```bash
sudo apt update
sudo apt install golang-go -y
```

### Install Subfinder

```bash
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
```

### Install Httpx

```
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
```

Tambahkan PATH
```
export PATH=$PATH:$(go env GOPATH)/bin
```

### Install Anew

```bash
go install github.com/tomnomnom/anew@latest
export PATH=$PATH:$(go env GOPATH)/bin
```

> Script juga mampu mendeteksi dan menginstal tools otomatis jika belum tersedia.

---

##  4. Cara Menjalankan Script

```bash
cd ~/recon-automation-bela
chmod +x scripts/recon-auto.sh
./scripts/recon-auto.sh
```

Script akan membuka terminal baru dan menjalankan proses scanning otomatis.

---

##  5. Contoh Input & Output

### Input (`input/domains.txt`)

```
shopee.com
tokopedia.com
gojek.com
traveloka.com
detik.com
cnnindonesia.com
mozilla.org
                             
```

### Output yang Dihasilkan

| File               | Fungsi                   |
| ------------------ | ------------------------ |
| all-subdomains.txt | Semua subdomain unik     |
| all-live.txt       | Host aktif + status code |
| domain-summary.txt | Statistik per domain     |
| example.com       | berisi subs.txt dan live.txt khusus domain (example.com)               |
| progress.log       | Log proses               |
| errors.log         | Log error                |

---

##  6. Penjelasan Bagian Kode

| Modul                      | Fungsi                                                                                                       |
| -------------------------- | ------------------------------------------------------------------------------------------------------------ |
| **Module Check & Install** | Mengecek tools via `command -v`. Jika tidak ada, script menjalankan `go install` dan mengatur PATH otomatis. |
| **Environment Fix**        | `unset GOROOT` untuk mencegah konflik instalasi Go lama                                                     |
| **Execution Engine**       | Menggunakan `gnome-terminal` agar proses berjalan di jendela baru. (bisa diganti xterm juga kalau mau yg lebih ringan, di script sudah tersedia tinggal dihapus saja commentnya)                                           |
| **Enumeration Engine**     | `subfinder` mencari subdomain secara pasif                                                                  |
| **Data Filtering**         | `anew` mencegah duplikasi subdomain                                                                         |
| **Live Host Detection**    | `httpx` mengecek host aktif beserta status HTTP dan title.                                                   |
| **Logging System**         | Semua proses dicatat dengan timestamp via `tee`.                                                             |
| **Error Handling**         | stderr diarahkan ke `logs/errors.log`                                                                       |
| **Reporting Engine**       | `awk`, `wc -l`, dan `printf` menghasilkan tabel statistik rapih                                             |

---

##  7. Final Output Metrics

Script menampilkan:

* Total domain diproses
* Total subdomain unik
* Total live hosts aktif
* Durasi scan

---

##  8. Screenshots

Tambahkan screenshot berikut:
### 📸 8. Screenshots

* **[Figure 1. Input Domains](./Screenshots/01.%20Input-Domains/01-Input.txt.png)**
  ![Input Domains](./Screenshots/01.%20Input-Domains/01-Input.tx.png)
**Figure 1. Recon automation execution**

```
![Execution](screenshots/execution.png)
```

**Figure 2. Live hosts discovered**

```
![Live Hosts](screenshots/live-hosts.png)
```

**Figure 3. Output directory structure**

```
![Directory](screenshots/tree.png)
```

---

## 👤 Author

**Bela Agustina**
Cyber Security Student

---

> This project simulates a real-world reconnaissance automation pipeline aligned with penetration testing and SOC operational workflows.
