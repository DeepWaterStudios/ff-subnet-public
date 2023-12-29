# Configuration files from the imported subnets

Once the subnet is initially created, you can export the configuration to a file, and check it in here. You need it when
importing to other nodes.

```
avalanche subnet export FerdyNet --output /tmp/subnet_config.json
cat /tmp/subnet_config | jq
```
