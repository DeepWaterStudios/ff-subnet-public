# Setup for `ferdyflip-evm`

This folder contains a `cloudbuild.yaml` that will build the FerdyFlip Subnet EVM and push it into a GCS bucket.

If Subnet-EVM updates and we want to upgrade the subnet to use it, the custom VM will need to be rebuilt, pushed, and
then the Subnet has to be upgraded to use it (which means rebuilding the VM image and upgrading nodes one by one).

NOTE: This isn't exactly accurate right now. The `avalanche-cli` doesn't currently support importing the VM from a
pre-built binary, it always wants to download the Github repo and build it. But I'm leaving this in place for the day
that it does =(

```
gcloud storage buckets create gs://ferdyflip-evm-artifacts --project=ferdyflip-evm --uniform-bucket-level-access
gcloud storage buckets add-iam-policy-binding gs://ferdyflip-evm-artifacts --member=allUsers --role=roles/storage.objectViewer
```

## Rebuilding the custom subnet-evm for ferdynet

1) Open https://github.com/tactical-retreat/subnet-evm
2) Hit 'Sync Fork' to pull the latest changes from upstream
3) Run `gcloud builds submit --project=ferdyflip-evm --no-source`
