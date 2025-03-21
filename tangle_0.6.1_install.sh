#!/bin/bash

clear

if [[ ! -f "$HOME/.bash_profile" ]]; then
    touch "$HOME/.bash_profile"
fi

if [ -f "$HOME/.bash_profile" ]; then
    source $HOME/.bash_profile
fi

logo_nodelab(){

clear

 cat << "EOF"
=========================================================================
     __	 __          __      __           __       _______        __ 
    | \ | |         | |     | |          | |      |__ ___|       | |
    |  \| | ___	  __| |	___ | |    ___ _ | |__      | | ___  ___ | |___
    |	  |/ _ \ / _  |/ __\| |   /   | ||  _ \	    | |/   \/  _\|  __ \
    | |\  | (_) | (_) | /o__| |___| (|  || |_) | _  | | /o__| |__| | | |
    |_| \_|\___/ \____|\___||____|\___|_||____/ (_) |_|\___|\___/|_| |_|
	
=========================================================================
             Developed by: NodeLab.Tech
             Twitter: https://twitter.com/theNodeLab
             Telegram: https://t.me/theNodeLab
=========================================================================
	
EOF

}

logo_nodelab;

# Request Validator Name

echo "======================== Tangle Mainnet v1.0.0 Install ==================== " && sleep 1

read -p "Do you want run node Tangle Network? (y/n): " choice

if [ "$choice" == "y" ]; then

if [ "$choice" == "y" ]; then
    read -p "Set Node Name: " input_moniker
    if [ -z "$input_moniker" ]; then
    echo "Node Name cannot be empty!"
    exit 1
     fi
     MONIKER="$input_moniker"
     echo "Node Name is: $MONIKER"
fi

# Install Build Pre-requisites

sudo apt update && apt upgrade -y

sudo apt install curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev libgmp3-dev tar clang bsdmainutils ncdu unzip llvm libudev-dev make protobuf-compiler -y

cd $HOME

# Install Tangle

sudo mkdir -p $HOME/.tangle && cd $HOME/.tangle

sudo wget -O tangle https://github.com/webb-tools/tangle/releases/download/v1.0.0/tangle-default-linux-amd64
sudo chmod 744 tangle
sudo mv tangle /usr/bin/
sudo tangle --version
# 0.5.0-e892e17-x86_64-linux-gnu

sudo wget -O $HOME/.tangle/tangle-mainnet.json "https://github.com/webb-tools/tangle/blob/main/chainspecs/mainnet/tangle-mainnet.json"

sudo chmod 744 ~/.tangle/tangle-mainnet.json

# Create System File

sudo tee /etc/systemd/system/full.service > /dev/null << EOF
[Unit]
Description=Tangle Full Node
After=network-online.target
StartLimitIntervalSec=0
 
[Service]
User=$USER
Restart=always
RestartSec=3
ExecStart=/usr/bin/tangle \
  --base-path $HOME/.tangle/data \
  --name "$MONIKER" \
  --chain tangle-mainnet \
  --node-key-file "$HOME/.tangle/node-key" \
  --rpc-cors all \
  --port 9946 \
  --no-mdns \
  --telemetry-url "wss://telemetry.polkadot.io/submit/ 1"
 
[Install]
WantedBy=multi-user.target
EOF

# Start Service

sudo systemctl daemon-reload
sudo systemctl enable full
sudo systemctl restart full && sudo journalctl -u full -f -o cat

fi

# Cleanup

sudo rm -rf tangle_install

echo "Check logs: sudo journalctl -u full -f -o cat"

echo "Check status: sudo systemctl status full"
