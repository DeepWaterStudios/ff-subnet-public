# Packer generation of the node boot disks

The validator and rpc nodes launch with a custom image built by Packer. Those VMs are intended to be fungible. An
update to `avalanchego`, for example, should be done by creating a new image and doing a rolling update to all nodes.
All the important blockchain data is stored on separate persistent disks.

## Contents of the built image

* Installs `jq`
* Installs the Google Cloud ops agent for better monitoring
* Installs avalanchego
* Updates the `node.json` with:
    * `data-dir` pointing to a mount point for the PD
    * `track-subnets` if a subnet_id is provided
    * TODO: add blockchain config instead of doing it on the mounted PD
* Installs avalanche-cli and adds it to the path
* Install avalanche-monitoring 1-5
* Install gcc, git, golang (for compiling the custom VM)
* (Disabled) Copy the custom VM onto the disk
* (If RPC node) Install Nginx

## First run

Run this command one time to install the GCP plugin.

```
packer init node.pkr.hcl
```

## Building updates

Run these commands to build new timestamped testnet images.

```
packer build -var-file=testnet.pkrvars.hcl -var="image_type=validator" node.pkr.hcl
packer build -var-file=testnet.pkrvars.hcl -var="image_type=rpc" node.pkr.hcl
```

Run these commands to build new timestamped mainnet images.

```
packer build -var-file=mainnet.pkrvars.hcl -var="image_type=validator" node.pkr.hcl
packer build -var-file=mainnet.pkrvars.hcl -var="image_type=rpc" node.pkr.hcl
```

This will output something like:

```
--> googlecompute.debian-12: A disk image was created in the 'ferdyflip-testnet' project: node-rpc-testnet-v11012-20231014184325
```

Save this VM image name, you need to put it in the terraform config vars.

# TODOs

## `avalanchego-proxy.conf`

Should be configurable via settings, as opposed to just hardcoded stuff. The mainnet/testnet RPC nodes don't need the
other config. I got lazy working on this and didn't make it configurable.

## Custom VM

Disabled for now, but I didn't do anything special to optionally include this only if necessary. Most people will use
subnet-evm I assume.
