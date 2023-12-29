# Subnet registration

Bootstrapping on fuji took less than a day, I didn't time it.

I registered a friction log here: https://github.com/ava-labs/avalanche-cli/issues/1287

There are a couple of things that would make this process easier, but they only really probably affect Custom VM
subnets. A vanilla Subnet-EVM will probably be a smoother deployment.

## Registering validators

Created random private key, imported to Core. Went to https://test.core.app/stake/cross-chain-transfer/ and had to make
sure the web app was in testnet mode. Transferred 10 Fuji AVAX to P chain.

Get the Node IDs on each validator:

```
curl -X POST --data '{
    "jsonrpc":"2.0",
    "id"     :1,
    "method" :"info.getNodeID"
}' -H 'content-type:application/json' 127.0.0.1:9650/ext/info
```

* NodeID-8F62HdqXVhqGTySVZ7HyQbEyFDMo33iKd
* NodeID-LJH9JffagSPthZ4adGRjHByXFytPdrmmc
* NodeID-N59JVgQCpF5cRt4e6zKQUBgDkgyNH5GAa

Pretty straightforward process to register each validator for 1 year at https://test.core.app/stake/validate/ 

Can check uptime using https://testnet.avascan.info/staking/validator/NodeID-8F62HdqXVhqGTySVZ7HyQbEyFDMo33iKd

## Prework

Log into each validator

```
sudo su ava
cd /tmp
echo "private key value here" > key.pk
avalanche key create validator-key --file /tmp/key.pk
rm key.pk
```

## Create Subnet

On one validator, write `genesis_files/ferdy_testnet.json` into `/tmp/testnet.json`.

```
# Note: --custom-vm-path ended up being unnecessary because other parts of the workflow did not support it.
$ avalanche subnet create FerdyNet --custom-vm-path /home/ava/ferdynet/ferdynet_evm.bin --genesis /tmp/testnet.json
✔ Custom
creating custom VM subnet FerdyNet
Source code repository URL: https://github.com/tactical-retreat/subnet-evm
✔ Branch: master
Build script: scripts/build.sh
Successfully created subnet configuration
```

## Deploy Subnet

```
$ avalanche subnet deploy FerdyNet --fuji
Deploying [FerdyNet] to Fuji
✔ Use stored key
✔ validator-key
Configure which addresses may make changes to the subnet.
These addresses are known as your control keys. You will also
set how many control keys are required to make a subnet change (the threshold).
✔ Use fee-paying key
Your Subnet's control keys: [P-fuji1jcuq5fy92w66h242nnw9tkfnxr35npkg3qtken]
Your subnet auth keys for chain creation: [P-fuji1jcuq5fy92w66h242nnw9tkfnxr35npkg3qtken]
Subnet has been created with ID: 2tjQ43HKjArCS5W5ckMRouHyvU8ez1yp81H4M6fZ9wMDMrn5rH
Now creating blockchain...
+--------------------+----------------------------------------------------+
| DEPLOYMENT RESULTS |                                                    |
+--------------------+----------------------------------------------------+
| Chain Name         | FerdyNet                                           |
+--------------------+----------------------------------------------------+
| Subnet ID          | 2tjQ43HKjArCS5W5ckMRouHyvU8ez1yp81H4M6fZ9wMDMrn5rH |
+--------------------+----------------------------------------------------+
| VM ID              | Y1BMATFymvjectqm11Zex8wVS88MwJHeh2nSx8q6ygNk8Br8P  |
+--------------------+----------------------------------------------------+
| Blockchain ID      | e3k9c6RKgouPWtyQkr1ULC2PSFVu6BZdFefXZXJfwJ1zjWsmE  |
+--------------------+                                                    +
| P-Chain TXID       |                                                    |
+--------------------+----------------------------------------------------+
```

## Join the registering validator to the subnet

