# ------------------------------------------------------------------------------
# ENABLE SERVICES
# ------------------------------------------------------------------------------
resource "google_project_service" "compute" {
  project = var.project
  service = "compute.googleapis.com"
}

# ------------------------------------------------------------------------------
# CONFIGURE OUR VPC AND SUBNETS
# ------------------------------------------------------------------------------
resource "google_compute_network" "vpc_network" {
  name                    = var.project
  project                 = var.project
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "node_subnet" {
  for_each = {for v in var.vpc_subnets : v.region => v}

  name          = var.node_subnet_name
  project       = var.project
  region        = each.value.region
  ip_cidr_range = each.value.cidr_range
  network       = google_compute_network.vpc_network.id
}

# ---------------------------------------------------------------------------------------------------------------------
# ALLOW SSH VIA IAP
# ---------------------------------------------------------------------------------------------------------------------
resource "google_compute_firewall" "iap_ingress" {
  name    = "iap-ingress"
  project = var.project
  network = var.project

  direction = "INGRESS"

  source_ranges = ["35.235.240.0/20"] # this is googles IAP range

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = [var.validator_tag, var.rpc_node_tag]
}

# ---------------------------------------------------------------------------------------------------------------------
# ALLOW P2P PORT INGRESS
# ---------------------------------------------------------------------------------------------------------------------
resource "google_compute_firewall" "p2p_ingress" {
  name    = "p2p-ingress"
  project = var.project
  network = var.project

  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"] # we need to allow any peer inbound

  allow {
    protocol = "tcp"
    ports    = [var.p2p_port]
  }

  target_tags = [var.validator_tag]
}

# ---------------------------------------------------------------------------------------------------------------------
# ALLOW LOAD BALANCER
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_firewall" "lb_ingress" {
  name    = "lb-ingress"
  project = var.project
  network = var.project

  direction = "INGRESS"

  # Google load balancer ranges
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags = [var.rpc_node_tag]
}
