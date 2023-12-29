# ------------------------------------------------------------------------------
# ENABLE SERVICES
# ------------------------------------------------------------------------------
resource "google_project_service" "compute" {
  project = var.project
  service = "compute.googleapis.com"
}

# ------------------------------------------------------------------------------
# CREATE INSTANCE GROUPS FOR EACH ZONE
# ------------------------------------------------------------------------------
locals {
  unique_zones = toset([for v in var.rpc_nodes : v.zone])
}

resource "google_compute_instance_group" "rpc_group" {
  for_each = local.unique_zones

  name        = "rpc-group-${each.key}"
  project     = var.project
  description = "Instance group for RPC nodes in ${each.key}"
  zone        = each.key

  named_port {
    name = "http"
    port = 80
  }

  instances = [for node in var.rpc_nodes : node.self_link if node.zone == each.key]
}

# ------------------------------------------------------------------------------
# HEALTH CHECK FOR THE LOAD BALANCER
# ------------------------------------------------------------------------------
resource "google_compute_health_check" "http_health_check" {
  name               = "rpc-node-health-check"
  project            = var.project
  check_interval_sec = 5
  timeout_sec        = 5
  http_health_check {
    port         = 80
    request_path = "/health"
  }
}

# ------------------------------------------------------------------------------
# BACKEND SERVICE FOR THE LOAD BALANCER
# ------------------------------------------------------------------------------
resource "google_compute_backend_service" "rpc_backend_service" {
  name                            = "rpc-backend-service"
  project                         = var.project
  protocol                        = "HTTP"
  port_name                       = "http"
  timeout_sec                     = 10
  connection_draining_timeout_sec = 10
  health_checks                   = [google_compute_health_check.http_health_check.self_link]

  dynamic "backend" {
    for_each = google_compute_instance_group.rpc_group
    content {
      group = backend.value.self_link
    }
  }
}

# ------------------------------------------------------------------------------
# URL MAP FOR THE LOAD BALANCER
# ------------------------------------------------------------------------------
resource "google_compute_url_map" "lb_url_map" {
  name            = "lb-url-map"
  project         = var.project
  default_service = google_compute_backend_service.rpc_backend_service.self_link
}

# ------------------------------------------------------------------------------
# CERTIFICATE FOR THE LOAD BALANCER
# ------------------------------------------------------------------------------

resource "google_compute_managed_ssl_certificate" "lb_cert" {
  name    = "lb-https-cert"
  project = var.project
  managed {
    domains = var.lb_cert_domains
  }
}

# ------------------------------------------------------------------------------
# TARGET HTTPS PROXY FOR THE LOAD BALANCER
# ------------------------------------------------------------------------------
resource "google_compute_target_https_proxy" "lb_https_proxy" {
  name             = "lb-https-proxy"
  project          = var.project
  url_map          = google_compute_url_map.lb_url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.lb_cert.self_link]
}

# ------------------------------------------------------------------------------
# RESERVE A STATIC IP FOR THE LOAD BALANCER
# ------------------------------------------------------------------------------
resource "google_compute_global_address" "lb_static_ip" {
  name    = "lb-static-ip"
  project = var.project
}

# ------------------------------------------------------------------------------
# GLOBAL FORWARDING RULE FOR THE LOAD BALANCER
# ------------------------------------------------------------------------------
resource "google_compute_global_forwarding_rule" "lb_forwarding_rule_ssl" {
  name       = "rpc-global-forwarding-rule-ssl"
  project    = var.project
  port_range = "443"
  ip_address = google_compute_global_address.lb_static_ip.address
  target     = google_compute_target_https_proxy.lb_https_proxy.self_link
}
