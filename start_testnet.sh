#!/usr/bin/env bash

# This script starts a local Cosmos simulation environment.
# This allows running deterministic tests.

REPO_ROOT=$(git rev-parse --show-toplevel)
export CHAIN_ID=theta-localnet
export NODE_MONIKER=my-theta-local-validator # whatever you like
export BINARY=gaiad

export NODE_HOME=$REPO_ROOT/.tmp/node-data-dir/.cosmost-testnet-data

rm -rf $NODE_HOME

mkdir -p $NODE_HOME
mkdir $NODE_HOME/data
mkdir $NODE_HOME/config
mkdir $NODE_HOME/cosmovisor

$BINARY config chain-id $CHAIN_ID --home $NODE_HOME
$BINARY config keyring-backend test --home $NODE_HOME
$BINARY config broadcast-mode block --home $NODE_HOME
$BINARY init $NODE_MONIKER --home $NODE_HOME --chain-id=$CHAIN_ID

echo $GAIAD_BOOSTTRAP_DATA_DIR/genesis.json
cp $GAIAD_BOOSTTRAP_DATA_DIR/genesis.json $NODE_HOME/config/genesis.json
cp $GAIAD_BOOSTTRAP_DATA_DIR/priv_validator_key.json $NODE_HOME/config/priv_validator_key.json

export USER_MNEMONIC="junk appear guide guess bar reject vendor illegal script sting shock afraid detect ginger other theory relief dress develop core pull across hen float"
export USER_KEY_NAME=my-validator-account
echo $USER_MNEMONIC | $BINARY --home $NODE_HOME keys add $USER_KEY_NAME --recover --keyring-backend=test

sed -i -e 's/minimum-gas-prices = ""/minimum-gas-prices = "0.0025uatom"/g' $NODE_HOME/config/app.toml
sed -i '/\[api\]/,+3 s/enable = false/enable = true/' $NODE_HOME/config/app.toml
sed -i -e '/fast_sync =/ s/= .*/= false/' $NODE_HOME/config/config.toml

$BINARY  --home  $NODE_HOME  start --x-crisis-skip-assert-invariants

wait