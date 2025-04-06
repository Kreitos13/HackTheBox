#!/bin/bash

# ============================
#   extractServices.sh
#   Author: Kr31tos
#   Purpose: Extract and colorize service info from Nmap -sV output
# ============================

OUTPUT_FILE="nmap_services"

show_help() {
    echo -e "\nUsage: \e[1mextract_services <nmap_output_file>\e[0m"
    echo
    echo "Example:"
    echo "       nmap -sV -sC -T5 -v -p22,80 <ip> -oN nmap_scan.txt"
    echo "       extract_services nmap_scan.txt"
    echo
    exit 0
}

# Colors
CYAN="\e[1;36m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BOLD="\e[1m"
RESET="\e[0m"

# Handle help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
fi

# Check input file
if [ $# -ne 1 ]; then
    echo -e "${YELLOW}[-] Error:${RESET} Please provide an Nmap output file"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo -e "${YELLOW}[-] Error:${RESET} File not found: $FILE"
    exit 1
fi

# Initialize output file
echo "Service Scan Summary (from: $FILE)" > "$OUTPUT_FILE"
echo "--------------------------------------" >> "$OUTPUT_FILE"

# Header for terminal
echo -e "\n${BOLD}${CYAN}[*] Extracted Services:${RESET}"
printf "${BOLD}%-10s %-15s %-40s${RESET}\n" "PORT" "SERVICE" "VERSION"
echo -e "${CYAN}-------------------------------------------------------------${RESET}"

# Process and output
grep -E "^[0-9]+/(tcp|udp)" "$FILE" | grep open | while read -r line; do
    port=$(echo "$line" | awk '{print $1}')
    service=$(echo "$line" | awk '{print $3}')
    version=$(echo "$line" | cut -d ' ' -f4-)

    # Print to terminal (colorized)
    printf "[${CYAN}%-8s${RESET}] ${GREEN}%-13s${RESET} - ${YELLOW}%-40s${RESET}\n" "$port" "$service" "$version"

    # Print to file (plain)
    printf "%-10s %-15s %s\n" "$port" "$service" "$version" >> "$OUTPUT_FILE"
done

# Footer
echo -e "\n${GREEN}[✔] Output saved to:${RESET} $OUTPUT_FILE"
