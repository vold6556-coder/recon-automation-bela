# Automated Reconnaissance Tools

**Author:** Bela Agustina

**Project Category:** Cyber Security – Reconnaissance Automation

**Repository:** `recon-automation-bela`

---

## 1. Project Title & Description

**Recon-Automation-Bela** adalah tool otomasi berbasis Bash untuk mempercepat fase **Reconnaissance** pada pengujian keamanan web. Tool ini mengintegrasikan beberapa OSINT tools populer untuk menemukan subdomain dan memvalidasi host aktif secara massal dengan sistem logging dan reporting terstruktur.

### Tujuan Utama
Tahap reconnaissance merupakan bagian penting dalam penetration testing. Jika dilakukan secara manual, proses ini bisa memakan waktu lama dan hasilnya sering kali tidak konsisten.

Script ini dibuat untuk mengotomatisasi proses recon awal dengan tujuan:
- Mengumpulkan subdomain secara pasif
- Menyimpan hanya hasil yang unik
- Mencatat seluruh proses eksekusi melalui logging
- Menjaga struktur output tetap rapi per domain target

Fokus utama tool ini adalah Meningkatkan efisiensi waktu dalam proses pengumpulan aset domain selama tahap information gathering.

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
├── Screenshots/                 # Dokumentasi gambar untuk README.md
│   ├── 01. Input Domains/
│   │   └── 01-Input.txt.png       
│   ├── 02. Recon-Proses-Berjalan/
│   │   ├── 01-Proses-recon.txt.png
│   │   ├── 02-Proses-recon.txt.png              
│   │   └── 03-Proses-recon.txt.png        
│   ├── 03. Ouput-Hasil-Recon/
│   │   ├── 01-output.png
│   │   ├── 02-output-1-all-live.txt.png              
│   │   ├── 02-output-2-all-live.txt.png
│   │   ├── 03-output-1-all-subdomains.txt.png
│   │   ├── 03-output-2-all-subdomains.txt.png
│   │   ├── 04-output-domain-summary.txt.png
│   │   ├── 05-output-1-example.com-live.txt.png
│   │   ├── 05-output-2-example.com-live.txt.png
│   │   ├── 05-output-2.1-example.com-subs.txt.png
│   │   └── 05-output-2.2-example.com-subs.txt.png        
│   └── 04. Logs/
│   │   ├── 01-errors-log.txt.png
│   │   ├── 02-progress-log-1.txt.png              
│   │   └── 03-progress-log-2.txt.png     
│
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

**Tool memisahkan:**
- hasil global (gabungan semua domain)
- hasil per-domain untuk analisis mendalam
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

## 📸 8. Screenshots
Dokumentasi proses input domain, proses tools berjalan, dokumentasi output serta log error & progress 

### 1. Input Domains 
<details>
<summary><b>Klik di sini untuk melihat dokumentasi hasil (Screenshots)</b></summary>
<br>

> **Deskripsi:** Tahap awal memasukkan daftar target ke dalam file `domains.txt`.
<br>
<img src="Screenshots/01.%20Input%20Domains/01-input.txt.png" width="800" alt="Input Domains">
</details>

---

### 2. Execution Process
<details>
<summary><b>Klik di sini untuk melihat dokumentasi hasil (Screenshots)</b></summary>
<br>

> **Deskripsi:** Proses jalannya script automation recon di terminal.
<br>
<img src="Screenshots/02. Recon-Proses-Berjalan/01-proses-recon.png" width="800" alt="Execution">
<br>
<br>

> **Deskripsi:** Setiap selesai scan suatu domain akan muncul total subdomainnya.
<img src="Screenshots/02. Recon-Proses-Berjalan/02-proses-recon.png" width="800" alt="Execution">

<br>
<br>

> **Deskripsi:** Setelah selesai scan akan muncul table summary hasil recon yang rapi.
<img src="Screenshots/02. Recon-Proses-Berjalan/03-proses-recon.png" width="800" alt="Execution">
</details>

---

### 3. Hasil Output 
<details>
<summary><b>Klik di sini untuk melihat dokumentasi hasil (Screenshots)</b></summary>
<br>

