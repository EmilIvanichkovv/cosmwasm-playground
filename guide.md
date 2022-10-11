# Guide

Following https://docs.cosmwasm.com/docs/1.0/

## Source the network configuration
```bash
source network_configuration.fish
```
## Set up wallet addresses

```bash
# add wallets for testing
wasmd keys add wallet
wasmd keys add wallet2
```

##  Store the bytecode on chain
```bash
# store the bytecode on chain
set RES (wasmd tx wasm store PATH_TO_THE_WASM_FILE  --from wallet $TXFLAG -y --output json -b block)

# get the Code Id of the uploaded wasm binary from the response
set CODE_ID $(echo $RES | jq -r '.logs[0].events[-1].attributes[0].value')
```

## Instantiating the Contract
```bash
# Prepare the instantiation message
set INIT '{"purchase_price":{"amount":"100","denom":"umlg"},"transfer_price":{"amount":"999","denom":"umlg"}}'

# Instantiate the contract
wasmd tx wasm instantiate $CODE_ID "$INIT" --from wallet --label "name service" $TXFLAG -y --no-admin


set CONTRACT $(wasmd query wasm list-contract-by-code $CODE_ID $NODE --output json | jq -r '.contracts[-1]')
# See the contract details
wasmd query wasm contract $CONTRACT $NODE
# Check the contract balance
wasmd query bank balances $CONTRACT $NODE
# Upon instantiation the cw_nameservice contract will store the instatiation message data in the contract's storage with the storage key "config".
# Query the entire contract state
wasmd query wasm contract-state all $CONTRACT $NODE
```

# Contract Interaction
```bash
# Register a name for the wallet address
set REGISTER '{"register":{"name":"fred"}}'
wasmd tx wasm execute $CONTRACT "$REGISTER" --amount 100umlg --from wallet $TXFLAG -y

# Query the owner of the name record
set NAME_QUERY '{"resolve_record": {"name": "fred"}}'
wasmd query wasm contract-state smart $CONTRACT "$NAME_QUERY" $NODE --output json

# Transfer the ownership of the name record to wallet2 (change the "to" address to wallet2 generated during environment setup)
wasmd keys list
set TRANSFER '{"transfer":{"name":"fred","to":"SOME_CORRECT_ADDRESS"}}'
wasmd tx wasm execute $CONTRACT "$TRANSFER" --amount 999umlg --from wallet $TXFLAG -y

# Query the record owner again to see the new owner address:
set NAME_QUERY '{"resolve_record": {"name": "fred"}}'
wasmd query wasm contract-state smart $CONTRACT "$NAME_QUERY" $NODE --output json
```