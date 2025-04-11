#!/bin/sh
# ============================
#   htb_machine.sh
#   Author: Kr31tos 😈
#   Purpose: Write machine's IP in pannel Generic Monitor widget
#   Add script in /usr/local/bin/htb_machine
#   sudo chmod +x /usr/local/bin/htb_machine
# ============================

CONFIG_FILE="/home/kr31tos/Documents/Scripts/.config/htb/machine_ip.txt" # Change this with you path to ip.txt

show_help() {
    echo
    echo "HTB IP Panel Script"
    echo
    echo "Usage:"
    echo "  htb_machine                          Run in XFCE panel mode (GENMON)"
    echo "  htb_machine --set <IP> <HOSTNAME>    Set the current HTB machine"
    echo "  htb_machine -h | --help              Show this help message"
    echo "  htb_machine --reset                  Reset status"
    echo
    echo "Examples:"
    echo "  htb_machine --set 10.10.11.150 knife.htb"
    echo
    exit 0
}

# Handle CLI arguments
case "$1" in
    -h|--help)
        show_help
        ;;
    --set)
        if [ $# -ne 3 ]; then
            echo "[-] Usage: $0 --set <IP> <HOSTNAME>"
            exit 1
        fi
        echo "$2 $3" > "$CONFIG_FILE"
    echo
        echo "[+] HTB IP set to: $2 $3"
    echo
        exit 0
        ;;
    --reset)
    echo "No Machine" > "$CONFIG_FILE"
    echo
        echo "[✔] HTB machine reset to 'No Machine'"
    echo
        exit 0
        ;;
esac

# Normal XFCE panel display mode
info="$(cat "$CONFIG_FILE" 2>/dev/null)"

if [ -n "$info" ]; then
  printf "<icon>network-server-symbolic</icon>"
  printf "<txt>%s</txt>" "$info"
  if command -v xclip >/dev/null; then
    printf "<iconclick>sh -c 'printf \"%s\" | xclip -selection clipboard'</iconclick>" "$info"
    printf "<txtclick>sh -c 'printf \"%s\" | xclip -selection clipboard'</txtclick>" "$info"
    printf "<tool>HTB IP & Hostname (click to copy)</tool>"
  else
    printf "<tool>Install xclip to enable click-to-copy</tool>"
  fi
else
  printf "<txt>--</txt>"
  printf "<tool>No HTB machine set</tool>"
fi