```
$ avalanche subnet join FerdyNet
✔ Fuji
✔ Automatic
Scanning your system for existing files...
Found a config file at /home/ava/.avalanchego/configs/node.json
✔ Yes
Will use file at path /home/ava/.avalanchego/configs/node.json to update the configuration
Scanning your system for the plugin directory...
No plugin directory found on your system
Path to your avalanchego plugin dir (likely avalanchego/build/plugins): /mnt/avax-db/config/plugins
VM binary written to /mnt/avax-db/config/plugins/Y1BMATFymvjectqm11Zex8wVS88MwJHeh2nSx8q6ygNk8Br8P
This will edit your existing config file. This edit is nondestructive,
but it's always good to have a backup.
✔ Yes
The config file has been edited. To use it, make sure to start the node with the '--config-file' option, e.g.

./build/avalanchego --config-file /home/ava/.avalanchego/configs/node.json

(using your binary location). The node has to be restarted for the changes to take effect.


$ cat ~/.avalanchego/configs/node.json 
{
  "data-dir": "/mnt/avax-db/config",
  "db-dir": "/mnt/avax-db",
  "network-id": "fuji",
  "public-ip-resolution-service": "opendns",
  "track-subnets": "2tjQ43HKjArCS5W5ckMRouHyvU8ez1yp81H4M6fZ9wMDMrn5rH"
}
```

## Dump the subnet config from the registering validator

```
avalanche subnet export FerdyNet --output /tmp/ferdynet.json
cat /tmp/ferdynet.json
```

Copied this for safekeeping into subnet_confiuration/exported_configurations

## On each additional validator/rpc node

Stick the json containing the exported subnet params into `/tmp/ferdynet.json` first.

```
$ avalanche subnet import file --config /tmp/ferdynet.json  
# It will check out the VM and build it. VM image is already configured with required tooling.
```

Then join each validator/rpc node to the subnet:

```
$ avalanche subnet join FerdyNet
✔ Fuji
✔ Automatic
Scanning your system for existing files...
Found a config file at /home/ava/.avalanchego/configs/node.json
✔ Yes
Will use file at path /home/ava/.avalanchego/configs/node.json to update the configuration
Scanning your system for the plugin directory...
No plugin directory found on your system
Path to your avalanchego plugin dir (likely avalanchego/build/plugins): /mnt/avax-db/config/plugins
VM binary written to /mnt/avax-db/config/plugins/Y1BMATFymvjectqm11Zex8wVS88MwJHeh2nSx8q6ygNk8Br8P
This will edit your existing config file. This edit is nondestructive,
but it's always good to have a backup.
✔ Yes
The config file has been edited. To use it, make sure to start the node with the '--config-file' option, e.g.

./build/avalanchego --config-file /home/ava/.avalanchego/configs/node.json

(using your binary location). The node has to be restarted for the changes to take effect.

$ sudo systemctl restart avalanchego
```

## Add the validators to the subnet

This can be done on any VM with the control keys installed. Need to run it for every validator.

```
$ avalanche subnet addValidator FerdyNet
✔ Fuji
✔ Use stored key
✔ validator-key
Your subnet auth keys for add validator tx creation: [P-fuji1jcuq5fy92w66h242nnw9tkfnxr35npkg3qtken]
Next, we need the NodeID of the validator you want to whitelist.

Check https://docs.avax.network/apis/avalanchego/apis/info#infogetnodeid for instructions about how to query the NodeID from your node
(Edit host IP address and port to match your deployment, if needed).
What is the NodeID of the validator you'd like to whitelist?: NodeID-8F62HdqXVhqGTySVZ7HyQbEyFDMo33iKd
✔ Default (20)
When should your validator start validating?
If you validator is not ready by this time, subnet downtime can occur.
✔ Start in five minutes
✔ Until primary network validator expires
NodeID: NodeID-8F62HdqXVhqGTySVZ7HyQbEyFDMo33iKd
Network: Fuji
Start time: 2023-12-11 03:42:17
End time: 2024-12-08 17:55:50
Weight: 20
Inputs complete, issuing transaction to add the provided validator information...
Transaction successful, transaction ID: 2FbMkGoJngm28oswEjjyr73CbnpcRcoWwovuzYMqD3CTHXzHMM
```

