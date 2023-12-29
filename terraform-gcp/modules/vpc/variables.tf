variable "project" {
  description = "The project name"
  type        = string
}

variable "vpc_subnets" {
  description = "List of [region,cidr_range] tuples"
  type        = list(object({
    region     = string
    cidr_range = string
  }))
}

variable "node_subnet_name" {
  description = "The node subnet name"
  type        = string
}

variable "validator_tag" {
  description = "Tag expected to be applied to validator instances"
  type        = string
}

variable "rpc_node_tag" {
  description = "Tag expected to be applied to rpc node instances"
  type        = string
}

variable "p2p_port" {
  description = "The peer to peer port"
  type        = string
}
