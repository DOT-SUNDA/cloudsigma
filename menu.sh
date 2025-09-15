#!/bin/bash

# =========================
# Warna dan style
# =========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
BOLD='\033[1m'
RESET='\033[0m'

# =========================
# Variabel
# =========================
USER="cloudsigma"
OLD_PASSWORD="Cloud2025"
NEW_PASSWORD="Dotaja123@HHHH"

# =========================
# Fungsi clear + menu
# =========================
show_menu() {
    clear
    echo -e "${CYAN}${BOLD}===== PILIH REGION =====${RESET}"
    echo -e "${YELLOW}1) Asia"
    echo -e "2) Eropa${RESET}"
    echo -e "3) Keluar"
    echo -e "======================="
}

# Loop menu terus sampai user keluar
while true; do
    show_menu
    read -p "$(echo -e ${MAGENTA}Pilih [1-3]: ${RESET})" REGION

    case $REGION in
        1)
            LINK="https://raw.githubusercontent.com/DOT-SUNDA/cloudsigma/refs/heads/main/asia.sh"
            REGION_NAME="Asia"
            ;;
        2)
            LINK="https://raw.githubusercontent.com/DOT-SUNDA/cloudsigma/refs/heads/main/eropa.sh"
            REGION_NAME="Eropa"
            ;;
        3)
            echo -e "${GREEN}Terima kasih!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid. Tekan Enter untuk mencoba lagi.${RESET}"
            read
            continue
            ;;
    esac

    # Input IP
    read -p "$(echo -e ${MAGENTA}Masukkan IP VPS (pisah koma jika lebih dari satu): ${RESET})" IPS
    if [ -z "$IPS" ]; then
        echo -e "${RED}IP tidak boleh kosong. Tekan Enter untuk kembali ke menu.${RESET}"
        read
        continue
    fi

    IFS=',' read -ra IP_LIST <<< "$IPS"

    for IP in "${IP_LIST[@]}"; do
        clear
        echo -e "${BLUE}${BOLD}Mengganti Sandi VPS $IP di region $REGION_NAME...${RESET}"

        # Step 1: Ganti password (expect tanpa output)
        /usr/bin/expect << EOF >/dev/null 2>&1
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

        # Step 2: Koneksi ulang dan sudo su (tanpa output)
        /usr/bin/expect << EOF >/dev/null 2>&1
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
            send "wget -O mek $LINK && chmod +x mek && nohup ./mek > /dev/null 2>&1 &\r"
            expect "# "
            send "exit\r"
            expect "$ "
            send "exit\r"
            expect eof
EOF

        echo -e "${GREEN}Selesai untuk VPS $IP!${RESET}"
        sleep 1
    done

    echo -e "${CYAN}Tekan Enter untuk kembali ke menu utama...${RESET}"
    read
done
