#!/bin/bash

# Buka jendela Gnome Terminal baru
if [ "$1" != "--child" ]; then
    # Cek apakah gnome-terminal ada di sistem
    if command -v gnome-terminal >/dev/null 2>&1; then
        gnome-terminal --window --title="RECON AUTOMATION - BELA AGUSTINA" -- bash -c "$0 --child; exec bash"
        exit
    else
        echo "gnome-terminal tidak ditemukan, menjalankan di terminal ini..."
    fi
fi

##  buka jendela xterm baru (laptop/pc kentang friendly) -> hapus tanda commentnya kalau mau pake xterm
# if [ "$1" != "--child" ]; then
#    if command -v xterm >/dev/null 2>&1; then
#        xterm -hold -T "RECON AUTOMATION - BELA AGUSTINA" -bg black -fg white -geometry 100x30 -e "$0 --child"
#        exit
#    else
#        echo "xterm tidak ditemukan, menjalankan di terminal ini..."
#    fi
# fi

# ==== PENGATURAN WARNA ====
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'

colorize() {
    local value=$1
    # Ambil hanya angka murni
    value=$(echo "$value" | grep -oE '[0-9]+' | head -1)
    [[ -z "$value" ]] && value=0

    if [ "$value" -eq 0 ]; then echo -e "${RED}${value}${NC}";
    elif [ "$value" -lt 50 ]; then echo -e "${GREEN}${value}${NC}";
    else echo -e "${YELLOW}${value}${NC}"; fi
}

# banner tools recon
echo -e "${YELLOW}====================================================${NC}"
echo -e "${GREEN}      ██████╗ ███████╗ ██████╗ ██████╗ ███╗    ██╗${NC}"
echo -e "${GREEN}      ██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║${NC}"
echo -e "${GREEN}      ██████╔╝█████╗  ██║      ██║   ██║██╔██╗ ██║${NC}"
echo -e "${GREEN}      ██╔══██╗██╔══╝  ██║      ██║   ██║██║╚██╗██║${NC}"
echo -e "${GREEN}      ██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║${NC}"
echo -e "${GREEN}      ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝${NC}"
echo -e "${CYAN}                RECON AUTOMATION TOOL${NC}"
echo -e "${CYAN}                  BY: BELA AGUSTINA${NC}"
echo -e "${YELLOW}====================================================${NC}"
sleep 1

# penanda waktu biar folder hasil scan unik (biar ga ketimpa filenya)
SCAN_ID=$(date "+%d%m_%H%M")
DOMAIN_LIST="../input/domains.txt"
BASE_OUTPUT="../output/recon_$SCAN_ID"

# semua log scan disimpan di folder utama project
GLOBAL_LOG_DIR="../logs"
SUBDOMAIN_OUTPUT="$BASE_OUTPUT/all-subdomains.txt"
LIVE_ALL="$BASE_OUTPUT/all-live.txt"
DOMAIN_SUMMARY="$BASE_OUTPUT/domain-summary.txt"
LOG_FILE="$GLOBAL_LOG_DIR/progress.log"
ERR_FILE="$GLOBAL_LOG_DIR/errors.log"

# Bikin fungsi jam biar setiap aktivitas ada notenya kapan kejadian
time_now() { date "+%Y-%m-%d %H:%M:%S"; }
START_TIME=$(date +%s)

# Bikin folder utama dan folder log
mkdir -p "$GLOBAL_LOG_DIR"
mkdir -p "$BASE_OUTPUT"

# aktifkan global session logging
exec > >(tee -a "$LOG_FILE") 2> >(tee -a "$ERR_FILE" >&2)

# inisialisasi file biar gak error pas proses bikin tabel
touch "$SUBDOMAIN_OUTPUT" "$LIVE_ALL" "$DOMAIN_SUMMARY"

echo -e "${BLUE}========== RECON START ==========${NC}"
echo -e "${CYAN}Started at: $(time_now)${NC}"

# cek domain list
if [[ ! -s "$DOMAIN_LIST" ]]; then
    echo -e "${RED}[$(time_now)] domains.txt tidak ada atau kosong!${NC}" >&2
    exit 1
fi

TOTAL_DOMAINS=$(grep -cv '^$' "$DOMAIN_LIST")
COUNT=1

