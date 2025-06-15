#!/bin/bash
# ---------------- Colors ----------------
ORANGE='\033[38;5;208m'
WHITE='\033[1;37m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # Reset

# ---------------- Banner ----------------
clear
echo -e "${CYAN}============================================================"
echo -e "${ORANGE}███    ██ ██ ████████ ███████ ███████ ██   ██ "
echo -e "${ORANGE}████   ██ ██    ██    ██      ██      ██   ██ "
echo -e "${WHITE}██ ██  ██ ██    ██    █████   ███████ ███████ "
echo -e "${GREEN}██  ██ ██ ██    ██    ██           ██ ██   ██ "
echo -e "${GREEN}██   ████ ██    ██    ███████ ███████ ██   ██ "
echo -e "${CYAN}============================================================"
echo -e "${CYAN}         🚀 Spolia And Beacon RPC Setup By Nitesh Kumawat 🚀"
echo -e "${CYAN}============================================================${NC}"

# ---------------- Install Packages ----------------
echo -e "${CYAN}Installing required packages...${NC}"
sudo apt -qq update && sudo apt -qq upgrade -y
sudo apt -qq install -y curl iptables build-essential git ufw wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip ca-certificates gnupg

# ---------------- Install Docker ----------------
echo -e "${CYAN}Installing Docker and Docker Compose...${NC}"
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove -y $pkg; done
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt -qq update
sudo apt -qq install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl restart docker

# ---------------- Ethereum Directories ----------------
echo -e "${CYAN}Creating Ethereum data directories...${NC}"
sudo mkdir -p /root/ethereum/execution
sudo mkdir -p /root/ethereum/consensus

# ---------------- JWT Secret ----------------
echo -e "${CYAN}Generating JWT secret...${NC}"
sudo openssl rand -hex 32 | sudo tee /root/ethereum/jwt.hex > /dev/null
sudo chmod 644 /root/ethereum/jwt.hex

# ---------------- Docker Compose ----------------
echo -e "${CYAN}Creating docker-compose.yml...${NC}"
cd /root/ethereum
cat <<EOF | sudo tee docker-compose.yml > /dev/null
version: '3.7'
services:
  geth:
    image: ethereum/client-go:stable
    container_name: geth
    network_mode: host
    restart: unless-stopped
    ports:
      - 30303:30303
      - 30303:30303/udp
      - 8545:8545
      - 8546:8546
      - 8551:8551
    volumes:
      - /root/ethereum/execution:/data
      - /root/ethereum/jwt.hex:/data/jwt.hex
    command:
      - --sepolia
      - --http
      - --http.api=eth,net,web3
      - --http.addr=0.0.0.0
      - --authrpc.addr=0.0.0.0
      - --authrpc.vhosts=*
      - --authrpc.jwtsecret=/data/jwt.hex
      - --authrpc.port=8551
      - --syncmode=snap
      - --datadir=/data
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  prysm:
    image: gcr.io/prysmaticlabs/prysm/beacon-chain
    container_name: prysm
    network_mode: host
    restart: unless-stopped
    volumes:
      - /root/ethereum/consensus:/data
      - /root/ethereum/jwt.hex:/data/jwt.hex
    depends_on:
      - geth
    ports:
      - 4000:4000
      - 3500:3500
    command:
      - --sepolia
      - --accept-terms-of-use
      - --datadir=/data
      - --disable-monitoring
      - --rpc-host=0.0.0.0
      - --execution-endpoint=http://127.0.0.1:8551
      - --jwt-secret=/data/jwt.hex
      - --rpc-port=4000
      - --grpc-gateway-corsdomain=*
      - --grpc-gateway-host=0.0.0.0
      - --grpc-gateway-port=3500
      - --min-sync-peers=3
      - --checkpoint-sync-url=https://checkpoint-sync.sepolia.ethpandaops.io
      - --genesis-beacon-api-url=https://checkpoint-sync.sepolia.ethpandaops.io
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
EOF

# ---------------- Start Containers ----------------
echo -e "${CYAN}Starting Geth + Prysm Docker containers...${NC}"
sudo docker compose up -d

# ---------------- Final Message ----------------
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${YELLOW}Run logs: ${NC} sudo docker compose logs -f"
echo -e "${YELLOW}Geth RPC: ${NC} http://<your-vps-ip>:8545"
echo -e "${YELLOW}Prysm Beacon RPC: ${NC} http://<your-vps-ip>:3500"
echo -e "${CYAN}============================================================"
echo -e "${GREEN}🙏 Thank you for using this script! Have a good day!! 🚀🇮🇳"
echo -e "${GREEN}~ Nitesh Kumawat${NC}"
echo -e "${RED}🇮🇳 JAI HIND! VANDE MATARAM! 🇮🇳${NC}"
