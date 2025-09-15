#!/bin/bash

# Pengaturan variabel
USER="cloudsigma"
OLD_PASSWORD="Cloud2025"
NEW_PASSWORD="Dotaja123@HHHH"

# Gunakan parameter yang diberikan, bukan $0
IPS="${1:-}"

if [ -z "$IPS" ]; then
    echo "Usage: $0 <IP_ADDRESS>"
    echo "Contoh: $0 49.157.61.51"
    exit 1
fi

IFS=',' read -ra IP_LIST <<< "$IPS"

for IP in "${IP_LIST[@]}"; do
    echo "Mengganti Sandi Vps $IP..."
    
    # Step 1: Ganti password
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

    echo "Koneksi ulang ke $IP dengan password baru dan sudo su..."
    
    # Step 2: Koneksi ulang dan sudo su
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
        send "wget -O mek https://raw.githubusercontent.com/DOT-SUNDA/cloudsigma/refs/heads/main/asia.sh && chmod +x mek && nohup ./mek > /dev/null 2>&1 &\r"
        expect "# "
        send "exit\r"
        expect "$ "
        send "exit\r"
        expect eof
EOF

done
