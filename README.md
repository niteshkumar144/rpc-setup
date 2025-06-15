# 📄 Ethereum Sepolia & Beacon RPC Setup

## 👉 Made with ❤️ by **Nitesh Kumawat**

---

## 📌 Requirements

✅ **Recommended Server Specs:**

- **OS:** Ubuntu 20.04 or 22.04
- **CPU:** Minimum **4 vCPUs**
- **RAM:** Minimum **16 GB RAM**
- **Storage:** Minimum **1000 GB**
- **Network:** Stable internet

---

## ⚡ Quick Setup (One Click)

```bash
# Update system & install curl:
sudo apt-get -qq update && sudo apt-get upgrade -y
sudo apt -qq install curl -y

# Run the auto script:
curl -s https://raw.githubusercontent.com/niteshkumar144/rpc-setup/main/rpc-setup.sh | bash
```

---

## 🔧 What Will Be Setup

✅ Full **Ethereum Sepolia** Execution Client (**Geth**)\
✅ **Prysm Beacon** Consensus Client\
✅ Secure JWT Secret for authentication\
✅ Docker containers for easy management\
✅ Data directories:

- `/root/ethereum/execution` → Geth data
- `/root/ethereum/consensus` → Prysm data
- `/root/ethereum/jwt.hex` → Shared JWT token

---

## 🔑 RPC Endpoints

After setup is synced:

| Client                      | URL                         |
| --------------------------- | --------------------------- |
| **Execution Layer (Geth)**  | `http://<your-vps-ip>:8545` |
| **Consensus Layer (Prysm)** | `http://<your-vps-ip>:3500` |

Use these RPCs for wallets, Aztec CLI, or other tools.

---

## ✅ Allow Firewall Rules

```bash
# Allow SSH
sudo ufw allow ssh
sudo ufw allow 22

# Allow Geth P2P ports
sudo ufw allow 30303/tcp
sudo ufw allow 30303/udp

# Allow public RPC 
sudo ufw allow 8545/tcp
sudo ufw allow 3500/tcp

# Enable UFW
sudo ufw enable
sudo ufw reload
```

---

## 📊 How to Check Sync Status

### ✅ Geth Sync:

```bash
curl -X POST -H "Content-Type: application/json" \
--data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
http://localhost:8545
```

If `false` => Geth is fully synced.

### ✅ Prysm Sync:

```bash
curl http://localhost:3500/eth/v1/node/syncing
```

Check `is_syncing`: `false` means fully synced.

### ✅ View Live Logs:

#### 👉 Prysm logs:
```bash
sudo docker logs prysm -fn 100
```
#### 👉 Geth logs:
```bash
sudo docker logs geth -fn 100
```

---

## ✅ How to Use RPCs

Once both clients are synced:

- For Sepolia Use:\
  `http://<your-vps-ip>:8545`

- For Beacon Use:\
  `http://<your-vps-ip>:3500`

- Use these endpoints in Aztec CLI 

---

## ❤️ Thank you & 🇮🇳 Jai Hind! Vande Mataram 🇮🇳

