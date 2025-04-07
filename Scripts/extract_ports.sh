#!/bin/bash

# ============================
#   extract_ports.sh
#   Author: Kr31tos 😈
#   Purpose: Extract IP and open ports from nmap -oG output
#   Add script in /usr/local/bin/extract_ports
#   sudo chmod +x extract_ports
# ============================

# Colors
CYAN="\e[1;36m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
RED="\e[1;31m"
BLUE="\e[1;34m"
MAGENTA="\e[1;35m"
BOLD="\e[1m"
RESET="\e[0m"

function show_help() {
    echo -e "\n📘 ${YELLOW}Usage:${RESET}\n         extract_ports <nmap_grepable_output>"
    echo
    echo -e "🧪 ${YELLOW}Example:${RESET}"
    echo "         nmap -p- --open -T5 -v -n <ip> -oG machine_initial_scan"
    echo "         extract_ports machine_initial_scan"
    echo
    echo -e "🔧 ${YELLOW}Options:${RESET}"
    echo "         -h, --help            Show this help message"
    exit 0
}

# Help option
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
fi

# Validation
if [ $# -ne 1 ]; then
    echo -e "\n${RED}[✘] Error:${RESET} No input file specified."
    echo -e "Use ${YELLOW}-h${RESET} for help.\n"
    exit 1
fi

FILE="$1"
if [ ! -f "$FILE" ]; then
    echo -e "\n${RED}[✘] Error:${RESET} File '${FILE}' not found.\n"
    exit 1
fi

# Extract data
ports_array=($(grep -oP '\d{1,5}/open' "$FILE" | cut -d '/' -f1))
ports_csv=$(IFS=, ; echo "${ports_array[*]}")
ip=$(grep -oP '\d{1,3}(\.\d{1,3}){3}' "$FILE" | sort -u | head -n 1)
machine_name=$(grep "$ip" /etc/hosts | awk '{print $2}' | cut -d. -f1)
[ -z "$machine_name" ] && machine_name="target"

OUTPUT_FILE="${machine_name}_ports_scan"

# Start writing to file
{
echo -e "\n${BLUE}╔═════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}      🔍 Nmap Port Extractor by Kr31tos 😈${RESET}"
echo -e "${BLUE}╚═════════════════════════════════════════════╝${RESET}"

echo -e "${CYAN}[📌]${RESET} ${BOLD}Target IP:${RESET}     ${GREEN}$ip${RESET}"
echo -e "${CYAN}[🚪]${RESET} ${BOLD}Open Ports:${RESET}    ${YELLOW}$ports_csv${RESET}\n"

echo -e "${CYAN}[📊]${RESET} ${BOLD}Open Ports Table:${RESET}"
echo -e "${BLUE}──────────────────────${RESET}"
echo -e "${BOLD}${YELLOW}PORT${RESET}"
echo -e "${BLUE}──────────────────────${RESET}"

for port in "${ports_array[@]}"; do
    echo -e "${GREEN}$port${RESET}"
done

echo -e "${BLUE}──────────────────────${RESET}"

if command -v xclip >/dev/null; then
    echo -e "\n${CYAN}[✅]${RESET} Ports copied to clipboard!"
else
    echo -e "\n${YELLOW}[⚠] xclip not found. Ports not copied.${RESET}"
fi

echo -e "${BLUE}══════════════════════════════════════════════${RESET}\n"
} > "$OUTPUT_FILE"

# Print to terminal as well
cat "$OUTPUT_FILE"
