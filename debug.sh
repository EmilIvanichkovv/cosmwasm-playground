#!/usr/bin/env bash

set -euxo pipefail

CHAIN_ID="malaga-420"
TESTNET_NAME="malaga-420"
FEE_DENOM="umlg"
STAKE_DENOM="uand"
BECH32_HRP="wasm"
WASMD_VERSION="v0.27.0"
CONFIG_DIR=".wasmd"
BINARY="wasmd"

COSMJS_VERSION="v0.28.1"
GENESIS_URL="https://raw.githubusercontent.com/CosmWasm/testnets/master/malaga-420/config/genesis.json"

RPC="https://rpc.malaga-420.cosmwasm.com:443"
API="https://api.malaga-420.cosmwasm.com"
FAUCET="https://faucet.malaga-420.cosmwasm.com"

NODE="--node ${RPC}"
TXFLAG="${NODE} --chain-id ${CHAIN_ID} --gas-prices 0.25umlg --gas auto --gas-adjustment 1.3"

# Path to the root of the project
ROOT=$(git rev-parse --show-toplevel)

# Path to the contract dir
CONTRACT_DIR=${ROOT}/contracts/cosmos/light-client

# Compile Light Client implemeted in nim.
nim-wasm c --lib:${LOCAL_NIM_LIB} --nimcache:./nimbuild \
        -o:./nimbuild/light_client.wasm /${ROOT}/beacon-light-client/nim/light_client.nim \

# Compile and optimize the cosmwasm smart contract
docker run -t --rm -v "${CONTRACT_DIR}":/code \
  --mount type=volume,source="$(basename "$(pwd)")_cache",target=/code/target \
  --mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
  cosmwasm/rust-optimizer:0.12.8 .
RES=$(wasmd tx wasm store /home/Emil/code/repos/metacraft-labs/DendrETH/contracts/cosmos/light-client/artifacts/light_client.wasm --from wallet $TXFLAG -y --output json -b block)
CODE_ID=$(echo "$RES" | jq -r '.logs[0].events[-1].attributes[0].value')

# RES=$(wasmd tx wasm store /home/Emil/code/repos/metacraft-labs/DendrETH/contracts/cosmos/light-client/artifacts/light_client.wasm --from wallet --node https://rpc.malaga-420.cosmwasm.com:443 --chain-id malaga-420 --gas-prices 0.25umlg --gas auto --gas-adjustment 1.3 -y --output json -b block)CODE_ID=$(echo $RES | jq -r '.logs[0].events[-1].attributes[0].value')
INIT='{
         "slot": "1173120",
         "proposer_index": "33040",
         "parent_root": "0xca6ddab42853a7aef751e6c2bf38b4ddb79a06a1f971201dcf28b0f2db2c0d61",
         "state_root": "0xcb597e166ac3bc152cad03eed80ff83cbf75114f1c0c08a628c9ebaac90d457b",
         "body_root": "0xd366f6f755b510194b3a8b9f6ad8fd717d46d707efa1ad58b219074388dafce9"
       }'
wasmd tx wasm instantiate $CODE_ID "$INIT" --from wallet --label "name service" ${TXFLAG} -y --no-admin
sleep 10
CONTRACT=$(wasmd query wasm list-contract-by-code $CODE_ID $NODE --output json | jq -r '.contracts[-1]')
# CONTRACT=$(jq "$LIST_CONTRACT" -r '.contracts[-1]')

NAME_QUERY="{\"beacon_block_header\": {}}"
wasmd query wasm contract-state smart $CONTRACT "$NAME_QUERY" $NODE --output json

NAME_QUERY="{\"slot_response\": {}}"
wasmd query wasm contract-state smart $CONTRACT "$NAME_QUERY" $NODE --output json
