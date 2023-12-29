variable "project" {
  description = "The project name"
  type        = string
}

variable "lb_cert_domains" {
  description = "List of domains for the load balancer https certificate to support"
  type        = list(string)
}

variable "rpc_nodes" {
  description = "List of [region,zone,instance_name,optional(disk_image)] objects"
  type        = list(object({
    zone      = string
    self_link = string
  }))
}
