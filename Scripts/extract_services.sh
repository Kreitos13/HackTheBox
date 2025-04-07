#!/bin/bash

# ============================
#   extract_services.sh
#   Author: Kr31tos 😈
#   Purpose: Extract and colorize service info from Nmap -sV output
#   Add script in /usr/local/bin/extract_services
#   sudo chmod +x extract_services
# ============================

#!/bin/bash

# Colors
CYAN="\e[1;36m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
RED="\e[1;31m"
MAGENTA="\e[1;35m"
BOLD="\e[1m"
RESET="\e[0m"

# BANNER
echo -e "${CYAN}${BOLD}"
cat << "EOF"
  ______      _                  _        _____                 _               
 |  ____|    | |                | |      / ____|               (_)              
 | |__  __  _| |_ _ __ __ _  ___| |_    | (___   ___ _ ____   ___  ___ ___  ___ 
 |  __| \ \/ / __| '__/ _` |/ __| __|    \___ \ / _ \ '__\ \ / / |/ __/ _ \/ __|
 | |____ >  <| |_| | | (_| | (__| |_     ____) |  __/ |   \ V /| | (_|  __/\__ \
 |______/_/\_\\__|_|  \__,_|\___|\__|   |_____/ \___|_|    \_/ |_|\___\___||___/
EOF
echo -e "\n${MAGENTA}${BOLD}                          Service Extractor by Kr31tos 😈${RESET}\n"

# Help
show_help() {
    echo -e "\n${YELLOW}Usage:${RESET} extract_services <ip> <ports>"
    echo -e "\n${YELLOW}Example:${RESET} extract_services 10.10.10.75 22,80"
    echo
    exit 0
}

# Validate args
if [ "$#" -ne 2 ]; then
    show_help
fi

IP="$1"
PORTS="$2"
MACHINE_NAME=$(grep "$IP" /etc/hosts | awk '{print $2}' | cut -d. -f1)
[ -z "$MACHINE_NAME" ] && MACHINE_NAME="target"

SCAN_FILE="nmap_services_scan.txt"
OUTPUT_FILE="${MACHINE_NAME}_services_scan"

echo -e "${CYAN}[+]${RESET} Target IP: ${YELLOW}$IP${RESET}"
echo -e "${CYAN}[+]${RESET} Ports:     ${GREEN}$PORTS${RESET}"
echo -e "\n${CYAN}[+]${RESET} Running Nmap scan... Output → ${MAGENTA}$SCAN_FILE${RESET}\n"

# Run Nmap
nmap -sC -sV -T5 -vv -p"$PORTS" "$IP" -oN "$SCAN_FILE"

# Header for both terminal and file
TABLE_HEADER=$(cat <<EOF
╔═══════════════════════════════════════════════════════════════════════╗
               🚀 Extracted Services from: $MACHINE_NAME             
╚═══════════════════════════════════════════════════════════════════════╝
       PORT             SERVICE           VERSION
─────────────────────────────────────────────────────────────────────────
EOF
)

echo -e "\n${BOLD}${CYAN}${TABLE_HEADER}${RESET}"
echo -e "\n${BOLD}${CYAN}$TABLE_HEADER${RESET}" > "$OUTPUT_FILE"

# Process & output
grep -E "^[0-9]+/(tcp|udp)" "$SCAN_FILE" | grep open | while read -r line; do
    port=$(echo "$line" | awk '{print $1}')
    service=$(echo "$line" | awk '{print $3}')
    version=$(echo "$line" | cut -d ' ' -f4-)

    # Terminal Output (with colors)
    printf " [    ${GREEN}%-10s${RESET}] ${MAGENTA}%-15s${RESET} ${YELLOW}%-40s${RESET}\n" "$port" "       $service" "        $version"

    # File Output (with raw ANSI colors)
    printf "\n [    \e[1;32m%-10s\e[0m] \e[1;35m%-15s\e[0m \e[1;33m%-40s\e[0m\n" "$port" "       $service" "        $version" >> "$OUTPUT_FILE"
done

# Final Line
echo -e "\n${GREEN}[✔]${RESET} Output saved to: ${BOLD}$OUTPUT_FILE${RESET}\n"
