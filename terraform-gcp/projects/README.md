# Subnet projects

Create a folder here named after each GCP project you're deploying to.

Optimally you would probably use separate projects for each subnet, but it's possible to run multiple subnets on the
same set of hardware. At a minimum though, you should have a separate mainnet and testnet project.

Check out [ferdyflip-testnet](ferdyflip-testnet) for an example project. You should basically copy-paste this, and then
update `terraform.tfvars` to populate the details.

## Prerequisites 

Make sure you have `gcloud`, `packer`, and `terraform` installed.

## Terraform commands

```
# First time setup, you need to create a bucket to store the TF state in.
PROJECT=ferdyflip-testnet
gcloud storage buckets create gs://${PROJECT}-tf --project=${PROJECT}

# Add this to your .bashrc
alias tf=terraform

# You need to run this one time
tf init -upgrade

# To check changes
tf plan

# To apply changes
tf apply
```

## Example `terraform.tfvars`

To get the values for `validator_base_os_image` and `rpc_base_os_image` you have to run the
[Packer](../../packer/node) commands to generate it. Note that the `validators`/`rpc_nodes` sections accept an override
for the disk image, so you can do rolling updates by updating them one by one.

It seems like 40GB disk and `e2-standard-2` are sufficient for testnet with a subnet.

For mainnet, you want something with more CPU and RAM, currently I'm using `e2-custom-12-16384` for the validators. For
disk you need at least 150GB with state pruning enabled, 200GB to be safe. You  can bootstrap one validator and then
replicate the data instead of bootstrapping them all independently. It's also more  costly to bootstrap than to serve as
an RPC node, so you can use a smaller sized VM as the RPC node after bootstrapping.

Supposedly the requirement of validating C-Chain is going away, at which point I expect it should be possible to
dramatically scale down the requirements for mainnet.
