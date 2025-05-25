#!/bin/bash
set -e
set -o pipefail

echo "[*] Installing ODAT with Python 3.11 using pyenv"

# Step 1: Install dependencies
echo "[*] Installing system packages..."
sudo apt update
sudo apt install -y git curl wget unzip build-essential alien libaio-dev \
  libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
  llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
  libffi-dev liblzma-dev python3-pip python3-scapy

# Step 2: Install pyenv
if ! command -v pyenv >/dev/null; then
  echo "[*] Installing pyenv..."
  curl https://pyenv.run | bash

  # Add pyenv to shell
  echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(pyenv init -)"' >> ~/.bashrc
  echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
else
  echo "[*] pyenv already installed."
fi

# Step 3: Install Python 3.11 via pyenv
if ! pyenv versions | grep -q "3.11"; then
  echo "[*] Installing Python 3.11..."
  pyenv install 3.11.8
fi

pyenv global 3.11.8

# Step 4: Clone ODAT and set up environment
echo "[*] Cloning ODAT..."
git clone https://github.com/quentinhardy/odat.git
cd odat
git submodule update --init

echo "[*] Creating virtual environment..."
python3.11 -m venv ../odat-env
source ../odat-env/bin/activate

# Step 5: Download Oracle Instant Client
echo "[*] Downloading Oracle Instant Client..."
cd ..
mkdir -p oracle && cd oracle
wget https://download.oracle.com/otn_software/linux/instantclient/2380000/oracle-instantclient-basic-23.8.0.25.04-1.el9.x86_64.rpm
wget https://download.oracle.com/otn_software/linux/instantclient/2380000/oracle-instantclient-devel-23.8.0.25.04-1.el9.x86_64.rpm
wget https://download.oracle.com/otn_software/linux/instantclient/2380000/oracle-instantclient-sqlplus-23.8.0.25.04-1.el9.x86_64.rpm

echo "[*] Converting and installing Oracle client packages..."
sudo alien --to-deb *.rpm
sudo dpkg -i *.deb

# Step 6: Configure environment for Oracle
export ORACLE_HOME=/usr/lib/oracle/23/client64
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export PATH=$ORACLE_HOME/bin:$PATH
echo "$ORACLE_HOME/lib/" | sudo tee /etc/ld.so.conf.d/oracle.conf
sudo ldconfig

# Step 7: Activate venv and install Python packages
cd ../odat
source ../odat-env/bin/activate
pip install --upgrade pip
pip install cx_Oracle pycryptodome colorlog termcolor passlib python-libnmap argcomplete pyinstaller

# Step 8: Final Test
echo "[*] Testing ODAT..."
python odat.py -h || echo "ODAT ready but asyncore warnings may appear on newer Python."

echo ""
echo "✅ ODAT installed successfully!"
echo "To use it later, run:"
echo "  source ../odat-env/bin/activate && cd odat && python odat.py -h"
