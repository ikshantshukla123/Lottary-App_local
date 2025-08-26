## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```


//to deploy 
forge script script/Deploy.s.sol:Deploy \
--private-key : $PRIVATE_KEY,
--RPC_URL: 
--broadcast -vv



//to enter multiple
forge script script/Interact.s.sol:Interact \
  --rpc-url http://127.0.0.1:8545 \
  --broadcast \
  --sig "enterMultiple(address,uint256)"


//to pick winner
forge script script/Interact.s.sol:Interact \
  --rpc-url http://127.0.0.1:8545 \
  --broadcast \
  --sig "pick(address)"


