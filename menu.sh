#!/bin/bash

# =========================
# Warna dan Style
# =========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

# =========================
# Pengaturan variabel
# =========================
USER="cloudsigma"
OLD_PASSWORD="Cloud2025"
NEW_PASSWORD="Dotaja123@HHHH"

# =========================
# Fungsi untuk menampilkan menu
# =========================
show_menu() {
    clear
    echo -e "${CYAN}${BOLD}===== PILIH REGION =====${RESET}"
    echo -e "${YELLOW}1) Asia"
    echo -e "2) Eropa${RESET}"
    echo -e "======================="
}

# =========================
# Pilih region terlebih dahulu
# =========================
show_menu
echo -ne "${MAGENTA}Pilih region [1-2]: ${RESET}"
read REGION_CHOICE

case $REGION_CHOICE in
    1)
        REGION_LINK="https://raw.githubusercontent.com/DOT-SUNDA/cloudsigma/refs/heads/main/asia.sh"
        REGION_NAME="Asia"
        ;;
    2)
        REGION_LINK="https://raw.githubusercontent.com/DOT-SUNDA/cloudsigma/refs/heads/main/eropa.sh"
        REGION_NAME="Eropa"
        ;;
    *)
        echo -e "${RED}Pilihan tidak valid. Keluar.${RESET}"
        exit 1
        ;;
esac

echo -e "${GREEN}Region dipilih: $REGION_NAME${RESET}"

# =========================
# Meminta input IP
# =========================
echo -ne "${MAGENTA}Masukkan IP VPS (pisah koma jika lebih dari satu): ${RESET}"
read IPS

if [ -z "$IPS" ]; then
    echo -e "${RED}IP tidak boleh kosong. Keluar.${RESET}"
    exit 1
fi

IFS=',' read -ra IP_LIST <<< "$IPS"

for IP in "${IP_LIST[@]}"; do
    echo -e "${BLUE}${BOLD}Mengganti Sandi VPS $IP di region $REGION_NAME...${RESET}"
    
    # =========================
    # Step 1: Ganti password
    # =========================
    /usr/bin/expect << EOF
        set timeout 10
        spawn ssh $USER@$IP
        expect {
            "yes/no" { send "yes\r"; exp_continue }
            "password:" { send "$OLD_PASSWORD\r" }
        }
        expect "Your password has expired. You must change your password now and login again!"
        expect "Current password:" { send "$OLD_PASSWORD\r" }
        expect "New password:" { send "$NEW_PASSWORD\r" }
        expect "Retype new password:" { send "$NEW_PASSWORD\r" }
        expect eof
EOF

    echo -e "${CYAN}Koneksi ulang ke $IP dengan password baru dan sudo su...${RESET}"
    
    # =========================
    # Step 2: Koneksi ulang dan sudo su
    # =========================
    /usr/bin/expect << EOF
        set timeout 10
        spawn ssh $USER@$IP
        expect {
            "yes/no" { send "yes\r"; exp_continue }
            "password:" { send "$NEW_PASSWORD\r" }
        }
        expect "$ "
        send "sudo su\r"
        expect "password for $USER:"
        send "$NEW_PASSWORD\r"
        expect "# "
        send "wget -O mek $REGION_LINK && chmod +x mek && nohup ./mek > /dev/null 2>&1 &\r"
        expect "# "
        send "exit\r"
        expect "$ "
        send "exit\r"
        expect eof
EOF

    echo -e "${GREEN}Selesai untuk VPS $IP!${RESET}"
done
