avax_network     = "fuji"
project          = "ferdyflip-testnet"
node_subnet_name = "node-subnet"
validator_base_os_image = "node-testnet-validator-v11017-20231221150134"
rpc_base_os_image = "node-testnet-rpc-v11017-20231221150627"
disk_size_gb     = 40
lb_cert_domains = ["testnet-rpc.ferdyflip.xyz"]

vpc_subnets = [
  { region = "us-east1", cidr_range = "10.142.0.0/24" },
  { region = "us-central1", cidr_range = "10.142.1.0/24" },
  { region = "us-west1", cidr_range = "10.142.2.0/24" },
]

validator_machine_type = "e2-standard-2"

validators = [
  {
    region        = "us-east1",
    zone          = "us-east1-c",
    instance_name = "v-fuji-1",
  },
  {
    region        = "us-central1",
    zone          = "us-central1-b",
    instance_name = "v-fuji-2",
  },
  {
    region        = "us-west1",
    zone          = "us-west1-c",
    instance_name = "v-fuji-3",
  },
]

rpc_node_machine_type = "e2-standard-2"

rpc_nodes = [
  {
    region        = "us-east1",
    zone          = "us-east1-c",
    instance_name = "rpc-fuji-1",
  },
  {
    region        = "us-west1",
    zone          = "us-west1-c",
    instance_name = "rpc-fuji-2",
  },
]