# cek tools dan install otomatis kalau belum ada
for tool in go subfinder httpx anew; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo -e "${YELLOW}[$(time_now)] Tool $tool tidak ditemukan. Mencoba install otomatis...${NC}"
        case $tool in
            go)
                # instal go
                # unset GOROOT buat bersihin environment variabel go yang lama supaya pas install ulang nggak bentrok (clean install)
                unset GOROOT
                sudo apt update && sudo apt install golang-go -y >/dev/null 2>&1
                export PATH=$PATH:/usr/lib/go/bin
                ;;
            subfinder)
                # install subfinder
                go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest >/dev/null 2>&1
                ;;
            httpx)
               # install httpx
                go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest >/dev/null 2>&1
                ;;
            anew)
                # install anew
                go install -v github.com/tomnomnom/anew@latest >/dev/null 2>&1
                ;;
        esac

        # Update Path supaya tool go langsung bisa kebaca
        export PATH=$PATH:$(go env GOPATH)/bin

        # Cek ulang setelah percobaan instal
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo -e "${RED}[$(time_now)] Gagal install $tool. Silakan install manual.${NC}" >&2
            exit 1
        else
            echo -e "${GREEN}[$(time_now)] $tool berhasil diinstall!${NC}"
        fi
    fi
done

# Pastikan path sudah terupdate untuk session ini
export PATH=$PATH:$(go env GOPATH)/bin

# mulai looping buat scan daftar domain
while read -u 3 -r line; do
    domain=$(echo "$line" | tr -d '\r' | xargs)
    [[ -z "$domain" ]] && continue

    # Bikin folder khusus buat tiap domain
    DOMAIN_DIR="$BASE_OUTPUT/$domain"
    mkdir -p "$DOMAIN_DIR"

    echo -e "${GREEN}[$(time_now)] [$COUNT/$TOTAL_DOMAINS] Scan domain: $domain${NC}"

    DOMAIN_SUBS="$DOMAIN_DIR/subs.txt"
    DOMAIN_LIVE="$DOMAIN_DIR/live.txt"

    # Cari subdomain
    subfinder -d "$domain" -silent 2>>"$ERR_FILE" | sort -u > "$DOMAIN_SUBS"

    FOUND=$(cat "$DOMAIN_SUBS" | wc -l)

    if [ "$FOUND" -gt 0 ]; then
        cat "$DOMAIN_SUBS" | anew "$SUBDOMAIN_OUTPUT" >/dev/null
    fi

    # Simpen dulu buat diolah jadi tabel nanti
    echo "$domain|$FOUND" >> "${DOMAIN_SUMMARY}.tmp"

    # Cek subdomain mana aja yang beneran aktif
    LIVE_COUNT=0
    if [ "$FOUND" -gt 0 ]; then
        echo -e "${BLUE}[$(time_now)] Probing live hosts for $domain...${NC}"
        # Menampilkan output httpx langsung ke terminal (stderr dibuang ke file error)
        httpx -l "$DOMAIN_SUBS" -status-code -title -silent 2>>"$ERR_FILE" | tee "$DOMAIN_LIVE" | anew "$LIVE_ALL"
        LIVE_COUNT=$(cat "$DOMAIN_LIVE" | wc -l)
    fi

    # Menampilkan total subdomain per domain setelah scan selesai
    echo -e "${YELLOW}Total subdomain $domain: $FOUND${NC}"
    echo -e "----------------------------------------------------------"

    #  kasih table summary di baris bawah subs.txt per domainnya
    mv "$DOMAIN_SUBS" "${DOMAIN_SUBS}.tmp_file"
    {
        echo "=========================================================="
        echo " SUBDOMAIN LIST FOR : $domain"
        echo " Generated at       : $(time_now)"
        echo "=========================================================="
        echo ""
        cat "${DOMAIN_SUBS}.tmp_file"
        echo ""
        echo "----------------------------------------------------------"
        echo " RINGKASAN SCAN"
        echo "----------------------------------------------------------"
        printf "| %-30s | %-15s |\n" "Kategori" "Jumlah"
        echo "----------------------------------------------------------"
        printf "| %-30s | %-15s |\n" "Total Subdomain Unik" "$FOUND"
        echo "----------------------------------------------------------"
    } > "$DOMAIN_SUBS"
    rm "${DOMAIN_SUBS}.tmp_file"

    #  kasih table summary di baris bawah live.txt per domain
    touch "$DOMAIN_LIVE"
    mv "$DOMAIN_LIVE" "${DOMAIN_LIVE}.tmp_file"
    {
        echo "=========================================================="
        echo " LIVE HOSTS FOR : $domain"
        echo " Generated at   : $(time_now)"
        echo "=========================================================="
        echo ""
        cat "${DOMAIN_LIVE}.tmp_file"
        echo ""
        echo "----------------------------------------------------------"
        echo " RINGKASAN LIVE HOSTS"
        echo "----------------------------------------------------------"
        printf "| %-30s | %-15s |\n" "Kategori" "Jumlah"
        echo "----------------------------------------------------------"
        printf "| %-30s | %-15s |\n" "Subdomain Aktif (Live)" "$LIVE_COUNT"
        echo "----------------------------------------------------------"
    } > "$DOMAIN_LIVE"
    rm "${DOMAIN_LIVE}.tmp_file"

    ((COUNT++))
