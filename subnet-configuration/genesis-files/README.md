# Genesis files

Store the genesis files for subnets in here. The `default.json` is a config from the docs, that you can diff against to
see what a change looks like.

# Chain IDs

666984 is 'BET' in ascii (ferdyflip mainnet)
668577 is 'BUM' in ascii (ferdyflip testnet)

# Ferdy genesis changes

* `config.chainId` is overridden for testnet/mainnet
* `config.minBaseFee` 25 gwei -> 15 gwei since we don't need to charge gas fees other than to prevent abuse
* `config.feeConfig.targetBlockRate` 2 -> 1 since the goal is to have minimum blocktimes anyway
    * Believe that this should make `blockGasCostStep` / `minBlockGasCost` / `maxBlockGasCost` irrelevant
* Allocation
    * On testnet, large airdrop goes to DWS deployer and the faucet address
    * On mainnet, small airdrop to DWS deployer so we can deploy the bridge? All other incoming FAVAX should be bridged.
* Deployer allowlist
    * On both chains, set to DWS deployer.
* Native minter
    * On testnet, set to DWS deployer
    * On mainnet, set to bridge?
* Reward manager
    * Always send rewards to fixed place. Currently set to DWS deployer, needs a new address.
    * On testnet, editable.
    * On mainnet, not editable.
