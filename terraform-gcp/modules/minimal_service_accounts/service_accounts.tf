# ------------------------------------------------------------------------------
# ENABLE SERVICES
# ------------------------------------------------------------------------------

resource "google_project_service" "iam" {
  project = var.project
  service = "iam.googleapis.com"
}

# ------------------------------------------------------------------------------
# SERVICE ACCOUNT FOR GCE TO USE
# ------------------------------------------------------------------------------
resource "google_service_account" "minimal_gce" {
  project      = var.project
  account_id   = "minimal-gce"
  display_name = "Minimal SA used for GCE instances"
}

resource "google_project_iam_member" "minimal_gce_log_writer_binding" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.minimal_gce.email}"
}

resource "google_project_iam_member" "minimal_gce_metric_writer_binding" {
  project = var.project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.minimal_gce.email}"
}
