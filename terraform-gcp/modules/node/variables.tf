variable "region" {
  description = "The GCP region"
  type        = string
}

variable "zone" {
  description = "The GCP zone"
  type        = string
}

variable "project" {
  description = "The project name"
  type        = string
}

variable "avax_network" {
  description = "The asset network; fuji or avalanche"
  type        = string

  validation {
    condition     = contains(["fuji", "avalanche"], var.avax_network)
    error_message = "Must be either fuji or avalanche."
  }
}

variable "node_subnet_name" {
  description = "The node subnet name"
  type        = string
}

variable "instance_name" {
  description = "The node instance name"
  type        = string
}

variable "machine_type" {
  description = "The machine type to provision"
  type        = string
}

variable "base_os_image" {
  description = "The subnet ip range to setup"
  type        = string
}

variable "disk_size_gb" {
  description = "Size of the node pd, in GB"
  type        = string
}

variable "tag" {
  description = "Tag to apply to node instance"
  type        = string
}

variable "service_account" {
  description = "Email address of the service account to use"
  type        = string
}

variable "is_validator" {
  description = "Determines if the node is a validator (meaning it has a static IP)"
  type        = bool
}
