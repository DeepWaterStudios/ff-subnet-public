# ------------------------------------------------------------------------------
# PURGE THE COMPUTE SA
# ------------------------------------------------------------------------------
resource "google_project_default_service_accounts" "default" {
  project = var.project
  action  = "DELETE"
}
