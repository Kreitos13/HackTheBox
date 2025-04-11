#!/bin/bash

# ============================
#   create.sh
#   Author: Kr31tos 😈
#   Purpose: Creates a root folder with your input name <machine_name> and the 4 subfolders.
#   Add script in /usr/local/bin/create
#   sudo chmod +x /usr/local/bin/create
# ============================

if [ -z "$1" ]; then
    echo -e "\n[!] Usage: create <machine_name>\n"
    exit 1
fi

MACHINE="$1"

# Create root folder
mkdir -p "$MACHINE"/{1-Enumeration,2-Web_Footprinting,3-Initial_Foothold,4-Privilege_Escalation}

echo -e"\n✅ Directory structure for '$MACHINE' created:\n"
tree "$MACHINE"
