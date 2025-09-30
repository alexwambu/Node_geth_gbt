#!/bin/bash
set -e

# Fetch genesis from server
echo "[*] Fetching genesis file from $GENESIS_SERVER_URL..."
curl -s $GENESIS_SERVER_URL -o /app/genesis.json

if [ ! -s /app/genesis.json ]; then
  echo "[!] Failed to download genesis file from $GENESIS_SERVER_URL"
  exit 1
fi

# Initialize the node with fetched genesis
if [ ! -d /root/.ethereum/geth ]; then
  echo "[*] Initializing with genesis.json..."
  geth init /app/genesis.json
fi

# Start geth node with RPC enabled
echo "[*] Starting GBT geth node..."
exec geth \
  --datadir /root/.ethereum \
  --networkid ${NETWORK_ID:-999} \
  --http --http.addr 0.0.0.0 --http.port ${RPC_PORT:-9636} \
  --http.api eth,net,web3,personal \
  --http.corsdomain="*" \
  --allow-insecure-unlock \
  --unlock $(cat /app/signer.key | jq -r .address) \
  --password /app/password.txt \
  --mine --miner.threads=1 \
  --port 30303 \
  --ipcdisable