done 3< "$DOMAIN_LIST"

# tabel summary domain breakdown
{
    echo "============================================================"
    echo "            DOMAIN BREAKDOWN SUMMARY TABLE"
    echo "============================================================"
    printf "| %-35s | %-15s |\n" "Domain Name" "Subdomains"
    echo "------------------------------------------------------------"
    while IFS="|" read -r d_name d_count; do
        printf "| %-35s | %-15s |\n" "$d_name" "$d_count"
    done < "${DOMAIN_SUMMARY}.tmp"
    echo "============================================================"
} > "$DOMAIN_SUMMARY"
rm "${DOMAIN_SUMMARY}.tmp"

# hitung total scan
TOTAL_SUBS=$(grep -vE '^-|^[[:space:]]*$|^=|Kategori|Total|GLOBAL|logs|progress\.log|errors\.log' "$SUBDOMAIN_OUTPUT" | wc -l)
TOTAL_LIVE=$(grep -vE '^-|^[[:space:]]*$|^=|Kategori|Total|GLOBAL|logs|progress\.log|errors\.log' "$LIVE_ALL" | wc -l)

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# tabel summary di page bagian bawah all-subdomains.txt
sort -uo "$SUBDOMAIN_OUTPUT" "$SUBDOMAIN_OUTPUT"
{
    echo -e "\n\n----------------------------------------------------------"
    echo " GLOBAL SUMMARY (ALL DOMAINS)"
    echo "----------------------------------------------------------"
    printf "| %-30s | %-15s |\n" "Kategori" "Total"
    echo "----------------------------------------------------------"
    printf "| %-30s | %-15s |\n" "Total Subdomain Gabungan" "$TOTAL_SUBS"
    echo "----------------------------------------------------------"
} >> "$SUBDOMAIN_OUTPUT"

# tabel summary di page bawah all-live.txt
{
    echo -e "\n\n----------------------------------------------------------"
    echo " GLOBAL LIVE SUMMARY"
    echo "----------------------------------------------------------"
    printf "| %-30s | %-15s |\n" "Kategori" "Total"
    echo "----------------------------------------------------------"
    printf "| %-30s | %-15s |\n" "Total Live Hosts Aktif" "$TOTAL_LIVE"
    echo "----------------------------------------------------------"
} >> "$LIVE_ALL"

# recon result summary (tabel)
echo ""
echo -e "${YELLOW}┌──────────────────────────────────────────────────┐${NC}"
echo -e "${YELLOW}│                RECON RESULT SUMMARY                │${NC}"
echo -e "${YELLOW}├───────────────────────────┬──────────────────────┤${NC}"
printf "${CYAN}│ %-25s │ %-20s ${CYAN}│${NC}\n" "Total Domain Diproses" "$TOTAL_DOMAINS"
printf "${CYAN}│ %-25s │ %b" "Subdomain Unik Found" "$(colorize "$TOTAL_SUBS")"
printf "${CYAN}%$((21 - ${#TOTAL_SUBS}))s │${NC}\n" " "
printf "${CYAN}│ %-25s │ %b" "Live Hosts Aktif" "$(colorize "$TOTAL_LIVE")"
printf "${CYAN}%$((21 - ${#TOTAL_LIVE}))s │${NC}\n" " "
printf "${CYAN}│ %-25s │ %-20s ${CYAN}│${NC}\n" "Durasi Scan" "$DURATION detik"
printf "${CYAN}│ %-25s │ %-20s ${CYAN}│${NC}\n" "Selesai Pada" "$(date '+%H:%M:%S')"
echo -e "${YELLOW}└───────────────────────────┴──────────────────────┘${NC}"

# breakdown summary per domain
echo
echo -e "${BLUE}═════════════════ DOMAIN BREAKDOWN ═════════════════${NC}"
if [ -f "$DOMAIN_SUMMARY" ]; then
    awk -F'|' '/^[[:space:]]*\|/ && !/Domain Name/ {
        d_name=$2; d_count=$3;
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", d_name);
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", d_count);
        if(d_name != "") print d_name " : " d_count " subdomains"
    }' "$DOMAIN_SUMMARY" | while read -r line; do
        d_name=$(echo "$line" | cut -d' ' -f1)
        d_count=$(echo "$line" | grep -oE '[0-9]+' | head -1)
        COLOR_COUNT=$(colorize "$d_count")
        printf "${CYAN}%-30s : %b subdomains${NC}\n" "$d_name" "$COLOR_COUNT"
    done
fi
echo -e "${BLUE}════════════════════════════════════════════════════${NC}"

echo -e "${GREEN}[$(time_now)] Beres! Cek folder $BASE_OUTPUT${NC}"
