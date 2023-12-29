# ------------------------------------------------------------------------------
# CONFIGURE OUR GCP CONNECTION
# ------------------------------------------------------------------------------
provider "google-beta" {
  project = var.project
}

# ------------------------------------------------------------------------------
# CLEAN UP UNWANTED SERVICE ACCOUNTS
# ------------------------------------------------------------------------------
module "safe_service_accounts" {
  source = "../../modules/safe_service_accounts"

  project = var.project
}

# ------------------------------------------------------------------------------
# MINIMAL SA FOR GCE TO USE
# ------------------------------------------------------------------------------
module "minimal_service_accounts" {
  source = "../../modules/minimal_service_accounts"

  project = var.project
}

# ------------------------------------------------------------------------------
# CREATE THE VPC AND SUBNET
# ------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  vpc_subnets      = var.vpc_subnets
  project          = var.project
  node_subnet_name = var.node_subnet_name
  validator_tag    = var.validator_tag
  rpc_node_tag     = var.rpc_node_tag
  p2p_port         = var.p2p_port
}

# ------------------------------------------------------------------------------
# BUILD THE NODES
# ------------------------------------------------------------------------------
module "validator" {
  source   = "../../modules/node"
  for_each = {for v in var.validators : v.instance_name => v}

  instance_name    = each.value.instance_name
  region           = each.value.region
  zone             = each.value.zone
  project          = var.project
  node_subnet_name = var.node_subnet_name
  machine_type     = var.validator_machine_type
  base_os_image    = coalesce(each.value.disk_image, var.validator_base_os_image)
  disk_size_gb     = var.disk_size_gb
  tag              = var.validator_tag
  service_account  = module.minimal_service_accounts.minimal_gce.email
  avax_network     = var.avax_network
  is_validator     = true
}

module "rpc_node" {
  source   = "../../modules/node"
  for_each = {for v in var.rpc_nodes : v.instance_name => v}

  instance_name    = each.value.instance_name
  region           = each.value.region
  zone             = each.value.zone
  project          = var.project
  node_subnet_name = var.node_subnet_name
  machine_type     = var.rpc_node_machine_type
  base_os_image    = coalesce(each.value.disk_image, var.rpc_base_os_image)
  disk_size_gb     = var.disk_size_gb
  tag              = var.rpc_node_tag
  service_account  = module.minimal_service_accounts.minimal_gce.email
  avax_network     = var.avax_network
  is_validator     = false
}

# ------------------------------------------------------------------------------
# SET UP A LOAD BALANCER
# ------------------------------------------------------------------------------
module "load_balancer" {
  source = "../../modules/load_balancer"

  project         = var.project
  lb_cert_domains = var.lb_cert_domains
  rpc_nodes       = [for rpc_node in module.rpc_node : rpc_node.node]
}
