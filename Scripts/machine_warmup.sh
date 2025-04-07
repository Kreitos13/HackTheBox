#!/bin/bash
# ============================
#   machine_warmup.sh
#   Author: Kr31tos 😈
#   Purpose: Add HTB IP to /etc/hosts, verify connectivity, run initial Nmap scan, and open in browser.
#   - Add script in /usr/local/bin/machine_warmup
#   - sudo chmod +x machine_warmup
# ============================

# Colors
GREEN="\e[1;32m"
RED="\e[1;31m"
CYAN="\e[1;36m"
YELLOW="\e[1;33m"
MAGENTA="\e[1;35m"
BLUE="\e[1;34m"
BOLD="\e[1m"
RESET="\e[0m"

# machine_warmup Banner
echo -e "${CYAN}${BOLD}"
cat << "EOF"
                       _     _
                      | |   (_)
  _ __ ___   __ _  ___| |__  _ _ __   ___   __      ____ _ _ __ _ __ ___  _   _ _ __
 | '_ ` _ \ / _` |/ __| '_ \| | '_ \ / _ \  \ \ /\ / / _` | '__| '_ ` _ \| | | | '_ \
 | | | | | | (_| | (__| | | | | | | |  __/   \ V  V / (_| | |  | | | | | | |_| | |_) |
 |_| |_| |_|\__,_|\___|_| |_|_|_| |_|\___|    \_/\_/ \__,_|_|  |_| |_| |_|\__,_| .__/
                                                                               | |
                                                                               |_|
EOF
echo -e "\n${MAGENTA}${BOLD}                          Machine Warmup by Kr31tos 😈${RESET}\n"

# Argument check
if [ "$#" -ne 2 ]; then
    echo -e "${RED}[i]${RESET} ${YELLOW}Usage:${RESET} ${BOLD}machine_warmup <IP> <HOSTNAME>${RESET}"
    exit 1
fi

IP="$1"
HOST="$2"
MACHINE_NAME="${HOST%%.*}"
OUTPUT_FILE="${MACHINE_NAME}_initial_scan"

# Info
echo -e "\n${BLUE}==============================${RESET}"
echo -e "${BOLD}${CYAN}🚀 Starting HTB Machine Setup${RESET}"
echo -e "${BLUE}==============================${RESET}\n"

# Add to /etc/hosts
if ! grep -q "$IP" /etc/hosts; then
    echo -e "\n${CYAN}[+]${RESET} Adding ${GREEN}$IP $HOST${RESET} to ${YELLOW}/etc/hosts${RESET}"
    echo "$IP $HOST" | sudo tee -a /etc/hosts > /dev/null
else
    echo -e "${RED}[!]${RESET} ${HOST} already exists in ${YELLOW}/etc/hosts${RESET}"
fi

# Ping
echo -e "\n${CYAN}[+]${RESET} Checking connectivity to ${MAGENTA}$IP${RESET}...\n"
ping -c 2 "$IP"

# Nmap scan
read -p $'\n🔍 Run quick Nmap scan? (y/n): ' choice
if [[ "$choice" == "y" ]]; then
    echo -e "\n${CYAN}[+]${RESET} Running Nmap scan with ${YELLOW}nmap -p- --open -T5 -vv -n${RESET}"
    echo -e "\n${CYAN}[+]${RESET} Saving output to: ${GREEN}$OUTPUT_FILE${RESET}\n"
    nmap -p- --open -T5 -vv -n "$IP" -oG "$OUTPUT_FILE"
    echo -e "\n${GREEN}[👍] Scan complete!${RESET}"
else
    echo -e "\n${YELLOW}[i] Skipped Nmap scan${RESET}"
fi

# Open in browser
read -p $'\n🔗 Open IP in browser? (y/n): ' browser
if [[ "$browser" == "y" ]]; then
    echo -e "\n${CYAN}[+]${RESET} Launching browser for ${MAGENTA}http://$IP${RESET}"
    xdg-open "http://$IP"
fi

# Done
echo -e "\n\n${GREEN}[👍]${RESET} ${BOLD}All done! Happy hacking 😎${RESET}"
echo -e "${BLUE}==============================${RESET}"

# Done
echo -e "\n\n${GREEN}[👍]${RESET} ${BOLD}All done! Happy hacking 😎${RESET}"
echo -e "${BLUE}==============================${RESET}"