> **Deskripsi:** Hasil output dari auto recon. Setiap kali dijalankan, script otomatis membuat folder baru dengan format timestamp `recon_DayMonth_HourMinute` untuk mencegah data tertimpa.
<img src="Screenshots/03. Ouput-Hasil-Recon/01-output.png" width="800" alt="Output Folder">
<br>
<br>

> **Deskripsi:** Hasil recon semua subdomain yang aktif/live (`all-live.txt`).
<img src="Screenshots/03. Ouput-Hasil-Recon/02-output-1-all-live.txt.png" width="800" alt="All Live 1">
<img src="Screenshots/03. Ouput-Hasil-Recon/02-output-2-all-live.txt.png" width="800" alt="All Live 2">
<br>
<br>

> **Deskripsi:** List gabungan semua subdomain unik yang berhasil ditemukan (`all-subdomains.txt`).
<br>
<img src="Screenshots/03. Ouput-Hasil-Recon/03-output-1-all-subdomains.txt.png" width="800" alt="All Subs 1">
<img src="Screenshots/03. Ouput-Hasil-Recon/03-output-2-all-subdomains.txt.png" width="800" alt="All Subs 2">

<br>
<br>

> **Deskripsi:** Ringkasan statistik total subdomain per domain (`domain-summary.txt`).

<img src="Screenshots/03. Ouput-Hasil-Recon/04-output-domain-summary.txt.png" width="800" alt="Summary">
<br>
<br>

> **Deskripsi:** Hasil spesifik per domain (Contoh: `example.com`). Selain hasil global, tersedia folder khusus per domain untuk memudahkan analisa mendalam.
<br>
<img src="Screenshots/03. Ouput-Hasil-Recon/05-output-1-example.com-live.txt.png" width="800" alt="Individual Live">
<img src="Screenshots/03. Ouput-Hasil-Recon/05-output-2-example.com-live.txt.png" width="800" alt="Individual Live 2">
<br>
<br>
<img src="Screenshots/03. Ouput-Hasil-Recon/05-output-2.1-example.com-subs.txt.png" width="800" alt="Individual Subs">
<img src="Screenshots/03. Ouput-Hasil-Recon/05-output-2.2-example.com-subs.txt.png" width="800" alt="Individual Subs 2">
<br>
<br>
</details>

---

### 4. Logs
<details>
<summary><b>Klik di sini untuk melihat dokumentasi hasil (Screenshots)</b></summary>
<br>

> **Deskripsi:** Rekaman log kesalahan (`errors-log.txt`) untuk keperluan debugging jika terjadi kendala pada tools.

<img src="Screenshots/04. Logs/01-errors-log.txt.png" width="800" alt="Error Logs">

<br>
<br>

> **Deskripsi:** Rekaman seluruh aktivitas proses scan (`progress-log.txt`) dari awal hingga selesai.
<br>
<img src="Screenshots/04. Logs/02-progress-log-1.txt.png" width="800" alt="Progress Log 1">
<img src="Screenshots/04. Logs/02-progress.log-2.txt.png" width="800" alt="Progress Log 2">

</details>

---

## 9. Kesimpulan

Melalui proyek ini, penulis berhasil membangun sebuah tool otomasi reconnaissance berbasis Bash yang mampu menjalankan proses enumerasi subdomain dan validasi host aktif secara end-to-end. Tool ini mengintegrasikan beberapa recon tools populer ke dalam satu pipeline terstruktur dengan sistem logging dan output yang rapi.

Selain menghasilkan data recon yang siap digunakan untuk tahap lanjutan (seperti vulnerability assessment atau penetration testing), proyek ini juga memberikan pemahaman praktis mengenai pengelolaan input/output, deduplikasi data, serta pentingnya error handling dalam otomasi security tooling. Tool ini diharapkan dapat menjadi fondasi awal untuk pengembangan otomasi recon yang lebih kompleks di masa mendatang.

## 👤 Author

**Bela Agustina**
Cyber Security Student

---

> This project simulates a real-world reconnaissance automation pipeline aligned with penetration testing and SOC operational workflows.
