variable "avax_network" {
  description = "The asset network; fuji or avalanche"
  type        = string

  validation {
    condition     = contains(["fuji", "avalanche"], var.avax_network)
    error_message = "Must be either fuji or avalanche."
  }
}

variable "project" {
  description = "The project name"
  type        = string
}

variable "node_subnet_name" {
  description = "The node subnet name"
  type        = string
}

variable "p2p_port" {
  description = "The peer to peer port"
  type        = string
  default     = "9651"
}

variable "validator_base_os_image" {
  description = "The base os image to use for validators"
  type        = string
}

variable "rpc_base_os_image" {
  description = "The base os image to use for rpc nodes"
  type        = string
}

variable "disk_size_gb" {
  description = "Size of the node pd, in GB"
  type        = string
}

variable "vpc_subnets" {
  description = "List of [region,cidr_range] tuples"
  type        = list(object({
    region     = string
    cidr_range = string
  }))
}

variable "validator_machine_type" {
  description = "The validator machine spec to provision"
  type        = string
}

variable "validators" {
  description = "List of [region,zone,instance_name,optional(disk_image)] tuples"
  type        = list(object({
    region        = string
    zone          = string
    instance_name = string
    disk_image    = optional(string)
  }))
}

variable "validator_tag" {
  description = "Tag to apply to validator instances"
  type        = string
  default     = "validator"
}

variable "rpc_node_machine_type" {
  description = "The rpc node machine spec to provision"
  type        = string
}

variable "rpc_nodes" {
  description = "List of [region,zone,instance_name,optional(disk_image)] tuples"
  type        = list(object({
    region        = string
    zone          = string
    instance_name = string
    disk_image    = optional(string)
  }))
}

variable "rpc_node_tag" {
  description = "Tag to apply to rpc node instances"
  type        = string
  default     = "rpc-node"
}

variable "lb_cert_domains" {
  description = "List of domains for the load balancer https certificate to support"
  type        = list(string)
}
