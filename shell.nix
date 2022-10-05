{pkgs}: let
  rustTargetWasm =
    pkgs.rust-bin.stable.latest.default.override
    {
      extensions = ["rust-src"];
      targets = ["wasm32-unknown-unknown"];
    };

  wasmd = pkgs.callPackage ./nix/wasmd {};
in
  pkgs.mkShell {
    packages = [
      pkgs.metacraft-labs.cosmos-theta-testnet # <after>
      rustTargetWasm
      pkgs.go

      wasmd

      pkgs.jq
    ];
    shellHook = ''
      export GAIAD_BOOSTTRAP_DATA_DIR=${pkgs.metacraft-labs.cosmos-theta-testnet}/data

      export CHAIN_ID="malaga-420"
      export TESTNET_NAME="malaga-420"
      export FEE_DENOM="umlg"
      export STAKE_DENOM="uand"
      export BECH32_HRP="wasm"
      export WASMD_VERSION="v0.27.0"
      export CONFIG_DIR=".wasmd"
      export BINARY="wasmd"

      export COSMJS_VERSION="v0.28.1"
      export GENESIS_URL="https://raw.githubusercontent.com/CosmWasm/testnets/master/malaga-420/config/genesis.json"

      export RPC="https://rpc.malaga-420.cosmwasm.com:443"
      export API="https://api.malaga-420.cosmwasm.com"
      export FAUCET="https://faucet.malaga-420.cosmwasm.com"

      export NODE="--node"
      export TXFLAG="$NODE --chain-id $CHAIN_ID --gas-prices 0.25umlg --gas auto --gas-adjustment 1.3"


      figlet "Cosmos Playground"

    '';
  }
