# ------------------------------------------------------------------------------
# ENABLE SERVICES
# ------------------------------------------------------------------------------
resource "google_project_service" "compute" {
  project = var.project
  service = "compute.googleapis.com"
}

resource "google_project_service" "iap" {
  project = var.project
  service = "iap.googleapis.com"
}

# ------------------------------------------------------------------------------
# CREATE EXTERNAL IP
# ------------------------------------------------------------------------------

resource "google_compute_address" "static" {
  count        = var.is_validator ? 1 : 0
  project      = var.project
  region       = var.region
  name         = "static-ip-${var.instance_name}"
  address_type = "EXTERNAL"
}

# ------------------------------------------------------------------------------
# CREATE OUR DISK
# ------------------------------------------------------------------------------

resource "google_compute_disk" "node_disk" {
  project = var.project
  name    = "db-disk-${var.instance_name}"
  type    = "pd-ssd"
  zone    = var.zone
  size    = var.disk_size_gb
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE OUR NODE
# ---------------------------------------------------------------------------------------------------------------------
resource "google_compute_instance" "node" {
  project      = var.project
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  # We're tagging the instance with it's unique name within the project to set FW rules
  tags = [var.tag]

  labels = {
    project = var.project
    network = var.avax_network
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      image = var.base_os_image
    }
  }

  attached_disk {
    source      = google_compute_disk.node_disk.self_link
    device_name = google_compute_disk.node_disk.name
  }

  # we need this scope to enable ops monitoring
  service_account {
    email  = var.service_account
    scopes = ["monitoring", "storage-rw", "logging-write"]
  }

  # Disabled during testing
  # deletion_protection = true
  allow_stopping_for_update = true
  shielded_instance_config {
    enable_vtpm = true
  }

  network_interface {
    network            = var.project
    subnetwork         = var.node_subnet_name
    subnetwork_project = var.project

    access_config {
      nat_ip = var.is_validator ? google_compute_address.static[0].address : ""
    }
  }

  metadata = {
    startup-script = templatefile("${path.module}/startup.sh.template", { avax_network = var.avax_network })
  }

  lifecycle {
    ignore_changes = [
      metadata["ssh-keys"]
    ]
  }
}
