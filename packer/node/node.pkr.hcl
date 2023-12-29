packer {
  required_version = ">= 1.7"
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

variable "gcp_project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "avalanchego_version" {
  description = "The avalanchego version"
  type        = string

  validation {
    condition     = regex("^v\\d+\\.\\d+\\.\\d+$", var.avalanchego_version) != null
    error_message = "The avalanchego version must follow the format vX.Y.Z where X, Y, and Z are numbers."
  }
}

variable "network_type" {
  description = "Either mainnet or testnet"
  type        = string

  validation {
    condition     = contains(["mainnet", "testnet"], var.network_type)
    error_message = "Must be either mainnet or testnet."
  }
}

# Disabled for now; avalanche-cli doesn't support a precompiled binary well.
# variable "ferdynet_evm_url" {
#   description = "Public URL for the ferdynet evm binary."
#   type        = string
# }

variable "subnet_ids" {
  description = "Comma separated list of subnets to track."
  type        = string
}

variable "image_type" {
  description = "Type of image to produce: 'validator' or 'rpc'"
  type        = string

  validation {
    condition     = contains(["validator", "rpc"], var.image_type)
    error_message = "Must be either 'validator' or 'rpc'."
  }
}

locals {
  node_flag     = var.network_type == "testnet" ? "--fuji" : ""
  timestamp     = regex_replace(timestamp(), "[- TZ:]", "")
  version_clean = replace(var.avalanchego_version, ".", "")
  suffix        = "${var.network_type}-${var.image_type}-${local.version_clean}-${local.timestamp}"
}

source "googlecompute" "debian-12" {
  project_id              = var.gcp_project_id
  source_image            = "debian-12-bookworm-v20231212"
  source_image_project_id = ["debian-cloud"]
  zone                    = "us-central1-a"
  instance_name           = "packer-${local.suffix}"
  ssh_username            = "ava"
  image_name              = "node-${local.suffix}"

  disable_default_service_account = "true"
}

build {
  sources = ["source.googlecompute.debian-12"]

  provisioner "file" {
    source      = "./avalanchego-proxy.conf"
    destination = "/tmp/avalanchego-proxy.conf"
  }

  provisioner "shell" {
    inline = [
      # Make sure apt repo is up to date before installing anything.
      "sudo apt update",

      # Install jq which will be used for editing json files.
      "sudo apt install jq -y",

      # Install the optional gce monitoring agent, which gets disk/memory monitoring
      "curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh",
      "sudo bash add-google-cloud-ops-agent-repo.sh --also-install",
      "rm add-google-cloud-ops-agent-repo.sh",

      # Download and execute the avalanchego installer script.
      "curl https://raw.githubusercontent.com/ava-labs/avalanche-docs/master/scripts/avalanchego-installer.sh > /tmp/avalanchego-installer.sh",
      "chmod 755 /tmp/avalanchego-installer.sh",
      # Uses the following settings:
      #   Enables state sync for C-Chain, faster bootstrapping
      #   Marks the RPC as private; we use an Nginx proxy to avalanchego anyway, which runs on localhost
      #   Marks the data dir in a standard location, which will later be attached as a persistant disk
      #   Uses a specific configured avalanchego binary version
      #   Optionally toggles the installer to Fuji
      "/tmp/avalanchego-installer.sh --state-sync=on --ip=dynamic --rpc=private --db-dir=/mnt/avax-db --version=${var.avalanchego_version} ${local.node_flag}",

      # Take down avalanchego so we can update config files.
      "sudo systemctl stop avalanchego",

      # Move the node config for editing
      "cp ~ava/.avalanchego/configs/node.json /tmp/node.json",

      # Clean up the avalanchego directory, and recreate it.
      "rm -rf ~ava/.avalanchego",
      "mkdir -p ~ava/.avalanchego/configs",

      # Adjust the node config to use a data dir on the attached PD.
      "jq '. += {\"data-dir\": \"/mnt/avax-db/config\"}' /tmp/node.json > /tmp/node_with_data_dir.json",

      # Adjust the node config to track specified subnets and move it to the final location.
      "jq '. += {\"track-subnets\": \"${var.subnet_ids}\"}' /tmp/node_with_data_dir.json > ~ava/.avalanchego/configs/node.json",
      "sudo systemctl start avalanchego",

      # Install the avalanche-cli and include it into the default path.
      "curl -sSfL https://raw.githubusercontent.com/ava-labs/avalanche-cli/main/scripts/install.sh | sh -s",
      "echo export PATH=~/bin:$PATH >> .bashrc",

      # Install avalanche-monitoring onto the host.
      "wget -P /tmp/ https://raw.githubusercontent.com/ava-labs/avalanche-monitoring/main/grafana/monitoring-installer.sh",
      "chmod 755 /tmp/monitoring-installer.sh",
      "/tmp/monitoring-installer.sh --1 --2 --3 --4 --5",

      # Install gcc, git, and golang, required for subnet stuff.
      "sudo apt install build-essential -y",
      "sudo apt-get install git -y",
      "cd /tmp/",
      "wget https://go.dev/dl/go1.20.10.linux-amd64.tar.gz",
      "sudo tar -xvf go1.20.10.linux-amd64.tar.gz",
      "sudo cp go/bin/go /usr/local/bin/go",
      "sudo cp -r go /usr/local/",

      # Disabled for now; avalanche-cli doesn't support a precompiled binary well.
      # "mkdir ~ava/ferdynet",
      # "curl ${var.ferdynet_evm_url} > ~ava/ferdynet/ferdynet_evm.bin",
    ]
  }

  # If the image is for an RPC node, additionally install Nginx.
  dynamic "provisioner" {
    for_each = var.image_type == "rpc" ? [1] : []
    labels = ["shell"]
    content {
      inline = [
        # Install nginx.
        "sudo apt install nginx -y",

        # Use the avalanchego proxy configuration we've set up.
        "sudo mv /tmp/avalanchego-proxy.conf /etc/nginx/sites-available/avalanchego-proxy.conf",
        "sudo ln -s /etc/nginx/sites-available/avalanchego-proxy.conf /etc/nginx/sites-enabled/",

        # We do not want the default nginx site.
        "sudo rm /etc/nginx/sites-enabled/default",
      ]
    }
  }
}