## Tweak the blockchain configuration

TODO: This should probably move into packer?

Enable debug tx api, and store all history. Block explorers will need this.

```
sudo su ava
mkdir -p /mnt/avax-db/config/configs/chains/e3k9c6RKgouPWtyQkr1ULC2PSFVu6BZdFefXZXJfwJ1zjWsmE
echo '{ "pruning-enabled": false, "state-sync-enabled": false, eth-apis": ["public-eth","public-eth-filter","net","web3","internal-public-eth","internal-public-blockchain","internal-public-transaction-pool", "debug-tracer"] }' | jq > /mnt/avax-db/config/configs/chains/e3k9c6RKgouPWtyQkr1ULC2PSFVu6BZdFefXZXJfwJ1zjWsmE/config.json
````

## Other notes

```
$ avalanche subnet describe FerdyNet
 
+-------------------+----------------------------------------------------+
|     PARAMETER     |                       VALUE                        |
+-------------------+----------------------------------------------------+
| Subnet Name       | FerdyNet                                           |
+-------------------+----------------------------------------------------+
| ChainID           | 668577                                             |
+-------------------+----------------------------------------------------+
| Mainnet ChainID   | 0                                                  |
+-------------------+----------------------------------------------------+
| Token Name        | TEST                                               |
+-------------------+----------------------------------------------------+
| VM Version        |                                                    |
+-------------------+----------------------------------------------------+
| VM ID             | Y1BMATFymvjectqm11Zex8wVS88MwJHeh2nSx8q6ygNk8Br8P  |
+-------------------+----------------------------------------------------+
| Fuji SubnetID     | 2tjQ43HKjArCS5W5ckMRouHyvU8ez1yp81H4M6fZ9wMDMrn5rH |
+-------------------+----------------------------------------------------+
| Fuji BlockchainID | e3k9c6RKgouPWtyQkr1ULC2PSFVu6BZdFefXZXJfwJ1zjWsmE  |
+-------------------+----------------------------------------------------+

+--------------------------+-------------+
|      GAS PARAMETER       |    VALUE    |
+--------------------------+-------------+
| GasLimit                 |     8000000 |
+--------------------------+-------------+
| MinBaseFee               | 15000000000 |
+--------------------------+-------------+
| TargetGas (per 10s)      |    15000000 |
+--------------------------+-------------+
| BaseFeeChangeDenominator |          36 |
+--------------------------+-------------+
| MinBlockGasCost          |           0 |
+--------------------------+-------------+
| MaxBlockGasCost          |     1000000 |
+--------------------------+-------------+
| TargetBlockRate          |           1 |
+--------------------------+-------------+
| BlockGasCostStep         |      200000 |
+--------------------------+-------------+

+--------------------------------------------+------------------------+----------------------------+
|                  ADDRESS                   | AIRDROP AMOUNT (10^18) |    AIRDROP AMOUNT (WEI)    |
+--------------------------------------------+------------------------+----------------------------+
| 0x689650Fee4c8F9D11cE434695151a4a1f2C42A37 |               50000000 | 50000000000000000000000000 |
+--------------------------------------------+------------------------+----------------------------+
| 0x2352D20fC81225c8ECD8f6FaA1B37F24FEd450c9 |               50000000 | 50000000000000000000000000 |
+--------------------------------------------+------------------------+----------------------------+

+---------------------------+--------------------------------------------+---------+
|        PRECOMPILE         |                   ADMIN                    | ENABLED |
+---------------------------+--------------------------------------------+---------+
| Native Minter             | 0x689650Fee4c8F9D11cE434695151a4a1f2C42A37 |         |
+---------------------------+                                            +---------+
| Contract Allow List       |                                            |         |
+---------------------------+                                            +---------+
| Reward Manager Allow List |                                            |         |
+---------------------------+--------------------------------------------+---------+

```
