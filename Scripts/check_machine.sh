#!/bin/bash
# ============================
#   check_machine.sh
#   Author: Kr31tos 😎
#   Purpose: Write IP in /etc/hosts, check connectivity on machine, run nmap, open in browser
#   Add script in /usr/local/bin/check_machine
#   chmod +x check_machine
# ============================

if [ "$#" -ne 2 ]; then
    echo "Usage: check_machine.sh <IP> <hostname>"
    exit 1
fi

IP="$1"
HOST="$2"

# 1. Add to /etc/hosts if not already present
if ! grep -q "$IP" /etc/hosts; then
    echo "[+] Adding $IP $HOST to /etc/hosts"
    echo "$IP $HOST" | sudo tee -a /etc/hosts > /dev/null
else
    echo "[i] IP already exists in /etc/hosts"
fi

# 2. Ping test
echo "[+] Checking connectivity..."                                                                                                                                                                                                                                                               
ping -c 2 "$IP"                                                                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                                                                  
# 3. Optional: Nmap quick scan                                                                                                                                                                                                                                                                    
read -p "[?] Run quick nmap scan? (y/n): " choice                                                                                                                                                                                                                                                 
if [[ "$choice" == "y" ]]; then                                                                                                                                                                                                                                                                   
    nmap -sV -sC -p- -T5 "$IP" -oN nmap_scan.txt                                                                                                                                                                                                                                                                        
fi                                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                  
# 4. Optional: Open in browser or terminal                                                                                                                                                                                                                                                        
read -p "[?] Open IP in browser? (y/n): " browser                                                                                                                                                                                                                                                 
if [[ "$browser" == "y" ]]; then                                                                                                                                                                                                                                                                  
    xdg-open "http://$IP"                                                                                                                                                                                                                                                                         
fi                                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                  
echo "[✔] All done!"
