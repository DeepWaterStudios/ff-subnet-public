# ff-subnet

This repo contains everything needed to build the FerdyFlip Subnet.

This is just a snapshot at a moment in time of what we're actually using. I don't trust myself to build this
in public. Plus it's embarrassing for everyone to see me fuck things up in real time.

## ferdyflip-evm

This subdirectory contains instructions on how to rebuild the FerdyFlip Subnet-EVM fork, but currently is unused due
to limitations of the `avalanche-cli`. The EVM will always be rebuilt from Github when a node is set up.

Note that if you're using the vanilla subnet-evm and not doing anything custom, you can ignore a bunch of things
here and there in this repo.

## packer

The RPC and Validator nodes are designed to use ephemeral primary disks. Packer is used to create a new template for
each type of node, and then the instance can be deleted / recreated with the new template. All the chain data is stored
on an attached persistent disk.

Eventually I'd like to add a Blockscout instance to the setup as well.

## subnet-configuration

Contains mostly static files related to configuring the subnet, including:

* Genesis files - describe how the subnet should be created
* Exported configurations - output from the `avalanche-cli` once the subnet has been instantiated
* Setup logs - notes taken along the way during deployment of the subnet

## terraform-gcp

Terraform configuration for Google Cloud, used to set up a subnet. Broken into a 'modules' directory that contains
reusable bits of code, and a 'projects' directory that has setup for individual deployments.

## High level TODOs

Lots of things could be improved here, but it's working for testnet already.

* Extract 'avalanche_subnet' terraform module
* Add blockscout option
* Monioring dashboard across all validators
* Uptime checks
* Nginx setup could be more generic
* Chain config should be moved to VM disk
