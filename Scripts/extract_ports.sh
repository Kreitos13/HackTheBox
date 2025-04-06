#!/bin/bash

# ============================
#   extractPorts.sh
#   Author: Kr31tos 😎
#   Purpose: Extract IP and open ports from nmap -oG output
#   Add script in /usr/local/bin/extract_ports
#   chmod +x extract_ports
# ============================

function show_help() {
    echo "Usage: $0 <nmap_grepable_output>"
    echo
    echo "Example:"
    echo "  nmap -p- --open -T5 -v -n <ip> -oG allPorts"
    echo "  $0 allPorts"
    echo
    echo "Options:"
    echo "  -h, --help      Show this help message"
    exit 0
}

# Show help if -h or --help is passed
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
fi

# Check if file is provided and exists
if [ $# -ne 1 ]; then
    echo "[-] Error: No input file specified."
    echo "Use -h for help."
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "[-] Error: File '$FILE' not found."
    exit 1
fi

# Extract open ports and IP address
ports=$(grep -oP '\d{1,5}/open' "$FILE" | cut -d '/' -f1 | xargs | tr ' ' ',')
ip=$(grep -oP '\d{1,3}(\.\d{1,3}){3}' "$FILE" | sort -u | head -n 1)

# Display results
echo -e "\n\e[1;34m[*] Extracting information from:\e[0m $FILE"
echo -e "\e[1;32m[+] IP Address:\e[0m     $ip"
echo -e "\e[1;32m[+] Open Ports:\e[0m     $ports"

# Copy to clipboard (if xclip is available)
if command -v xclip >/dev/null; then
    echo -n "$ports" | xclip -selection clipboard
    echo -e "\e[1;33m[✔] Ports copied to clipboard\e[0m"
else
    echo -e "\e[1;31m[!] xclip not found, ports not copied to clipboard\e[0m"
fi
